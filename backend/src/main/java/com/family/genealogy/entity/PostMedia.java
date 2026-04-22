package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 动态媒体实体
 */
@Data
@TableName("t_post_media")
public class PostMedia {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long postId;

    private String mediaType;

    private String mediaUrl;

    private String thumbUrl;

    private String originalName;

    private Long fileSize;

    private Integer width;

    private Integer height;

    private Integer duration;

    private Integer sortOrder;

    private Integer isCover;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    private Integer deleted;
}
