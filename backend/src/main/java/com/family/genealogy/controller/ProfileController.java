package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.dto.ProfileDTO;
import com.family.genealogy.dto.ProfileUpdateDTO;
import com.family.genealogy.service.ProfileService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * 个人主页控制器
 * 提供主页信息查询和编辑接口
 */
@RestController
@RequestMapping("/api/v1/profiles")
public class ProfileController {

    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    /**
     * 获取个人主页信息
     * GET /api/v1/profiles/{userId}
     */
    @GetMapping("/{userId}")
    public Result<ProfileDTO> getProfile(@PathVariable Long userId,
                                          Authentication authentication) {
        Long requesterId = (Long) authentication.getPrincipal();

        // 自动创建主页
        profileService.createProfileIfNotExists(userId);

        ProfileDTO profile = profileService.getProfile(userId, requesterId);
        return Result.success(profile);
    }

    /**
     * 编辑个人主页
     * PUT /api/v1/profiles/me
     */
    @PutMapping("/me")
    public Result<ProfileDTO> updateProfile(Authentication authentication,
                                             @Valid @RequestBody ProfileUpdateDTO dto) {
        Long userId = (Long) authentication.getPrincipal();
        ProfileDTO result = profileService.updateProfile(userId, dto);
        return Result.success("主页信息更新成功", result);
    }
}
