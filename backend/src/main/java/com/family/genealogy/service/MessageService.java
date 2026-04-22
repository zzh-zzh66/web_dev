package com.family.genealogy.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.family.genealogy.common.ErrorCode;
import com.family.genealogy.dto.*;
import com.family.genealogy.entity.*;
import com.family.genealogy.exception.BusinessException;
import com.family.genealogy.mapper.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 私信服务
 * 负责私信会话管理、消息收发、已读标记
 */
@Slf4j
@Service
public class MessageService {

    private final MessageSessionMapper messageSessionMapper;
    private final PrivateMessageMapper privateMessageMapper;
    private final UserMapper userMapper;

    public MessageService(MessageSessionMapper messageSessionMapper,
                          PrivateMessageMapper privateMessageMapper,
                          UserMapper userMapper) {
        this.messageSessionMapper = messageSessionMapper;
        this.privateMessageMapper = privateMessageMapper;
        this.userMapper = userMapper;
    }

    /**
     * 获取会话列表
     */
    public PageDTO<MessageSessionDTO> getMessageSessions(Long userId, int page, int size) {
        List<MessageSession> sessions;
        LambdaQueryWrapper<MessageSession> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w.eq(MessageSession::getUserId1, userId)
                          .or()
                          .eq(MessageSession::getUserId2, userId))
               .orderByDesc(MessageSession::getLastMessageTime);

        Page<MessageSession> pageParam = new Page<>(page, size);
        Page<MessageSession> result = messageSessionMapper.selectPage(pageParam, wrapper);

        List<MessageSessionDTO> records = result.getRecords().stream()
                .map(session -> buildSessionDTO(session, userId))
                .collect(Collectors.toList());

