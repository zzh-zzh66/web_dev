package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 评论实体类
 * 用于存储动态的评论内容
 */
@Data
@TableName("t_comment")
public class Comment {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 所属动态ID
     */
    private Long postId;

    /**
     * 父评论ID(用于回复嵌套, NULL为顶级评论)
     */
    private Long parentId;

    /**
     * 评论者用户ID
     */
    private Long userId;

    /**
     * 评论者成员ID
     */
    private Long memberId;

    /**
     * 评论内容
     */
    private String content;

    /**
     * 被@的成员ID列表(JSON数组)
     */
    private String mentionedMembers;

    /**
     * 状态: 1-正常, 0-已删除
     */
    private Integer status;

    /**
     * 创建时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
}
