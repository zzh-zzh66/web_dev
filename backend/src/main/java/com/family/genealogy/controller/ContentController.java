package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.dto.PageDTO;
import com.family.genealogy.dto.PostCreateDTO;
import com.family.genealogy.dto.PostDTO;
import com.family.genealogy.service.ContentService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * 内容管理控制器
 * 提供动态的发布、查询、更新、删除接口
 */
@RestController
@RequestMapping("/api/v1/contents")
public class ContentController {

    private final ContentService contentService;

    public ContentController(ContentService contentService) {
        this.contentService = contentService;
    }

    /**
     * 发布动态
     * POST /api/v1/contents
     */
    @PostMapping
    public Result<PostDTO> createPost(Authentication authentication,
                                       @Valid @RequestBody PostCreateDTO dto) {
        Long userId = (Long) authentication.getPrincipal();
        PostDTO post = contentService.createPost(userId, dto);
        return Result.created("动态发布成功", post);
    }

    /**
     * 获取动态列表（时间轴）
     * GET /api/v1/contents
     */
    @GetMapping
    public Result<PageDTO<PostDTO>> getPostList(
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer month,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication authentication) {
        Long requesterId = (Long) authentication.getPrincipal();
        PageDTO<PostDTO> result = contentService.getPostList(userId, categoryId, year, month, page, size, requesterId);
        return Result.success(result);
    }

    /**
     * 获取动态详情
     * GET /api/v1/contents/{contentId}
     */
    @GetMapping("/{contentId}")
    public Result<PostDTO> getPostDetail(@PathVariable Long contentId,
                                          Authentication authentication) {
        Long requesterId = (Long) authentication.getPrincipal();
        PostDTO post = contentService.getPostDetail(contentId, requesterId);
        return Result.success(post);
    }

    /**
     * 编辑动态
     * PUT /api/v1/contents/{contentId}
     */
    @PutMapping("/{contentId}")
    public Result<PostDTO> updatePost(@PathVariable Long contentId,
                                       Authentication authentication,
                                       @Valid @RequestBody PostCreateDTO dto) {
        Long userId = (Long) authentication.getPrincipal();
        PostDTO post = contentService.updatePost(contentId, userId, dto);
        return Result.success("动态更新成功", post);
    }

    /**
     * 删除动态
     * DELETE /api/v1/contents/{contentId}
     */
    @DeleteMapping("/{contentId}")
    public Result<Void> deletePost(@PathVariable Long contentId,
                                    Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        contentService.deletePost(contentId, userId);
        return Result.success("内容删除成功");
    }

    /**
     * 获取家族动态列表
     * GET /api/v1/contents/family
     */
    @GetMapping("/family")
    public Result<PageDTO<PostDTO>> getFamilyPosts(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication authentication) {
        Long requesterId = (Long) authentication.getPrincipal();
        PageDTO<PostDTO> result = contentService.getFamilyPosts(page, size, requesterId);
        return Result.success(result);
    }
}
