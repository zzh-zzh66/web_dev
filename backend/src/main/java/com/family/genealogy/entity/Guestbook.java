package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 留言板实体类
 * 用于存储用户主页的留言记录
 */
@Data
@TableName("t_guestbook")
public class Guestbook {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 留言板所有者成员ID
     */
    private Long ownerMemberId;

    /**
     * 留言者用户ID
     */
    private Long userId;

    /**
     * 留言者成员ID
     */
    private Long memberId;

    /**
     * 父留言ID(用于回复嵌套)
     */
    private Long parentId;

    /**
     * 留言内容
     */
    private String content;

    /**
     * 状态: 1-正常, 0-已删除
     */
    private Integer status;

    /**
     * 留言时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
}
