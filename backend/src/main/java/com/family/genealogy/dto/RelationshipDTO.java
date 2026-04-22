package com.family.genealogy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 关系响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RelationshipDTO {

    private Boolean isRelative;

    private Boolean sameFamily;

    private String relationshipLabel;

    private Integer generationDiff;

    private String pathDescription;
}
