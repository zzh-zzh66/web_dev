package com.family.genealogy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

/**
 * 回复响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReplyDTO {

    private Long id;
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
}
