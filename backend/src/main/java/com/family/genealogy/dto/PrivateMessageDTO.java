package com.family.genealogy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

/**
 * 私信响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PrivateMessageDTO {

    private Long id;
    private Long sessionId;
    private Long senderId;
    private String senderName;
    private Long receiverId;
    private String msgType;
    private String content;
    private String mediaUrl;
    private Boolean isRead;
    private LocalDateTime createdAt;
}
