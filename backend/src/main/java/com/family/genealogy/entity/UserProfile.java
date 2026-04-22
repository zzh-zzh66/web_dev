package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 用户主页档案实体
 */
@Data
@TableName("t_user_profile")
public class UserProfile {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private Long memberId;

    private String bio;

    private String backgroundUrl;

    private String signature;

    private String birthPlace;

    private String occupation;

    private String education;

    private String hometown;

    private String lifeEvents;

    private String statsJson;

    private Long visitCount;

    private String theme;

    private Integer status;

    private Long createdBy;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    private Long updatedBy;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    private Integer deleted;
}
