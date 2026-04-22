package com.family.genealogy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

/**
 * 通知响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDTO {

    private Long id;
    private Long fromUserId;
    private String fromUserName;
    private String fromUserAvatar;
    private String type;
    private String content;
    private String targetType;
    private Long targetId;
    private Boolean isRead;
    private LocalDateTime createdAt;
}
