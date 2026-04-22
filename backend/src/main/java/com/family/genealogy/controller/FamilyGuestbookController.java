package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.dto.FamilyGuestbookDTO;
import com.family.genealogy.dto.PageDTO;
import com.family.genealogy.service.FamilyGuestbookService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * 家族留言板控制器
 */
@RestController
@RequestMapping("/api/v1/family")
public class FamilyGuestbookController {

    private final FamilyGuestbookService familyGuestbookService;

    public FamilyGuestbookController(FamilyGuestbookService familyGuestbookService) {
        this.familyGuestbookService = familyGuestbookService;
    }

    /**
     * 获取家族留言列表
     * GET /api/v1/family/guestbook
     */
    @GetMapping("/guestbook")
    public Result<PageDTO<FamilyGuestbookDTO>> getGuestbookList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication authentication) {
        Long requesterId = (Long) authentication.getPrincipal();
        PageDTO<FamilyGuestbookDTO> result = familyGuestbookService.getGuestbookList(page, size, requesterId);
        return Result.success(result);
    }

    /**
     * 发布家族留言
     * POST /api/v1/family/guestbook
     */
    @PostMapping("/guestbook")
    public Result<FamilyGuestbookDTO> createGuestbook(
            @Valid @RequestBody FamilyGuestbookDTO dto,
            Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        FamilyGuestbookDTO result = familyGuestbookService.createGuestbook(userId, dto);
        return Result.created("留言成功", result);
    }

    /**
     * 删除家族留言
     * DELETE /api/v1/family/guestbook/{id}
     */
    @DeleteMapping("/guestbook/{id}")
    public Result<Void> deleteGuestbook(
            @PathVariable Long id,
            Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        familyGuestbookService.deleteGuestbook(id, userId);
        return Result.success("删除成功");
    }
}
