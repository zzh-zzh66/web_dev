package com.family.genealogy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GenealogyTreeDTO {

    private Long memberId;
    private String name;
    private String gender;
    private Integer generation;
    private List<GenealogyTreeDTO> children;
}
