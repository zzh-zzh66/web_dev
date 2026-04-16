package com.family.genealogy.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.family.genealogy.dto.*;
import com.family.genealogy.entity.*;
import com.family.genealogy.exception.BusinessException;
import com.family.genealogy.mapper.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 个人主页服务类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ProfileService {

    private final PostMapper postMapper;
    private final CommentMapper commentMapper;
    private final LikeMapper likeMapper;
    private final GuestbookMapper guestbookMapper;
    private final MessageMapper messageMapper;
    private final NotificationMapper notificationMapper;
    private final UserProfileMapper userProfileMapper;
    private final MemberMapper memberMapper;
    private final UserMapper userMapper;
    private final ObjectMapper objectMapper;

    /**
     * 获取个人主页信息
     */
    public ProfileDTO getProfile(Long memberId, Long currentUserId) {
        Member member = memberMapper.selectById(memberId);
        if (member == null || member.getDeleted() == 1) {
            throw new BusinessException("MEMBER_001", "成员不存在");
        }

        User memberUser = userMapper.selectById(member.getCreatedBy());
        if (memberUser == null) {
            throw new BusinessException("MEMBER_001", "用户不存在");
        }

        ProfileDTO profile = new ProfileDTO();
        profile.setMemberId(member.getId());
        profile.setUserId(member.getCreatedBy());
        profile.setName(member.getName());
        profile.setGender(member.getGender());
        profile.setGeneration(member.getGeneration());
        profile.setRole(memberUser.getRole());
        profile.setBirthDate(member.getBirthDate());
        profile.setOccupation(member.getOccupation());
        profile.setBirthPlace(member.getBirthPlace());
        profile.setBio(member.getBiography());
        profile.setAvatarUrl(member.getPortraitUrl());
        profile.setIsSelf(member.getCreatedBy().equals(currentUserId));

        // 获取用户扩展资料
        LambdaQueryWrapper<UserProfile> profileQuery = new LambdaQueryWrapper<>();
        profileQuery.eq(UserProfile::getMemberId, memberId);
        UserProfile userProfile = userProfileMapper.selectOne(profileQuery);
        if (userProfile != null) {
            profile.setCoverUrl(userProfile.getCoverUrl());
            profile.setCurrentPlace(userProfile.getCurrentPlace());
            profile.setMotto(userProfile.getMotto());
            if (userProfile.getHobbies() != null) {
                try {
                    profile.setHobbies(objectMapper.readValue(userProfile.getHobbies(), new TypeReference<List<String>>() {}));
                } catch (JsonProcessingException e) {
                    log.error("解析爱好失败", e);
                }
            }
            if (userProfile.getAchievements() != null) {
                try {
                    profile.setAchievements(objectMapper.readValue(userProfile.getAchievements(), new TypeReference<List<String>>() {}));
                } catch (JsonProcessingException e) {
                    log.error("解析成就失败", e);
                }
            }
        }

        // 统计动态数量
        LambdaQueryWrapper<Post> postQuery = new LambdaQueryWrapper<>();
        postQuery.eq(Post::getMemberId, memberId)
                  .eq(Post::getStatus, 1);
        profile.setPostCount(postMapper.selectCount(postQuery).intValue());

        // 计算亲属关系
        if (!profile.getIsSelf() && currentUserId != null) {
            profile.setRelationTag(calculateRelationTag(memberId, currentUserId));
        }

        return profile;
    }

    /**
     * 获取用户动态列表
     */
    public PageDTO<PostDTO> getUserPosts(Long memberId, Long currentUserId, Integer page, Integer size) {
        LambdaQueryWrapper<Post> query = new LambdaQueryWrapper<>();
        query.eq(Post::getMemberId, memberId)
              .eq(Post::getStatus, 1)
              .orderByDesc(Post::getCreatedAt);

        Page<Post> postPage = new Page<>(page, size);
        Page<Post> result = postMapper.selectPage(postPage, query);

        List<PostDTO> postDTOs = result.getRecords().stream()
            .map(post -> convertToPostDTO(post, currentUserId))
            .collect(Collectors.toList());

        PageDTO<PostDTO> pageDTO = new PageDTO<>();
        pageDTO.setRecords(postDTOs);
        pageDTO.setTotal(result.getTotal());
        pageDTO.setPage(result.getCurrent());
        pageDTO.setSize(result.getSize());

        return pageDTO;
    }

    /**
     * 发布动态
     */
    @Transactional
    public Long createPost(PostCreateRequest request, Long userId) {
        // 验证用户
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("AUTH_001", "用户不存在");
        }

        Post post = new Post();
        post.setMemberId(request.getMemberId());
        post.setAuthorUserId(userId);
        post.setTitle(request.getTitle());
        post.setContent(request.getContent());
        post.setPostType(request.getPostType() != null ? request.getPostType() : "DAILY");
        post.setEventDate(request.getEventDate());
        post.setEventPlace(request.getEventPlace());
        post.setVisibility(request.getVisibility() != null ? request.getVisibility() : "FAMILY");
        post.setLikeCount(0);
        post.setCommentCount(0);
        post.setViewCount(0);
        post.setStatus(1);
        post.setCreatedAt(LocalDateTime.now());
        post.setUpdatedAt(LocalDateTime.now());

        if (request.getImages() != null && !request.getImages().isEmpty()) {
            try {
                post.setImages(objectMapper.writeValueAsString(request.getImages()));
            } catch (JsonProcessingException e) {
                log.error("序列化图片失败", e);
            }
        }

        if (request.getTaggedMemberIds() != null && !request.getTaggedMemberIds().isEmpty()) {
            try {
                post.setTaggedMembers(objectMapper.writeValueAsString(request.getTaggedMemberIds()));
            } catch (JsonProcessingException e) {
                log.error("序列化标记成员失败", e);
            }
        }

        postMapper.insert(post);
        return post.getId();
    }

    /**
     * 获取动态详情
     */
    public PostDTO getPostDetail(Long postId, Long currentUserId) {
        Post post = postMapper.selectById(postId);
        if (post == null || post.getStatus() == 0) {
            throw new BusinessException("POST_001", "动态不存在");
        }
        return convertToPostDTO(post, currentUserId);
    }

    /**
     * 删除动态
     */
    @Transactional
    public void deletePost(Long postId, Long userId) {
        Post post = postMapper.selectById(postId);
        if (post == null) {
            throw new BusinessException("POST_001", "动态不存在");
        }
        if (!post.getAuthorUserId().equals(userId)) {
            throw new BusinessException("POST_002", "无权删除此动态");
        }
        post.setStatus(0);
        postMapper.updateById(post);
    }

    /**
     * 点赞动态
     */
    @Transactional
    public void likePost(Long postId, Long userId) {
        Post post = postMapper.selectById(postId);
        if (post == null || post.getStatus() == 0) {
            throw new BusinessException("POST_001", "动态不存在");
        }

        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("AUTH_001", "用户不存在");
        }

        // 检查是否已点赞
        LambdaQueryWrapper<Like> likeQuery = new LambdaQueryWrapper<>();
        likeQuery.eq(Like::getPostId, postId)
                  .eq(Like::getUserId, userId)
                  .eq(Like::getStatus, 1);
        Like existingLike = likeMapper.selectOne(likeQuery);

        if (existingLike != null) {
            throw new BusinessException("LIKE_001", "已经点过赞了");
        }

        // 获取用户关联的成员ID
        LambdaQueryWrapper<Member> memberQuery = new LambdaQueryWrapper<>();
        memberQuery.eq(Member::getCreatedBy, userId);
        Member member = memberMapper.selectOne(memberQuery);
        if (member == null) {
            throw new BusinessException("MEMBER_001", "用户关联的成员不存在");
        }

        // 创建点赞记录
        Like like = new Like();
        like.setPostId(postId);
        like.setUserId(userId);
        like.setMemberId(member.getId());
        like.setStatus(1);
        like.setCreatedAt(LocalDateTime.now());
        likeMapper.insert(like);

        // 更新点赞数
        post.setLikeCount(post.getLikeCount() == null ? 1 : post.getLikeCount() + 1);
        postMapper.updateById(post);

        // 发送通知
        if (!post.getAuthorUserId().equals(userId)) {
            createNotification(userId, member.getId(), post.getAuthorUserId(),
                             "LIKE", "点赞了你的动态", post.getContent(), "post", postId);
        }
    }

    /**
     * 取消点赞
     */
    @Transactional
    public void unlikePost(Long postId, Long userId) {
        LambdaQueryWrapper<Like> likeQuery = new LambdaQueryWrapper<>();
        likeQuery.eq(Like::getPostId, postId)
                 .eq(Like::getUserId, userId)
                 .eq(Like::getStatus, 1);
        Like like = likeMapper.selectOne(likeQuery);

        if (like == null) {
            throw new BusinessException("LIKE_002", "还未点赞");
        }

        like.setStatus(0);
        likeMapper.updateById(like);

        Post post = postMapper.selectById(postId);
        if (post != null && post.getLikeCount() != null && post.getLikeCount() > 0) {
            post.setLikeCount(post.getLikeCount() - 1);
            postMapper.updateById(post);
        }
    }

    /**
     * 评论动态
     */
    @Transactional
    public Long createComment(CommentCreateRequest request, Long userId) {
        Post post = postMapper.selectById(request.getPostId());
        if (post == null || post.getStatus() == 0) {
            throw new BusinessException("POST_001", "动态不存在");
        }

        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("AUTH_001", "用户不存在");
        }

        LambdaQueryWrapper<Member> memberQuery = new LambdaQueryWrapper<>();
        memberQuery.eq(Member::getCreatedBy, userId);
        Member member = memberMapper.selectOne(memberQuery);
        if (member == null) {
            throw new BusinessException("MEMBER_001", "用户关联的成员不存在");
        }

        Comment comment = new Comment();
        comment.setPostId(request.getPostId());
        comment.setParentId(request.getParentId());
        comment.setUserId(userId);
        comment.setMemberId(member.getId());
        comment.setContent(request.getContent());
        comment.setStatus(1);
        comment.setCreatedAt(LocalDateTime.now());
        comment.setUpdatedAt(LocalDateTime.now());

        if (request.getMentionedMemberIds() != null && !request.getMentionedMemberIds().isEmpty()) {
            try {
                comment.setMentionedMembers(objectMapper.writeValueAsString(request.getMentionedMemberIds()));
            } catch (JsonProcessingException e) {
                log.error("序列化提及成员失败", e);
            }
        }

        commentMapper.insert(comment);

        // 更新评论数
        post.setCommentCount(post.getCommentCount() == null ? 1 : post.getCommentCount() + 1);
        postMapper.updateById(post);

        // 发送通知
        String notifyType = request.getParentId() != null ? "REPLY" : "COMMENT";
        String notifyContent = request.getParentId() != null ? "回复了你的评论" : "评论了你的动态";
        if (!post.getAuthorUserId().equals(userId)) {
            createNotification(userId, member.getId(), post.getAuthorUserId(),
                             notifyType, notifyContent, post.getContent(), "post", postId);
        }

        // 如果是回复评论，通知原评论者
        if (request.getParentId() != null) {
            Comment parentComment = commentMapper.selectById(request.getParentId());
            if (parentComment != null && !parentComment.getUserId().equals(userId)) {
                createNotification(userId, member.getId(), parentComment.getUserId(),
                                 "REPLY", "回复了你的评论", request.getContent(), "comment", comment.getId());
            }
        }

        return comment.getId();
    }

    /**
     * 获取动态评论列表
     */
    public List<CommentDTO> getPostComments(Long postId) {
        LambdaQueryWrapper<Comment> query = new LambdaQueryWrapper<>();
        query.eq(Comment::getPostId, postId)
             .eq(Comment::getStatus, 1)
             .isNull(Comment::getParentId)
             .orderByAsc(Comment::getCreatedAt);
        List<Comment> comments = commentMapper.selectList(query);

        return comments.stream()
            .map(this::convertToCommentDTO)
            .collect(Collectors.toList());
    }

    /**
     * 获取留言板
     */
    public List<GuestbookDTO> getGuestbook(Long ownerMemberId) {
        LambdaQueryWrapper<Guestbook> query = new LambdaQueryWrapper<>();
        query.eq(Guestbook::getOwnerMemberId, ownerMemberId)
             .eq(Guestbook::getStatus, 1)
             .isNull(Guestbook::getParentId)
             .orderByDesc(Guestbook::getCreatedAt);
        List<Guestbook> guestbooks = guestbookMapper.selectList(query);

        return guestbooks.stream()
            .map(this::convertToGuestbookDTO)
            .collect(Collectors.toList());
    }

    /**
     * 添加留言
     */
    @Transactional
    public Long createGuestbook(GuestbookRequest request, Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("AUTH_001", "用户不存在");
        }

        LambdaQueryWrapper<Member> memberQuery = new LambdaQueryWrapper<>();
        memberQuery.eq(Member::getCreatedBy, userId);
        Member member = memberMapper.selectOne(memberQuery);
        if (member == null) {
            throw new BusinessException("MEMBER_001", "用户关联的成员不存在");
        }

        Guestbook guestbook = new Guestbook();
        guestbook.setOwnerMemberId(request.getOwnerMemberId());
        guestbook.setUserId(userId);
        guestbook.setMemberId(member.getId());
        guestbook.setParentId(request.getParentId());
        guestbook.setContent(request.getContent());
        guestbook.setStatus(1);
        guestbook.setCreatedAt(LocalDateTime.now());
        guestbook.setUpdatedAt(LocalDateTime.now());

        guestbookMapper.insert(guestbook);
        return guestbook.getId();
    }

    /**
     * 删除留言
     */
    public void deleteGuestbook(Long guestbookId, Long userId) {
        Guestbook guestbook = guestbookMapper.selectById(guestbookId);
        if (guestbook == null) {
            throw new BusinessException("GUESTBOOK_001", "留言不存在");
        }

        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("AUTH_001", "用户不存在");
        }

        LambdaQueryWrapper<Member> memberQuery = new LambdaQueryWrapper<>();
        memberQuery.eq(Member::getCreatedBy, userId);
        Member member = memberMapper.selectOne(memberQuery);

        // 只有留言者或留言板主人可以删除
        if (!guestbook.getUserId().equals(userId) &&
            (member == null || !guestbook.getOwnerMemberId().equals(member.getId()))) {
            throw new BusinessException("GUESTBOOK_002", "无权删除此留言");
        }

        guestbook.setStatus(0);
        guestbookMapper.updateById(guestbook);
    }

    /**
     * 获取私信列表
     */
    public PageDTO<MessageDTO> getMessages(Long userId, Integer page, Integer size) {
        LambdaQueryWrapper<Message> query = new LambdaQueryWrapper<>();
        query.and(w -> w.eq(Message::getSenderId, userId).eq(Message::getSenderDeleted, 0)
                       .or()
                       .eq(Message::getReceiverId, userId).eq(Message::getReceiverDeleted, 0))
             .orderByDesc(Message::getCreatedAt);

        Page<Message> messagePage = new Page<>(page, size);
        Page<Message> result = messageMapper.selectPage(messagePage, query);

        List<MessageDTO> messageDTOs = result.getRecords().stream()
            .map(this::convertToMessageDTO)
            .collect(Collectors.toList());

        PageDTO<MessageDTO> pageDTO = new PageDTO<>();
        pageDTO.setRecords(messageDTOs);
        pageDTO.setTotal(result.getTotal());
        pageDTO.setPage(result.getCurrent());
        pageDTO.setSize(result.getSize());

        return pageDTO;
    }

    /**
     * 发送私信
     */
    @Transactional
    public Long sendMessage(MessageSendRequest request, Long senderId) {
        User sender = userMapper.selectById(senderId);
        if (sender == null) {
            throw new BusinessException("AUTH_001", "发送者不存在");
        }

        User receiver = userMapper.selectById(request.getReceiverId());
        if (receiver == null) {
            throw new BusinessException("AUTH_001", "接收者不存在");
        }

        LambdaQueryWrapper<Member> senderMemberQuery = new LambdaQueryWrapper<>();
        senderMemberQuery.eq(Member::getCreatedBy, senderId);
        Member senderMember = memberMapper.selectOne(senderMemberQuery);

        LambdaQueryWrapper<Member> receiverMemberQuery = new LambdaQueryWrapper<>();
        receiverMemberQuery.eq(Member::getCreatedBy, request.getReceiverId());
        Member receiverMember = memberMapper.selectOne(receiverMemberQuery);

        Message message = new Message();
        message.setSenderId(senderId);
        message.setSenderMemberId(senderMember != null ? senderMember.getId() : 0);
        message.setReceiverId(request.getReceiverId());
        message.setReceiverMemberId(receiverMember != null ? receiverMember.getId() : 0);
        message.setContent(request.getContent());
        message.setSenderDeleted(0);
        message.setReceiverDeleted(0);
        message.setIsRead(0);
        message.setCreatedAt(LocalDateTime.now());

        messageMapper.insert(message);

        // 发送通知
        if (senderMember != null && receiverMember != null) {
            createNotification(senderId, senderMember.getId(), request.getReceiverId(),
                             "MESSAGE", "发来私信", request.getContent(), "message", message.getId());
        }

        return message.getId();
    }

    /**
     * 获取通知列表
     */
    public PageDTO<NotificationDTO> getNotifications(Long userId, Integer page, Integer size) {
        LambdaQueryWrapper<Member> memberQuery = new LambdaQueryWrapper<>();
        memberQuery.eq(Member::getCreatedBy, userId);
        Member member = memberMapper.selectOne(memberQuery);
        if (member == null) {
            throw new BusinessException("MEMBER_001", "用户关联的成员不存在");
        }

        LambdaQueryWrapper<Notification> query = new LambdaQueryWrapper<>();
        query.eq(Notification::getUserId, userId)
              .orderByDesc(Notification::getCreatedAt);

        Page<Notification> notifPage = new Page<>(page, size);
        Page<Notification> result = notificationMapper.selectPage(notifPage, query);

        List<NotificationDTO> notificationDTOs = result.getRecords().stream()
            .map(notif -> convertToNotificationDTO(notif))
            .collect(Collectors.toList());

        PageDTO<NotificationDTO> pageDTO = new PageDTO<>();
        pageDTO.setRecords(notificationDTOs);
        pageDTO.setTotal(result.getTotal());
        pageDTO.setPage(result.getCurrent());
        pageDTO.setSize(result.getSize());

        return pageDTO;
    }

    /**
     * 标记通知已读
     */
    public void markNotificationRead(Long notificationId, Long userId) {
        Notification notification = notificationMapper.selectById(notificationId);
        if (notification == null) {
            throw new BusinessException("NOTIFICATION_001", "通知不存在");
        }
        if (!notification.getUserId().equals(userId)) {
            throw new BusinessException("NOTIFICATION_002", "无权操作此通知");
        }
        notification.setIsRead(1);
        notificationMapper.updateById(notification);
    }

    /**
     * 标记所有通知已读
     */
    public void markAllNotificationsRead(Long userId) {
        LambdaQueryWrapper<Notification> query = new LambdaQueryWrapper<>();
        query.eq(Notification::getUserId, userId)
             .eq(Notification::getIsRead, 0);
        Notification notification = new Notification();
        notification.setIsRead(1);
        notificationMapper.update(notification, query);
    }

    /**
     * 更新个人资料
     */
    @Transactional
    public void updateProfile(ProfileUpdateRequest request, Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("AUTH_001", "用户不存在");
        }

        LambdaQueryWrapper<Member> memberQuery = new LambdaQueryWrapper<>();
        memberQuery.eq(Member::getCreatedBy, userId);
        Member member = memberMapper.selectOne(memberQuery);
        if (member == null) {
            throw new BusinessException("MEMBER_001", "用户关联的成员不存在");
        }

        // 更新成员表
        if (request.getBio() != null) {
            member.setBiography(request.getBio());
        }
        if (request.getOccupation() != null) {
            member.setOccupation(request.getOccupation());
        }
        if (request.getAvatarUrl() != null) {
            member.setPortraitUrl(request.getAvatarUrl());
        }
        memberMapper.updateById(member);

        // 更新或创建用户扩展资料
        LambdaQueryWrapper<UserProfile> profileQuery = new LambdaQueryWrapper<>();
        profileQuery.eq(UserProfile::getUserId, userId);
        UserProfile userProfile = userProfileMapper.selectOne(profileQuery);

        if (userProfile == null) {
            userProfile = new UserProfile();
            userProfile.setUserId(userId);
            userProfile.setMemberId(member.getId());
            userProfile.setCreatedAt(LocalDateTime.now());
            userProfile.setUpdatedAt(LocalDateTime.now());
        }

        if (request.getCoverUrl() != null) {
            userProfile.setCoverUrl(request.getCoverUrl());
        }
        if (request.getBio() != null) {
            userProfile.setBio(request.getBio());
        }
        if (request.getOccupation() != null) {
            userProfile.setOccupation(request.getOccupation());
        }
        if (request.getBirthPlace() != null) {
            userProfile.setBirthPlace(request.getBirthPlace());
        }
        if (request.getCurrentPlace() != null) {
            userProfile.setCurrentPlace(request.getCurrentPlace());
        }
        if (request.getHobbies() != null) {
            try {
                userProfile.setHobbies(objectMapper.writeValueAsString(request.getHobbies()));
            } catch (JsonProcessingException e) {
                log.error("序列化爱好失败", e);
            }
        }
        if (request.getAchievements() != null) {
            try {
                userProfile.setAchievements(objectMapper.writeValueAsString(request.getAchievements()));
            } catch (JsonProcessingException e) {
                log.error("序列化成就失败", e);
            }
        }
        if (request.getMotto() != null) {
            userProfile.setMotto(request.getMotto());
        }
        if (request.getEmail() != null) {
            userProfile.setEmail(request.getEmail());
        }
        if (request.getPhone() != null) {
            userProfile.setPhone(request.getPhone());
        }
        if (request.getPrivacySetting() != null) {
            userProfile.setPrivacySetting(request.getPrivacySetting());
        }
        userProfile.setUpdatedAt(LocalDateTime.now());

        if (userProfile.getId() == null) {
            userProfileMapper.insert(userProfile);
        } else {
            userProfileMapper.updateById(userProfile);
        }
    }

    /**
     * 计算亲属关系标签
     */
    private String calculateRelationTag(Long memberId, Long currentUserId) {
        Member targetMember = memberMapper.selectById(memberId);

        LambdaQueryWrapper<Member> memberQuery = new LambdaQueryWrapper<>();
        memberQuery.eq(Member::getCreatedBy, currentUserId);
        Member currentMember = memberMapper.selectOne(memberQuery);

        if (currentMember == null || targetMember == null) {
            return "家族成员";
        }

        // 简单关系判断
        if (targetMember.getFatherId() != null && targetMember.getFatherId().equals(currentMember.getId())) {
            return "父亲";
        }
        if (targetMember.getMotherId() != null && targetMember.getMotherId().equals(currentMember.getId())) {
            return "母亲";
        }
        if (currentMember.getFatherId() != null && currentMember.getFatherId().equals(targetMember.getId())) {
            return "子女";
        }
        if (currentMember.getMotherId() != null && currentMember.getMotherId().equals(targetMember.getId())) {
            return "子女";
        }
        if (targetMember.getSpouseName() != null && targetMember.getSpouseName().equals(currentMember.getName())) {
            return "配偶";
        }

        // 同辈判断（相同父亲）
        if (targetMember.getFatherId() != null && currentMember.getFatherId() != null
            && targetMember.getFatherId().equals(currentMember.getFatherId())) {
            if (targetMember.getGender() != null && targetMember.getGender().equals("MALE")) {
                return "兄弟";
            } else {
                return "姐妹";
            }
        }

        // 叔伯/姑姨判断
        if (currentMember.getFatherId() != null) {
            Member father = memberMapper.selectById(currentMember.getFatherId());
            if (father != null && father.getFatherId() != null
                && targetMember.getId().equals(father.getFatherId())) {
                if (targetMember.getGender() != null && targetMember.getGender().equals("MALE")) {
                    return "叔伯";
                } else {
                    return "姑母";
                }
            }
        }

        return "家族成员";
    }

    /**
     * 创建通知
     */
    private void createNotification(Long triggerUserId, Long triggerMemberId, Long targetUserId,
                                   String type, String content, String resourceContent,
                                   String resourceType, Long resourceId) {
        User targetUser = userMapper.selectById(targetUserId);
        if (targetUser == null) return;

        LambdaQueryWrapper<Member> memberQuery = new LambdaQueryWrapper<>();
        memberQuery.eq(Member::getCreatedBy, targetUserId);
        Member targetMember = memberMapper.selectOne(memberQuery);
        if (targetMember == null) return;

        Notification notification = new Notification();
        notification.setUserId(targetUserId);
        notification.setMemberId(targetMember.getId());
        notification.setTriggerUserId(triggerUserId);
        notification.setTriggerMemberId(triggerMemberId);
        notification.setType(type);
        notification.setTitle(content);
        notification.setContent(resourceContent != null && resourceContent.length() > 50
            ? resourceContent.substring(0, 50) + "..." : resourceContent);
        notification.setResourceType(resourceType);
        notification.setResourceId(resourceId);
        notification.setIsRead(0);
        notification.setCreatedAt(LocalDateTime.now());

        notificationMapper.insert(notification);
    }

    /**
     * 转换Post为PostDTO
     */
    private PostDTO convertToPostDTO(Post post, Long currentUserId) {
        PostDTO dto = new PostDTO();
        BeanUtils.copyProperties(post, dto);
        dto.setPostId(post.getId());

        // 设置类型名称
        dto.setPostTypeName(getPostTypeName(post.getPostType()));

        // 解析图片
        if (post.getImages() != null) {
            try {
                dto.setImages(objectMapper.readValue(post.getImages(), new TypeReference<List<String>>() {}));
            } catch (JsonProcessingException e) {
                log.error("解析图片失败", e);
            }
        }

        // 获取发布者信息
        Member author = memberMapper.selectById(post.getMemberId());
        if (author != null) {
            dto.setAuthorName(author.getName());
            dto.setAuthorAvatar(author.getPortraitUrl());
            dto.setAuthorGeneration(author.getGeneration());
        }

        User authorUser = userMapper.selectById(post.getAuthorUserId());
        if (authorUser != null) {
            dto.setAuthorRole(authorUser.getRole());
        }

        // 检查是否点赞
        if (currentUserId != null) {
            LambdaQueryWrapper<Like> likeQuery = new LambdaQueryWrapper<>();
            likeQuery.eq(Like::getPostId, post.getId())
                     .eq(Like::getUserId, currentUserId)
                     .eq(Like::getStatus, 1);
            dto.setIsLiked(likeMapper.selectCount(likeQuery) > 0);
        } else {
            dto.setIsLiked(false);
        }

        dto.setIsSelf(post.getAuthorUserId().equals(currentUserId));

        return dto;
    }

    /**
     * 获取动态类型名称
     */
    private String getPostTypeName(String postType) {
        if (postType == null) return "日常";
        switch (postType) {
            case "LIFE_EVENT": return "人生大事";
            case "MILESTONE": return "里程碑";
            case "MEMORY": return "回忆分享";
            case "THOUGHT": return "心得感悟";
            case "DAILY": return "日常分享";
            default: return "日常";
        }
    }

    /**
     * 转换Comment为CommentDTO
     */
    private CommentDTO convertToCommentDTO(Comment comment) {
        CommentDTO dto = new CommentDTO();
        BeanUtils.copyProperties(comment, dto);
        dto.setCommentId(comment.getId());

        Member member = memberMapper.selectById(comment.getMemberId());
        if (member != null) {
            dto.setUserName(member.getName());
            dto.setUserAvatar(member.getPortraitUrl());
            dto.setUserGeneration(member.getGeneration());
        }

        // 查询回复
        LambdaQueryWrapper<Comment> replyQuery = new LambdaQueryWrapper<>();
        replyQuery.eq(Comment::getParentId, comment.getId())
                  .eq(Comment::getStatus, 1)
                  .orderByAsc(Comment::getCreatedAt);
        List<Comment> replies = commentMapper.selectList(replyQuery);
        dto.setReplies(replies.stream().map(this::convertToCommentDTO).collect(Collectors.toList()));
        dto.setReplyCount(replies.size());

        return dto;
    }

    /**
     * 转换Guestbook为GuestbookDTO
     */
    private GuestbookDTO convertToGuestbookDTO(Guestbook guestbook) {
        GuestbookDTO dto = new GuestbookDTO();
        BeanUtils.copyProperties(guestbook, dto);
        dto.setGuestbookId(guestbook.getId());

        Member member = memberMapper.selectById(guestbook.getMemberId());
        if (member != null) {
            dto.setUserName(member.getName());
            dto.setUserAvatar(member.getPortraitUrl());
            dto.setUserGeneration(member.getGeneration());
        }

        // 查询回复
        LambdaQueryWrapper<Guestbook> replyQuery = new LambdaQueryWrapper<>();
        replyQuery.eq(Guestbook::getParentId, guestbook.getId())
                  .eq(Guestbook::getStatus, 1)
                  .orderByAsc(Guestbook::getCreatedAt);
        List<Guestbook> replies = guestbookMapper.selectList(replyQuery);
        dto.setReplies(replies.stream().map(this::convertToGuestbookDTO).collect(Collectors.toList()));

        return dto;
    }

    /**
     * 转换Message为MessageDTO
     */
    private MessageDTO convertToMessageDTO(Message message) {
        MessageDTO dto = new MessageDTO();
        BeanUtils.copyProperties(message, dto);
        dto.setMessageId(message.getId());

        Member senderMember = memberMapper.selectById(message.getSenderMemberId());
        if (senderMember != null) {
            dto.setSenderName(senderMember.getName());
            dto.setSenderAvatar(senderMember.getPortraitUrl());
        }

        Member receiverMember = memberMapper.selectById(message.getReceiverMemberId());
        if (receiverMember != null) {
            dto.setReceiverName(receiverMember.getName());
            dto.setReceiverAvatar(receiverMember.getPortraitUrl());
        }

        return dto;
    }

    /**
     * 转换Notification为NotificationDTO
     */
    private NotificationDTO convertToNotificationDTO(Notification notification) {
        NotificationDTO dto = new NotificationDTO();
        BeanUtils.copyProperties(notification, dto);
        dto.setNotificationId(notification.getId());
        dto.setTypeName(getNotificationTypeName(notification.getType()));
        dto.setIsRead(notification.getIsRead() == 1);

        Member triggerMember = memberMapper.selectById(notification.getTriggerMemberId());
        if (triggerMember != null) {
            dto.setTriggerUserName(triggerMember.getName());
            dto.setTriggerUserAvatar(triggerMember.getPortraitUrl());
        }

        return dto;
    }

    /**
     * 获取通知类型名称
     */
    private String getNotificationTypeName(String type) {
        if (type == null) return "通知";
        switch (type) {
            case "COMMENT": return "评论";
            case "REPLY": return "回复";
            case "LIKE": return "点赞";
            case "MESSAGE": return "私信";
            case "MENTION": return "@提及";
            case "BIRTHDAY": return "生日提醒";
            case "ANNIVERSARY": return "纪念日提醒";
            default: return "通知";
        }
    }
}
