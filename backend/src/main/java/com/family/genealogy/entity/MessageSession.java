package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 私信会话实体
 */
@Data
@TableName("t_message_session")
public class MessageSession {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String sessionKey;

    private Long userId1;

    private Long userId2;

    private String lastMessage;

    private LocalDateTime lastMessageTime;

    private Integer unreadCount1;

    private Integer unreadCount2;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
