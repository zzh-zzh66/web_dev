package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.dto.*;
import com.family.genealogy.service.InteractionService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * 互动控制器
 * 提供评论、点赞、留言板等互动功能接口
 */
@RestController
@RequestMapping("/api/v1")
public class InteractionController {

    private final InteractionService interactionService;

    public InteractionController(InteractionService interactionService) {
        this.interactionService = interactionService;
    }

    /**
     * 发布评论
     * POST /api/v1/contents/{contentId}/comments
     */
    @PostMapping("/contents/{contentId}/comments")
    public Result<CommentDTO> createComment(@PathVariable Long contentId,
                                             Authentication authentication,
                                             @Valid @RequestBody CommentCreateDTO dto) {
        Long userId = (Long) authentication.getPrincipal();
        CommentDTO comment = interactionService.createComment(contentId, userId, dto);
        return Result.created("评论发布成功", comment);
    }

    /**
     * 获取评论列表
     * GET /api/v1/contents/{contentId}/comments
     */
    @GetMapping("/contents/{contentId}/comments")
    public Result<PageDTO<CommentDTO>> getComments(@PathVariable Long contentId,
                                                     @RequestParam(defaultValue = "1") int page,
                                                     @RequestParam(defaultValue = "20") int size,
                                                     Authentication authentication) {
        Long requesterId = (Long) authentication.getPrincipal();
        PageDTO<CommentDTO> result = interactionService.getComments(contentId, page, size, requesterId);
        return Result.success(result);
    }

    /**
     * 获取评论的回复列表
     * GET /api/v1/comments/{rootId}/replies
     */
    @GetMapping("/comments/{rootId}/replies")
    public Result<PageDTO<ReplyDTO>> getReplies(@PathVariable Long rootId,
                                                  @RequestParam(defaultValue = "1") int page,
                                                  @RequestParam(defaultValue = "20") int size,
                                                  Authentication authentication) {
        Long requesterId = (Long) authentication.getPrincipal();
        PageDTO<ReplyDTO> result = interactionService.getReplies(rootId, page, size, requesterId);
        return Result.success(result);
    }

    /**
     * 删除评论
     * DELETE /api/v1/comments/{commentId}
     */
    @DeleteMapping("/comments/{commentId}")
    public Result<Void> deleteComment(@PathVariable Long commentId,
                                       Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        interactionService.deleteComment(commentId, userId);
        return Result.success("评论删除成功");
    }

    /**
     * 切换点赞状态
     * POST /api/v1/likes
     */
    @PostMapping("/likes")
    public Result<LikeDTO> toggleLike(Authentication authentication,
                                       @Valid @RequestBody LikeRequestDTO dto) {
        Long userId = (Long) authentication.getPrincipal();
        LikeDTO result = interactionService.toggleLike(userId, dto.getTargetType(), dto.getTargetId());
        return Result.success(result);
    }

    /**
     * 发布留言
     * POST /api/v1/profiles/{userId}/guestbook
     */
    @PostMapping("/profiles/{userId}/guestbook")
    public Result<MessageBoardDTO> createGuestbook(@PathVariable Long userId,
                                                     Authentication authentication,
                                                     @Valid @RequestBody MessageBoardCreateDTO dto) {
        Long senderId = (Long) authentication.getPrincipal();
        MessageBoardDTO result = interactionService.createGuestbook(userId, senderId, dto);
        return Result.created("留言发布成功", result);
    }

    /**
     * 获取留言列表
     * GET /api/v1/profiles/{userId}/guestbook
     */
    @GetMapping("/profiles/{userId}/guestbook")
    public Result<PageDTO<MessageBoardDTO>> getGuestbookList(@PathVariable Long userId,
                                                               @RequestParam(defaultValue = "1") int page,
                                                               @RequestParam(defaultValue = "20") int size,
                                                               Authentication authentication) {
        Long requesterId = (Long) authentication.getPrincipal();
        PageDTO<MessageBoardDTO> result = interactionService.getGuestbookList(userId, page, size, requesterId);
        return Result.success(result);
    }

    /**
     * 删除留言
     * DELETE /api/v1/guestbook/{guestbookId}
     */
    @DeleteMapping("/guestbook/{guestbookId}")
    public Result<Void> deleteGuestbook(@PathVariable Long guestbookId,
                                         Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        interactionService.deleteGuestbook(guestbookId, userId);
        return Result.success("留言删除成功");
    }
}
