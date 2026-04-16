package com.family.genealogy.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.family.genealogy.entity.Guestbook;
import org.apache.ibatis.annotations.Mapper;

/**
 * 留言板Mapper接口
 */
@Mapper
public interface GuestbookMapper extends BaseMapper<Guestbook> {
}
