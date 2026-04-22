package com.family.genealogy.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.family.genealogy.dto.CategoryDTO;
import com.family.genealogy.entity.PostCategory;
import com.family.genealogy.mapper.PostCategoryMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 分类服务
 * 负责动态分类的查询和管理
 */
@Slf4j
@Service
public class CategoryService {

    private final PostCategoryMapper postCategoryMapper;

    public CategoryService(PostCategoryMapper postCategoryMapper) {
        this.postCategoryMapper = postCategoryMapper;
    }

    /**
     * 获取所有分类（用户自定义+系统预设）
     */
    public List<CategoryDTO> getAllCategories(Long userId) {
        LambdaQueryWrapper<PostCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PostCategory::getStatus, 1)
               .eq(PostCategory::getDeleted, 0)
               .and(w -> w.eq(PostCategory::getUserId, userId)
                          .or()
                          .eq(PostCategory::getIsSystem, 1))
               .orderByAsc(PostCategory::getSortOrder);

        List<PostCategory> categories = postCategoryMapper.selectList(wrapper);

        return categories.stream()
                .map(this::buildCategoryDTO)
                .collect(Collectors.toList());
    }

    /**
     * 获取系统预设分类
     */
    public List<CategoryDTO> getSystemCategories() {
        LambdaQueryWrapper<PostCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PostCategory::getIsSystem, 1)
               .eq(PostCategory::getStatus, 1)
               .eq(PostCategory::getDeleted, 0)
               .orderByAsc(PostCategory::getSortOrder);

        List<PostCategory> categories = postCategoryMapper.selectList(wrapper);

        return categories.stream()
                .map(this::buildCategoryDTO)
                .collect(Collectors.toList());
    }

    /**
     * 构建CategoryDTO
     */
    private CategoryDTO buildCategoryDTO(PostCategory category) {
        return CategoryDTO.builder()
                .id(category.getId())
                .name(category.getName())
                .code(category.getCode())
                .icon(category.getIcon())
                .color(category.getColor())
                .description(category.getDescription())
                .sortOrder(category.getSortOrder())
                .isSystem(category.getIsSystem() == 1)
                .postCount(category.getPostCount())
                .build();
    }
}
