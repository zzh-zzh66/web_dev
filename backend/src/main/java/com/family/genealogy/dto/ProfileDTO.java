package com.family.genealogy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

/**
 * 主页信息响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProfileDTO {

    private Long id;
    private Long userId;
    private Long memberId;
    private String name;
    private String gender;
    private Integer generation;
    private String familyName;
    private String backgroundUrl;
    private String signature;
    private ProfileStats stats;
    private String relationshipLabel;
    private Boolean isOwner;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProfileStats {
        private Long visitCount;
        private Integer contentCount;
        private Long likeCount;
        private Integer guestbookCount;
    }
}
