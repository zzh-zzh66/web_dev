package com.family.genealogy.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.family.genealogy.entity.TimelinePost;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 时间轴动态Mapper
 */
@Mapper
public interface TimelinePostMapper extends BaseMapper<TimelinePost> {

    /**
     * 分页查询动态列表(含用户信息、媒体列表、点赞状态)
     */
    List<Map<String, Object>> selectPostListWithDetails(
            @Param("userId") Long userId,
            @Param("requesterId") Long requesterId,
            @Param("categoryId") Long categoryId,
            @Param("year") Integer year,
            @Param("month") Integer month
    );

    /**
     * 查询动态详情(含用户信息)
     */
    Map<String, Object> selectPostDetail(@Param("postId") Long postId);
}
