package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 动态分类实体
 */
@Data
@TableName("t_post_category")
public class PostCategory {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private String name;

    private String code;

    private String icon;

    private String color;

    private String description;

    private Integer sortOrder;

    private Integer isSystem;

    private Integer postCount;

    private Integer status;

    private Long createdBy;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    private Long updatedBy;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    private Integer deleted;
}
