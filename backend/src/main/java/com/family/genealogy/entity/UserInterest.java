package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 用户兴趣实体
 */
@Data
@TableName("t_user_interest")
public class UserInterest {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private String interestTag;

    private Integer interestLevel;

    private Integer sortOrder;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    private Integer deleted;
}
