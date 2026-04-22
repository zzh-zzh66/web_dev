package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.dto.CategoryDTO;
import com.family.genealogy.service.CategoryService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 分类控制器
 * 提供动态分类查询接口
 */
@RestController
@RequestMapping("/api/v1/categories")
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    /**
     * 获取所有分类
     * GET /api/v1/categories
     */
    @GetMapping
    public Result<List<CategoryDTO>> getAllCategories(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        List<CategoryDTO> categories = categoryService.getAllCategories(userId);
        return Result.success(categories);
    }

    /**
     * 获取系统预设分类
     * GET /api/v1/categories/system
     */
    @GetMapping("/system")
    public Result<List<CategoryDTO>> getSystemCategories() {
        List<CategoryDTO> categories = categoryService.getSystemCategories();
        return Result.success(categories);
    }
}
