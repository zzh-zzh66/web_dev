package com.family.genealogy.service;

import com.family.genealogy.common.ErrorCode;
import com.family.genealogy.exception.BusinessException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 文件服务
 * 负责图片、视频等文件的上传、存储和缩略图生成
 */
@Slf4j
@Service
public class FileService {

    // 允许的图片格式
    private static final List<String> IMAGE_EXTENSIONS = Arrays.asList(
            "jpg", "jpeg", "png", "gif", "webp"
    );

    // 允许的视频格式
    private static final List<String> VIDEO_EXTENSIONS = Arrays.asList(
            "mp4"
    );

    // 文件大小限制（字节）
    private static final long MAX_IMAGE_SIZE = 10 * 1024 * 1024; // 10MB
    private static final long MAX_VIDEO_SIZE = 500 * 1024 * 1024; // 500MB

    // 存储根目录
    private static final String STORAGE_ROOT = System.getProperty("user.dir") + "/storage";

    /**
     * 上传图片
     */
    public Map<String, Object> uploadImage(MultipartFile file) {
        // 校验文件类型
        String originalFilename = file.getOriginalFilename();
        String extension = getExtension(originalFilename);
        if (!IMAGE_EXTENSIONS.contains(extension.toLowerCase())) {
            throw new BusinessException(ErrorCode.FILE_TYPE_UNSUPPORTED,
                    "不支持的图片格式: " + extension);
        }

        // 校验文件大小
        if (file.getSize() > MAX_IMAGE_SIZE) {
            throw new BusinessException(ErrorCode.FILE_SIZE_EXCEEDED,
                    "图片文件大小超过限制(10MB)");
        }

        // 生成存储路径
        String category = "content";
        String relativePath = generateFilePath(category, extension);
        String fullPath = STORAGE_ROOT + "/" + relativePath;

        // 确保目录存在
        ensureDirectoryExists(fullPath);

        try {
            // 保存文件
            file.transferTo(new File(fullPath));

            // 获取图片尺寸
            int[] dimensions = getImageDimensions(fullPath);

            // 生成缩略图
            String thumbPath = generateThumbnail(fullPath, extension);

            Map<String, Object> result = new HashMap<>();
            result.put("url", "/upload/" + relativePath);
            result.put("width", dimensions[0]);
            result.put("height", dimensions[1]);
            result.put("fileSize", file.getSize());
            if (thumbPath != null) {
                result.put("thumbnailUrl", "/upload/" + thumbPath);
            }

            log.info("图片上传成功: {}", relativePath);
            return result;

        } catch (IOException e) {
            log.error("图片上传失败", e);
            throw new BusinessException(ErrorCode.RESOURCE_NOT_FOUND, "图片上传失败");
        }
    }

    /**
     * 上传视频
     */
    public Map<String, Object> uploadVideo(MultipartFile file) {
        // 校验文件类型
        String originalFilename = file.getOriginalFilename();
        String extension = getExtension(originalFilename);
        if (!VIDEO_EXTENSIONS.contains(extension.toLowerCase())) {
            throw new BusinessException(ErrorCode.FILE_TYPE_UNSUPPORTED,
                    "不支持的视频格式: " + extension);
        }

        // 校验文件大小
        if (file.getSize() > MAX_VIDEO_SIZE) {
            throw new BusinessException(ErrorCode.FILE_SIZE_EXCEEDED,
                    "视频文件大小超过限制(500MB)");
        }

        // 生成存储路径
        String category = "videos";
        String relativePath = generateFilePath(category, extension);
        String fullPath = STORAGE_ROOT + "/" + relativePath;

        // 确保目录存在
        ensureDirectoryExists(fullPath);

        try {
            // 保存文件
            file.transferTo(new File(fullPath));

            Map<String, Object> result = new HashMap<>();
            result.put("url", "/upload/" + relativePath);
            result.put("fileSize", file.getSize());

            log.info("视频上传成功: {}", relativePath);
            return result;

        } catch (IOException e) {
            log.error("视频上传失败", e);
            throw new BusinessException(ErrorCode.RESOURCE_NOT_FOUND, "视频上传失败");
        }
    }

