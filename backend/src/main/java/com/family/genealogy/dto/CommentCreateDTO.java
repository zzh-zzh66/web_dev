package com.family.genealogy.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 评论发布请求DTO
 */
@Data
public class CommentCreateDTO {

    @NotBlank(message = "评论内容不能为空")
    private String content;

    private Long parentId;

    private Long replyToUserId;
}
