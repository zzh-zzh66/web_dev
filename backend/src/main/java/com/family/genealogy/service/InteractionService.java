package com.family.genealogy.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.family.genealogy.common.ErrorCode;
import com.family.genealogy.dto.*;
import com.family.genealogy.entity.*;
import com.family.genealogy.exception.BusinessException;
import com.family.genealogy.mapper.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 互动服务
 * 负责评论、回复、点赞、留言板等互动功能
 */
@Slf4j
@Service
public class InteractionService {

    private final CommentMapper commentMapper;
    private final LikeRecordMapper likeRecordMapper;
    private final MessageBoardMapper messageBoardMapper;
    private final UserMapper userMapper;
    private final TimelinePostMapper timelinePostMapper;
    private final NotificationService notificationService;

    public InteractionService(CommentMapper commentMapper,
                              LikeRecordMapper likeRecordMapper,
                              MessageBoardMapper messageBoardMapper,
                              UserMapper userMapper,
                              TimelinePostMapper timelinePostMapper,
                              NotificationService notificationService) {
        this.commentMapper = commentMapper;
        this.likeRecordMapper = likeRecordMapper;
        this.messageBoardMapper = messageBoardMapper;
        this.userMapper = userMapper;
        this.timelinePostMapper = timelinePostMapper;
        this.notificationService = notificationService;
    }

    /**
     * 发布评论
     */
    @Transactional(rollbackFor = Exception.class)
    public CommentDTO createComment(Long postId, Long userId, CommentCreateDTO dto) {
        // 校验动态存在
        TimelinePost post = timelinePostMapper.selectById(postId);
        if (post == null || post.getDeleted() == 1) {
            throw new BusinessException(ErrorCode.POST_NOT_FOUND, "动态不存在");
        }

        // 层级限制：最多5层
        int depth = 0;
        Long rootId = null;
        Long parentId = dto.getParentId();

        if (parentId != null && parentId > 0) {
            // 回复评论
            Comment parentComment = commentMapper.selectById(parentId);
            if (parentComment == null) {
                throw new BusinessException(ErrorCode.COMMENT_NOT_FOUND, "父评论不存在");
            }
            depth = parentComment.getDepth() + 1;
            if (depth > 5) {
                throw new BusinessException(ErrorCode.COMMENT_DEPTH_LIMIT, "评论层级超过限制");
            }
            rootId = parentComment.getRootId() != null ? parentComment.getRootId() : parentComment.getId();
        }

        // 创建评论
        Comment comment = new Comment();
        comment.setTargetType("POST");
        comment.setTargetId(postId);
        comment.setPostId(postId);
        comment.setUserId(userId);
        comment.setContent(dto.getContent());
        comment.setParentId(parentId != null && parentId > 0 ? parentId : 0L);
        comment.setRootId(rootId);
        comment.setReplyToUserId(dto.getReplyToUserId());
        comment.setDepth(depth);
        comment.setLikeCount(0);
        comment.setStatus("VISIBLE");
        comment.setCreatedBy(userId);
        commentMapper.insert(comment);

        // 如果是顶级评论，root_id设为自身ID
        if (rootId == null) {
            comment.setRootId(comment.getId());
            commentMapper.updateById(comment);
        }

        // 更新动态评论计数
        post.setCommentCount(post.getCommentCount() + 1);
        timelinePostMapper.updateById(post);

        // 生成通知
        if (!userId.equals(post.getUserId())) {
            notificationService.createNotification(
                    post.getUserId(), "COMMENT", "POST", postId,
                    userId, "评论了你的动态"
            );
        }

        return buildCommentDTO(comment, userId);
    }

    /**
     * 获取评论列表（仅一级评论）
     */
    public PageDTO<CommentDTO> getComments(Long postId, int page, int size, Long requesterId) {
        Page<Comment> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Comment::getPostId, postId)
               .eq(Comment::getDepth, 0)
               .eq(Comment::getStatus, "VISIBLE")
               .eq(Comment::getDeleted, 0)
               .orderByDesc(Comment::getLikeCount)
               .orderByAsc(Comment::getCreatedAt);

        Page<Comment> result = commentMapper.selectPage(pageParam, wrapper);

