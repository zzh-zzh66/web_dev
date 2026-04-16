package com.family.genealogy.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 通知DTO
 */
@Data
public class NotificationDTO {
    /**
     * 通知ID
     */
    private Long notificationId;

    /**
     * 通知类型
     */
    private String type;

    /**
     * 通知类型名称
     */
    private String typeName;

    /**
     * 通知标题
     */
    private String title;

    /**
     * 通知内容
     */
    private String content;

    /**
     * 触发者ID
     */
    private Long triggerUserId;

    /**
     * 触发者成员ID
     */
    private Long triggerMemberId;

    /**
     * 触发者姓名
     */
    private String triggerUserName;

    /**
     * 触发者头像
     */
    private String triggerUserAvatar;

    /**
     * 关联资源类型
     */
    private String resourceType;

    /**
     * 关联资源ID
     */
    private Long resourceId;

    /**
     * 是否已读
     */
    private Boolean isRead;

    /**
     * 通知时间
     */
    private LocalDateTime createdAt;
}
