package com.family.genealogy.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 留言请求DTO
 */
@Data
public class MessageBoardCreateDTO {

    @NotBlank(message = "留言内容不能为空")
    private String content;
}
