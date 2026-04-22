package com.family.genealogy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 点赞响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LikeDTO {

    private String action;

    private Integer likeCount;

    private Boolean isLiked;
}
