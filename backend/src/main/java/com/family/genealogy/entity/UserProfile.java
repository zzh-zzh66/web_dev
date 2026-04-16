package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户资料扩展实体类
 * 用于存储用户的个人主页扩展资料
 */
@Data
@TableName("t_user_profile")
public class UserProfile {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 关联成员ID
     */
    private Long memberId;

    /**
     * 主页封面图片URL
     */
    private String coverUrl;

    /**
     * 头像URL
     */
    private String avatarUrl;

    /**
     * 个人简介
     */
    private String bio;

    /**
     * 职业
     */
    private String occupation;

    /**
     * 出生地
     */
    private String birthPlace;

    /**
     * 现居地
     */
    private String currentPlace;

    /**
     * 兴趣爱好(JSON数组)
     */
    private String hobbies;

    /**
     * 个人成就(JSON数组)
     */
    private String achievements;

    /**
     * 人生座右铭
     */
    private String motto;

    /**
     * 电子邮箱
     */
    private String email;

    /**
     * 联系电话
     */
    private String phone;

    /**
     * 资料可见度: PUBLIC-公开, FAMILY-家族可见, RELATIVES-亲属可见, PRIVATE-仅自己
     */
    private String privacySetting;

    /**
     * 创建时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
}
