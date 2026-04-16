package com.family.genealogy.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.family.genealogy.entity.Message;
import org.apache.ibatis.annotations.Mapper;

/**
 * 私信Mapper接口
 */
@Mapper
public interface MessageMapper extends BaseMapper<Message> {
}
