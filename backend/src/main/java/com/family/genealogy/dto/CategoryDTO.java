package com.family.genealogy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 分类响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CategoryDTO {

    private Long id;

    private String name;

    private String code;

    private String icon;

    private String color;

    private String description;

    private Integer sortOrder;

    private Boolean isSystem;

    private Integer postCount;
}
