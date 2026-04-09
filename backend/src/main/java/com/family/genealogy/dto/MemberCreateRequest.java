package com.family.genealogy.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDate;

@Data
public class MemberCreateRequest {

    @NotBlank(message = "姓名不能为空")
    private String name;

    @NotBlank(message = "性别不能为空")
    private String gender;

    private LocalDate birthDate;

    private Integer generation;

    private String spouseName;

    private Long fatherId;

    private Long motherId;

    private String status;
}
