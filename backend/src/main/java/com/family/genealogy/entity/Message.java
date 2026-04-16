package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 私信实体类
 * 用于存储用户间的私信记录
 */
@Data
@TableName("t_message")
public class Message {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 发送者用户ID
     */
    private Long senderId;

    /**
     * 发送者成员ID
     */
    private Long senderMemberId;

    /**
     * 接收者用户ID
     */
    private Long receiverId;

    /**
     * 接收者成员ID
     */
    private Long receiverMemberId;

    /**
     * 私信内容
     */
    private String content;

    /**
     * 发送者删除标志: 0-未删除, 1-已删除
     */
    private Integer senderDeleted;

    /**
     * 接收者删除标志: 0-未删除, 1-已删除
     */
    private Integer receiverDeleted;

    /**
     * 是否已读: 0-未读, 1-已读
     */
    private Integer isRead;

    /**
     * 发送时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
}
