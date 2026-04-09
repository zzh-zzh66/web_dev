package com.family.genealogy.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.family.genealogy.common.ErrorCode;
import com.family.genealogy.dto.*;
import com.family.genealogy.entity.Member;
import com.family.genealogy.entity.User;
import com.family.genealogy.exception.BusinessException;
import com.family.genealogy.mapper.MemberMapper;
import com.family.genealogy.mapper.UserMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class MemberService {

    private final MemberMapper memberMapper;
    private final UserMapper userMapper;

    public MemberService(MemberMapper memberMapper, UserMapper userMapper) {
        this.memberMapper = memberMapper;
        this.userMapper = userMapper;
    }

    public Long createMember(Long userId, MemberCreateRequest request) {
        User user = userMapper.selectById(userId);
        if (user == null || user.getFamilyId() == null) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_EXISTS, "用户未关联家族");
        }

        Member member = new Member();
        member.setFamilyId(user.getFamilyId());
        member.setName(request.getName());
        member.setGender(request.getGender());
        member.setBirthDate(request.getBirthDate());
        member.setGeneration(request.getGeneration());
        member.setSpouseName(request.getSpouseName());
        member.setFatherId(request.getFatherId());
        member.setMotherId(request.getMotherId());
        member.setStatus(request.getStatus() != null ? request.getStatus() : "ALIVE");
        member.setCreatedBy(userId);
        memberMapper.insert(member);

        return member.getId();
    }

    public void updateMember(Long memberId, MemberUpdateRequest request) {
        Member member = memberMapper.selectById(memberId);
        if (member == null) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_EXISTS, "成员不存在");
        }

        if (StringUtils.hasText(request.getName())) {
            member.setName(request.getName());
        }
        if (StringUtils.hasText(request.getGender())) {
            member.setGender(request.getGender());
        }
        if (request.getBirthDate() != null) {
            member.setBirthDate(request.getBirthDate());
        }
        if (request.getDeathDate() != null) {
            member.setDeathDate(request.getDeathDate());
        }
        if (request.getGeneration() != null) {
            member.setGeneration(request.getGeneration());
        }
        if (request.getSpouseName() != null) {
            member.setSpouseName(request.getSpouseName());
        }
        if (request.getFatherId() != null) {
            member.setFatherId(request.getFatherId());
        }
        if (request.getMotherId() != null) {
            member.setMotherId(request.getMotherId());
        }
        if (StringUtils.hasText(request.getStatus())) {
            member.setStatus(request.getStatus());
        }

        memberMapper.updateById(member);
    }

    public void deleteMember(Long memberId) {
        Member member = memberMapper.selectById(memberId);
        if (member == null) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_EXISTS, "成员不存在");
        }
        memberMapper.deleteById(memberId);
    }

    public MemberDetailDTO getMemberDetail(Long memberId) {
        Member member = memberMapper.selectById(memberId);
        if (member == null) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_EXISTS, "成员不存在");
        }

        MemberDetailDTO.MemberDetailDTOBuilder builder = MemberDetailDTO.builder()
                .memberId(member.getId())
                .name(member.getName())
                .gender(member.getGender())
                .birthDate(member.getBirthDate())
                .deathDate(member.getDeathDate())
                .generation(member.getGeneration())
                .spouseName(member.getSpouseName())
                .fatherId(member.getFatherId())
                .motherId(member.getMotherId())
                .status(member.getStatus());

        // 查询父亲姓名
        if (member.getFatherId() != null) {
            Member father = memberMapper.selectById(member.getFatherId());
            if (father != null) {
                builder.fatherName(father.getName());
            }
        }

        // 查询母亲姓名
        if (member.getMotherId() != null) {
            Member mother = memberMapper.selectById(member.getMotherId());
            if (mother != null) {
                builder.motherName(mother.getName());
            }
        }

        return builder.build();
    }

    public PageDTO<MemberSimpleDTO> listMembers(Long userId, Integer page, Integer size,
                                                  String name, Integer generation) {
        User user = userMapper.selectById(userId);
        if (user == null || user.getFamilyId() == null) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_EXISTS, "用户未关联家族");
        }

        Page<Member> pageParam = new Page<>(page != null ? page : 1, size != null ? size : 20);
        LambdaQueryWrapper<Member> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Member::getFamilyId, user.getFamilyId());

        if (StringUtils.hasText(name)) {
            wrapper.like(Member::getName, name);
        }
        if (generation != null) {
            wrapper.eq(Member::getGeneration, generation);
        }

        wrapper.orderByAsc(Member::getGeneration, Member::getId);
        Page<Member> result = memberMapper.selectPage(pageParam, wrapper);

        PageDTO<MemberSimpleDTO> pageDTO = new PageDTO<>();
        pageDTO.setRecords(result.getRecords().stream()
                .map(m -> MemberSimpleDTO.builder()
                        .memberId(m.getId())
                        .name(m.getName())
                        .gender(m.getGender())
                        .generation(m.getGeneration())
                        .build())
                .toList());
        pageDTO.setTotal(result.getTotal());
        pageDTO.setPage((int) result.getCurrent());
        pageDTO.setSize((int) result.getSize());

        return pageDTO;
    }
}
