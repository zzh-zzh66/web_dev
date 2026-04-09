package com.family.genealogy.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class MemberUpdateRequest {

    private String name;
    private String gender;
    private LocalDate birthDate;
    private LocalDate deathDate;
    private Integer generation;
    private String spouseName;
    private Long fatherId;
    private Long motherId;
    private String status;
    private String occupation;
}
