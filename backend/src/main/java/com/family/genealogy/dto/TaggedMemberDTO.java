package com.family.genealogy.dto;

import lombok.Data;

/**
 * 被标记成员DTO
 */
@Data
public class TaggedMemberDTO {
    /**
     * 成员ID
     */
    private Long memberId;

    /**
     * 成员姓名
     */
    private String name;
}
