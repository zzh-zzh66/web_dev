package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 通知实体类
 * 用于存储用户的互动通知
 */
@Data
@TableName("t_notification")
public class Notification {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 通知接收者用户ID
     */
    private Long userId;

    /**
     * 通知接收者成员ID
     */
    private Long memberId;

    /**
     * 触发通知的用户ID
     */
    private Long triggerUserId;

    /**
     * 触发通知的成员ID
     */
    private Long triggerMemberId;

    /**
     * 通知类型: COMMENT-评论, REPLY-回复, LIKE-点赞, MESSAGE-私信, MENTION-@提及, BIRTHDAY-生日, ANNIVERSARY-纪念日
     */
    private String type;

    /**
     * 通知标题
     */
    private String title;

    /**
     * 通知内容
     */
    private String content;

    /**
     * 关联资源类型: post, comment, message
     */
    private String resourceType;

    /**
     * 关联资源ID
     */
    private Long resourceId;

    /**
     * 是否已读: 0-未读, 1-已读
     */
    private Integer isRead;

    /**
     * 通知时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
}
