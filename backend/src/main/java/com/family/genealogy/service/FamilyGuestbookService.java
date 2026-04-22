package com.family.genealogy.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.family.genealogy.exception.BusinessException;
import com.family.genealogy.common.ErrorCode;
import com.family.genealogy.dto.FamilyGuestbookDTO;
import com.family.genealogy.dto.PageDTO;
import com.family.genealogy.entity.FamilyGuestbook;
import com.family.genealogy.entity.User;
import com.family.genealogy.mapper.FamilyGuestbookMapper;
import com.family.genealogy.mapper.UserMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
public class FamilyGuestbookService {

    private final FamilyGuestbookMapper familyGuestbookMapper;
    private final UserMapper userMapper;

    @Autowired
    @Lazy
    private NotificationService notificationService;

    public FamilyGuestbookService(FamilyGuestbookMapper familyGuestbookMapper, UserMapper userMapper) {
        this.familyGuestbookMapper = familyGuestbookMapper;
        this.userMapper = userMapper;
    }

    public PageDTO<FamilyGuestbookDTO> getGuestbookList(int page, int size, Long requesterId) {
        Page<FamilyGuestbook> pageParam = new Page<>(page, size);

        LambdaQueryWrapper<FamilyGuestbook> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(FamilyGuestbook::getStatus, "ACTIVE")
               .eq(FamilyGuestbook::getDeleted, 0)
               .orderByDesc(FamilyGuestbook::getCreatedAt);

        Page<FamilyGuestbook> result = familyGuestbookMapper.selectPage(pageParam, wrapper);

        List<FamilyGuestbookDTO> records = result.getRecords().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());

        PageDTO<FamilyGuestbookDTO> pageDTO = new PageDTO<>();
        pageDTO.setRecords(records);
        pageDTO.setTotal(result.getTotal());
        pageDTO.setPage((int) result.getCurrent());
        pageDTO.setSize((int) result.getSize());

        return pageDTO;
    }

    @Transactional(rollbackFor = Exception.class)
    public FamilyGuestbookDTO createGuestbook(Long userId, FamilyGuestbookDTO dto) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.RESOURCE_NOT_FOUND, "用户不存在");
        }

        FamilyGuestbook guestbook = new FamilyGuestbook();
        guestbook.setUserId(userId);
        guestbook.setFamilyId(user.getFamilyId());
        guestbook.setContent(dto.getContent());
        guestbook.setStatus("ACTIVE");
        guestbook.setCreatedBy(userId);

        familyGuestbookMapper.insert(guestbook);

        try {
            notifyFamilyMembers(user.getFamilyId(), userId, user.getName(), guestbook.getId(), dto.getContent());
        } catch (Exception e) {
            log.error("发送家族留言通知失败", e);
        }

        return toDTO(guestbook);
    }

    /**
     * 通知所有家族成员有新留言（包括发布者自己）
     */
    private void notifyFamilyMembers(Long familyId, Long senderId, String senderName, Long guestbookId, String content) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getFamilyId, familyId);
        List<User> familyMembers = userMapper.selectList(wrapper);

        for (User member : familyMembers) {
            String notificationContent = senderName + "在家族留言板留言了";
            notificationService.createNotification(
                member.getId(),
                "GUESTBOOK",
                "FAMILY_GUESTBOOK",
                guestbookId,
                senderId,
                notificationContent
            );
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void deleteGuestbook(Long id, Long userId) {
        FamilyGuestbook guestbook = familyGuestbookMapper.selectById(id);
        if (guestbook == null) {
            throw new BusinessException(ErrorCode.RESOURCE_NOT_FOUND, "留言不存在");
        }

        if (!guestbook.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED, "无权删除此留言");
        }

        guestbook.setDeleted(1);
        guestbook.setStatus("DELETED");
        guestbook.setUpdatedBy(userId);
        familyGuestbookMapper.updateById(guestbook);
    }

    private FamilyGuestbookDTO toDTO(FamilyGuestbook guestbook) {
        FamilyGuestbookDTO dto = new FamilyGuestbookDTO();
        dto.setId(guestbook.getId());
        dto.setUserId(guestbook.getUserId());
        dto.setContent(guestbook.getContent());
        dto.setCreatedAt(guestbook.getCreatedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));

        User user = userMapper.selectById(guestbook.getUserId());
        if (user != null) {
            dto.setUserName(user.getName());
            dto.setUserAvatar(user.getAvatarUrl());
        }

        return dto;
    }
}
