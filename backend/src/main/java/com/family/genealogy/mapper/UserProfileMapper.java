package com.family.genealogy.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.family.genealogy.entity.UserProfile;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserProfileMapper extends BaseMapper<UserProfile> {
}
