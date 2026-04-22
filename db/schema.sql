-- ================================================
-- 家族族谱管理系统 - 数据库Schema脚本
-- 版本: v1.0 MVP
-- 数据库: MySQL 8.0
-- 字符集: utf8mb4
-- ================================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS family_genealogy
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE family_genealogy;

-- ================================================
-- 1. 家族表 (t_family)
-- 功能: 存储家族基本信息
-- ================================================
DROP TABLE IF EXISTS t_family;

CREATE TABLE t_family (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '家族ID',
    name            VARCHAR(100) NOT NULL COMMENT '家族名称',
    description     TEXT COMMENT '家族描述',
    origin_place    VARCHAR(200) COMMENT '家族起源地',
    logo_url        VARCHAR(500) COMMENT '家族标志URL',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted         TINYINT DEFAULT 0 COMMENT '删除标志: 0-未删除, 1-已删除',

    INDEX idx_family_name (name),
    INDEX idx_family_deleted (deleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='家族表';

-- ================================================
-- 2. 用户表 (t_user)
-- 功能: 存储用户账号信息，支持JWT认证
-- ================================================
DROP TABLE IF EXISTS t_user;

CREATE TABLE t_user (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    phone           VARCHAR(20) NOT NULL COMMENT '手机号(登录账号)',
    password        VARCHAR(255) NOT NULL COMMENT '密码(Bcrypt加密存储)',
    name            VARCHAR(50) COMMENT '用户姓名',
    avatar_url      VARCHAR(500) COMMENT '用户头像URL',
    family_id       BIGINT COMMENT '所属家族ID',
    role            ENUM('ADMIN', 'MEMBER') DEFAULT 'MEMBER' COMMENT '角色: ADMIN-管理员, MEMBER-普通成员',
    status          TINYINT DEFAULT 1 COMMENT '账号状态: 1-正常, 0-禁用',
    last_login_at   DATETIME COMMENT '最后登录时间',
    last_login_ip   VARCHAR(50) COMMENT '最后登录IP',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted         TINYINT DEFAULT 0 COMMENT '删除标志: 0-未删除, 1-已删除',

    -- 唯一约束: 手机号唯一
    CONSTRAINT uk_user_phone UNIQUE (phone),

    -- 索引优化
    INDEX idx_user_family (family_id),
    INDEX idx_user_role (role),
    INDEX idx_user_status (status),
    INDEX idx_user_deleted (deleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ================================================
-- 3. 成员表 (t_member)
-- 功能: 存储家族成员信息，支持族谱树形结构
-- ================================================
DROP TABLE IF EXISTS t_member;

CREATE TABLE t_member (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '成员ID',
    family_id       BIGINT NOT NULL COMMENT '所属家族ID',

    -- 基本信息
    name            VARCHAR(50) NOT NULL COMMENT '姓名',
    gender          ENUM('MALE', 'FEMALE') NOT NULL COMMENT '性别: MALE-男, FEMALE-女',

    -- 出生和死亡信息
    birth_date      DATE COMMENT '出生日期',
    birth_place     VARCHAR(200) COMMENT '出生地',
    death_date      DATE COMMENT '去世日期',

    -- 族谱关系
    generation      INT COMMENT '辈分(数字越大辈分越小, 如1为最大辈)',
    spouse_name     VARCHAR(50) COMMENT '配偶姓名',
    father_id       BIGINT COMMENT '父亲ID(指向t_member.id)',
    mother_id       BIGINT COMMENT '母亲ID(指向t_member.id)',

    -- 扩展信息(v2.0预留)
    portrait_url    VARCHAR(500) COMMENT '头像URL',
    biography       TEXT COMMENT '个人简介',
    occupation      VARCHAR(100) COMMENT '职业',

    -- 状态和审计字段
    status          ENUM('ALIVE', 'DECEASED') DEFAULT 'ALIVE' COMMENT '状态: ALIVE-在世, DECEASED-去世',
    created_by      BIGINT COMMENT '创建人用户ID',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted         TINYINT DEFAULT 0 COMMENT '删除标志: 0-未删除, 1-已删除',

    -- 外键约束
    CONSTRAINT fk_member_family FOREIGN KEY (family_id)
        REFERENCES t_family(id) ON DELETE RESTRICT ON UPDATE CASCADE,

    -- 索引优化(族谱查询关键索引)
    INDEX idx_member_family (family_id),
    INDEX idx_member_name (name),
    INDEX idx_member_gender (gender),
    INDEX idx_member_father (father_id),
    INDEX idx_member_mother (mother_id),
    INDEX idx_member_generation (generation),
    INDEX idx_member_status (status),
    INDEX idx_member_birth_date (birth_date),
    INDEX idx_member_deleted (deleted),

    -- 复合索引优化常见查询
    INDEX idx_member_family_generation (family_id, generation),
    INDEX idx_member_family_name (family_id, name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='家族成员表';

-- ================================================
-- 添加成员表的外键自引用约束(在表创建后添加)
-- 注意: MySQL外键自引用需要在表创建后添加
-- ================================================
ALTER TABLE t_member
    ADD CONSTRAINT fk_member_father FOREIGN KEY (father_id)
        REFERENCES t_member(id) ON DELETE SET NULL ON UPDATE CASCADE,
    ADD CONSTRAINT fk_member_mother FOREIGN KEY (mother_id)
        REFERENCES t_member(id) ON DELETE SET NULL ON UPDATE CASCADE;

-- ================================================
-- 初始化序列(可选,用于某些特殊场景)
-- ================================================
-- 注意: MySQL 8.0可以使用序列对象
-- CREATE SEQUENCE family_seq START WITH 1 INCREMENT BY 1;

-- ================================================
-- Schema创建完成
-- ================================================
