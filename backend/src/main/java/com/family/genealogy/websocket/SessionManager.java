package com.family.genealogy.websocket;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * WebSocket会话管理器
 * 管理在线用户的WebSocket会话，支持消息推送
 */
@Slf4j
@Component
public class SessionManager {

    /**
     * 用户ID -> WebSocketSession映射
     */
    private final Map<Long, WebSocketSession> sessionMap = new ConcurrentHashMap<>();

    /**
     * 用户ID -> 订阅频道列表映射
     */
    private final Map<Long, List<String>> userChannels = new ConcurrentHashMap<>();

    /**
     * 频道 -> 用户ID列表映射
     */
    private final Map<String, List<Long>> channelUsers = new ConcurrentHashMap<>();

    /**
     * 添加用户会话
     */
    public void addSession(Long userId, WebSocketSession session) {
        sessionMap.put(userId, session);
        log.info("用户 {} 上线, 当前在线人数: {}", userId, getOnlineCount());
    }

    /**
     * 移除用户会话
     */
    public void removeSession(Long userId) {
        sessionMap.remove(userId);
        userChannels.remove(userId);
        // 清理频道订阅
        channelUsers.values().forEach(users -> users.remove(userId));
        log.info("用户 {} 下线, 当前在线人数: {}", userId, getOnlineCount());
    }

    /**
     * 获取用户会话
     */
    public WebSocketSession getSession(Long userId) {
        return sessionMap.get(userId);
    }

    /**
     * 判断用户是否在线
     */
    public boolean isOnline(Long userId) {
        WebSocketSession session = sessionMap.get(userId);
        return session != null && session.isOpen();
    }

    /**
     * 获取在线用户数
     */
    public int getOnlineCount() {
        return sessionMap.size();
    }

    /**
     * 获取在线用户ID列表
     */
    public Set<Long> getOnlineUsers() {
        return sessionMap.keySet();
    }

    /**
     * 发送消息给指定用户
     */
    public void sendToUser(Long userId, String message) {
        WebSocketSession session = sessionMap.get(userId);
        if (session != null && session.isOpen()) {
            try {
                session.sendMessage(new org.springframework.web.socket.TextMessage(message));
            } catch (IOException e) {
                log.error("发送消息给用户 {} 失败", userId, e);
            }
        } else {
            log.warn("用户 {} 不在线或连接已关闭", userId);
        }
    }

    /**
     * 广播消息给所有在线用户
     */
    public void broadcast(String message) {
        sessionMap.values().forEach(session -> {
            if (session.isOpen()) {
                try {
                    session.sendMessage(new org.springframework.web.socket.TextMessage(message));
                } catch (IOException e) {
                    log.error("广播消息失败", e);
                }
            }
        });
    }

    /**
     * 订阅频道
     */
    public void subscribe(Long userId, String channel) {
        userChannels.computeIfAbsent(userId, k -> new ArrayList<>()).add(channel);
        channelUsers.computeIfAbsent(channel, k -> new ArrayList<>()).add(userId);
    }

    /**
     * 取消订阅频道
     */
    public void unsubscribe(Long userId, String channel) {
        List<String> channels = userChannels.get(userId);
        if (channels != null) {
            channels.remove(channel);
        }
        List<Long> users = channelUsers.get(channel);
        if (users != null) {
            users.remove(userId);
        }
    }

    /**
     * 向频道内用户广播消息
     */
    public void broadcastToChannel(String channel, String message) {
        List<Long> users = channelUsers.get(channel);
        if (users != null) {
            users.forEach(userId -> sendToUser(userId, message));
        }
    }
}
