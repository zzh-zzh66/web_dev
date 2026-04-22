package com.family.genealogy.websocket;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * WebSocket处理器
 * 实现消息分发、订阅管理、心跳检测和私信转发
 */
@Slf4j
@Component
public class WebSocketHandler implements org.springframework.web.socket.WebSocketHandler {

    private final SessionManager sessionManager;
    private final ObjectMapper objectMapper;

    public WebSocketHandler(SessionManager sessionManager, ObjectMapper objectMapper) {
        this.sessionManager = sessionManager;
        this.objectMapper = objectMapper;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        Long userId = (Long) session.getAttributes().get("userId");
        sessionManager.addSession(userId, session);
        log.info("用户 {} WebSocket连接建立, sessionId={}", userId, session.getId());

        // 发送连接成功消息
        try {
            sendMessage(session, createMessage("CONNECTED",
                    "连接成功", userId));
        } catch (IOException e) {
            log.error("发送连接消息失败", e);
        }
    }

    @Override
    public void handleMessage(WebSocketSession session, WebSocketMessage<?> message) {
        Long userId = (Long) session.getAttributes().get("userId");
        String payload = message.getPayload().toString();

        try {
            JsonNode jsonNode = objectMapper.readTree(payload);
            String type = jsonNode.has("type") ? jsonNode.get("type").asText() : "";

            switch (type) {
                case "SUBSCRIBE":
                    handleSubscribe(session, userId, jsonNode);
                    break;
                case "PING":
                    handlePing(session);
                    break;
                case "MESSAGE":
                    handleMessage(session, userId, jsonNode);
                    break;
                case "UNSUBSCRIBE":
                    handleUnsubscribe(session, userId, jsonNode);
                    break;
                default:
                    log.warn("未知消息类型: {}", type);
            }
        } catch (Exception e) {
            log.error("处理WebSocket消息失败, userId={}", userId, e);
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        Long userId = (Long) session.getAttributes().get("userId");
        log.error("WebSocket传输错误, userId={}", userId, exception);
        sessionManager.removeSession(userId);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus closeStatus) {
        Long userId = (Long) session.getAttributes().get("userId");
        sessionManager.removeSession(userId);
        log.info("用户 {} WebSocket连接关闭, status={}", userId, closeStatus);
    }

    @Override
    public boolean supportsPartialMessages() {
        return false;
    }

    // ==================== 消息处理方法 ====================

    /**
     * 处理订阅消息
     */
    private void handleSubscribe(WebSocketSession session, Long userId, JsonNode jsonNode) throws IOException {
        String channel = jsonNode.has("channel") ? jsonNode.get("channel").asText() : "";
        sessionManager.subscribe(userId, channel);

        sendMessage(session, createMessage("SUBSCRIBED",
                "订阅频道 " + channel + " 成功", userId));
        log.info("用户 {} 订阅频道 {}", userId, channel);
    }

    /**
     * 处理取消订阅
     */
    private void handleUnsubscribe(WebSocketSession session, Long userId, JsonNode jsonNode) {
        String channel = jsonNode.has("channel") ? jsonNode.get("channel").asText() : "";
        sessionManager.unsubscribe(userId, channel);
        log.info("用户 {} 取消订阅频道 {}", userId, channel);
    }

    /**
     * 处理心跳
     */
    private void handlePing(WebSocketSession session) throws IOException {
        sendMessage(session, createMessage("PONG", null, null));
    }

    /**
     * 处理私信消息转发
     */
    private void handleMessage(WebSocketSession session, Long senderId, JsonNode jsonNode) throws IOException {
        String channel = jsonNode.has("channel") ? jsonNode.get("channel").asText() : "";
        JsonNode data = jsonNode.get("data");

        // 解析目标用户ID (channel格式: user_{userId})
        Long targetUserId = parseUserIdFromChannel(channel);
        if (targetUserId == null) {
            log.warn("无效的频道格式: {}", channel);
            return;
        }

        // 转发给目标用户
        Map<String, Object> msgData = objectMapper.convertValue(data, Map.class);
        Map<String, Object> wsMsg = createMessage("MESSAGE", null, senderId);
        wsMsg.put("data", msgData);
        wsMsg.put("timestamp", System.currentTimeMillis());

        sessionManager.sendToUser(targetUserId, objectMapper.writeValueAsString(wsMsg));
        log.info("私信转发: {} -> {}", senderId, targetUserId);
    }

    /**
     * 推送通知给指定用户
     */
    public void pushNotification(Long userId, Map<String, Object> notificationData) {
        try {
            Map<String, Object> wsMsg = createMessage("NOTIFICATION", null, null);
            wsMsg.put("data", notificationData);
            wsMsg.put("timestamp", System.currentTimeMillis());

            sessionManager.sendToUser(userId, objectMapper.writeValueAsString(wsMsg));
        } catch (Exception e) {
            log.error("推送通知失败, userId={}", userId, e);
        }
    }

    // ==================== 辅助方法 ====================

    /**
     * 创建WebSocket消息
     */
    private Map<String, Object> createMessage(String type, String message, Long userId) {
        Map<String, Object> wsMsg = new ConcurrentHashMap<>();
        wsMsg.put("type", type);
        if (message != null) wsMsg.put("message", message);
        if (userId != null) wsMsg.put("userId", userId);
        wsMsg.put("timestamp", System.currentTimeMillis());
        return wsMsg;
    }

    /**
     * 发送消息到Session
     */
    private void sendMessage(WebSocketSession session, Map<String, Object> message) throws IOException {
        if (session.isOpen()) {
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(message)));
        }
    }

    /**
     * 从频道名解析用户ID
     */
    private Long parseUserIdFromChannel(String channel) {
        if (channel != null && channel.startsWith("user_")) {
            try {
                return Long.parseLong(channel.substring(5));
            } catch (NumberFormatException e) {
                log.warn("频道用户ID解析失败: {}", channel);
            }
        }
        return null;
    }
}
