package com.family.genealogy.dto;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

/**
 * 创建动态请求DTO
 */
@Data
public class PostCreateRequest {
    /**
     * 成员ID
     */
    private Long memberId;

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
     * 事件日期
     */
    private LocalDate eventDate;

    /**
     * 事件地点
     */
    private String eventPlace;

    /**
     * 图片URL列表
     */
    private List<String> images;

    /**
     * 被标记的成员ID列表
     */
    private List<Long> taggedMemberIds;

    /**
     * 可见范围
     */
    private String visibility;
}
