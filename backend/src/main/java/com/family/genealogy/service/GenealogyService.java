package com.family.genealogy.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.family.genealogy.common.ErrorCode;
import com.family.genealogy.dto.GenealogyTreeDTO;
import com.family.genealogy.dto.MemberSimpleDTO;
import com.family.genealogy.entity.Member;
import com.family.genealogy.entity.User;
import com.family.genealogy.exception.BusinessException;
import com.family.genealogy.mapper.MemberMapper;
import com.family.genealogy.mapper.UserMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class GenealogyService {

    private final MemberMapper memberMapper;
    private final UserMapper userMapper;

    public GenealogyService(MemberMapper memberMapper, UserMapper userMapper) {
        this.memberMapper = memberMapper;
        this.userMapper = userMapper;
    }

    public GenealogyTreeDTO getGenealogyTree(Long userId, Long rootMemberId) {
        User user = userMapper.selectById(userId);
        if (user == null || user.getFamilyId() == null) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_EXISTS, "用户未关联家族");
        }

        Long familyId = user.getFamilyId();

        // 如果没有指定根节点，查找辈分最小的成员作为根节点
        Member rootMember;
        if (rootMemberId != null) {
            rootMember = memberMapper.selectById(rootMemberId);
            if (rootMember == null || !rootMember.getFamilyId().equals(familyId)) {
                throw new BusinessException(ErrorCode.MEMBER_NOT_EXISTS, "成员不存在");
            }
        } else {
            // 查找辈分最小的成员（generation值最小）
            LambdaQueryWrapper<Member> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Member::getFamilyId, familyId)
                    .orderByAsc(Member::getGeneration)
                    .last("LIMIT 1");
            rootMember = memberMapper.selectOne(wrapper);
            if (rootMember == null) {
                throw new BusinessException(ErrorCode.MEMBER_NOT_EXISTS, "族谱中暂无成员");
            }
        }

        return buildGenealogyTree(rootMember, familyId);
    }

    private GenealogyTreeDTO buildGenealogyTree(Member member, Long familyId) {
        GenealogyTreeDTO dto = GenealogyTreeDTO.builder()
                .memberId(member.getId())
                .name(member.getName())
                .gender(member.getGender())
                .generation(member.getGeneration())
                .children(new ArrayList<>())
                .build();

        // 查询所有子女
        LambdaQueryWrapper<Member> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Member::getFamilyId, familyId)
                .eq(Member::getFatherId, member.getId());
        List<Member> children = memberMapper.selectList(wrapper);

        // 同时查询母亲ID匹配的子女
        LambdaQueryWrapper<Member> motherWrapper = new LambdaQueryWrapper<>();
        motherWrapper.eq(Member::getFamilyId, familyId)
                .eq(Member::getMotherId, member.getId());
        List<Member> childrenFromMother = memberMapper.selectList(motherWrapper);

        // 合并去重
        Map<Long, Member> childMap = children.stream()
                .collect(Collectors.toMap(Member::getId, m -> m, (a, b) -> a));
        childrenFromMother.forEach(m -> childMap.putIfAbsent(m.getId(), m));

        for (Member child : childMap.values()) {
            dto.getChildren().add(buildGenealogyTree(child, familyId));
        }

        return dto;
    }

    public List<MemberSimpleDTO> getDescendants(Long memberId) {
        Member member = memberMapper.selectById(memberId);
        if (member == null) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_EXISTS, "成员不存在");
        }

        List<MemberSimpleDTO> descendants = new ArrayList<>();
        collectDescendants(memberId, member.getFamilyId(), descendants);
        return descendants;
    }

    private void collectDescendants(Long parentId, Long familyId, List<MemberSimpleDTO> descendants) {
        LambdaQueryWrapper<Member> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Member::getFamilyId, familyId)
                .eq(Member::getFatherId, parentId);
        List<Member> children = memberMapper.selectList(wrapper);

        LambdaQueryWrapper<Member> motherWrapper = new LambdaQueryWrapper<>();
        motherWrapper.eq(Member::getFamilyId, familyId)
                .eq(Member::getMotherId, parentId);
        List<Member> childrenFromMother = memberMapper.selectList(motherWrapper);

        Map<Long, Member> childMap = children.stream()
                .collect(Collectors.toMap(Member::getId, m -> m, (a, b) -> a));
        childrenFromMother.forEach(m -> childMap.putIfAbsent(m.getId(), m));

        for (Member child : childMap.values()) {
            descendants.add(MemberSimpleDTO.builder()
                    .memberId(child.getId())
                    .name(child.getName())
                    .gender(child.getGender())
                    .generation(child.getGeneration())
                    .build());
            collectDescendants(child.getId(), familyId, descendants);
        }
    }

    public List<MemberSimpleDTO> getAncestors(Long memberId) {
        Member member = memberMapper.selectById(memberId);
        if (member == null) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_EXISTS, "成员不存在");
        }

        List<MemberSimpleDTO> ancestors = new ArrayList<>();
        collectAncestors(member.getFatherId(), member.getMotherId(), ancestors);
        return ancestors;
    }

    private void collectAncestors(Long fatherId, Long motherId, List<MemberSimpleDTO> ancestors) {
        if (fatherId != null) {
            Member father = memberMapper.selectById(fatherId);
            if (father != null) {
                ancestors.add(MemberSimpleDTO.builder()
                        .memberId(father.getId())
                        .name(father.getName())
                        .gender(father.getGender())
                        .generation(father.getGeneration())
                        .build());
                collectAncestors(father.getFatherId(), father.getMotherId(), ancestors);
            }
        }

        if (motherId != null) {
            Member mother = memberMapper.selectById(motherId);
            if (mother != null) {
                ancestors.add(MemberSimpleDTO.builder()
                        .memberId(mother.getId())
                        .name(mother.getName())
                        .gender(mother.getGender())
                        .generation(mother.getGeneration())
                        .build());
                collectAncestors(mother.getFatherId(), motherId, ancestors);
            }
        }
    }
}
