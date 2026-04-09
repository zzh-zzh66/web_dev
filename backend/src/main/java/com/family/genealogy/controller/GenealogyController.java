package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.dto.GenealogyTreeDTO;
import com.family.genealogy.dto.MemberSimpleDTO;
import com.family.genealogy.service.GenealogyService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/genealogy")
public class GenealogyController {

    private final GenealogyService genealogyService;

    public GenealogyController(GenealogyService genealogyService) {
        this.genealogyService = genealogyService;
    }

    @GetMapping("/tree")
    public Result<GenealogyTreeDTO> getGenealogyTree(Authentication authentication,
                                                     @RequestParam(required = false) Long rootMemberId) {
        Long userId = (Long) authentication.getPrincipal();
        GenealogyTreeDTO tree = genealogyService.getGenealogyTree(userId, rootMemberId);
        return Result.success(tree);
    }

    @GetMapping("/{id}/descendants")
    public Result<List<MemberSimpleDTO>> getDescendants(Authentication authentication,
                                                         @PathVariable Long id) {
        Long userId = (Long) authentication.getPrincipal();
        List<MemberSimpleDTO> descendants = genealogyService.getDescendants(id);
        return Result.success(descendants);
    }

    @GetMapping("/{id}/ancestors")
    public Result<List<MemberSimpleDTO>> getAncestors(Authentication authentication,
                                                      @PathVariable Long id) {
        Long userId = (Long) authentication.getPrincipal();
        List<MemberSimpleDTO> ancestors = genealogyService.getAncestors(id);
        return Result.success(ancestors);
    }
}
