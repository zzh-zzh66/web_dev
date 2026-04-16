-- ================================================
-- 家族族谱管理系统 - 个人主页模块数据库Schema
-- 版本: v2.0 个人主页模块
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
-- 1. 家族表 (t_family) - 已有
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
-- 2. 用户表 (t_user) - 已有
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
-- 3. 成员表 (t_member) - 已有
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

    -- 扩展信息
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
-- ================================================
ALTER TABLE t_member
    ADD CONSTRAINT fk_member_father FOREIGN KEY (father_id)
        REFERENCES t_member(id) ON DELETE SET NULL ON UPDATE CASCADE,
    ADD CONSTRAINT fk_member_mother FOREIGN KEY (mother_id)
        REFERENCES t_member(id) ON DELETE SET NULL ON UPDATE CASCADE;

-- ================================================
-- 4. 动态表 (t_post) - 新增
-- 功能: 存储用户发布的动态内容
-- ================================================
DROP TABLE IF EXISTS t_post;

CREATE TABLE t_post (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '动态ID',
    member_id       BIGINT NOT NULL COMMENT '发布者成员ID',
    author_user_id  BIGINT NOT NULL COMMENT '发布者用户ID',

    -- 动态内容
    title           VARCHAR(200) COMMENT '动态标题',
    content         TEXT NOT NULL COMMENT '动态正文内容',
    post_type       ENUM('LIFE_EVENT', 'MILESTONE', 'MEMORY', 'THOUGHT', 'DAILY') DEFAULT 'DAILY' COMMENT '动态类型',
    event_date      DATE COMMENT '事件发生日期',
    event_place     VARCHAR(200) COMMENT '事件发生地点',

    -- 媒体文件
    images          VARCHAR(2000) COMMENT '图片URL列表(JSON数组)',

    -- 关联人物
    tagged_members  VARCHAR(500) COMMENT '被标记的成员ID列表(JSON数组)',

    -- 可见范围
    visibility      ENUM('PUBLIC', 'FAMILY', 'RELATIVES', 'PRIVATE') DEFAULT 'FAMILY' COMMENT '可见范围',

    -- 统计数据
    like_count      INT DEFAULT 0 COMMENT '点赞数',
    comment_count   INT DEFAULT 0 COMMENT '评论数',
    view_count      INT DEFAULT 0 COMMENT '浏览数',

    -- 状态和审计
    status          TINYINT DEFAULT 1 COMMENT '状态: 1-正常, 0-已删除',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    -- 外键约束
    CONSTRAINT fk_post_member FOREIGN KEY (member_id)
        REFERENCES t_member(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_post_author FOREIGN KEY (author_user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,

    -- 索引优化
    INDEX idx_post_member (member_id),
    INDEX idx_post_author (author_user_id),
    INDEX idx_post_type (post_type),
    INDEX idx_post_created_at (created_at),
    INDEX idx_post_status (status),
    INDEX idx_post_visibility (visibility),
    INDEX idx_post_member_created (member_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动态表';

-- ================================================
-- 5. 评论表 (t_comment) - 新增
-- 功能: 存储动态的评论内容
-- ================================================
DROP TABLE IF EXISTS t_comment;

CREATE TABLE t_comment (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评论ID',
    post_id         BIGINT NOT NULL COMMENT '所属动态ID',
    parent_id       BIGINT COMMENT '父评论ID(用于回复嵌套, NULL为顶级评论)',
    user_id         BIGINT NOT NULL COMMENT '评论者用户ID',
    member_id       BIGINT NOT NULL COMMENT '评论者成员ID',

    -- 评论内容
    content         TEXT NOT NULL COMMENT '评论内容',
    mentioned_members VARCHAR(500) COMMENT '被@的成员ID列表(JSON数组)',

    -- 状态和审计
    status          TINYINT DEFAULT 1 COMMENT '状态: 1-正常, 0-已删除',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    -- 外键约束
    CONSTRAINT fk_comment_post FOREIGN KEY (post_id)
        REFERENCES t_post(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_comment_parent FOREIGN KEY (parent_id)
        REFERENCES t_comment(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_comment_user FOREIGN KEY (user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_comment_member FOREIGN KEY (member_id)
        REFERENCES t_member(id) ON DELETE CASCADE ON UPDATE CASCADE,

    -- 索引优化
    INDEX idx_comment_post (post_id),
    INDEX idx_comment_parent (parent_id),
    INDEX idx_comment_user (user_id),
    INDEX idx_comment_member (member_id),
    INDEX idx_comment_created_at (created_at),
    INDEX idx_comment_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';

-- ================================================
-- 6. 点赞表 (t_like) - 新增
-- 功能: 存储用户对动态的点赞记录
-- ================================================
DROP TABLE IF EXISTS t_like;

CREATE TABLE t_like (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '点赞ID',
    post_id         BIGINT NOT NULL COMMENT '被点赞的动态ID',
    user_id         BIGINT NOT NULL COMMENT '点赞用户ID',
    member_id       BIGINT NOT NULL COMMENT '点赞者成员ID',

    -- 状态和审计
    status          TINYINT DEFAULT 1 COMMENT '状态: 1-有效, 0-已取消',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',

    -- 外键约束
    CONSTRAINT fk_like_post FOREIGN KEY (post_id)
        REFERENCES t_post(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_like_user FOREIGN KEY (user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_like_member FOREIGN KEY (member_id)
        REFERENCES t_member(id) ON DELETE CASCADE ON UPDATE CASCADE,

    -- 唯一约束: 同一用户对同一动态只能点赞一次
    CONSTRAINT uk_like_post_user UNIQUE (post_id, user_id),

    -- 索引优化
    INDEX idx_like_post (post_id),
    INDEX idx_like_user (user_id),
    INDEX idx_like_member (member_id),
    INDEX idx_like_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='点赞表';

-- ================================================
-- 7. 留言板表 (t_guestbook) - 新增
-- 功能: 存储用户主页的留言记录
-- ================================================
DROP TABLE IF EXISTS t_guestbook;

CREATE TABLE t_guestbook (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '留言ID',
    owner_member_id BIGINT NOT NULL COMMENT '留言板所有者成员ID',
    user_id         BIGINT NOT NULL COMMENT '留言者用户ID',
    member_id       BIGINT NOT NULL COMMENT '留言者成员ID',
    parent_id       BIGINT COMMENT '父留言ID(用于回复嵌套)',

    -- 留言内容
    content         TEXT NOT NULL COMMENT '留言内容',

    -- 状态和审计
    status          TINYINT DEFAULT 1 COMMENT '状态: 1-正常, 0-已删除',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '留言时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    -- 外键约束
    CONSTRAINT fk_guestbook_owner FOREIGN KEY (owner_member_id)
        REFERENCES t_member(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_guestbook_user FOREIGN KEY (user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_guestbook_member FOREIGN KEY (member_id)
        REFERENCES t_member(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_guestbook_parent FOREIGN KEY (parent_id)
        REFERENCES t_guestbook(id) ON DELETE CASCADE ON UPDATE CASCADE,

    -- 索引优化
    INDEX idx_guestbook_owner (owner_member_id),
    INDEX idx_guestbook_user (user_id),
    INDEX idx_guestbook_member (member_id),
    INDEX idx_guestbook_parent (parent_id),
    INDEX idx_guestbook_created_at (created_at),
    INDEX idx_guestbook_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='留言板表';

-- ================================================
-- 8. 私信表 (t_message) - 新增
-- 功能: 存储用户间的私信记录
-- ================================================
DROP TABLE IF EXISTS t_message;

CREATE TABLE t_message (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '私信ID',
    sender_id       BIGINT NOT NULL COMMENT '发送者用户ID',
    sender_member_id BIGINT NOT NULL COMMENT '发送者成员ID',
    receiver_id     BIGINT NOT NULL COMMENT '接收者用户ID',
    receiver_member_id BIGINT NOT NULL COMMENT '接收者成员ID',

    -- 私信内容
    content         TEXT NOT NULL COMMENT '私信内容',

    -- 状态
    sender_deleted  TINYINT DEFAULT 0 COMMENT '发送者删除标志: 0-未删除, 1-已删除',
    receiver_deleted TINYINT DEFAULT 0 COMMENT '接收者删除标志: 0-未删除, 1-已删除',
    is_read         TINYINT DEFAULT 0 COMMENT '是否已读: 0-未读, 1-已读',

    -- 审计字段
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',

    -- 外键约束
    CONSTRAINT fk_message_sender FOREIGN KEY (sender_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_message_receiver FOREIGN KEY (receiver_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_message_sender_member FOREIGN KEY (sender_member_id)
        REFERENCES t_member(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_message_receiver_member FOREIGN KEY (receiver_member_id)
        REFERENCES t_member(id) ON DELETE CASCADE ON UPDATE CASCADE,

    -- 索引优化
    INDEX idx_message_sender (sender_id),
    INDEX idx_message_receiver (receiver_id),
    INDEX idx_message_sender_created (sender_id, created_at),
    INDEX idx_message_receiver_created (receiver_id, created_at),
    INDEX idx_message_sender_deleted (sender_deleted),
    INDEX idx_message_receiver_deleted (receiver_deleted),
    INDEX idx_message_is_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='私信表';

-- ================================================
-- 9. 通知表 (t_notification) - 新增
-- 功能: 存储用户的互动通知
-- ================================================
DROP TABLE IF EXISTS t_notification;

CREATE TABLE t_notification (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '通知ID',
    user_id         BIGINT NOT NULL COMMENT '通知接收者用户ID',
    member_id       BIGINT NOT NULL COMMENT '通知接收者成员ID',

    -- 通知来源
    trigger_user_id BIGINT NOT NULL COMMENT '触发通知的用户ID',
    trigger_member_id BIGINT NOT NULL COMMENT '触发通知的成员ID',

    -- 通知类型和内容
    type            ENUM('COMMENT', 'REPLY', 'LIKE', 'MESSAGE', 'MENTION', 'BIRTHDAY', 'ANNIVERSARY') NOT NULL COMMENT '通知类型',
    title           VARCHAR(200) COMMENT '通知标题',
    content         TEXT COMMENT '通知内容',

    -- 关联资源
    resource_type   VARCHAR(50) COMMENT '关联资源类型: post, comment, message',
    resource_id     BIGINT COMMENT '关联资源ID',

    -- 状态
    is_read         TINYINT DEFAULT 0 COMMENT '是否已读: 0-未读, 1-已读',

    -- 审计字段
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '通知时间',

    -- 外键约束
    CONSTRAINT fk_notification_user FOREIGN KEY (user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_notification_member FOREIGN KEY (member_id)
        REFERENCES t_member(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_notification_trigger_user FOREIGN KEY (trigger_user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_notification_trigger_member FOREIGN KEY (trigger_member_id)
        REFERENCES t_member(id) ON DELETE CASCADE ON UPDATE CASCADE,

    -- 索引优化
    INDEX idx_notification_user (user_id),
    INDEX idx_notification_member (member_id),
    INDEX idx_notification_type (type),
    INDEX idx_notification_is_read (is_read),
    INDEX idx_notification_created_at (created_at),
    INDEX idx_notification_user_read (user_id, is_read, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知表';

-- ================================================
-- 10. 用户资料扩展表 (t_user_profile) - 新增
-- 功能: 存储用户的个人主页扩展资料
-- ================================================
DROP TABLE IF EXISTS t_user_profile;

CREATE TABLE t_user_profile (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '资料ID',
    user_id         BIGINT NOT NULL COMMENT '用户ID',
    member_id       BIGINT NOT NULL COMMENT '关联成员ID',

    -- 封面和头像
    cover_url       VARCHAR(500) COMMENT '主页封面图片URL',
    avatar_url      VARCHAR(500) COMMENT '头像URL',

    -- 个人详细信息
    bio             VARCHAR(500) COMMENT '个人简介',
    occupation      VARCHAR(100) COMMENT '职业',
    birth_place     VARCHAR(200) COMMENT '出生地',
    current_place   VARCHAR(200) COMMENT '现居地',

    -- 兴趣信息
    hobbies         VARCHAR(500) COMMENT '兴趣爱好(JSON数组)',
    achievements    VARCHAR(1000) COMMENT '个人成就(JSON数组)',
    motto           VARCHAR(200) COMMENT '人生座右铭',

    -- 联系信息(仅对亲属可见)
    email           VARCHAR(100) COMMENT '电子邮箱',
    phone           VARCHAR(20) COMMENT '联系电话',

    -- 隐私设置
    privacy_setting ENUM('PUBLIC', 'FAMILY', 'RELATIVES', 'PRIVATE') DEFAULT 'FAMILY' COMMENT '资料可见度',

    -- 状态和审计
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    -- 外键约束
    CONSTRAINT fk_profile_user FOREIGN KEY (user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_profile_member FOREIGN KEY (member_id)
        REFERENCES t_member(id) ON DELETE CASCADE ON UPDATE CASCADE,

    -- 唯一约束: 一个用户只有一个资料
    CONSTRAINT uk_profile_user UNIQUE (user_id),
    CONSTRAINT uk_profile_member UNIQUE (member_id),

    -- 索引优化
    INDEX idx_profile_user (user_id),
    INDEX idx_profile_member (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户资料扩展表';

-- ================================================
-- 11. 关系表 (t_relation) - 已有
-- ================================================
DROP TABLE IF EXISTS t_relation;

CREATE TABLE t_relation (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '关系ID',
    member_a_id     BIGINT NOT NULL COMMENT '成员A ID',
    member_b_id     BIGINT NOT NULL COMMENT '成员B ID',
    relation_type   VARCHAR(20) NOT NULL COMMENT '关系类型',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    CONSTRAINT fk_relation_a FOREIGN KEY (member_a_id)
        REFERENCES t_member(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_relation_b FOREIGN KEY (member_b_id)
        REFERENCES t_member(id) ON DELETE CASCADE ON UPDATE CASCADE,

    INDEX idx_relation_members (member_a_id, member_b_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='关系表';

-- ================================================
-- 12. 媒体文件表 (t_media) - 已有
-- ================================================
DROP TABLE IF EXISTS t_media;

CREATE TABLE t_media (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '文件ID',
    member_id       BIGINT COMMENT '关联成员ID',
    user_id         BIGINT COMMENT '上传用户ID',
    file_name       VARCHAR(200) NOT NULL COMMENT '文件名',
    file_url        VARCHAR(500) COMMENT '访问URL',
    file_type       VARCHAR(20) COMMENT '文件类型',
    file_size       BIGINT COMMENT '文件大小(字节)',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',

    INDEX idx_media_member (member_id),
    INDEX idx_media_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='媒体文件表';

-- ================================================
-- Schema创建完成
-- ================================================
