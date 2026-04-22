package com.family.genealogy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 话题响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TopicDTO {

    private Long id;

    private String name;

    private String code;

    private String description;

    private String icon;

    private String coverUrl;

    private Integer postCount;

    private Integer participantCount;
}
