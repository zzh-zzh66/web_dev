package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.dto.RelationshipDTO;
import com.family.genealogy.service.RelationshipService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * 关系控制器
 * 提供亲属关系查询接口
 */
@RestController
@RequestMapping("/api/v1/relationships")
public class RelationshipController {

    private final RelationshipService relationshipService;

    public RelationshipController(RelationshipService relationshipService) {
        this.relationshipService = relationshipService;
    }

    /**
     * 获取两个用户的关系
     * GET /api/v1/relationships/{userId}/to/{targetUserId}
     */
    @GetMapping("/{userId}/to/{targetUserId}")
    public Result<RelationshipDTO> getRelationship(@PathVariable Long userId,
                                                     @PathVariable Long targetUserId,
                                                     Authentication authentication) {
        // 权限校验：仅本人或同族谱成员可查询
        RelationshipDTO result = relationshipService.getRelationship(userId, targetUserId);
        return Result.success(result);
    }
}
