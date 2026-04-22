package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 隐私设置实体
 */
@Data
@TableName("t_privacy_setting")
public class PrivacySetting {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private String settingKey;

    private String settingValue;

    private String scope;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