        // 查询每条一级评论的最新3条回复
        List<CommentDTO> records = result.getRecords().stream()
                .map(comment -> buildCommentDTOWithReplies(comment, requesterId))
                .collect(Collectors.toList());

        PageDTO<CommentDTO> pageDTO = new PageDTO<>();
        pageDTO.setRecords(records);
        pageDTO.setTotal(result.getTotal());
        pageDTO.setPage((int) result.getCurrent());
        pageDTO.setSize((int) result.getSize());
        return pageDTO;
    }

    /**
     * 获取回复列表
     */
    public PageDTO<ReplyDTO> getReplies(Long rootId, int page, int size, Long requesterId) {
        Page<Comment> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Comment::getRootId, rootId)
               .gt(Comment::getDepth, 0)
               .eq(Comment::getStatus, "VISIBLE")
               .eq(Comment::getDeleted, 0)
               .orderByAsc(Comment::getCreatedAt);

        Page<Comment> result = commentMapper.selectPage(pageParam, wrapper);

        List<ReplyDTO> records = result.getRecords().stream()
                .map(comment -> buildReplyDTO(comment, requesterId))
                .collect(Collectors.toList());

        PageDTO<ReplyDTO> pageDTO = new PageDTO<>();
        pageDTO.setRecords(records);
        pageDTO.setTotal(result.getTotal());
        pageDTO.setPage((int) result.getCurrent());
        pageDTO.setSize((int) result.getSize());
        return pageDTO;
    }

    /**
     * 删除评论
     */
    @Transactional(rollbackFor = Exception.class)
    public void deleteComment(Long commentId, Long userId) {
        Comment comment = commentMapper.selectById(commentId);
        if (comment == null) {
            throw new BusinessException(ErrorCode.COMMENT_NOT_FOUND, "评论不存在");
        }

        // 权限校验：评论作者或动态作者可删除
        if (!userId.equals(comment.getUserId())) {
            // 检查是否为动态作者
            TimelinePost post = timelinePostMapper.selectById(comment.getPostId());
            if (post == null || !userId.equals(post.getUserId())) {
                throw new BusinessException(ErrorCode.PERMISSION_DENIED, "无权删除此评论");
            }
        }

        comment.setDeleted(1);
        comment.setStatus("DELETED");
        commentMapper.updateById(comment);

        // 更新动态评论计数
        if (comment.getPostId() != null) {
            TimelinePost post = timelinePostMapper.selectById(comment.getPostId());
            if (post != null && post.getCommentCount() > 0) {
                post.setCommentCount(post.getCommentCount() - 1);
                timelinePostMapper.updateById(post);
            }
        }
    }

    /**
     * 切换点赞状态
     */
    @Transactional(rollbackFor = Exception.class)
    public LikeDTO toggleLike(Long userId, String targetType, Long targetId) {
        // 查询是否已点赞
        LambdaQueryWrapper<LikeRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(LikeRecord::getTargetType, targetType)
               .eq(LikeRecord::getTargetId, targetId)
               .eq(LikeRecord::getUserId, userId);

        LikeRecord existingRecord = likeRecordMapper.selectOne(wrapper);
        String action;

        if (existingRecord != null) {
            // 已点赞，切换为取消
            if ("ACTIVE".equals(existingRecord.getStatus())) {
                existingRecord.setStatus("CANCELLED");
                likeRecordMapper.updateById(existingRecord);
                action = "UNLIKE";
                decrementLikeCount(targetType, targetId);
            } else {
                existingRecord.setStatus("ACTIVE");
                likeRecordMapper.updateById(existingRecord);
                action = "LIKE";
                incrementLikeCount(targetType, targetId);
            }
        } else {
            // 未点赞，创建记录
            LikeRecord record = new LikeRecord();
            record.setTargetType(targetType);
            record.setTargetId(targetId);
            record.setUserId(userId);
            record.setStatus("ACTIVE");
            likeRecordMapper.insert(record);
            action = "LIKE";
            incrementLikeCount(targetType, targetId);

            // 生成通知（非点赞目标作者时）
            notifyLikeTarget(userId, targetType, targetId);
        }

        // 获取最新点赞数和状态
        Integer likeCount = getLikeCount(targetType, targetId);
        boolean isLiked = "LIKE".equals(action);

        return LikeDTO.builder()
                .action(action)
                .likeCount(likeCount)
                .isLiked(isLiked)
                .build();
    }

    /**
     * 发布留言
     */
    @Transactional(rollbackFor = Exception.class)
    public MessageBoardDTO createGuestbook(Long targetUserId, Long userId, MessageBoardCreateDTO dto) {
        MessageBoard board = new MessageBoard();
        board.setOwnerUserId(targetUserId);
        board.setSenderId(userId);
        board.setContent(dto.getContent());
        board.setLikeCount(0);
        board.setReplyCount(0);
        board.setIsHidden(0);
        board.setStatus("VISIBLE");
        board.setCreatedBy(userId);
        messageBoardMapper.insert(board);

        return buildMessageBoardDTO(board, userId);
    }

    /**
     * 获取留言列表
     */
    public PageDTO<MessageBoardDTO> getGuestbookList(Long userId, int page, int size, Long requesterId) {
        Page<MessageBoard> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<MessageBoard> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MessageBoard::getOwnerUserId, userId)
               .eq(MessageBoard::getStatus, "VISIBLE")
               .eq(MessageBoard::getDeleted, 0)
               .orderByDesc(MessageBoard::getCreatedAt);

        Page<MessageBoard> result = messageBoardMapper.selectPage(pageParam, wrapper);

        List<MessageBoardDTO> records = result.getRecords().stream()
                .map(board -> buildMessageBoardDTO(board, requesterId))
                .collect(Collectors.toList());

        PageDTO<MessageBoardDTO> pageDTO = new PageDTO<>();
        pageDTO.setRecords(records);
        pageDTO.setTotal(result.getTotal());
        pageDTO.setPage((int) result.getCurrent());
        pageDTO.setSize((int) result.getSize());
        return pageDTO;
    }

    /**
     * 删除留言
     */
    @Transactional(rollbackFor = Exception.class)
    public void deleteGuestbook(Long guestbookId, Long userId) {
        MessageBoard board = messageBoardMapper.selectById(guestbookId);
        if (board == null) {
            throw new BusinessException(ErrorCode.GUESTBOOK_NOT_FOUND, "留言不存在");
        }

        // 权限校验：留言作者或被留言主页的主人可删除
        if (!userId.equals(board.getSenderId()) && !userId.equals(board.getOwnerUserId())) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED, "无权删除此留言");
        }

        board.setDeleted(1);
        board.setStatus("DELETED");
        messageBoardMapper.updateById(board);
    }

    // ==================== 私有辅助方法 ====================

    /**
     * 构建CommentDTO
     */
    private CommentDTO buildCommentDTO(Comment comment, Long requesterId) {
        User user = userMapper.selectById(comment.getUserId());
        Boolean isLiked = checkLiked(requesterId, "COMMENT", comment.getId());

        return CommentDTO.builder()
                .id(comment.getId())
                .targetType(comment.getTargetType())
                .targetId(comment.getTargetId())
                .userId(comment.getUserId())
                .userName(user != null ? user.getName() : null)
                .content(comment.getContent())
                .parentId(comment.getParentId())
                .rootId(comment.getRootId())
                .replyToUserId(comment.getReplyToUserId())
                .depth(comment.getDepth())
                .likeCount(comment.getLikeCount())
                .isLiked(isLiked)
                .createdAt(comment.getCreatedAt())
                .replies(new ArrayList<>())
                .replyCount(0)
                .build();
    }

    /**
     * 构建CommentDTO（含最新回复）
     */
    private CommentDTO buildCommentDTOWithReplies(Comment comment, Long requesterId) {
        CommentDTO dto = buildCommentDTO(comment, requesterId);

        // 查询回复总数
        LambdaQueryWrapper<Comment> countWrapper = new LambdaQueryWrapper<>();
        countWrapper.eq(Comment::getRootId, comment.getId())
                    .gt(Comment::getDepth, 0)
                    .eq(Comment::getStatus, "VISIBLE")
                    .eq(Comment::getDeleted, 0);
        long replyCount = commentMapper.selectCount(countWrapper);
        dto.setReplyCount((int) replyCount);

        // 查询最新3条回复
        LambdaQueryWrapper<Comment> replyWrapper = new LambdaQueryWrapper<>();
        replyWrapper.eq(Comment::getRootId, comment.getId())
                    .gt(Comment::getDepth, 0)
                    .eq(Comment::getStatus, "VISIBLE")
                    .eq(Comment::getDeleted, 0)
                    .orderByAsc(Comment::getCreatedAt)
                    .last("LIMIT 3");
        List<Comment> replies = commentMapper.selectList(replyWrapper);

        List<ReplyDTO> replyDTOs = replies.stream()
                .map(r -> buildReplyDTO(r, requesterId))
                .collect(Collectors.toList());
        dto.setReplies(replyDTOs);

        return dto;
    }

    /**
     * 构建ReplyDTO
     */
    private ReplyDTO buildReplyDTO(Comment comment, Long requesterId) {
        User user = userMapper.selectById(comment.getUserId());
        User replyToUser = null;
        if (comment.getReplyToUserId() != null) {
            replyToUser = userMapper.selectById(comment.getReplyToUserId());
        }
        Boolean isLiked = checkLiked(requesterId, "COMMENT", comment.getId());

        return ReplyDTO.builder()
                .id(comment.getId())
                .userId(comment.getUserId())
                .userName(user != null ? user.getName() : null)
                .content(comment.getContent())
                .parentId(comment.getParentId())
                .rootId(comment.getRootId())
                .replyToUserId(comment.getReplyToUserId())
                .replyToUserName(replyToUser != null ? replyToUser.getName() : null)
                .depth(comment.getDepth())
                .likeCount(comment.getLikeCount())
                .isLiked(isLiked)
                .createdAt(comment.getCreatedAt())
                .build();
    }

    /**
     * 构建MessageBoardDTO
     */
    private MessageBoardDTO buildMessageBoardDTO(MessageBoard board, Long requesterId) {
        User user = userMapper.selectById(board.getSenderId());
        Boolean isLiked = checkLiked(requesterId, "GUESTBOOK", board.getId());

        return MessageBoardDTO.builder()
                .id(board.getId())
                .userId(board.getSenderId())
                .userName(user != null ? user.getName() : null)
                .content(board.getContent())
                .likeCount(board.getLikeCount())
                .isLiked(isLiked)
                .createdAt(board.getCreatedAt())
                .build();
    }

    /**
     * 检查是否已点赞
     */
    private Boolean checkLiked(Long userId, String targetType, Long targetId) {
        if (userId == null) return false;
        LambdaQueryWrapper<LikeRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(LikeRecord::getTargetType, targetType)
               .eq(LikeRecord::getTargetId, targetId)
               .eq(LikeRecord::getUserId, userId)
               .eq(LikeRecord::getStatus, "ACTIVE");
        return likeRecordMapper.selectCount(wrapper) > 0;
    }

    /**
     * 获取点赞数
     */
    private Integer getLikeCount(String targetType, Long targetId) {
        LambdaQueryWrapper<LikeRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(LikeRecord::getTargetType, targetType)
               .eq(LikeRecord::getTargetId, targetId)
               .eq(LikeRecord::getStatus, "ACTIVE");
        return Math.toIntExact(likeRecordMapper.selectCount(wrapper));
    }

    /**
     * 增加点赞计数
     */
    private void incrementLikeCount(String targetType, Long targetId) {
        if ("POST".equals(targetType)) {
            TimelinePost post = timelinePostMapper.selectById(targetId);
            if (post != null) {
                post.setLikeCount(post.getLikeCount() + 1);
                timelinePostMapper.updateById(post);
            }
        }
    }

    /**
     * 减少点赞计数
     */
    private void decrementLikeCount(String targetType, Long targetId) {
        if ("POST".equals(targetType)) {
            TimelinePost post = timelinePostMapper.selectById(targetId);
            if (post != null && post.getLikeCount() > 0) {
                post.setLikeCount(post.getLikeCount() - 1);
                timelinePostMapper.updateById(post);
            }
        }
    }

    /**
     * 通知点赞目标
     */
    private void notifyLikeTarget(Long userId, String targetType, Long targetId) {
        if ("POST".equals(targetType)) {
            TimelinePost post = timelinePostMapper.selectById(targetId);
            if (post != null && !userId.equals(post.getUserId())) {
                notificationService.createNotification(
                        post.getUserId(), "LIKE", "POST", targetId,
                        userId, "点赞了你的动态"
                );
            }
        }
    }
}
