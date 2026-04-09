package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.dto.*;
import com.family.genealogy.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public Result<Long> register(@Valid @RequestBody RegisterRequest request) {
        Long userId = authService.register(request);
        return Result.success("注册成功", userId);
    }

    @PostMapping("/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return Result.success("登录成功", response);
    }

    @PostMapping("/logout")
    public Result<Void> logout() {
        authService.logout();
        return Result.success("退出成功");
    }

    @GetMapping("/profile")
    public Result<UserProfileDTO> getProfile(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        UserProfileDTO profile = authService.getProfile(userId);
        return Result.success(profile);
    }

    @PutMapping("/profile")
    public Result<Void> updateProfile(Authentication authentication,
                                      @RequestBody UpdateProfileRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        authService.updateProfile(userId, request);
        return Result.success("修改成功");
    }
}
