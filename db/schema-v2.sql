-- ================================================
-- 家族族谱管理系统 V2.0 - 个人主页功能数据库Schema脚本
-- 版本: v2.0
-- 数据库: MySQL 8.0
-- 字符集: utf8mb4
-- 说明: 在v1.0基础上增量执行,无需修改现有表
-- ================================================

USE family_genealogy;

-- 禁用外键检查,避免DROP表时出现依赖错误
SET FOREIGN_KEY_CHECKS = 0;

-- ================================================
-- 1. 用户主页档案表 (t_user_profile)
-- 功能: 扩展用户个人信息,支持个人主页自定义
-- ================================================
DROP TABLE IF EXISTS t_user_profile;

CREATE TABLE t_user_profile (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id             BIGINT NOT NULL COMMENT '关联用户ID',
    member_id           BIGINT COMMENT '关联族谱成员ID',

    -- 个人信息
    bio                 TEXT COMMENT '个人简介/生平介绍',
    background_url      VARCHAR(500) COMMENT '主页背景图URL',
    signature           VARCHAR(200) COMMENT '个性签名',
    birth_place         VARCHAR(200) COMMENT '出生地',
    occupation          VARCHAR(100) COMMENT '职业',
    education           VARCHAR(100) COMMENT '学历',
    hometown            VARCHAR(200) COMMENT '籍贯',

    -- 扩展数据
    life_events         JSON COMMENT '人生大事记(JSON数组)',
    stats_json          JSON COMMENT '统计信息缓存(内容数、获赞数、访客数等)',

    -- 主页设置
    visit_count         BIGINT DEFAULT 0 COMMENT '主页访客数',
    theme               VARCHAR(50) DEFAULT 'default' COMMENT '主页主题风格',

    -- 状态和审计字段
    status              TINYINT DEFAULT 1 COMMENT '状态: 1-正常, 0-隐藏',
    created_by          BIGINT COMMENT '创建人',
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by          BIGINT COMMENT '最后修改人',
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted             TINYINT DEFAULT 0 COMMENT '软删除: 0-未删除, 1-已删除',

    -- 唯一约束
    CONSTRAINT uk_profile_user_id UNIQUE (user_id),

    -- 索引
    INDEX idx_profile_member_id (member_id),
    INDEX idx_profile_status (status),
    INDEX idx_profile_deleted (deleted),

    -- 外键约束
    CONSTRAINT fk_profile_user FOREIGN KEY (user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_profile_member FOREIGN KEY (member_id)
        REFERENCES t_member(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户主页档案表';


-- ================================================
-- 2. 动态分类表 (t_post_category)
-- 功能: 用户自定义的内容分类体系
-- 说明: 先于t_timeline_post创建,被其外键引用
-- ================================================
DROP TABLE IF EXISTS t_post_category;

CREATE TABLE t_post_category (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id             BIGINT COMMENT '所属用户ID, NULL表示系统预置分类',
    name                VARCHAR(50) NOT NULL COMMENT '分类名称',
    code                VARCHAR(50) COMMENT '分类编码(系统预置分类用)',
    icon                VARCHAR(100) COMMENT '分类图标',
    color               VARCHAR(20) COMMENT '分类颜色',
    description         VARCHAR(200) COMMENT '分类描述',
    sort_order          INT DEFAULT 0 COMMENT '排序序号',
    is_system           TINYINT DEFAULT 0 COMMENT '是否系统预置: 0-否, 1-是',
    post_count          INT DEFAULT 0 COMMENT '内容数量(冗余计数)',
    status              TINYINT DEFAULT 1 COMMENT '状态: 1-启用, 0-禁用',
    created_by          BIGINT COMMENT '创建人',
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by          BIGINT COMMENT '最后修改人',
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted             TINYINT DEFAULT 0 COMMENT '软删除: 0-未删除, 1-已删除',

    -- 索引
    INDEX idx_category_user_id (user_id, status, deleted),
    INDEX idx_category_code (code),
    INDEX idx_category_user_sort (user_id, sort_order),

    -- 外键约束(用户ID可为NULL,系统预置分类无关联用户)
    CONSTRAINT fk_category_user FOREIGN KEY (user_id)
        REFERENCES t_user(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动态分类表';


-- ================================================
-- 3. 时间轴动态表 (t_timeline_post)
-- 功能: 用户发布的时间轴动态内容
-- ================================================
DROP TABLE IF EXISTS t_timeline_post;

CREATE TABLE t_timeline_post (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id             BIGINT NOT NULL COMMENT '发布者用户ID',
    member_id           BIGINT COMMENT '关联族谱成员ID',
    category_id         BIGINT COMMENT '内容分类ID',

    -- 内容信息
    post_type           ENUM('TEXT', 'IMAGE', 'VIDEO', 'LIFE_EVENT') NOT NULL COMMENT '内容类型: TEXT-纯文本, IMAGE-图文, VIDEO-视频, LIFE_EVENT-生平事件',
    title               VARCHAR(200) COMMENT '内容标题',
    content             LONGTEXT COMMENT '内容正文(富文本HTML/Markdown)',
    event_date          DATE COMMENT '事件发生日期(用于生平时间线排序)',

    -- 权限和状态
    visibility          ENUM('PUBLIC', 'FAMILY', 'RELATIVE', 'PRIVATE') DEFAULT 'FAMILY' COMMENT '可见范围: PUBLIC-公开, FAMILY-全家族, RELATIVE-仅亲属, PRIVATE-仅自己',
    status              ENUM('DRAFT', 'PUBLISHED', 'HIDDEN', 'DELETED') DEFAULT 'PUBLISHED' COMMENT '状态: DRAFT-草稿, PUBLISHED-已发布, HIDDEN-已隐藏, DELETED-已删除',

    -- 统计计数(冗余)
    like_count          INT DEFAULT 0 COMMENT '点赞数',
    comment_count       INT DEFAULT 0 COMMENT '评论数',
    view_count          INT DEFAULT 0 COMMENT '浏览数',
    share_count         INT DEFAULT 0 COMMENT '分享数',

    -- 特殊标记
    is_top              TINYINT DEFAULT 0 COMMENT '是否置顶: 0-否, 1-是',
    is_essence          TINYINT DEFAULT 0 COMMENT '是否精华: 0-否, 1-是',

    -- 附加信息
    location            VARCHAR(200) COMMENT '发布地点',
    mood                VARCHAR(50) COMMENT '心情标签',
    ip_address          VARCHAR(50) COMMENT '发布IP地址',

    -- 审计字段
    created_by          BIGINT COMMENT '创建人',
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by          BIGINT COMMENT '最后修改人',
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted             TINYINT DEFAULT 0 COMMENT '软删除: 0-未删除, 1-已删除',

    -- 索引
    INDEX idx_timeline_user_id (user_id),
    INDEX idx_timeline_user_status (user_id, status, created_at),
    INDEX idx_timeline_member_id (member_id),
    INDEX idx_timeline_category (category_id),
    INDEX idx_timeline_event_date (event_date),
    INDEX idx_timeline_visibility (visibility, status),
    INDEX idx_timeline_created_at (created_at),
    INDEX idx_timeline_essence_top (is_essence, is_top, created_at),
    INDEX idx_timeline_deleted (deleted),

    -- 外键约束
    CONSTRAINT fk_timeline_user FOREIGN KEY (user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_timeline_member FOREIGN KEY (member_id)
        REFERENCES t_member(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_timeline_category FOREIGN KEY (category_id)
        REFERENCES t_post_category(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='时间轴动态表';


-- ================================================
-- 4. 动态媒体表 (t_post_media)
-- 功能: 存储动态关联的图片、视频等媒体文件
-- ================================================
DROP TABLE IF EXISTS t_post_media;

CREATE TABLE t_post_media (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    post_id             BIGINT NOT NULL COMMENT '关联动态ID',
    media_type          ENUM('IMAGE', 'VIDEO', 'AUDIO') NOT NULL COMMENT '媒体类型: IMAGE-图片, VIDEO-视频, AUDIO-音频',
    media_url           VARCHAR(500) NOT NULL COMMENT '媒体文件URL',
    thumb_url           VARCHAR(500) COMMENT '缩略图URL',
    original_name       VARCHAR(255) COMMENT '原始文件名',
    file_size           BIGINT DEFAULT 0 COMMENT '文件大小(字节)',
    width               INT COMMENT '图片/视频宽度',
    height              INT COMMENT '图片/视频高度',
    duration            INT COMMENT '视频时长(秒)',
    sort_order          INT DEFAULT 0 COMMENT '排序序号',
    is_cover            TINYINT DEFAULT 0 COMMENT '是否封面图: 0-否, 1-是',
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted             TINYINT DEFAULT 0 COMMENT '软删除: 0-未删除, 1-已删除',

    -- 索引
    INDEX idx_media_post_id (post_id),
    INDEX idx_media_type (media_type),
    INDEX idx_media_sort (post_id, sort_order),
    INDEX idx_media_deleted (deleted),

    -- 外键约束
    CONSTRAINT fk_media_post FOREIGN KEY (post_id)
        REFERENCES t_timeline_post(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动态媒体表';


-- ================================================
-- 5. 评论表 (t_comment)
-- 功能: 支持多层级评论回复(最多5层嵌套)
-- ================================================
DROP TABLE IF EXISTS t_comment;

CREATE TABLE t_comment (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    target_type         ENUM('POST', 'COMMENT', 'MESSAGE_BOARD') NOT NULL COMMENT '评论目标类型: POST-动态, COMMENT-评论, MESSAGE_BOARD-留言板',
    target_id           BIGINT NOT NULL COMMENT '评论目标ID',
    post_id             BIGINT COMMENT '关联动态ID(冗余字段,便于查询动态的所有评论)',
    parent_id           BIGINT COMMENT '父评论ID(自引用,实现多层级回复)',
    root_id             BIGINT COMMENT '根评论ID(一级评论的ID,便于快速查询评论树)',
    user_id             BIGINT NOT NULL COMMENT '评论者用户ID',
    reply_to_user_id    BIGINT COMMENT '回复的用户ID(@回复某人)',

    -- 内容
    content             TEXT NOT NULL COMMENT '评论内容',

    -- 统计
    like_count          INT DEFAULT 0 COMMENT '点赞数',

    -- 层级
    depth               TINYINT DEFAULT 0 COMMENT '评论层级深度(0-一级评论, 最大5)',

    -- 附加信息
    ip_address          VARCHAR(50) COMMENT '评论IP',
    status              ENUM('VISIBLE', 'HIDDEN', 'DELETED') DEFAULT 'VISIBLE' COMMENT '状态: VISIBLE-可见, HIDDEN-隐藏, DELETED-已删除',

    -- 审计字段
    created_by          BIGINT COMMENT '创建人',
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted             TINYINT DEFAULT 0 COMMENT '软删除: 0-未删除, 1-已删除',

    -- 索引
    INDEX idx_comment_target (target_type, target_id, status, deleted),
    INDEX idx_comment_post_id (post_id, status, created_at),
    INDEX idx_comment_parent_id (parent_id),
    INDEX idx_comment_root_id (root_id, depth, created_at),
    INDEX idx_comment_user_id (user_id, created_at),
    INDEX idx_comment_like_count (post_id, like_count),
    INDEX idx_comment_created_at (created_at),
    INDEX idx_comment_deleted (deleted),

    -- 外键约束
    CONSTRAINT fk_comment_post FOREIGN KEY (post_id)
        REFERENCES t_timeline_post(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_comment_parent FOREIGN KEY (parent_id)
        REFERENCES t_comment(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_comment_user FOREIGN KEY (user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_comment_reply_to FOREIGN KEY (reply_to_user_id)
        REFERENCES t_user(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';


-- ================================================
-- 6. 点赞记录表 (t_like_record)
-- 功能: 记录点赞行为,支持点赞/取消操作
-- ================================================
DROP TABLE IF EXISTS t_like_record;

CREATE TABLE t_like_record (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    target_type         ENUM('POST', 'COMMENT', 'MESSAGE_BOARD') NOT NULL COMMENT '点赞目标类型: POST-动态, COMMENT-评论, MESSAGE_BOARD-留言',
    target_id           BIGINT NOT NULL COMMENT '点赞目标ID',
    user_id             BIGINT NOT NULL COMMENT '点赞用户ID',
    status              ENUM('ACTIVE', 'CANCELLED') DEFAULT 'ACTIVE' COMMENT '状态: ACTIVE-已点赞, CANCELLED-已取消',
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    -- 唯一约束: 防重复点赞
    CONSTRAINT uk_like_record UNIQUE (target_type, target_id, user_id),

    -- 索引
    INDEX idx_like_user (user_id, created_at),
    INDEX idx_like_target (target_type, target_id, status),
    INDEX idx_like_status (status),

    -- 外键约束
    CONSTRAINT fk_like_record_user FOREIGN KEY (user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='点赞记录表';


-- ================================================
-- 7. 留言板表 (t_message_board)
-- 功能: 用户个人主页的公开留言板
-- ================================================
DROP TABLE IF EXISTS t_message_board;

CREATE TABLE t_message_board (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    owner_user_id       BIGINT NOT NULL COMMENT '留言板所有者用户ID',
    sender_id           BIGINT NOT NULL COMMENT '留言者用户ID',
    parent_id           BIGINT COMMENT '父留言ID(支持回复留言)',

    -- 内容
    content             TEXT NOT NULL COMMENT '留言内容',

    -- 统计
    like_count          INT DEFAULT 0 COMMENT '点赞数',
    reply_count         INT DEFAULT 0 COMMENT '回复数',

    -- 附加信息
    ip_address          VARCHAR(50) COMMENT '留言IP',
    is_hidden           TINYINT DEFAULT 0 COMMENT '是否隐藏: 0-显示, 1-隐藏(仅所有者可见)',
    status              ENUM('VISIBLE', 'HIDDEN', 'DELETED') DEFAULT 'VISIBLE' COMMENT '状态: VISIBLE-可见, HIDDEN-已隐藏, DELETED-已删除',

    -- 审计字段
    created_by          BIGINT COMMENT '创建人',
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted             TINYINT DEFAULT 0 COMMENT '软删除: 0-未删除, 1-已删除',

    -- 索引
    INDEX idx_board_owner (owner_user_id, status, created_at),
    INDEX idx_board_sender (sender_id, created_at),
    INDEX idx_board_parent (parent_id),
    INDEX idx_board_created_at (created_at),
    INDEX idx_board_deleted (deleted),

    -- 外键约束
    CONSTRAINT fk_board_owner FOREIGN KEY (owner_user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_board_sender FOREIGN KEY (sender_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_board_parent FOREIGN KEY (parent_id)
        REFERENCES t_message_board(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='留言板表';


-- ================================================
-- 8. 私信会话表 (t_message_session)
-- 功能: 管理用户间的一对一私信会话,维护会话级别聚合信息
-- 说明: 先于t_private_message创建,被其外键引用
-- ================================================
DROP TABLE IF EXISTS t_message_session;

CREATE TABLE t_message_session (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '会话ID',
    session_key         VARCHAR(50) NOT NULL COMMENT '会话唯一键: minId_maxId',
    user_id_1           BIGINT NOT NULL COMMENT '参与用户1(ID较小者)',
    user_id_2           BIGINT NOT NULL COMMENT '参与用户2(ID较大者)',

    -- 会话信息
    last_message        VARCHAR(500) COMMENT '最后一条消息摘要',
    last_message_time   DATETIME COMMENT '最后消息时间',

    -- 未读计数
    unread_count_1      INT DEFAULT 0 COMMENT '用户1未读消息数',
    unread_count_2      INT DEFAULT 0 COMMENT '用户2未读消息数',

    -- 审计字段
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    -- 唯一约束
    CONSTRAINT uk_session_key UNIQUE (session_key),

    -- 索引
    INDEX idx_user1 (user_id_1),
    INDEX idx_user2 (user_id_2),
    INDEX idx_last_time (last_message_time),

    -- 外键约束
    CONSTRAINT fk_session_user1 FOREIGN KEY (user_id_1)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_session_user2 FOREIGN KEY (user_id_2)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='私信会话表';


-- ================================================
-- 9. 私信表 (t_private_message)
-- 功能: 用户间的私信聊天
-- ================================================
DROP TABLE IF EXISTS t_private_message;

CREATE TABLE t_private_message (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    session_id          BIGINT COMMENT '关联会话ID',
    sender_id           BIGINT NOT NULL COMMENT '发送者用户ID',
    receiver_id         BIGINT NOT NULL COMMENT '接收者用户ID',

    -- 消息内容
    content             TEXT NOT NULL COMMENT '消息内容',
    msg_type            ENUM('TEXT', 'IMAGE', 'SYSTEM') DEFAULT 'TEXT' COMMENT '消息类型: TEXT-文本, IMAGE-图片, SYSTEM-系统消息',
    media_url           VARCHAR(500) COMMENT '媒体URL(图片等)',

    -- 状态
    is_read             TINYINT DEFAULT 0 COMMENT '是否已读: 0-未读, 1-已读',
    read_at             DATETIME COMMENT '阅读时间',
    status              TINYINT DEFAULT 1 COMMENT '状态: 1-正常, 0-已撤回',

    -- 审计字段
    created_by          BIGINT COMMENT '创建人(发送者)',
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted             TINYINT DEFAULT 0 COMMENT '发送方删除标志',
    receiver_deleted    TINYINT DEFAULT 0 COMMENT '接收方删除标志',

    -- 索引
    INDEX idx_pm_session_id (session_id, created_at),
    INDEX idx_pm_sender_receiver (sender_id, receiver_id, created_at),
    INDEX idx_pm_receiver_unread (receiver_id, is_read, created_at),
    INDEX idx_pm_receiver_list (receiver_id, sender_id, created_at),
    INDEX idx_pm_sender_list (sender_id, receiver_id, created_at),
    INDEX idx_pm_created_at (created_at),
    INDEX idx_pm_deleted (deleted, receiver_deleted),

    -- 外键约束
    CONSTRAINT fk_pm_session FOREIGN KEY (session_id)
        REFERENCES t_message_session(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_pm_sender FOREIGN KEY (sender_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pm_receiver FOREIGN KEY (receiver_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='私信表';


-- ================================================
-- 10. 通知表 (t_notification)
-- 功能: 系统通知、互动通知、@提醒统一管理
-- ================================================
DROP TABLE IF EXISTS t_notification;

CREATE TABLE t_notification (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    receiver_id         BIGINT NOT NULL COMMENT '接收者用户ID',
    sender_id           BIGINT COMMENT '发送者用户ID(系统通知为NULL)',

    -- 通知信息
    type                ENUM('COMMENT', 'REPLY', 'LIKE', 'AT_MENTION', 'MESSAGE_BOARD', 'PRIVATE_MESSAGE', 'FOLLOW', 'SYSTEM') NOT NULL COMMENT '通知类型',
    target_type         VARCHAR(50) COMMENT '关联目标类型: POST, COMMENT, MESSAGE_BOARD, PRIVATE_MESSAGE',
    target_id           BIGINT COMMENT '关联目标ID',
    content             VARCHAR(500) COMMENT '通知内容摘要',
    extra_data          JSON COMMENT '扩展数据',

    -- 状态
    is_read             TINYINT DEFAULT 0 COMMENT '是否已读: 0-未读, 1-已读',
    read_at             DATETIME COMMENT '阅读时间',
    status              TINYINT DEFAULT 1 COMMENT '状态: 1-正常, 0-已失效',

    -- 审计字段
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted             TINYINT DEFAULT 0 COMMENT '软删除: 0-未删除, 1-已删除',

    -- 索引
    INDEX idx_notification_receiver (receiver_id, is_read, created_at),
    INDEX idx_notification_receiver_type (receiver_id, type, created_at),
    INDEX idx_notification_unread_count (receiver_id, is_read),
    INDEX idx_notification_sender (sender_id, created_at),
    INDEX idx_notification_target (target_type, target_id),
    INDEX idx_notification_created_at (created_at),
    INDEX idx_notification_deleted (deleted),

    -- 外键约束
    CONSTRAINT fk_notification_receiver FOREIGN KEY (receiver_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_notification_sender FOREIGN KEY (sender_id)
        REFERENCES t_user(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知表';


-- ================================================
-- 11. 话题表 (t_topic)
-- 功能: 兴趣话题定义和管理
-- ================================================
DROP TABLE IF EXISTS t_topic;

CREATE TABLE t_topic (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    name                VARCHAR(50) NOT NULL COMMENT '话题名称',
    code                VARCHAR(50) COMMENT '话题编码',
    description         VARCHAR(200) COMMENT '话题描述',
    icon                VARCHAR(100) COMMENT '话题图标',
    cover_url           VARCHAR(500) COMMENT '话题封面图',
    post_count          INT DEFAULT 0 COMMENT '关联动态数(冗余计数)',
    participant_count   INT DEFAULT 0 COMMENT '参与人数(冗余计数)',
    status              TINYINT DEFAULT 1 COMMENT '状态: 1-启用, 0-禁用',
    created_by          BIGINT COMMENT '创建人',
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by          BIGINT COMMENT '最后修改人',
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted             TINYINT DEFAULT 0 COMMENT '软删除: 0-未删除, 1-已删除',

    -- 唯一约束
    CONSTRAINT uk_topic_name UNIQUE (name),
    CONSTRAINT uk_topic_code UNIQUE (code),

    -- 索引
    INDEX idx_topic_status (status, deleted),
    INDEX idx_topic_post_count (post_count)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='话题表';


-- ================================================
-- 12. 话题动态关联表 (t_topic_post)
-- 功能: 动态与话题的多对多关联
-- ================================================
DROP TABLE IF EXISTS t_topic_post;

CREATE TABLE t_topic_post (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    topic_id            BIGINT NOT NULL COMMENT '话题ID',
    post_id             BIGINT NOT NULL COMMENT '动态ID',
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '关联时间',

    -- 唯一约束
    CONSTRAINT uk_topic_post UNIQUE (topic_id, post_id),

    -- 索引
    INDEX idx_topic_post_topic (topic_id, created_at),
    INDEX idx_topic_post_post (post_id),

    -- 外键约束
    CONSTRAINT fk_topic_post_topic FOREIGN KEY (topic_id)
        REFERENCES t_topic(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_topic_post_post FOREIGN KEY (post_id)
        REFERENCES t_timeline_post(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='话题动态关联表';


-- ================================================
-- 13. 用户兴趣表 (t_user_interest)
-- 功能: 用户的兴趣标签设置
-- ================================================
DROP TABLE IF EXISTS t_user_interest;

CREATE TABLE t_user_interest (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id             BIGINT NOT NULL COMMENT '用户ID',
    interest_tag        VARCHAR(30) NOT NULL COMMENT '兴趣标签(如:#旅行#, #摄影#)',
    interest_level      TINYINT DEFAULT 1 COMMENT '兴趣程度: 1-一般, 2-喜欢, 3-热爱',
    sort_order          INT DEFAULT 0 COMMENT '排序序号',
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted             TINYINT DEFAULT 0 COMMENT '软删除: 0-未删除, 1-已删除',

    -- 唯一约束
    CONSTRAINT uk_user_interest UNIQUE (user_id, interest_tag, deleted),

    -- 索引
    INDEX idx_interest_user (user_id, sort_order),
    INDEX idx_interest_tag (interest_tag),

    -- 外键约束
    CONSTRAINT fk_interest_user FOREIGN KEY (user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户兴趣表';


-- ================================================
-- 14. 隐私设置表 (t_privacy_setting)
-- 功能: 用户个性化的隐私权限设置
-- ================================================
DROP TABLE IF EXISTS t_privacy_setting;

CREATE TABLE t_privacy_setting (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id             BIGINT NOT NULL COMMENT '用户ID',
    setting_key         VARCHAR(50) NOT NULL COMMENT '设置项标识',
    setting_value       VARCHAR(200) NOT NULL COMMENT '设置值',
    scope               ENUM('PUBLIC', 'FAMILY', 'PRIVATE') DEFAULT 'FAMILY' COMMENT '适用范围',
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    -- 唯一约束
    CONSTRAINT uk_privacy_setting UNIQUE (user_id, setting_key),

    -- 索引
    INDEX idx_privacy_user (user_id),

    -- 外键约束
    CONSTRAINT fk_privacy_user FOREIGN KEY (user_id)
        REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='隐私设置表';


-- ================================================
-- V2.0 Schema创建完成
-- 新增表: 14张
--   t_user_profile, t_post_category, t_timeline_post, t_post_media,
--   t_comment, t_like_record, t_message_board, t_message_session,
--   t_private_message, t_notification, t_topic, t_topic_post,
--   t_user_interest, t_privacy_setting
-- ================================================

-- 恢复外键检查
SET FOREIGN_KEY_CHECKS = 1;
