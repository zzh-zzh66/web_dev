package com.family.genealogy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 动态响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostDTO {

    private Long id;
    private Long profileId;
    private Long userId;
    private String userName;
    private String userAvatar;
    private String postType;
    private Long categoryId;
    private String categoryName;
    private String title;
    private String content;
    private String visibility;
    private List<PostMediaDTO> mediaList;
    private Integer likeCount;
    private Integer commentCount;
    private Boolean isLiked;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String relationshipLabel;
}
