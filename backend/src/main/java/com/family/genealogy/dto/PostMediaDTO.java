package com.family.genealogy.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 媒体信息DTO
 */
@Data
public class PostMediaDTO {

    private Long id;

    @NotBlank(message = "媒体类型不能为空")
    private String type;

    @NotBlank(message = "媒体URL不能为空")
    private String url;

    private String thumbnailUrl;

    private Integer width;

    private Integer height;

    private Long fileSize;

    private Integer sortOrder;
}
