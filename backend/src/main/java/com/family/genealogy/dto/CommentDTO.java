package com.family.genealogy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 评论响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CommentDTO {

    private Long id;
    private String targetType;
    private Long targetId;
    private Long userId;
    private String userName;
    private String userAvatar;
    private String content;
    private Long parentId;
    private Long rootId;
    private Long replyToUserId;
    private String replyToUserName;
    private Integer depth;
    private Integer likeCount;
    private Boolean isLiked;
    private LocalDateTime createdAt;
    private List<ReplyDTO> replies;
    private Integer replyCount;
}
