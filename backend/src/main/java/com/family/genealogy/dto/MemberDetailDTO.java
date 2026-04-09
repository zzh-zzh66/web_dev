package com.family.genealogy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MemberDetailDTO {

    private Long memberId;
    private String name;
    private String gender;
    private LocalDate birthDate;
    private LocalDate deathDate;
    private Integer generation;
    private String spouseName;
    private Long fatherId;
    private String fatherName;
    private Long motherId;
    private String motherName;
    private String status;
    private String occupation;
}
