package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.dto.FamilyGuestbookDTO;
import com.family.genealogy.dto.PageDTO;
import com.family.genealogy.service.FamilyGuestbookService;
import com.family.genealogy.service.NotificationService;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * 家族留言板控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/family")
public class FamilyGuestbookController {

    private final FamilyGuestbookService familyGuestbookService;
    private final ObjectProvider<NotificationService> notificationServiceProvider;

    public FamilyGuestbookController(FamilyGuestbookService familyGuestbookService,
                                     ObjectProvider<NotificationService> notificationServiceProvider) {
        this.familyGuestbookService = familyGuestbookService;
        this.notificationServiceProvider = notificationServiceProvider;
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
        log.info("=== FamilyGuestbookController.createGuestbook 被调用 === userId={}, content={}", userId, dto.getContent());
        FamilyGuestbookDTO result = familyGuestbookService.createGuestbook(userId, dto);
        return Result.created("留言成功", result);
    }

    /**
     * 测试通知功能（临时）
     * POST /api/v1/family/test-notification
     */
    @PostMapping("/test-notification")
    public Result<Void> testNotification(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        log.info("=== 测试通知接口被调用 === userId={}", userId);
        NotificationService notificationService = notificationServiceProvider.getObject();
        notificationService.createNotification(
            userId,
            "GUESTBOOK",
            "FAMILY_GUESTBOOK",
            1L,
            userId,
            "测试通知内容"
        );
        return Result.success("测试通知已发送");
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
