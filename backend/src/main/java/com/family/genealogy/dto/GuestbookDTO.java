package com.family.genealogy.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 留言DTO
 */
@Data
public class GuestbookDTO {
    /**
     * 留言ID
     */
    private Long guestbookId;

    /**
     * 留言板所有者ID
     */
    private Long ownerMemberId;

    /**
     * 留言者ID
     */
    private Long userId;

    /**
     * 留言者成员ID
     */
    private Long memberId;

    /**
     * 留言者姓名
     */
    private String userName;

    /**
     * 留言者头像
     */
    private String userAvatar;

    /**
     * 留言者辈分
     */
    private Integer userGeneration;

    /**
     * 亲属关系标签
     */
    private String relationTag;

    /**
     * 父留言ID
     */
    private Long parentId;

    /**
     * 留言内容
     */
    private String content;

    /**
     * 留言时间
     */
    private LocalDateTime createdAt;

    /**
     * 子留言列表
     */
    private java.util.List<GuestbookDTO> replies;
}
