package com.family.genealogy.dto;

import lombok.Data;

/**
 * 留言请求DTO
 */
@Data
public class GuestbookRequest {
    /**
     * 留言板所有者成员ID
     */
    private Long ownerMemberId;

    /**
     * 父留言ID(用于回复)
     */
    private Long parentId;

    /**
     * 留言内容
     */
    private String content;
}
