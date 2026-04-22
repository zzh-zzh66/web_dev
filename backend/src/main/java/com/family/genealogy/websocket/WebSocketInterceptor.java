package com.family.genealogy.websocket;

import com.family.genealogy.util.JwtUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import java.util.Map;

/**
 * WebSocket握手拦截器
 * 负责在WebSocket建立连接前进行JWT认证
 */
@Slf4j
@Component
public class WebSocketInterceptor implements HandshakeInterceptor {

    private final JwtUtils jwtUtils;

    public WebSocketInterceptor(JwtUtils jwtUtils) {
        this.jwtUtils = jwtUtils;
    }

    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response,
                                    WebSocketHandler wsHandler, Map<String, Object> attributes) {
        // 从URL参数获取token
        String query = request.getURI().getQuery();
        if (query == null || !query.contains("token=")) {
            log.warn("WebSocket连接缺少token参数");
            return false;
        }

        String token = query.split("token=")[1].split("&")[0];

        // 验证token
        try {
            if (!jwtUtils.validateToken(token)) {
                log.warn("WebSocket连接token无效");
                return false;
            }

            Long userId = jwtUtils.getUserIdFromToken(token);
            attributes.put("userId", userId);
            log.info("WebSocket用户 {} 认证成功", userId);
            return true;

        } catch (Exception e) {
            log.error("WebSocket token验证异常", e);
            return false;
        }
    }

    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response,
                                WebSocketHandler wsHandler, Exception exception) {
        // 握手后处理
    }
}