    /**
     * 上传头像
     */
    public Map<String, Object> uploadAvatar(MultipartFile file) {
        return uploadToCategory(file, "avatars");
    }

    /**
     * 上传背景图
     */
    public Map<String, Object> uploadBackground(MultipartFile file) {
        return uploadToCategory(file, "backgrounds");
    }

    /**
     * 生成缩略图
     */
    private String generateThumbnail(String imagePath, String extension) {
        try {
            BufferedImage originalImage = ImageIO.read(new File(imagePath));
            if (originalImage == null) {
                return null;
            }

            // 缩略图尺寸：宽度最大200，高度按比例缩放
            int thumbWidth = 200;
            int thumbHeight = (int) ((double) originalImage.getHeight() / originalImage.getWidth() * thumbWidth);

            BufferedImage thumbImage = new BufferedImage(thumbWidth, thumbHeight, BufferedImage.TYPE_INT_RGB);
            thumbImage.getGraphics().drawImage(
                    originalImage.getScaledInstance(thumbWidth, thumbHeight, java.awt.Image.SCALE_SMOOTH),
                    0, 0, null
            );

            // 保存缩略图
            String thumbPath = imagePath.replace("." + extension, "_thumb." + extension);
            ImageIO.write(thumbImage, extension, new File(thumbPath));

            // 返回相对于STORAGE_ROOT的路径
            return thumbPath.substring(STORAGE_ROOT.length() + 1);

        } catch (IOException e) {
            log.warn("生成缩略图失败: {}", imagePath, e);
            return null;
        }
    }

    /**
     * 获取图片尺寸
     */
    private int[] getImageDimensions(String imagePath) {
        try {
            BufferedImage image = ImageIO.read(new File(imagePath));
            if (image != null) {
                return new int[]{image.getWidth(), image.getHeight()};
            }
        } catch (IOException e) {
            log.warn("获取图片尺寸失败: {}", imagePath, e);
        }
        return new int[]{0, 0};
    }

    /**
     * 上传到指定分类
     */
    private Map<String, Object> uploadToCategory(MultipartFile file, String category) {
        String originalFilename = file.getOriginalFilename();
        String extension = getExtension(originalFilename);

        if (!IMAGE_EXTENSIONS.contains(extension.toLowerCase())) {
            throw new BusinessException(ErrorCode.FILE_TYPE_UNSUPPORTED,
                    "不支持的文件格式: " + extension);
        }

        String relativePath = generateFilePath(category, extension);
        String fullPath = STORAGE_ROOT + "/" + relativePath;

        ensureDirectoryExists(fullPath);

        try {
            file.transferTo(new File(fullPath));

            int[] dimensions = getImageDimensions(fullPath);

            Map<String, Object> result = new HashMap<>();
            result.put("url", "/upload/" + relativePath);
            result.put("width", dimensions[0]);
            result.put("height", dimensions[1]);
            result.put("fileSize", file.getSize());

            return result;
        } catch (IOException e) {
            log.error("文件上传失败: {}", category, e);
            throw new BusinessException(ErrorCode.RESOURCE_NOT_FOUND, "文件上传失败");
        }
    }

    /**
     * 生成文件路径（日期分目录）
     * 格式: {category}/{year}/{month}/{uuid}.{extension}
     */
    private String generateFilePath(String category, String extension) {
        String datePath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM"));
        String fileName = UUID.randomUUID().toString().replace("-", "") + "." + extension;
        return category + "/" + datePath + "/" + fileName;
    }

    /**
     * 获取文件扩展名
     */
    private String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return "";
        }
        return filename.substring(filename.lastIndexOf(".") + 1);
    }

    /**
     * 确保文件所在目录存在
     */
    private void ensureDirectoryExists(String filePath) {
        try {
            Path path = Paths.get(filePath).getParent();
            if (path != null && !Files.exists(path)) {
                Files.createDirectories(path);
            }
        } catch (IOException e) {
            log.error("创建目录失败: {}", filePath, e);
        }
    }
}
