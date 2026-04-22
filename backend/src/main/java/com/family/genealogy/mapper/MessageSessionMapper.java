package com.family.genealogy.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.family.genealogy.entity.MessageSession;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 私信会话Mapper
 */
@Mapper
public interface MessageSessionMapper extends BaseMapper<MessageSession> {

    /**
     * 查询用户会话列表(含最后消息、对方信息)
     */
    List<Map<String, Object>> selectUserSessions(
            @Param("userId") Long userId
    );

    /**
     * 根据session_key查询会话
     */
    MessageSession selectBySessionKey(@Param("sessionKey") String sessionKey);
}
