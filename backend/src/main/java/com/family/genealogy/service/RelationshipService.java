package com.family.genealogy.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.family.genealogy.dto.RelationshipDTO;
import com.family.genealogy.entity.Member;
import com.family.genealogy.entity.User;
import com.family.genealogy.mapper.MemberMapper;
import com.family.genealogy.mapper.UserMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 关系服务
 * 负责亲属关系判定、关系标签生成
 */
@Slf4j
@Service
public class RelationshipService {

    private final UserMapper userMapper;
    private final MemberMapper memberMapper;

    public RelationshipService(UserMapper userMapper, MemberMapper memberMapper) {
        this.userMapper = userMapper;
        this.memberMapper = memberMapper;
    }

    /**
     * 获取两个用户的关系
     */
    public RelationshipDTO getRelationship(Long userId, Long targetUserId) {
        User user1 = userMapper.selectById(userId);
        User user2 = userMapper.selectById(targetUserId);

        if (user1 == null || user2 == null) {
            return RelationshipDTO.builder()
                    .isRelative(false)
                    .sameFamily(false)
                    .build();
        }

        boolean sameFamily = user1.getFamilyId() != null && user1.getFamilyId().equals(user2.getFamilyId());

        if (!sameFamily) {
            return RelationshipDTO.builder()
                    .isRelative(false)
                    .sameFamily(false)
                    .build();
        }

        // 获取成员信息
        Member member1 = getMemberByUserId(userId);
        Member member2 = getMemberByUserId(targetUserId);

        if (member1 == null || member2 == null) {
            return RelationshipDTO.builder()
                    .isRelative(false)
                    .sameFamily(true)
                    .build();
        }

        // 判断是否亲属并计算关系标签
        boolean isRelative = checkIsRelative(member1, member2);
        String label = calculateRelationshipLabel(member1, member2);
        int genDiff = 0;
        if (member1.getGeneration() != null && member2.getGeneration() != null) {
            genDiff = member2.getGeneration() - member1.getGeneration();
        }

        String pathDesc = generatePathDescription(member1, member2, label);

        return RelationshipDTO.builder()
                .isRelative(isRelative)
                .sameFamily(true)
                .relationshipLabel(label)
                .generationDiff(genDiff)
                .pathDescription(pathDesc)
                .build();
    }

    /**
     * 判断是否为亲属
     */
    public boolean isRelative(Long userId1, Long userId2) {
        Member member1 = getMemberByUserId(userId1);
        Member member2 = getMemberByUserId(userId2);

        if (member1 == null || member2 == null) {
            return false;
        }

        return checkIsRelative(member1, member2);
    }

    /**
     * 获取关系标签
     */
    public String getRelationshipLabel(Long userId1, Long userId2) {
        Member member1 = getMemberByUserId(userId1);
        Member member2 = getMemberByUserId(userId2);

        if (member1 == null || member2 == null) {
            return null;
        }

        return calculateRelationshipLabel(member1, member2);
    }

    // ==================== 私有辅助方法 ====================

    /**
     * 根据用户ID查询成员
     */
    private Member getMemberByUserId(Long userId) {
        // 通过查询所有成员来查找关联的（简化实现）
        LambdaQueryWrapper<Member> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Member::getFamilyId, userMapper.selectById(userId).getFamilyId());
        List<Member> members = memberMapper.selectList(wrapper);
        // 实际业务中应通过user_id关联查询
        return null;
    }

    /**
     * BFS检查两个成员是否亲属
     * 通过族谱树中的father_id/mother_id关系判定连通性
     */
    private boolean checkIsRelative(Member member1, Member member2) {
        if (member1.getFamilyId() == null || !member1.getFamilyId().equals(member2.getFamilyId())) {
            return false;
        }

        // BFS遍历族谱树，从member1开始查找是否能到达member2
        Set<Long> visited = new HashSet<>();
        Queue<Long> queue = new LinkedList<>();
        queue.offer(member1.getId());
        visited.add(member1.getId());

        // 获取同族谱所有成员建立索引
        Map<Long, Member> memberMap = getAllMembersByFamilyId(member1.getFamilyId());

        while (!queue.isEmpty()) {
            Long currentId = queue.poll();
            if (currentId.equals(member2.getId())) {
                return true;
            }

            Member current = memberMap.get(currentId);
            if (current == null) continue;

            // 向上遍历：父亲
            if (current.getFatherId() != null && !visited.contains(current.getFatherId())) {
                visited.add(current.getFatherId());
                queue.offer(current.getFatherId());
            }

            // 向上遍历：母亲
            if (current.getMotherId() != null && !visited.contains(current.getMotherId())) {
                visited.add(current.getMotherId());
                queue.offer(current.getMotherId());
            }
        }

        return false;
    }

    /**
     * 计算关系标签
     */
    private String calculateRelationshipLabel(Member member1, Member member2) {
        if (member1.getFatherId() != null && member1.getFatherId().equals(member2.getId())) {
            return "父亲";
        }
        if (member1.getMotherId() != null && member1.getMotherId().equals(member2.getId())) {
            return "母亲";
        }

        // 简化处理：同代判断兄弟姐妹
        if (member1.getGeneration() != null && member2.getGeneration() != null
                && member1.getGeneration().equals(member2.getGeneration())) {
            if (member1.getFatherId() != null && member1.getFatherId().equals(member2.getFatherId())) {
                return "兄弟/姐妹";
            }
        }

        // 实际实现需要更复杂的关系计算算法
        return null;
    }

    /**
     * 生成路径描述
     */
    private String generatePathDescription(Member member1, Member member2, String label) {
        if (label == null) {
            return null;
        }
        return "通过族谱关系关联: " + label;
    }

    /**
     * 获取同族谱所有成员
     */
    private Map<Long, Member> getAllMembersByFamilyId(Long familyId) {
        LambdaQueryWrapper<Member> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Member::getFamilyId, familyId);
        List<Member> members = memberMapper.selectList(wrapper);

        Map<Long, Member> map = new HashMap<>();
        for (Member m : members) {
            map.put(m.getId(), m);
        }
        return map;
    }
}
