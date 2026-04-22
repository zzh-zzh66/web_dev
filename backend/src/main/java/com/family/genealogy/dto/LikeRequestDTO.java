package com.family.genealogy.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 点赞请求DTO
 */
@Data
public class LikeRequestDTO {

    @NotBlank(message = "点赞目标类型不能为空")
    private String targetType;

    private Long targetId;
}
