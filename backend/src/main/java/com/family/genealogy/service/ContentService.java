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

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 内容管理服务
 * 负责动态的发布、查询、更新、删除
 */
@Slf4j
@Service
public class ContentService {

    private final TimelinePostMapper timelinePostMapper;
    private final PostMediaMapper postMediaMapper;
    private final UserProfileMapper userProfileMapper;
    private final UserMapper userMapper;
    private final PostCategoryMapper postCategoryMapper;
    private final LikeRecordMapper likeRecordMapper;

    public ContentService(TimelinePostMapper timelinePostMapper,
                          PostMediaMapper postMediaMapper,
                          UserProfileMapper userProfileMapper,
                          UserMapper userMapper,
                          PostCategoryMapper postCategoryMapper,
                          LikeRecordMapper likeRecordMapper) {
        this.timelinePostMapper = timelinePostMapper;
        this.postMediaMapper = postMediaMapper;
        this.userProfileMapper = userProfileMapper;
        this.userMapper = userMapper;
        this.postCategoryMapper = postCategoryMapper;
        this.likeRecordMapper = likeRecordMapper;
    }

    /**
     * 发布动态
     */
    @Transactional(rollbackFor = Exception.class)
    public PostDTO createPost(Long userId, PostCreateDTO dto) {
        // 确保用户主页存在（自动创建如果不存在）
        UserProfile profile = getOrCreateProfile(userId);

        // 创建动态
        TimelinePost post = new TimelinePost();
        post.setUserId(userId);
        post.setPostType(dto.getPostType());
        post.setCategoryId(dto.getCategoryId());
        post.setTitle(dto.getTitle());
        post.setContent(dto.getContent());
        post.setVisibility(dto.getVisibility() != null ? dto.getVisibility() : "PUBLIC");
        post.setStatus("PUBLISHED");
        post.setLikeCount(0);
        post.setCommentCount(0);
        post.setViewCount(0);
        post.setShareCount(0);
        post.setIsTop(0);
        post.setIsEssence(0);
        post.setLocation(dto.getLocation());
        post.setMood(dto.getMood());
        post.setCreatedBy(userId);

        // 解析事件日期
        if (dto.getEventDate() != null && !dto.getEventDate().isEmpty()) {
            try {
                post.setEventDate(LocalDate.parse(dto.getEventDate()));
            } catch (DateTimeParseException e) {
                log.warn("事件日期格式错误: {}", dto.getEventDate());
            }
        }

        timelinePostMapper.insert(post);

        // 保存媒体文件
        if (dto.getMediaList() != null && !dto.getMediaList().isEmpty()) {
            saveMediaList(post.getId(), dto.getMediaList());
        }

        // 更新主页统计
        incrementProfilePostCount(userId);

        return buildPostDTO(post, userId);
    }

    /**
     * 获取动态列表（时间轴）
     */
    public PageDTO<PostDTO> getPostList(Long userId, Long categoryId,
                                        Integer year, Integer month,
                                        int page, int size, Long requesterId) {
        // 如果未指定userId，则查询当前用户
        Long queryUserId = userId != null ? userId : requesterId;

        // 分页查询
        Page<TimelinePost> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<TimelinePost> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TimelinePost::getUserId, queryUserId)
               .eq(TimelinePost::getStatus, "PUBLISHED")
               .eq(TimelinePost::getDeleted, 0);

        // 权限过滤：非作者只能查看PUBLIC内容
        if (!queryUserId.equals(requesterId)) {
            wrapper.eq(TimelinePost::getVisibility, "PUBLIC");
        }

        if (categoryId != null) {
            wrapper.eq(TimelinePost::getCategoryId, categoryId);
        }
        if (year != null) {
            wrapper.apply("YEAR(created_at) = {0}", year);
        }
        if (month != null) {
            wrapper.apply("MONTH(created_at) = {0}", month);
        }

        wrapper.orderByDesc(TimelinePost::getCreatedAt);
        Page<TimelinePost> result = timelinePostMapper.selectPage(pageParam, wrapper);

        // 构建响应
        List<PostDTO> records = result.getRecords().stream()
                .map(post -> buildPostDTO(post, requesterId))
                .collect(Collectors.toList());

