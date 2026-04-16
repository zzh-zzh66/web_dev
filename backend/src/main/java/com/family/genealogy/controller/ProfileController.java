package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.dto.*;
import com.family.genealogy.service.ProfileService;
import com.family.genealogy.util.JwtUtils;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 个人主页控制器
 */
@RestController
@RequestMapping("/api/v1/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;
    private final JwtUtils jwtUtils;

    /**
     * 获取个人主页信息
     */
    @GetMapping("/{memberId}")
    public Result<ProfileDTO> getProfile(@PathVariable Long memberId, HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        ProfileDTO profile = profileService.getProfile(memberId, currentUserId);
        return Result.success(profile);
    }

    /**
     * 获取用户动态列表
     */
    @GetMapping("/{memberId}/posts")
    public Result<PageDTO<PostDTO>> getUserPosts(
            @PathVariable Long memberId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        PageDTO<PostDTO> posts = profileService.getUserPosts(memberId, currentUserId, page, size);
        return Result.success(posts);
    }

    /**
     * 更新个人资料
     */
    @PutMapping
    public Result<Void> updateProfile(@RequestBody ProfileUpdateRequest profileRequest, HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        profileService.updateProfile(profileRequest, currentUserId);
        return Result.success(null);
    }

    /**
     * 发布动态
     */
    @PostMapping("/posts")
    public Result<Long> createPost(@RequestBody PostCreateRequest postRequest, HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        Long postId = profileService.createPost(postRequest, currentUserId);
        return Result.success(postId);
    }

    /**
     * 获取动态详情
     */
    @GetMapping("/posts/{postId}")
    public Result<PostDTO> getPostDetail(@PathVariable Long postId, HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        PostDTO post = profileService.getPostDetail(postId, currentUserId);
        return Result.success(post);
    }

    /**
     * 删除动态
     */
    @DeleteMapping("/posts/{postId}")
    public Result<Void> deletePost(@PathVariable Long postId, HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        profileService.deletePost(postId, currentUserId);
        return Result.success(null);
    }

    /**
     * 点赞动态
     */
    @PostMapping("/posts/{postId}/like")
    public Result<Void> likePost(@PathVariable Long postId, HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        profileService.likePost(postId, currentUserId);
        return Result.success(null);
    }

    /**
     * 取消点赞
     */
    @DeleteMapping("/posts/{postId}/like")
    public Result<Void> unlikePost(@PathVariable Long postId, HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        profileService.unlikePost(postId, currentUserId);
        return Result.success(null);
    }

    /**
     * 评论动态
     */
    @PostMapping("/posts/{postId}/comments")
    public Result<Long> createComment(
            @PathVariable Long postId,
            @RequestBody CommentCreateRequest commentRequest,
            HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        commentRequest.setPostId(postId);
        Long commentId = profileService.createComment(commentRequest, currentUserId);
        return Result.success(commentId);
    }

    /**
     * 获取动态评论列表
     */
    @GetMapping("/posts/{postId}/comments")
    public Result<List<CommentDTO>> getPostComments(@PathVariable Long postId) {
        List<CommentDTO> comments = profileService.getPostComments(postId);
        return Result.success(comments);
    }

    /**
     * 获取留言板
     */
    @GetMapping("/members/{memberId}/guestbook")
    public Result<List<GuestbookDTO>> getGuestbook(@PathVariable Long memberId) {
        List<GuestbookDTO> guestbooks = profileService.getGuestbook(memberId);
        return Result.success(guestbooks);
    }

    /**
     * 添加留言
     */
    @PostMapping("/members/{memberId}/guestbook")
    public Result<Long> createGuestbook(
            @PathVariable Long memberId,
            @RequestBody GuestbookRequest guestbookRequest,
            HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        guestbookRequest.setOwnerMemberId(memberId);
        Long guestbookId = profileService.createGuestbook(guestbookRequest, currentUserId);
        return Result.success(guestbookId);
    }

    /**
     * 删除留言
     */
    @DeleteMapping("/guestbook/{guestbookId}")
    public Result<Void> deleteGuestbook(@PathVariable Long guestbookId, HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        profileService.deleteGuestbook(guestbookId, currentUserId);
        return Result.success(null);
    }

    /**
     * 获取私信列表
     */
    @GetMapping("/messages")
    public Result<PageDTO<MessageDTO>> getMessages(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size,
            HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        PageDTO<MessageDTO> messages = profileService.getMessages(currentUserId, page, size);
        return Result.success(messages);
    }

    /**
     * 发送私信
     */
    @PostMapping("/messages")
    public Result<Long> sendMessage(@RequestBody MessageSendRequest messageRequest, HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        Long messageId = profileService.sendMessage(messageRequest, currentUserId);
        return Result.success(messageId);
    }

    /**
     * 获取通知列表
     */
    @GetMapping("/notifications")
    public Result<PageDTO<NotificationDTO>> getNotifications(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size,
            HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        PageDTO<NotificationDTO> notifications = profileService.getNotifications(currentUserId, page, size);
        return Result.success(notifications);
    }

    /**
     * 标记通知已读
     */
    @PutMapping("/notifications/{notificationId}/read")
    public Result<Void> markNotificationRead(
            @PathVariable Long notificationId,
            HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        profileService.markNotificationRead(notificationId, currentUserId);
        return Result.success(null);
    }

    /**
     * 标记所有通知已读
     */
    @PutMapping("/notifications/read-all")
    public Result<Void> markAllNotificationsRead(HttpServletRequest request) {
        Long currentUserId = getCurrentUserId(request);
        profileService.markAllNotificationsRead(currentUserId);
        return Result.success(null);
    }

    /**
     * 获取当前用户ID
     */
    private Long getCurrentUserId(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
            return jwtUtils.getUserIdFromToken(token);
        }
        return null;
    }
}
