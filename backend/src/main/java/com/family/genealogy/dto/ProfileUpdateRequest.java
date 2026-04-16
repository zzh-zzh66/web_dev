package com.family.genealogy.dto;

import lombok.Data;

import java.util.List;

/**
 * 更新个人资料请求DTO
 */
@Data
public class ProfileUpdateRequest {
    /**
     * 头像URL
     */
    private String avatarUrl;

    /**
     * 封面URL
     */
    private String coverUrl;

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
     * 电子邮箱
     */
    private String email;

    /**
     * 联系电话
     */
    private String phone;

    /**
     * 隐私设置
     */
    private String privacySetting;
}
