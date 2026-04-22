package com.family.genealogy.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.family.genealogy.common.ErrorCode;
import com.family.genealogy.dto.NotificationDTO;
import com.family.genealogy.dto.NotificationUnreadCountDTO;
import com.family.genealogy.dto.PageDTO;
import com.family.genealogy.entity.Notification;
import com.family.genealogy.entity.User;
import com.family.genealogy.exception.BusinessException;
import com.family.genealogy.mapper.NotificationMapper;
import com.family.genealogy.mapper.UserMapper;
import com.family.genealogy.websocket.SessionManager;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 通知服务
 * 负责通知的创建、查询、已读标记、未读统计
 */
@Slf4j
@Service
public class NotificationService {

    private final NotificationMapper notificationMapper;
    private final UserMapper userMapper;
    private final SessionManager sessionManager;
    private final ObjectMapper objectMapper;

    public NotificationService(NotificationMapper notificationMapper, UserMapper userMapper,
                                 SessionManager sessionManager, ObjectMapper objectMapper) {
        this.notificationMapper = notificationMapper;
        this.userMapper = userMapper;
        this.sessionManager = sessionManager;
        this.objectMapper = objectMapper;
    }

    /**
     * 获取通知列表
     */
    public PageDTO<NotificationDTO> getNotifications(Long userId, String type, int page, int size) {
        Page<Notification> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notification::getReceiverId, userId)
               .eq(Notification::getDeleted, 0)
               .eq(Notification::getStatus, 1)
               .orderByDesc(Notification::getCreatedAt);

        if (type != null && !type.isEmpty()) {
            wrapper.eq(Notification::getType, type);
        }

        Page<Notification> result = notificationMapper.selectPage(pageParam, wrapper);

        List<NotificationDTO> records = result.getRecords().stream()
                .map(notification -> buildNotificationDTO(notification))
                .collect(Collectors.toList());

