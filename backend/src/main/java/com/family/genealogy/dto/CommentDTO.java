package com.family.genealogy.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 评论DTO
 */
@Data
public class CommentDTO {
    /**
     * 评论ID
     */
    private Long commentId;

    /**
     * 所属动态ID
     */
    private Long postId;

    /**
     * 父评论ID
     */
    private Long parentId;

    /**
     * 评论者ID
     */
    private Long userId;

    /**
     * 评论者成员ID
     */
    private Long memberId;

    /**
     * 评论者姓名
     */
    private String userName;

    /**
     * 评论者头像
     */
    private String userAvatar;

    /**
     * 评论者辈分
     */
    private Integer userGeneration;

    /**
     * 亲属关系标签
     */
    private String relationTag;

    /**
     * 评论内容
     */
    private String content;

    /**
     * 被@的成员
     */
    private String mentionedMembers;

    /**
     * 回复数量
     */
    private Integer replyCount;

    /**
     * 点赞数
     */
    private Integer likeCount;

    /**
     * 评论时间
     */
    private LocalDateTime createdAt;

    /**
     * 子评论列表
     */
    private java.util.List<CommentDTO> replies;
}
