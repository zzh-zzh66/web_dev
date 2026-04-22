package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 私信实体
 */
@Data
@TableName("t_private_message")
public class PrivateMessage {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long sessionId;

    private Long senderId;

    private Long receiverId;

    private String content;

    private String msgType;

    private String mediaUrl;

    private Integer isRead;

    private LocalDateTime readAt;

    private Integer status;

    private Long createdBy;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    private Integer deleted;

    private Integer receiverDeleted;
}
