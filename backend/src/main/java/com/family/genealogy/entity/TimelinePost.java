package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 时间轴动态实体
 */
@Data
@TableName("t_timeline_post")
public class TimelinePost {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private Long memberId;

    private Long categoryId;

    private String postType;

    private String title;

    private String content;

    private LocalDate eventDate;

    private String visibility;

    private String status;

    private Integer likeCount;

    private Integer commentCount;

    private Integer viewCount;

    private Integer shareCount;

    private Integer isTop;

    private Integer isEssence;

    private String location;

    private String mood;

    private String ipAddress;

    private Long createdBy;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    private Long updatedBy;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    private Integer deleted;
}
