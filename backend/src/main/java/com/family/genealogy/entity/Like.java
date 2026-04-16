package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 点赞实体类
 * 用于存储用户对动态的点赞记录
 */
@Data
@TableName("t_like")
public class Like {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 被点赞的动态ID
     */
    private Long postId;

    /**
     * 点赞用户ID
     */
    private Long userId;

    /**
     * 点赞者成员ID
     */
    private Long memberId;

    /**
     * 状态: 1-有效, 0-已取消
     */
    private Integer status;

    /**
     * 点赞时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
}
