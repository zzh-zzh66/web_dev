package com.family.genealogy.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.family.genealogy.common.ErrorCode;
import com.family.genealogy.dto.*;
import com.family.genealogy.entity.User;
import com.family.genealogy.exception.BusinessException;
import com.family.genealogy.mapper.UserMapper;
import com.family.genealogy.util.JwtUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;

    public AuthService(UserMapper userMapper, PasswordEncoder passwordEncoder, JwtUtils jwtUtils) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtils = jwtUtils;
    }

    public Long register(RegisterRequest request) {
        // 检查手机号是否已注册
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getPhone, request.getPhone());
        if (userMapper.selectCount(wrapper) > 0) {
            throw new BusinessException(ErrorCode.AUTH_PHONE_EXISTS, "手机号已注册");
        }

        User user = new User();
        user.setPhone(request.getPhone());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setName(request.getName());
        user.setRole("ADMIN");
        user.setStatus(1);
        userMapper.insert(user);

        return user.getId();
    }

    public LoginResponse login(LoginRequest request) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getPhone, request.getPhone());
        User user = userMapper.selectOne(wrapper);

        if (user == null || !passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException(ErrorCode.AUTH_CREDENTIALS_ERROR, "用户名或密码错误");
        }

        String token = jwtUtils.generateToken(user.getId(), user.getPhone());

        LoginResponse.UserDTO userDTO = LoginResponse.UserDTO.builder()
                .userId(user.getId())
                .phone(user.getPhone())
                .name(user.getName())
                .role(user.getRole())
                .build();

        return LoginResponse.builder()
                .token(token)
                .user(userDTO)
                .build();
    }

    public void logout() {
        // JWT无状态，logout由前端处理，直接返回成功
    }

    public UserProfileDTO getProfile(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_EXISTS, "用户不存在");
        }

        return UserProfileDTO.builder()
                .userId(user.getId())
                .phone(user.getPhone())
                .name(user.getName())
                .role(user.getRole())
                .familyId(user.getFamilyId())
                .build();
    }

    public void updateProfile(Long userId, UpdateProfileRequest request) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_EXISTS, "用户不存在");
        }

        if (request.getName() != null) {
            user.setName(request.getName());
        }
        userMapper.updateById(user);
    }
}
