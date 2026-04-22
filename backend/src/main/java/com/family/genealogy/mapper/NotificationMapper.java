package com.family.genealogy.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.family.genealogy.entity.Notification;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 通知Mapper
 */
@Mapper
public interface NotificationMapper extends BaseMapper<Notification> {

    /**
     * 按类型分组统计未读数
     */
    List<Map<String, Object>> countUnreadByType(@Param("userId") Long userId);
}
