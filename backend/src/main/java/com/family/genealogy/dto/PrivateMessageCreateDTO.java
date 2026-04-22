package com.family.genealogy.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 私信请求DTO
 */
@Data
public class PrivateMessageCreateDTO {

    @NotNull(message = "接收者ID不能为空")
    private Long receiverId;

    @NotBlank(message = "消息类型不能为空")
    private String msgType;

    @NotBlank(message = "消息内容不能为空")
    private String content;

    private String mediaUrl;
}