        PageDTO<PostDTO> pageDTO = new PageDTO<>();
        pageDTO.setRecords(records);
        pageDTO.setTotal(result.getTotal());
        pageDTO.setPage((int) result.getCurrent());
        pageDTO.setSize((int) result.getSize());
        return pageDTO;
    }

    /**
     * 获取动态详情
     */
    public PostDTO getPostDetail(Long postId, Long requesterId) {
        TimelinePost post = timelinePostMapper.selectById(postId);
        if (post == null || post.getDeleted() == 1) {
            throw new BusinessException(ErrorCode.POST_NOT_FOUND, "动态不存在");
        }

        // 可见性校验
        checkPostVisibility(post, requesterId);

        return buildPostDTO(post, requesterId);
    }

    /**
     * 更新动态
     */
    @Transactional(rollbackFor = Exception.class)
    public PostDTO updatePost(Long postId, Long userId, PostCreateDTO dto) {
        TimelinePost post = timelinePostMapper.selectById(postId);
        if (post == null || post.getDeleted() == 1) {
            throw new BusinessException(ErrorCode.POST_NOT_FOUND, "动态不存在");
        }

        // 权限校验：仅作者可编辑
        if (!userId.equals(post.getUserId())) {
            throw new BusinessException(ErrorCode.POST_EDIT_DENIED, "无权编辑此动态");
        }

        // 更新字段
        if (dto.getPostType() != null) {
            post.setPostType(dto.getPostType());
        }
        if (dto.getCategoryId() != null) {
            post.setCategoryId(dto.getCategoryId());
        }
        if (dto.getTitle() != null) {
            post.setTitle(dto.getTitle());
        }
        if (dto.getContent() != null) {
            post.setContent(dto.getContent());
        }
        if (dto.getVisibility() != null) {
            post.setVisibility(dto.getVisibility());
        }
        post.setLocation(dto.getLocation());
        post.setMood(dto.getMood());
        post.setUpdatedBy(userId);

        timelinePostMapper.updateById(post);

        // 更新媒体：先删除旧的，再添加新的
        if (dto.getMediaList() != null) {
            deleteMediaByPostId(postId);
            if (!dto.getMediaList().isEmpty()) {
                saveMediaList(postId, dto.getMediaList());
            }
        }

        return buildPostDTO(post, userId);
    }

    /**
     * 删除动态（软删除）
     */
    @Transactional(rollbackFor = Exception.class)
    public void deletePost(Long postId, Long userId) {
        TimelinePost post = timelinePostMapper.selectById(postId);
        if (post == null || post.getDeleted() == 1) {
            throw new BusinessException(ErrorCode.POST_NOT_FOUND, "动态不存在");
        }

        // 权限校验：仅作者可删除
        if (!userId.equals(post.getUserId())) {
            throw new BusinessException(ErrorCode.POST_EDIT_DENIED, "无权删除此动态");
        }

        post.setDeleted(1);
        post.setStatus("DELETED");
        post.setUpdatedBy(userId);
        timelinePostMapper.updateById(post);

        // 更新主页统计
        decrementProfilePostCount(userId);
    }

    /**
     * 获取家族动态列表
     */
    public PageDTO<PostDTO> getFamilyPosts(int page, int size, Long requesterId) {
        // 获取请求者的家族ID
        User requester = userMapper.selectById(requesterId);
        if (requester == null || requester.getFamilyId() == null) {
            PageDTO<PostDTO> emptyPage = new PageDTO<>();
            emptyPage.setRecords(List.of());
            emptyPage.setTotal(0L);
            emptyPage.setPage(page);
            emptyPage.setSize(size);
            return emptyPage;
        }

        Page<TimelinePost> pageParam = new Page<>(page, size);

        // 查询同一家族且可见性为FAMILY的动态
        LambdaQueryWrapper<TimelinePost> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TimelinePost::getStatus, "PUBLISHED")
               .eq(TimelinePost::getDeleted, 0)
               .eq(TimelinePost::getVisibility, "FAMILY")
               .inSql(TimelinePost::getUserId,
                       "SELECT id FROM t_user WHERE family_id = " + requester.getFamilyId());

        wrapper.orderByDesc(TimelinePost::getCreatedAt);
        Page<TimelinePost> result = timelinePostMapper.selectPage(pageParam, wrapper);

        // 构建响应
        List<PostDTO> records = result.getRecords().stream()
                .map(post -> buildPostDTO(post, requesterId))
                .collect(Collectors.toList());

        PageDTO<PostDTO> pageDTO = new PageDTO<>();
        pageDTO.setRecords(records);
        pageDTO.setTotal(result.getTotal());
        pageDTO.setPage((int) result.getCurrent());
        pageDTO.setSize((int) result.getSize());

        return pageDTO;
    }

    /**
     * 可见性校验
     */
    private void checkPostVisibility(TimelinePost post, Long requesterId) {
        String visibility = post.getVisibility();
        if ("PUBLIC".equals(visibility)) {
            return;
        }
        if ("PRIVATE".equals(visibility)) {
            if (!requesterId.equals(post.getUserId())) {
                throw new BusinessException(ErrorCode.POST_VISIBILITY_DENIED, "动态可见性限制");
            }
            return;
        }
        // FAMILY/RELATIVE: 需要亲属关系判定，简化处理：同族谱可访问
        if (!requesterId.equals(post.getUserId())) {
            User requester = userMapper.selectById(requesterId);
            User owner = userMapper.selectById(post.getUserId());
            if (requester == null || owner == null ||
                !requester.getFamilyId().equals(owner.getFamilyId())) {
                throw new BusinessException(ErrorCode.POST_VISIBILITY_DENIED, "动态可见性限制");
            }
        }
    }

    /**
     * 构建PostDTO响应
     */
    private PostDTO buildPostDTO(TimelinePost post, Long requesterId) {
        User user = userMapper.selectById(post.getUserId());
        PostCategory category = null;
        if (post.getCategoryId() != null) {
            category = postCategoryMapper.selectById(post.getCategoryId());
        }

        // 查询媒体列表
        List<PostMediaDTO> mediaList = getMediaListByPostId(post.getId());

        // 查询点赞状态
        Boolean isLiked = false;
        if (requesterId != null) {
            LambdaQueryWrapper<LikeRecord> likeWrapper = new LambdaQueryWrapper<>();
            likeWrapper.eq(LikeRecord::getTargetType, "POST")
                       .eq(LikeRecord::getTargetId, post.getId())
                       .eq(LikeRecord::getUserId, requesterId)
                       .eq(LikeRecord::getStatus, "ACTIVE");
            isLiked = likeRecordMapper.selectCount(likeWrapper) > 0;
        }

        PostDTO.PostDTOBuilder builder = PostDTO.builder()
                .id(post.getId())
                .userId(post.getUserId())
                .userName(user != null ? user.getName() : null)
                .postType(post.getPostType())
                .categoryId(post.getCategoryId())
                .categoryName(category != null ? category.getName() : null)
                .title(post.getTitle())
                .content(post.getContent())
                .visibility(post.getVisibility())
                .mediaList(mediaList)
                .likeCount(post.getLikeCount())
                .commentCount(post.getCommentCount())
                .isLiked(isLiked)
                .createdAt(post.getCreatedAt())
                .updatedAt(post.getUpdatedAt());

        return builder.build();
    }

    /**
     * 保存媒体列表
     */
    private void saveMediaList(Long postId, List<PostMediaDTO> mediaList) {
        int sortOrder = 0;
        for (PostMediaDTO mediaDTO : mediaList) {
            PostMedia media = new PostMedia();
            media.setPostId(postId);
            media.setMediaType(mediaDTO.getType());
            media.setMediaUrl(mediaDTO.getUrl());
            media.setThumbUrl(mediaDTO.getThumbnailUrl());
            media.setWidth(mediaDTO.getWidth());
            media.setHeight(mediaDTO.getHeight());
            media.setFileSize(mediaDTO.getFileSize());
            media.setSortOrder(mediaDTO.getSortOrder() != null ? mediaDTO.getSortOrder() : sortOrder++);
            postMediaMapper.insert(media);
        }
    }

    /**
     * 根据动态ID查询媒体列表
     */
    private List<PostMediaDTO> getMediaListByPostId(Long postId) {
        LambdaQueryWrapper<PostMedia> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PostMedia::getPostId, postId)
               .eq(PostMedia::getDeleted, 0)
               .orderByAsc(PostMedia::getSortOrder);
        List<PostMedia> mediaList = postMediaMapper.selectList(wrapper);

        return mediaList.stream().map(media -> {
            PostMediaDTO dto = new PostMediaDTO();
            dto.setId(media.getId());
            dto.setType(media.getMediaType());
            dto.setUrl(media.getMediaUrl());
            dto.setThumbnailUrl(media.getThumbUrl());
            dto.setWidth(media.getWidth());
            dto.setHeight(media.getHeight());
            dto.setFileSize(media.getFileSize());
            dto.setSortOrder(media.getSortOrder());
            return dto;
        }).collect(Collectors.toList());
    }

    /**
     * 删除动态关联的媒体
     */
    private void deleteMediaByPostId(Long postId) {
        LambdaQueryWrapper<PostMedia> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PostMedia::getPostId, postId);
        postMediaMapper.delete(wrapper);
    }

    /**
     * 根据用户ID查询主页
     */
    private UserProfile getProfileByUserId(Long userId) {
        LambdaQueryWrapper<UserProfile> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserProfile::getUserId, userId).eq(UserProfile::getDeleted, 0);
        return userProfileMapper.selectOne(wrapper);
    }

    /**
     * 获取或创建用户主页（自动创建如果不存在）
     */
    private UserProfile getOrCreateProfile(Long userId) {
        UserProfile profile = getProfileByUserId(userId);
        if (profile != null) {
            return profile;
        }

        // 自动创建新主页
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.RESOURCE_NOT_FOUND, "用户不存在");
        }

        profile = new UserProfile();
        profile.setUserId(userId);
        profile.setSignature("这个人很懒，什么都没写");
        profile.setBackgroundUrl(null);
        profile.setVisitCount(0L);
        profile.setStatus(1);
        profile.setCreatedBy(userId);
        userProfileMapper.insert(profile);

        log.info("为用户 {} 自动创建主页成功", userId);
        return profile;
    }

    /**
     * 增加主页动态计数
     */
    private void incrementProfilePostCount(Long userId) {
        // 实际可通过异步更新，这里简化处理
    }

    /**
     * 减少主页动态计数
     */
    private void decrementProfilePostCount(Long userId) {
        // 实际可通过异步更新，这里简化处理
    }
}
