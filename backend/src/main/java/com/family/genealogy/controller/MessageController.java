package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.dto.MessageSessionDTO;
import com.family.genealogy.dto.PageDTO;
import com.family.genealogy.dto.PrivateMessageCreateDTO;
import com.family.genealogy.dto.PrivateMessageDTO;
import com.family.genealogy.service.MessageService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * 私信控制器
 * 提供私信会话管理、消息收发、已读标记接口
 */
@RestController
@RequestMapping("/api/v1/messages")
public class MessageController {

    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    /**
     * 获取私信会话列表
     * GET /api/v1/messages/sessions
     */
    @GetMapping("/sessions")
    public Result<PageDTO<MessageSessionDTO>> getMessageSessions(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        PageDTO<MessageSessionDTO> result = messageService.getMessageSessions(userId, page, size);
        return Result.success(result);
    }

    /**
     * 获取私信会话消息
     * GET /api/v1/messages/sessions/{sessionId}
     */
    @GetMapping("/sessions/{sessionId}")
    public Result<PageDTO<PrivateMessageDTO>> getSessionMessages(@PathVariable Long sessionId,
                                                                   @RequestParam(defaultValue = "1") int page,
                                                                   @RequestParam(defaultValue = "50") int size,
                                                                   Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        PageDTO<PrivateMessageDTO> result = messageService.getSessionMessages(sessionId, page, size, userId);
        return Result.success(result);
    }

    /**
     * 发送私信
     * POST /api/v1/messages
     */
    @PostMapping
    public Result<PrivateMessageDTO> createMessage(Authentication authentication,
                                                     @Valid @RequestBody PrivateMessageCreateDTO dto) {
        Long senderId = (Long) authentication.getPrincipal();
        PrivateMessageDTO result = messageService.createMessage(senderId, dto);
        return Result.created("消息发送成功", result);
    }

    /**
     * 标记消息已读
     * PUT /api/v1/messages/sessions/{sessionId}/read
     */
    @PutMapping("/sessions/{sessionId}/read")
    public Result<Void> markSessionRead(@PathVariable Long sessionId,
                                         Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        messageService.markSessionRead(sessionId, userId);
        return Result.success("已标记为已读");
    }
}
