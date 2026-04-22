package com.family.genealogy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 未读数响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationUnreadCountDTO {

    private Long totalCount;

    private Long commentCount;

    private Long replyCount;

    private Long likeCount;

    private Long guestbookCount;

    private Long mentionCount;

    private Long messageCount;

    private Long systemCount;
}
