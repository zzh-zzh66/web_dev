package com.family.genealogy.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.family.genealogy.entity.Comment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 评论Mapper
 */
@Mapper
public interface CommentMapper extends BaseMapper<Comment> {

    /**
     * 查询一级评论及回复(含用户信息、点赞状态)
     */
    List<Map<String, Object>> selectRootCommentsWithDetails(
            @Param("postId") Long postId,
            @Param("requesterId") Long requesterId
    );

    /**
     * 查询回复列表(含用户信息、点赞状态)
     */
    List<Map<String, Object>> selectRepliesWithDetails(
            @Param("rootId") Long rootId,
            @Param("requesterId") Long requesterId
    );
}
