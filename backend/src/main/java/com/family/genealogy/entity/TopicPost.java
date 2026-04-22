package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 话题动态关联实体
 */
@Data
@TableName("t_topic_post")
public class TopicPost {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long topicId;

    private Long postId;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
