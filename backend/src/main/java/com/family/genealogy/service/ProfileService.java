package com.family.genealogy.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.family.genealogy.common.ErrorCode;
import com.family.genealogy.dto.ProfileDTO;
import com.family.genealogy.dto.ProfileUpdateDTO;
import com.family.genealogy.entity.Member;
import com.family.genealogy.entity.User;
import com.family.genealogy.entity.UserProfile;
import com.family.genealogy.exception.BusinessException;
import com.family.genealogy.mapper.MemberMapper;
import com.family.genealogy.mapper.UserMapper;
import com.family.genealogy.mapper.UserProfileMapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * 个人主页服务
 * 负责主页信息的查询、更新、自动创建和统计
 */
@Slf4j
@Service
public class ProfileService {

    private final UserProfileMapper userProfileMapper;
    private final UserMapper userMapper;
    private final MemberMapper memberMapper;
    private final ObjectMapper objectMapper;

    public ProfileService(UserProfileMapper userProfileMapper, UserMapper userMapper,
                          MemberMapper memberMapper, ObjectMapper objectMapper) {
        this.userProfileMapper = userProfileMapper;
        this.userMapper = userMapper;
        this.memberMapper = memberMapper;
        this.objectMapper = objectMapper;
    }

    /**
     * 获取主页信息
     * @param userId 目标用户ID
     * @param requesterId 请求者用户ID（用于权限校验和关系标签）
     */
    public ProfileDTO getProfile(Long userId, Long requesterId) {
        // 确保主页存在
        createProfileIfNotExists(userId);

        UserProfile profile = getProfileByUserId(userId);
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.PROFILE_NOT_FOUND, "用户不存在");
        }

        // 构建响应
        ProfileDTO.ProfileStats stats = buildStats(profile);

        // 获取关系标签（访问他人主页时）
        String relationshipLabel = null;
        if (!userId.equals(requesterId)) {
            relationshipLabel = getRelationshipLabel(requesterId, userId);
        }

        // 获取成员信息
        Member member = null;
        if (profile.getMemberId() != null) {
            member = memberMapper.selectById(profile.getMemberId());
        }

        return ProfileDTO.builder()
                .id(profile.getId())
                .userId(user.getId())
                .memberId(profile.getMemberId())
                .name(user.getName())
                .gender(member != null ? member.getGender() : null)
                .generation(member != null ? member.getGeneration() : null)
                .familyName(null) // 可通过familyId查询
                .backgroundUrl(profile.getBackgroundUrl())
                .signature(profile.getSignature())
                .stats(stats)
                .relationshipLabel(relationshipLabel)
                .isOwner(userId.equals(requesterId))
                .createdAt(profile.getCreatedAt())
                .updatedAt(profile.getUpdatedAt())
                .build();
    }

    /**
     * 更新主页信息
     */
    @Transactional(rollbackFor = Exception.class)
    public ProfileDTO updateProfile(Long userId, ProfileUpdateDTO dto) {
        UserProfile profile = getProfileByUserId(userId);
        if (profile == null) {
            throw new BusinessException(ErrorCode.PROFILE_NOT_FOUND, "主页不存在");
        }

        // 权限校验：仅本人可编辑
        if (!userId.equals(profile.getUserId())) {
            throw new BusinessException(ErrorCode.PROFILE_EDIT_DENIED, "无权编辑此主页");
        }

        // 更新字段
        if (dto.getBackgroundUrl() != null) {
            profile.setBackgroundUrl(dto.getBackgroundUrl());
        }
        if (dto.getSignature() != null) {
            profile.setSignature(dto.getSignature());
        }
        if (dto.getBio() != null) {
            profile.setBio(dto.getBio());
        }
        if (dto.getBirthPlace() != null) {
            profile.setBirthPlace(dto.getBirthPlace());
        }
        if (dto.getOccupation() != null) {
            profile.setOccupation(dto.getOccupation());
        }
        if (dto.getEducation() != null) {
            profile.setEducation(dto.getEducation());
        }
        if (dto.getHometown() != null) {
            profile.setHometown(dto.getHometown());
        }
        if (dto.getTheme() != null) {
            profile.setTheme(dto.getTheme());
        }

        // 如果提供了头像URL，同时更新用户表
        if (dto.getAvatarUrl() != null) {
            User user = userMapper.selectById(userId);
            if (user != null) {
                user.setAvatarUrl(dto.getAvatarUrl());
                userMapper.updateById(user);
            }
        }

        profile.setUpdatedBy(userId);
        userProfileMapper.updateById(profile);

        return getProfile(userId, userId);
    }

    /**
     * 自动创建主页（用户首次访问时）
     */
    @Transactional(rollbackFor = Exception.class)
    public void createProfileIfNotExists(Long userId) {
        LambdaQueryWrapper<UserProfile> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserProfile::getUserId, userId).eq(UserProfile::getDeleted, 0);
        UserProfile existing = userProfileMapper.selectOne(wrapper);
        if (existing != null) {
            return;
        }

        // 查询用户关联的成员信息
        User user = userMapper.selectById(userId);
        if (user == null) {
            return;
        }

        Long memberId = null;
        LambdaQueryWrapper<Member> memberWrapper = new LambdaQueryWrapper<>();
        // 这里可以根据实际业务逻辑查询成员关联
        // 暂时不自动关联成员

        // 创建新主页
        UserProfile profile = new UserProfile();
        profile.setUserId(userId);
        profile.setMemberId(memberId);
        profile.setVisitCount(0L);
        profile.setStatus(1);
        profile.setTheme("default");
        profile.setCreatedBy(userId);
        userProfileMapper.insert(profile);

        log.info("为用户 {} 自动创建主页", userId);
    }

    /**
     * 获取主页统计数据
     */
    public ProfileDTO.ProfileStats getProfileStats(Long userId) {
        UserProfile profile = getProfileByUserId(userId);
        if (profile == null) {
            throw new BusinessException(ErrorCode.PROFILE_NOT_FOUND, "主页不存在");
        }
        return buildStats(profile);
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
     * 构建统计数据
     */
    private ProfileDTO.ProfileStats buildStats(UserProfile profile) {
        return ProfileDTO.ProfileStats.builder()
                .visitCount(profile.getVisitCount() != null ? profile.getVisitCount() : 0L)
                .contentCount(0) // TODO: 从TimelinePost统计
                .likeCount(0L) // TODO: 从LikeRecord统计
                .guestbookCount(0) // TODO: 从MessageBoard统计
                .build();
    }

    /**
     * 获取关系标签
     */
    private String getRelationshipLabel(Long requesterId, Long targetUserId) {
        // 复用MemberService的族谱查询逻辑
        // 这里简化处理，实际应调用RelationshipService
        return null;
    }
}
