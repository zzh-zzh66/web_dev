package com.family.genealogy.dto;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 个人主页DTO
 */
@Data
public class ProfileDTO {
    /**
     * 成员ID
     */
    private Long memberId;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 姓名
     */
    private String name;

    /**
     * 性别
     */
    private String gender;

    /**
     * 辈分
     */
    private Integer generation;

    /**
     * 角色
     */
    private String role;

    /**
     * 出生日期
     */
    private LocalDate birthDate;

    /**
     * 职业
     */
    private String occupation;

    /**
     * 出生地
     */
    private String birthPlace;

    /**
     * 个人简介
     */
    private String bio;

    /**
     * 头像URL
     */
    private String avatarUrl;

    /**
     * 封面URL
     */
    private String coverUrl;

    /**
     * 现居地
     */
    private String currentPlace;

    /**
     * 兴趣爱好
     */
    private List<String> hobbies;

    /**
     * 个人成就
     */
    private List<String> achievements;

    /**
     * 座右铭
     */
    private String motto;

    /**
     * 动态数量
     */
    private Integer postCount;

    /**
     * 粉丝数量
     */
    private Integer fanCount;

    /**
     * 亲属关系标签
     */
    private String relationTag;

    /**
     * 是否已关注
     */
    private Boolean isFollowing;

    /**
     * 是否是自己
     */
    private Boolean isSelf;
}
