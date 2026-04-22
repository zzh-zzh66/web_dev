package com.family.genealogy.dto;

import lombok.Data;

/**
 * 主页更新请求DTO
 */
@Data
public class ProfileUpdateDTO {

    private String backgroundUrl;

    private String signature;

    private String bio;

    private String birthPlace;

    private String occupation;

    private String education;

    private String hometown;

    private String theme;

    private String avatarUrl;
}
