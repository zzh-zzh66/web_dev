package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.dto.NotificationDTO;
import com.family.genealogy.dto.NotificationUnreadCountDTO;
import com.family.genealogy.dto.PageDTO;
import com.family.genealogy.service.NotificationService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * 通知控制器
 * 提供通知查询、已读标记、未读统计接口
 */
@RestController
@RequestMapping("/api/v1/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    /**
     * 获取通知列表
     * GET /api/v1/notifications
     */
    @GetMapping
    public Result<PageDTO<NotificationDTO>> getNotifications(
            @RequestParam(required = false) String type,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        PageDTO<NotificationDTO> result = notificationService.getNotifications(userId, type, page, size);
        return Result.success(result);
    }

    /**
     * 获取未读通知数量
     * GET /api/v1/notifications/unread-count
     */
    @GetMapping("/unread-count")
    public Result<NotificationUnreadCountDTO> getUnreadCount(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        NotificationUnreadCountDTO result = notificationService.getUnreadCount(userId);
        return Result.success(result);
    }

    /**
     * 标记通知已读
     * PUT /api/v1/notifications/{notificationId}/read
     */
    @PutMapping("/{notificationId}/read")
    public Result<Void> markRead(@PathVariable Long notificationId,
                                  Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        notificationService.markRead(notificationId, userId);
        return Result.success("已标记为已读");
    }

    /**
     * 全部标记已读
     * PUT /api/v1/notifications/read-all
     */
    @PutMapping("/read-all")
    public Result<Void> markAllRead(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        notificationService.markAllRead(userId);
        return Result.success("全部已标记为已读");
    }
}
