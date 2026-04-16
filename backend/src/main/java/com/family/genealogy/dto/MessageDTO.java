package com.family.genealogy.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 私信DTO
 */
@Data
public class MessageDTO {
    /**
     * 私信ID
     */
    private Long messageId;

    /**
     * 发送者ID
     */
    private Long senderId;

    /**
     * 发送者成员ID
     */
    private Long senderMemberId;

    /**
     * 发送者姓名
     */
    private String senderName;

    /**
     * 发送者头像
     */
    private String senderAvatar;

    /**
     * 接收者ID
     */
    private Long receiverId;

    /**
     * 接收者成员ID
     */
    private Long receiverMemberId;

    /**
     * 接收者姓名
     */
    private String receiverName;

    /**
     * 接收者头像
     */
    private String receiverAvatar;

    /**
     * 私信内容
     */
    private String content;

    /**
     * 是否已读
     */
    private Boolean isRead;

    /**
     * 发送时间
     */
    private LocalDateTime createdAt;

    /**
     * 是否是自己发送的
     */
    private Boolean isSelf;
}
