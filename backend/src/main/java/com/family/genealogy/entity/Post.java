package com.family.genealogy.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 动态实体类
 * 用于存储用户发布的动态内容
 */
@Data
@TableName("t_post")
public class Post {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 发布者成员ID
     */
    private Long memberId;

    /**
     * 发布者用户ID
     */
    private Long authorUserId;

    /**
     * 动态标题
     */
    private String title;

    /**
     * 动态正文内容
     */
    private String content;

    /**
     * 动态类型: LIFE_EVENT-人生大事, MILESTONE-里程碑, MEMORY-回忆分享, THOUGHT-心得感悟, DAILY-日常分享
     */
    private String postType;

    /**
     * 事件发生日期
     */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate eventDate;

    /**
     * 事件发生地点
     */
    private String eventPlace;

    /**
     * 图片URL列表(JSON数组)
     */
    private String images;

    /**
     * 被标记的成员ID列表(JSON数组)
     */
    private String taggedMembers;

    /**
     * 可见范围: PUBLIC-公开, FAMILY-家族可见, RELATIVES-亲属可见, PRIVATE-仅自己
     */
    private String visibility;

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
     * 状态: 1-正常, 0-已删除
     */
    private Integer status;

    /**
     * 创建时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
}
