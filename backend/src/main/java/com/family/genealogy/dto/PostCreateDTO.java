package com.family.genealogy.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import java.util.List;

/**
 * 动态发布请求DTO
 */
@Data
public class PostCreateDTO {

    @NotBlank(message = "内容类型不能为空")
    private String postType;

    private Long categoryId;

    @Size(max = 200, message = "标题不能超过200字符")
    private String title;

    @NotBlank(message = "内容不能为空")
    private String content;

    private String visibility;

    private List<PostMediaDTO> mediaList;

    private String eventDate;

    private String location;

    private String mood;
}