        PageDTO<NotificationDTO> pageDTO = new PageDTO<>();
        pageDTO.setRecords(records);
        pageDTO.setTotal(result.getTotal());
        pageDTO.setPage((int) result.getCurrent());
        pageDTO.setSize((int) result.getSize());
        return pageDTO;
    }

    /**
     * 获取未读数（按类型分组）
     */
    public NotificationUnreadCountDTO getUnreadCount(Long userId) {
        // 统计总数
        LambdaQueryWrapper<Notification> totalWrapper = new LambdaQueryWrapper<>();
        totalWrapper.eq(Notification::getReceiverId, userId)
                    .eq(Notification::getIsRead, 0)
                    .eq(Notification::getDeleted, 0);
        long totalCount = notificationMapper.selectCount(totalWrapper);

        // 按类型统计
        Map<String, Long> countByType = new HashMap<>();
        List<Map<String, Object>> typeCounts = notificationMapper.countUnreadByType(userId);
        for (Map<String, Object> row : typeCounts) {
            String type = (String) row.get("type");
            Object countObj = row.get("count");
            long count = countObj instanceof Long ? (Long) countObj : Integer.parseInt(countObj.toString());
            countByType.put(type, count);
        }

        return NotificationUnreadCountDTO.builder()
                .totalCount(totalCount)
                .commentCount(countByType.getOrDefault("COMMENT", 0L))
                .replyCount(countByType.getOrDefault("REPLY", 0L))
                .likeCount(countByType.getOrDefault("LIKE", 0L))
                .guestbookCount(countByType.getOrDefault("GUESTBOOK", 0L))
                .mentionCount(countByType.getOrDefault("AT_MENTION", 0L))
                .messageCount(countByType.getOrDefault("PRIVATE_MESSAGE", 0L))
                .systemCount(countByType.getOrDefault("SYSTEM", 0L))
                .build();
    }

    /**
     * 标记通知已读
     */
    @Transactional(rollbackFor = Exception.class)
    public void markRead(Long notificationId, Long userId) {
        Notification notification = notificationMapper.selectById(notificationId);
        if (notification == null) {
            throw new BusinessException(ErrorCode.NOTIFICATION_NOT_FOUND, "通知不存在");
        }

        // 校验接收者
        if (!userId.equals(notification.getReceiverId())) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED, "无权操作此通知");
        }

        notification.setIsRead(1);
        notification.setReadAt(LocalDateTime.now());
        notificationMapper.updateById(notification);
    }

    /**
     * 全部标记已读
     */
    @Transactional(rollbackFor = Exception.class)
    public void markAllRead(Long userId) {
        LambdaUpdateWrapper<Notification> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Notification::getReceiverId, userId)
               .eq(Notification::getIsRead, 0)
               .eq(Notification::getDeleted, 0)
               .set(Notification::getIsRead, 1)
               .set(Notification::getReadAt, LocalDateTime.now());

        notificationMapper.update(null, wrapper);
    }

    /**
     * 创建通知（内部方法，供其他Service调用）
     * 创建通知后自动通过WebSocket推送给在线用户
     */
    public void createNotification(Long receiverId, String type, String targetType,
                                    Long targetId, Long senderId, String content) {
        log.info("=== createNotification 开始 ===");
        log.info("receiverId={}, type={}, targetType={}, targetId={}, senderId={}, content={}",
                receiverId, type, targetType, targetId, senderId, content);

        Notification notification = new Notification();
        notification.setReceiverId(receiverId);
        notification.setSenderId(senderId);
        notification.setType(type);
        notification.setTargetType(targetType);
        notification.setTargetId(targetId);
        notification.setContent(content);
        notification.setIsRead(0);
        notification.setStatus(1);
        notificationMapper.insert(notification);

        log.info("通知已保存到数据库, id={}", notification.getId());
        log.info("创建通知: receiverId={}, type={}, content={}", receiverId, type, content);

        log.info("检查用户是否在线: userId={}, isOnline={}", receiverId, sessionManager.isOnline(receiverId));
        pushNotificationToUser(receiverId, notification);
        log.info("=== createNotification 结束 ===");
    }

    /**
     * 通过WebSocket推送通知给在线用户
     */
    private void pushNotificationToUser(Long userId, Notification notification) {
        log.info("=== pushNotificationToUser 开始 ===");
        log.info("userId={}, notificationId={}", userId, notification.getId());

        if (sessionManager.isOnline(userId)) {
            log.info("用户在线，开始推送通知");
            try {
                NotificationDTO dto = buildNotificationDTO(notification);
                log.info("DTO构建完成: id={}, fromUserName={}, type={}, content={}",
                        dto.getId(), dto.getFromUserName(), dto.getType(), dto.getContent());

                Map<String, Object> wsMsg = new HashMap<>();
                wsMsg.put("type", "NOTIFICATION");
                wsMsg.put("payload", dto);
                wsMsg.put("timestamp", System.currentTimeMillis());

                String message = objectMapper.writeValueAsString(wsMsg);
                log.info("WebSocket消息构建完成: {}", message);

                sessionManager.sendToUser(userId, message);
                log.info("WebSocket推送通知成功: userId={}, notificationId={}", userId, notification.getId());
            } catch (Exception e) {
                log.error("WebSocket推送通知失败: userId={}", userId, e);
            }
        } else {
            log.warn("用户不在线，跳过WebSocket推送: userId={}", userId);
        }
        log.info("=== pushNotificationToUser 结束 ===");
    }

    /**
     * 构建NotificationDTO
     */
    private NotificationDTO buildNotificationDTO(Notification notification) {
        User sender = null;
        if (notification.getSenderId() != null) {
            sender = userMapper.selectById(notification.getSenderId());
        }

        return NotificationDTO.builder()
                .id(notification.getId())
                .fromUserId(notification.getSenderId())
                .fromUserName(sender != null ? sender.getName() : "系统")
                .fromUserAvatar(sender != null ? sender.getAvatarUrl() : null)
                .type(notification.getType())
                .content(notification.getContent())
                .targetType(notification.getTargetType())
                .targetId(notification.getTargetId())
                .isRead(notification.getIsRead() == 1)
                .createdAt(notification.getCreatedAt())
                .build();
    }
}
