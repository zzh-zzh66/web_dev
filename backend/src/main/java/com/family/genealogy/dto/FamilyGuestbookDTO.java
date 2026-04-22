package com.family.genealogy.dto;

import lombok.Data;

@Data
public class FamilyGuestbookDTO {

    private Long id;

    private Long userId;

    private String userName;

    private String userAvatar;

    private String content;

    private String createdAt;
}
