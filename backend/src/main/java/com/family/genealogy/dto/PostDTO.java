package com.family.genealogy.dto;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 动态DTO
 */
@Data
public class PostDTO {
    /**
     * 动态ID
     */
    private Long postId;

    /**
     * 发布者成员ID
     */
    private Long memberId;

    /**
     * 发布者姓名
     */
    private String authorName;

    /**
     * 发布者头像
     */
    private String authorAvatar;

    /**
     * 发布者辈分
     */
    private Integer authorGeneration;

    /**
     * 发布者角色
     */
    private String authorRole;

    /**
     * 动态标题
     */
    private String title;

    /**
     * 动态内容
     */
    private String content;

    /**
     * 动态类型
     */
    private String postType;

    /**
     * 动态类型名称
     */
    private String postTypeName;

    /**
     * 事件日期
     */
    private LocalDate eventDate;

    /**
     * 事件地点
     */
    private String eventPlace;

    /**
     * 图片列表
     */
    private List<String> images;

    /**
     * 被标记的成员
     */
    private List<TaggedMemberDTO> taggedMembers;

    /**
     * 点赞数
     */
    private Integer likeCount;

    /**
     * 评论数
     */
    private Integer commentCount;

    /**
     * 浏览数
     */
    private Integer viewCount;

    /**
     * 是否已点赞
     */
    private Boolean isLiked;

    /**
     * 发布时间
     */
    private LocalDateTime createdAt;

    /**
     * 是否是自己的动态
     */
    private Boolean isSelf;
}
