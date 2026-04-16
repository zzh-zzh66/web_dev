package com.family.genealogy.dto;

import lombok.Data;

import java.util.List;

/**
 * 创建评论请求DTO
 */
@Data
public class CommentCreateRequest {
    /**
     * 动态ID
     */
    private Long postId;

    /**
     * 父评论ID(用于回复)
     */
    private Long parentId;

    /**
     * 评论内容
     */
    private String content;

    /**
     * 被@的成员ID列表
     */
    private List<Long> mentionedMemberIds;
}
