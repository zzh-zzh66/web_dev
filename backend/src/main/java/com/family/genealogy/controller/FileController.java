package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.service.FileService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

/**
 * 文件上传控制器
 * 提供图片、视频、头像、背景图上传接口
 */
@RestController
@RequestMapping("/api/v1/files")
public class FileController {

    private final FileService fileService;

    public FileController(FileService fileService) {
        this.fileService = fileService;
    }

    /**
     * 上传图片
     * POST /api/v1/files/images
     */
    @PostMapping("/images")
    public Result<Map<String, Object>> uploadImage(@RequestParam("file") MultipartFile file) {
        Map<String, Object> result = fileService.uploadImage(file);
        return Result.success("上传成功", result);
    }

    /**
     * 上传视频
     * POST /api/v1/files/videos
     */
    @PostMapping("/videos")
    public Result<Map<String, Object>> uploadVideo(@RequestParam("file") MultipartFile file) {
        Map<String, Object> result = fileService.uploadVideo(file);
        return Result.success("上传成功", result);
    }

    /**
     * 上传头像
     * POST /api/v1/files/avatars
     */
    @PostMapping("/avatars")
    public Result<Map<String, Object>> uploadAvatar(@RequestParam("file") MultipartFile file) {
        Map<String, Object> result = fileService.uploadAvatar(file);
        return Result.success("上传成功", result);
    }

    /**
     * 上传背景图
     * POST /api/v1/files/backgrounds
     */
    @PostMapping("/backgrounds")
    public Result<Map<String, Object>> uploadBackground(@RequestParam("file") MultipartFile file) {
        Map<String, Object> result = fileService.uploadBackground(file);
        return Result.success("上传成功", result);
    }
}
