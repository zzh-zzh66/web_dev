package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 留言板实体
 */
@Data
@TableName("t_message_board")
public class MessageBoard {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long ownerUserId;

    private Long senderId;

    private Long parentId;

    private String content;

    private Integer likeCount;

    private Integer replyCount;

    private String ipAddress;

    private Integer isHidden;

    private String status;

    private Long createdBy;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    private Integer deleted;
}