        PageDTO<MessageSessionDTO> pageDTO = new PageDTO<>();
        pageDTO.setRecords(records);
        pageDTO.setTotal(result.getTotal());
        pageDTO.setPage((int) result.getCurrent());
        pageDTO.setSize((int) result.getSize());
        return pageDTO;
    }

    /**
     * 获取会话消息
     */
    public PageDTO<PrivateMessageDTO> getSessionMessages(Long sessionId, int page, int size, Long userId) {
        // 校验会话参与权限
        MessageSession session = messageSessionMapper.selectById(sessionId);
        if (session == null) {
            throw new BusinessException(ErrorCode.SESSION_NOT_FOUND, "会话不存在");
        }
        if (!userId.equals(session.getUserId1()) && !userId.equals(session.getUserId2())) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED, "无权访问此会话");
        }

        Page<PrivateMessage> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<PrivateMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PrivateMessage::getSessionId, sessionId)
               .eq(PrivateMessage::getDeleted, 0)
               .orderByDesc(PrivateMessage::getCreatedAt);

        Page<PrivateMessage> result = privateMessageMapper.selectPage(pageParam, wrapper);

        List<PrivateMessageDTO> records = result.getRecords().stream()
                .map(msg -> buildMessageDTO(msg))
                .collect(Collectors.toList());

        PageDTO<PrivateMessageDTO> pageDTO = new PageDTO<>();
        pageDTO.setRecords(records);
        pageDTO.setTotal(result.getTotal());
        pageDTO.setPage((int) result.getCurrent());
        pageDTO.setSize((int) result.getSize());
        return pageDTO;
    }

    /**
     * 发送私信
     */
    @Transactional(rollbackFor = Exception.class)
    public PrivateMessageDTO createMessage(Long senderId, PrivateMessageCreateDTO dto) {
        // 校验接收者存在
        User receiver = userMapper.selectById(dto.getReceiverId());
        if (receiver == null) {
            throw new BusinessException(ErrorCode.RESOURCE_NOT_FOUND, "接收者不存在");
        }

        // 创建或获取会话
        MessageSession session = getOrCreateSession(senderId, dto.getReceiverId());

        // 创建消息
        PrivateMessage message = new PrivateMessage();
        message.setSessionId(session.getId());
        message.setSenderId(senderId);
        message.setReceiverId(dto.getReceiverId());
        message.setContent(dto.getContent());
        message.setMsgType(dto.getMsgType());
        message.setMediaUrl(dto.getMediaUrl());
        message.setIsRead(0);
        message.setStatus(1);
        message.setCreatedBy(senderId);
        privateMessageMapper.insert(message);

        // 更新会话最后消息
        session.setLastMessage(dto.getContent().length() > 50
                ? dto.getContent().substring(0, 50) + "..."
                : dto.getContent());
        session.setLastMessageTime(LocalDateTime.now());

        // 增加接收者未读数
        if (senderId.equals(session.getUserId1())) {
            session.setUnreadCount2(session.getUnreadCount2() + 1);
        } else {
            session.setUnreadCount1(session.getUnreadCount1() + 1);
        }
        messageSessionMapper.updateById(session);

        return buildMessageDTO(message);
    }

    /**
     * 标记会话已读
     */
    @Transactional(rollbackFor = Exception.class)
    public void markSessionRead(Long sessionId, Long userId) {
        MessageSession session = messageSessionMapper.selectById(sessionId);
        if (session == null) {
            throw new BusinessException(ErrorCode.SESSION_NOT_FOUND, "会话不存在");
        }

        // 校验参与权限
        if (!userId.equals(session.getUserId1()) && !userId.equals(session.getUserId2())) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED, "无权操作此会话");
        }

        // 清除当前用户的未读计数
        if (userId.equals(session.getUserId1())) {
            session.setUnreadCount1(0);
        } else {
            session.setUnreadCount2(0);
        }

        // 标记该会话中发给当前用户的所有消息为已读
        LambdaQueryWrapper<PrivateMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PrivateMessage::getSessionId, sessionId)
               .eq(PrivateMessage::getReceiverId, userId)
               .eq(PrivateMessage::getIsRead, 0);

        List<PrivateMessage> unreadMessages = privateMessageMapper.selectList(wrapper);
        for (PrivateMessage msg : unreadMessages) {
            msg.setIsRead(1);
            msg.setReadAt(LocalDateTime.now());
            privateMessageMapper.updateById(msg);
        }

        messageSessionMapper.updateById(session);
    }

    /**
     * 获取或创建会话
     */
    private MessageSession getOrCreateSession(Long userId1, Long userId2) {
        Long minId = Math.min(userId1, userId2);
        Long maxId = Math.max(userId1, userId2);
        String sessionKey = minId + "_" + maxId;

        // 查询现有会话
        LambdaQueryWrapper<MessageSession> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MessageSession::getSessionKey, sessionKey);
        MessageSession existing = messageSessionMapper.selectOne(wrapper);

        if (existing != null) {
            return existing;
        }

        // 创建新会话
        MessageSession session = new MessageSession();
        session.setSessionKey(sessionKey);
        session.setUserId1(minId);
        session.setUserId2(maxId);
        session.setUnreadCount1(0);
        session.setUnreadCount2(0);
        messageSessionMapper.insert(session);

        return session;
    }

    /**
     * 构建MessageSessionDTO
     */
    private MessageSessionDTO buildSessionDTO(MessageSession session, Long userId) {
        Long peerUserId = userId.equals(session.getUserId1())
                ? session.getUserId2() : session.getUserId1();
        User peerUser = userMapper.selectById(peerUserId);
        Integer unreadCount = userId.equals(session.getUserId1())
                ? session.getUnreadCount1() : session.getUnreadCount2();

        return MessageSessionDTO.builder()
                .sessionId(session.getId())
                .peerUserId(peerUserId)
                .peerUserName(peerUser != null ? peerUser.getName() : null)
                .lastMessage(session.getLastMessage())
                .lastMessageTime(session.getLastMessageTime())
                .unreadCount(unreadCount)
                .build();
    }

    /**
     * 构建PrivateMessageDTO
     */
    private PrivateMessageDTO buildMessageDTO(PrivateMessage message) {
        User sender = userMapper.selectById(message.getSenderId());

        return PrivateMessageDTO.builder()
                .id(message.getId())
                .sessionId(message.getSessionId())
                .senderId(message.getSenderId())
                .senderName(sender != null ? sender.getName() : null)
                .receiverId(message.getReceiverId())
                .msgType(message.getMsgType())
                .content(message.getContent())
                .mediaUrl(message.getMediaUrl())
                .isRead(message.getIsRead() == 1)
                .createdAt(message.getCreatedAt())
                .build();
    }
}
