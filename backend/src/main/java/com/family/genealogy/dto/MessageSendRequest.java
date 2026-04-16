package com.family.genealogy.dto;

import lombok.Data;

/**
 * 发送私信请求DTO
 */
@Data
public class MessageSendRequest {
    /**
     * 接收者用户ID
     */
    private Long receiverId;

    /**
     * 私信内容
     */
    private String content;
}
