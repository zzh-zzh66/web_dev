# 家族族谱系统 V2.0 - 个人主页功能数据库设计文档

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-04-16 | MVP版本：核心表结构（用户、成员、家族） |
| v2.0 | 2026-04-17 | 个人主页功能模块：社交互动平台数据库设计 |

---

## 一、数据库信息

| 属性 | 值 |
|------|---|
| 数据库类型 | MySQL 8.0 |
| 字符集 | utf8mb4 |
| 排序规则 | utf8mb4_unicode_ci |
| 数据库名称 | family_genealogy |
| 存储引擎 | InnoDB |

---

## 二、命名规范

```
表命名：t_{entity}
  - t_user_profile      # 用户主页档案表
  - t_timeline_post     # 时间轴动态表
  - t_post_media        # 动态媒体表

字段命名：snake_case
  - user_id
  - post_content
  - created_at

索引命名：idx_{table}_{column}
  - idx_timeline_post_user_id
  - idx_post_media_post_id

外键命名：fk_{table}_{ref_table}
  - fk_timeline_post_user
  - fk_post_media_post
```

---

## 三、数据库ER图(ASCII)

```
+----------------+       1:1       +------------------+       1:1       +-----------------+
|   t_family     |◄──────────────►|    t_user        |◄──────────────►| t_user_profile  |
|                |                |                  |                |                 |
| id (PK)        |                | id (PK)          |                | id (PK)         |
| name           |                | phone            |                | user_id (FK)    |
| description    |                | password         |                | bio             |
| origin_place   |                | name             |                | background_url  |
+----------------+                | family_id (FK)   |                | signature       |
        |                         | role             |                +-----------------+
        |                         | status           |                         |
        | 1                       +------------------+                         | N
        | N                             |                                      |
        | N                             | N                                    |
+----------------+                      |                           +------------------------+
|   t_member     |                      |                           |   t_timeline_post    |
|                |                      |                           |                      |
| id (PK)        |                      |                           | id (PK)              |
| family_id (FK) |                      |                           | user_id (FK)         |
| name           |                      |                           | member_id (FK)       |
| gender         |                      |                           | category_id (FK)     |
| father_id (FK) |                      |                           | post_type            |
| mother_id (FK) |                      |                           | title                |
| generation     |                      |                           | content              |
+----------------+                      |                           | visibility           |
        |                               |                           | status               |
        | 关联查询                       |                           | like_count           |
        | 亲属关系                       |                           | comment_count        |
        ▼                               ▼                           +------------------------+
+----------------+              +------------------+                        | N
|  亲属关系查询   |              |  权限判定逻辑     |                        |
|  (业务层)      |              |  (业务层)         |                        |
+----------------+              +------------------+                        ▼
                                                             +------------------------+
                                                             |    t_post_media        |
                                                             |                        |
                                                             | id (PK)                |
                                                             | post_id (FK)           |
                                                             | media_type             |
                                                             | media_url              |
                                                             | sort_order             |
                                                             | thumb_url              |
                                                             +------------------------+

+------------------------+        +------------------------+        +------------------------+
|   t_post_category      |        |      t_comment         |        |     t_like_record      |
|                        |        |                        |        |                        |
| id (PK)                |        | id (PK)                |        | id (PK)                |
| user_id (FK)           |        | target_type            |        | target_type            |
| name                   |        | target_id              |        | target_id              |
| code                   |        | post_id (FK)           |        | user_id (FK)           |
| icon                   |        | parent_id (FK)         |        | status                 |
| sort_order             |        | content                |        | created_at             |
+------------------------+        | like_count             |        +------------------------+
                                  | depth                  |
                                  +------------------------+

+------------------------+        +------------------------+        +------------------------+
|    t_message_board     |        |   t_message_session    |        |     t_notification     |
|                        |        |                        |        |                        |
| id (PK)                |        | id (PK)                |        | id (PK)                |
| owner_user_id (FK)     |        | session_key (UK)       |        | receiver_id (FK)       |
| sender_id (FK)         |        | user_id_1 (FK)         |        | sender_id (FK)         |
| content                |        | user_id_2 (FK)         |        | type                   |
| like_count             |        | last_message           |        | target_type            |
| is_hidden              |        | last_message_time      |        | target_id              |
+------------------------+        | unread_count_1/2       |        | content                |
                                  +------------------------+        | is_read                |
                                        │ 1                        +------------------------+
                                        │
                                        │ N
                                  +------------------------+
                                  |   t_private_message    |
                                  |                        |
                                  | id (PK)                |
                                  | session_id (FK)        |
                                  | sender_id (FK)         |
                                  | receiver_id (FK)       |
                                  | content                |
                                  | msg_type               |
                                  | is_read                |
                                  | session_key (备用)     |
                                  +------------------------+

+------------------------+        +------------------------+        +------------------------+
|       t_topic          |        |    t_topic_post        |        |   t_user_interest      |
|                        |        |                        |        |                        |
| id (PK)                |        | id (PK)                |        | id (PK)                |
| name                   |        | topic_id (FK)          |        | user_id (FK)           |
| code                   |        | post_id (FK)           |        | interest_tag           |
| description            |        |                        |        | interest_level         |
| post_count             |        +------------------------+        +------------------------+
+------------------------+

+------------------------+
|   t_privacy_setting    |
|                        |
| id (PK)                |
| user_id (FK)           |
| setting_key            |
| setting_value          |
| scope                  |
+------------------------+
```

---

## 四、表结构详细说明

### 4.1 t_user_profile (用户主页档案表)

**用途**: 扩展用户个人信息，支持个人主页自定义设置

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键ID |
| user_id | BIGINT | NOT NULL, UNIQUE, FK | 关联用户ID (t_user.id) |
| member_id | BIGINT | NULL, FK | 关联成员ID (t_member.id)，建立用户与族谱成员关联 |
| bio | TEXT | NULL | 个人简介/生平介绍 |
| background_url | VARCHAR(500) | NULL | 主页背景图URL |
| signature | VARCHAR(200) | NULL | 个性签名 |
| birth_place | VARCHAR(200) | NULL | 出生地 |
| occupation | VARCHAR(100) | NULL | 职业 |
| education | VARCHAR(100) | NULL | 学历 |
| hometown | VARCHAR(200) | NULL | 籍贯 |
| life_events | JSON | NULL | 人生大事记（时间线关键事件） |
| stats_json | JSON | NULL | 统计信息缓存（内容数、获赞数、访客数等） |
| visit_count | BIGINT | DEFAULT 0 | 主页访客数 |
| theme | VARCHAR(50) | DEFAULT 'default' | 主页主题风格 |
| status | TINYINT | DEFAULT 1 | 状态：1-正常, 0-隐藏 |
| created_by | BIGINT | NULL | 创建人（通常为本人） |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_by | BIGINT | NULL | 最后修改人 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
| deleted | TINYINT | DEFAULT 0 | 软删除：0-未删除, 1-已删除 |

**索引设计**:
- `uk_profile_user_id` (user_id) - UNIQUE，用户与主页一对一
- `idx_profile_member_id` (member_id) - 关联族谱成员查询
- `idx_profile_status` (status) - 状态过滤
- `idx_profile_deleted` (deleted) - 软删除过滤

**外键约束**:
- `fk_profile_user`: user_id -> t_user.id ON DELETE CASCADE
- `fk_profile_member`: member_id -> t_member.id ON DELETE SET NULL

---

### 4.2 t_timeline_post (时间轴动态表)

**用途**: 用户发布的时间轴动态内容（生平日志、家族故事、照片、视频等）

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键ID |
| user_id | BIGINT | NOT NULL, FK | 发布者用户ID (t_user.id) |
| member_id | BIGINT | NULL, FK | 关联成员ID，用于族谱关系查询 |
| category_id | BIGINT | NULL, FK | 内容分类ID (t_post_category.id) |
| post_type | ENUM | NOT NULL | 内容类型: TEXT-纯文本, IMAGE-图文, VIDEO-视频, LIFE_EVENT-生平事件 |
| title | VARCHAR(200) | NULL | 内容标题 |
| content | LONGTEXT | NULL | 内容正文（富文本HTML/Markdown） |
| event_date | DATE | NULL | 事件发生日期（用于生平时间线排序） |
| visibility | ENUM | DEFAULT 'FAMILY' | 可见范围: PUBLIC-公开, FAMILY-全家族, RELATIVE-仅亲属, PRIVATE-仅自己 |
| status | ENUM | DEFAULT 'PUBLISHED' | 状态: DRAFT-草稿, PUBLISHED-已发布, HIDDEN-已隐藏, DELETED-已删除 |
| like_count | INT | DEFAULT 0 | 点赞数（冗余计数） |
| comment_count | INT | DEFAULT 0 | 评论数（冗余计数） |
| view_count | INT | DEFAULT 0 | 浏览数 |
| share_count | INT | DEFAULT 0 | 分享数 |
| is_top | TINYINT | DEFAULT 0 | 是否置顶: 0-否, 1-是 |
| is_essence | TINYINT | DEFAULT 0 | 是否精华: 0-否, 1-是 |
| location | VARCHAR(200) | NULL | 发布地点 |
| mood | VARCHAR(50) | NULL | 心情标签 |
| ip_address | VARCHAR(50) | NULL | 发布IP地址 |
| created_by | BIGINT | NULL | 创建人 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_by | BIGINT | NULL | 最后修改人 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
| deleted | TINYINT | DEFAULT 0 | 软删除 |

**索引设计**:
- `idx_timeline_user_id` (user_id) - 用户动态查询
- `idx_timeline_user_status` (user_id, status, created_at) - 复合索引：用户已发布动态按时间排序
- `idx_timeline_member_id` (member_id) - 通过成员查询动态
- `idx_timeline_category` (category_id) - 按分类查询
- `idx_timeline_event_date` (event_date) - 按事件日期排序（时间轴）
- `idx_timeline_visibility` (visibility, status) - 可见性和状态过滤
- `idx_timeline_created_at` (created_at) - 全局时间排序
- `idx_timeline_essence_top` (is_essence, is_top, created_at) - 精华/置顶查询
- `idx_timeline_deleted` (deleted) - 软删除过滤

**外键约束**:
- `fk_timeline_user`: user_id -> t_user.id ON DELETE CASCADE
- `fk_timeline_member`: member_id -> t_member.id ON DELETE SET NULL
- `fk_timeline_category`: category_id -> t_post_category.id ON DELETE SET NULL

**分区策略** (数据量超过100万行时启用):
```sql
PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p2027 VALUES LESS THAN (2028),
    PARTITION p_future VALUES LESS THAN MAXVALUE
)
```

---

### 4.3 t_post_media (动态媒体表)

**用途**: 存储动态关联的图片、视频等媒体文件信息

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键ID |
| post_id | BIGINT | NOT NULL, FK | 关联动态ID (t_timeline_post.id) |
| media_type | ENUM | NOT NULL | 媒体类型: IMAGE-图片, VIDEO-视频, AUDIO-音频 |
| media_url | VARCHAR(500) | NOT NULL | 媒体文件URL |
| thumb_url | VARCHAR(500) | NULL | 缩略图URL |
| original_name | VARCHAR(255) | NULL | 原始文件名 |
| file_size | BIGINT | DEFAULT 0 | 文件大小（字节） |
| width | INT | NULL | 图片/视频宽度 |
| height | INT | NULL | 图片/视频高度 |
| duration | INT | NULL | 视频时长（秒） |
| sort_order | INT | DEFAULT 0 | 排序序号（多图排序） |
| is_cover | TINYINT | DEFAULT 0 | 是否封面图: 0-否, 1-是 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
| deleted | TINYINT | DEFAULT 0 | 软删除 |

**索引设计**:
- `idx_media_post_id` (post_id) - 查询动态的所有媒体
- `idx_media_type` (media_type) - 按媒体类型过滤
- `idx_media_sort` (post_id, sort_order) - 排序查询
- `idx_media_deleted` (deleted) - 软删除过滤

**外键约束**:
- `fk_media_post`: post_id -> t_timeline_post.id ON DELETE CASCADE

---

### 4.4 t_post_category (动态分类表)

**用途**: 用户自定义的内容分类体系

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键ID |
| user_id | BIGINT | NOT NULL, FK | 所属用户ID (t_user.id)，NULL表示系统预置分类 |
| name | VARCHAR(50) | NOT NULL | 分类名称 |
| code | VARCHAR(50) | NULL | 分类编码（系统预置分类用） |
| icon | VARCHAR(100) | NULL | 分类图标 |
| color | VARCHAR(20) | NULL | 分类颜色 |
| description | VARCHAR(200) | NULL | 分类描述 |
| sort_order | INT | DEFAULT 0 | 排序序号 |
| is_system | TINYINT | DEFAULT 0 | 是否系统预置: 0-否, 1-是 |
| post_count | INT | DEFAULT 0 | 内容数量（冗余计数） |
| status | TINYINT | DEFAULT 1 | 状态: 1-启用, 0-禁用 |
| created_by | BIGINT | NULL | 创建人 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_by | BIGINT | NULL | 最后修改人 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
| deleted | TINYINT | DEFAULT 0 | 软删除 |

**索引设计**:
- `idx_category_user_id` (user_id, status, deleted) - 用户分类查询
- `idx_category_code` (code) - 系统预置分类查询
- `idx_category_user_sort` (user_id, sort_order) - 用户分类排序

**外键约束**:
- `fk_category_user`: user_id -> t_user.id ON DELETE CASCADE

**系统预置分类**:
- LIFE_LOG (生平日志)
- FAMILY_STORY (家族故事)
- PHOTO_WALL (照片墙)
- VIDEO_COLLECTION (视频集)
- MOOD_DIARY (心情随笔)
- IMPORTANT_EVENT (重要事件)

---

### 4.5 t_comment (评论表)

**用途**: 支持多层级评论回复，采用邻接表模型+深度限制（最多5层）

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键ID |
| target_type | ENUM | NOT NULL | 评论目标类型: POST-动态, COMMENT-评论, MESSAGE_BOARD-留言板 |
| target_id | BIGINT | NOT NULL | 评论目标ID |
| post_id | BIGINT | NULL, FK | 关联动态ID（冗余字段，便于查询动态的所有评论）(t_timeline_post.id) |
| parent_id | BIGINT | NULL, FK | 父评论ID（自引用，实现多层级回复）(t_comment.id) |
| root_id | BIGINT | NULL | 根评论ID（一级评论的ID，便于快速查询评论树） |
| user_id | BIGINT | NOT NULL, FK | 评论者用户ID (t_user.id) |
| reply_to_user_id | BIGINT | NULL, FK | 回复的用户ID（@回复某人）(t_user.id) |
| content | TEXT | NOT NULL | 评论内容 |
| like_count | INT | DEFAULT 0 | 点赞数 |
| depth | TINYINT | DEFAULT 0 | 评论层级深度（0-一级评论, 最大5） |
| ip_address | VARCHAR(50) | NULL | 评论IP |
| status | ENUM | DEFAULT 'VISIBLE' | 状态: VISIBLE-可见, HIDDEN-隐藏, DELETED-已删除 |
| created_by | BIGINT | NULL | 创建人 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
| deleted | TINYINT | DEFAULT 0 | 软删除 |

**索引设计**:
- `idx_comment_target` (target_type, target_id, status, deleted) - 查询目标的所有评论
- `idx_comment_post_id` (post_id, status, created_at) - 动态评论查询
- `idx_comment_parent_id` (parent_id) - 查询回复
- `idx_comment_root_id` (root_id, depth, created_at) - 评论树查询
- `idx_comment_user_id` (user_id, created_at) - 用户评论历史
- `idx_comment_like_count` (post_id, like_count) - 热门评论排序
- `idx_comment_created_at` (created_at) - 时间排序
- `idx_comment_deleted` (deleted) - 软删除过滤

**外键约束**:
- `fk_comment_post`: post_id -> t_timeline_post.id ON DELETE CASCADE
- `fk_comment_parent`: parent_id -> t_comment.id ON DELETE SET NULL
- `fk_comment_user`: user_id -> t_user.id ON DELETE CASCADE
- `fk_comment_reply_to`: reply_to_user_id -> t_user.id ON DELETE SET NULL

**层级说明**:
- depth=0: 一级评论（直接评论动态）
- depth=1~5: 回复评论（嵌套回复）
- root_id: 始终指向一级评论的ID，用于快速聚合

---

### 4.6 t_like_record (点赞记录表)

**用途**: 记录点赞行为，支持点赞/取消操作，统一处理所有类型的点赞

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键ID |
| target_type | ENUM | NOT NULL | 点赞目标类型: POST-动态, COMMENT-评论, MESSAGE_BOARD-留言 |
| target_id | BIGINT | NOT NULL | 点赞目标ID |
| user_id | BIGINT | NOT NULL, FK | 点赞用户ID (t_user.id) |
| status | ENUM | DEFAULT 'ACTIVE' | 状态: ACTIVE-已点赞, CANCELLED-已取消 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 点赞时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引设计**:
- `uk_like_record` (target_type, target_id, user_id) - UNIQUE，防重复点赞
- `idx_like_user` (user_id, created_at) - 用户点赞历史
- `idx_like_target` (target_type, target_id, status) - 查询目标的点赞记录
- `idx_like_status` (status) - 状态过滤

**外键约束**:
- `fk_like_user`: user_id -> t_user.id ON DELETE CASCADE

**设计说明**:
- 采用软取消策略：取消点赞不删除记录，而是标记为CANCELLED状态
- 业务层通过统计ACTIVE状态的记录来计算点赞数
- 冗余计数字段（如t_timeline_post.like_count）通过触发器或业务逻辑维护

---

### 4.7 t_message_board (留言板表)

**用途**: 用户个人主页的公开留言板

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键ID |
| owner_user_id | BIGINT | NOT NULL, FK | 留言板所有者用户ID (t_user.id) |
| sender_id | BIGINT | NOT NULL, FK | 留言者用户ID (t_user.id) |
| parent_id | BIGINT | NULL, FK | 父留言ID（支持回复留言）(t_message_board.id) |
| content | TEXT | NOT NULL | 留言内容 |
| like_count | INT | DEFAULT 0 | 点赞数 |
| reply_count | INT | DEFAULT 0 | 回复数 |
| ip_address | VARCHAR(50) | NULL | 留言IP |
| is_hidden | TINYINT | DEFAULT 0 | 是否隐藏: 0-显示, 1-隐藏（仅所有者可见） |
| status | ENUM | DEFAULT 'VISIBLE' | 状态: VISIBLE-可见, HIDDEN-已隐藏, DELETED-已删除 |
| created_by | BIGINT | NULL | 创建人 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
| deleted | TINYINT | DEFAULT 0 | 软删除 |

**索引设计**:
- `idx_board_owner` (owner_user_id, status, created_at) - 主页留言列表
- `idx_board_sender` (sender_id, created_at) - 用户留言历史
- `idx_board_parent` (parent_id) - 回复留言查询
- `idx_board_created_at` (created_at) - 时间排序
- `idx_board_deleted` (deleted) - 软删除过滤

**外键约束**:
- `fk_board_owner`: owner_user_id -> t_user.id ON DELETE CASCADE
- `fk_board_sender`: sender_id -> t_user.id ON DELETE CASCADE
- `fk_board_parent`: parent_id -> t_message_board.id ON DELETE SET NULL

---

### 4.8 t_message_session (私信会话表)

**用途**: 管理用户间的一对一私信会话，维护会话级别的聚合信息

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 会话ID |
| session_key | VARCHAR(50) | NOT NULL, UNIQUE | 会话唯一键: minId_maxId格式 |
| user_id_1 | BIGINT | NOT NULL, FK | 参与用户1（ID较小者）(t_user.id) |
| user_id_2 | BIGINT | NOT NULL, FK | 参与用户2（ID较大者）(t_user.id) |
| last_message | VARCHAR(500) | NULL | 最后一条消息摘要 |
| last_message_time | DATETIME | NULL | 最后消息时间 |
| unread_count_1 | INT | DEFAULT 0 | 用户1未读消息数 |
| unread_count_2 | INT | DEFAULT 0 | 用户2未读消息数 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引设计**:
- `uk_session_key` (session_key) - UNIQUE，会话唯一标识
- `idx_user1` (user_id_1) - 按用户查询会话
- `idx_user2` (user_id_2) - 按用户查询会话
- `idx_last_time` (last_message_time) - 按最后消息时间排序

**外键约束**:
- `fk_session_user1`: user_id_1 -> t_user.id ON DELETE CASCADE
- `fk_session_user2`: user_id_2 -> t_user.id ON DELETE CASCADE

**会话Key计算规则**:
```
session_key = CONCAT(LEAST(sender_id, receiver_id), '_', GREATEST(sender_id, receiver_id))
```
例如：用户3和用户7的会话，session_key = '3_7'

**设计说明**:
- 会话表用于维护会话级别的聚合信息，避免每次查询都要扫描私信表
- last_message和last_message_time用于会话列表展示
- unread_count_1和unread_count_2分别记录两个用户的未读消息数
- 用户ID排序保证session_key的唯一性和一致性

---

### 4.9 t_private_message (私信表)

**用途**: 用户间的私信聊天功能

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键ID |
| session_id | BIGINT | NULL, FK | 关联会话ID (t_message_session.id) |
| sender_id | BIGINT | NOT NULL, FK | 发送者用户ID (t_user.id) |
| receiver_id | BIGINT | NOT NULL, FK | 接收者用户ID (t_user.id) |
| content | TEXT | NOT NULL | 消息内容 |
| msg_type | ENUM | DEFAULT 'TEXT' | 消息类型: TEXT-文本, IMAGE-图片, SYSTEM-系统消息 |
| media_url | VARCHAR(500) | NULL | 媒体URL（图片等） |
| is_read | TINYINT | DEFAULT 0 | 是否已读: 0-未读, 1-已读 |
| read_at | DATETIME | NULL | 阅读时间 |
| status | TINYINT | DEFAULT 1 | 状态: 1-正常, 0-已撤回 |
| created_by | BIGINT | NULL | 创建人（发送者） |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 发送时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
| deleted | TINYINT | DEFAULT 0 | 软删除（发送方删除） |
| receiver_deleted | TINYINT | DEFAULT 0 | 接收方删除标志 |

**索引设计**:
- `idx_pm_session_id` (session_id, created_at) - 会话内消息查询
- `idx_pm_sender_receiver` (sender_id, receiver_id, created_at) - 会话查询
- `idx_pm_receiver_unread` (receiver_id, is_read, created_at) - 未读消息查询
- `idx_pm_receiver_list` (receiver_id, sender_id, created_at) - 会话列表
- `idx_pm_sender_list` (sender_id, receiver_id, created_at) - 发送会话列表
- `idx_pm_created_at` (created_at) - 时间排序
- `idx_pm_deleted` (deleted, receiver_deleted) - 删除过滤

**会话Key计算**:
```
session_key = CONCAT(LEAST(sender_id, receiver_id), '_', GREATEST(sender_id, receiver_id))
```
业务层可通过此规则作为备用标识，优先使用session_id关联。

**外键约束**:
- `fk_pm_session`: session_id -> t_message_session.id ON DELETE SET NULL
- `fk_pm_sender`: sender_id -> t_user.id ON DELETE CASCADE
- `fk_pm_receiver`: receiver_id -> t_user.id ON DELETE CASCADE

**分区策略** (数据量超过500万行时启用):
```sql
PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p_future VALUES LESS THAN MAXVALUE
)
```

---

### 4.10 t_notification (通知表)

**用途**: 系统通知、互动通知、@提醒等统一通知管理

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键ID |
| receiver_id | BIGINT | NOT NULL, FK | 接收者用户ID (t_user.id) |
| sender_id | BIGINT | NULL, FK | 发送者用户ID (t_user.id)，系统通知为NULL |
| type | ENUM | NOT NULL | 通知类型: COMMENT-评论, REPLY-回复, LIKE-点赞, AT_MENTION-@提醒, MESSAGE_BOARD-留言, PRIVATE_MESSAGE-私信, FOLLOW-关注, SYSTEM-系统通知 |
| target_type | VARCHAR(50) | NULL | 关联目标类型: POST, COMMENT, MESSAGE_BOARD, PRIVATE_MESSAGE |
| target_id | BIGINT | NULL | 关联目标ID |
| content | VARCHAR(500) | NULL | 通知内容摘要 |
| extra_data | JSON | NULL | 扩展数据（如@提及的详细信息） |
| is_read | TINYINT | DEFAULT 0 | 是否已读: 0-未读, 1-已读 |
| read_at | DATETIME | NULL | 阅读时间 |
| status | TINYINT | DEFAULT 1 | 状态: 1-正常, 0-已失效 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
| deleted | TINYINT | DEFAULT 0 | 软删除 |

**索引设计**:
- `idx_notification_receiver` (receiver_id, is_read, created_at) - 用户通知列表（最常用）
- `idx_notification_receiver_type` (receiver_id, type, created_at) - 按类型查询通知
- `idx_notification_unread_count` (receiver_id, is_read) - 未读数量统计
- `idx_notification_sender` (sender_id, created_at) - 发送者通知历史
- `idx_notification_target` (target_type, target_id) - 关联目标查询
- `idx_notification_created_at` (created_at) - 时间排序
- `idx_notification_deleted` (deleted) - 软删除过滤

**外键约束**:
- `fk_notification_receiver`: receiver_id -> t_user.id ON DELETE CASCADE
- `fk_notification_sender`: sender_id -> t_user.id ON DELETE SET NULL

**分区策略** (数据量超过500万行时启用):
```sql
PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p_future VALUES LESS THAN MAXVALUE
)
```

---

### 4.11 t_topic (话题表)

**用途**: 兴趣话题定义和管理

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键ID |
| name | VARCHAR(50) | NOT NULL, UNIQUE | 话题名称 |
| code | VARCHAR(50) | NULL, UNIQUE | 话题编码 |
| description | VARCHAR(200) | NULL | 话题描述 |
| icon | VARCHAR(100) | NULL | 话题图标 |
| cover_url | VARCHAR(500) | NULL | 话题封面图 |
| post_count | INT | DEFAULT 0 | 关联动态数（冗余计数） |
| participant_count | INT | DEFAULT 0 | 参与人数（冗余计数） |
| status | TINYINT | DEFAULT 1 | 状态: 1-启用, 0-禁用 |
| created_by | BIGINT | NULL | 创建人 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_by | BIGINT | NULL | 最后修改人 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
| deleted | TINYINT | DEFAULT 0 | 软删除 |

**索引设计**:
- `uk_topic_name` (name) - UNIQUE
- `uk_topic_code` (code) - UNIQUE
- `idx_topic_status` (status, deleted) - 状态过滤
- `idx_topic_post_count` (post_count) - 热门话题排序

---

### 4.12 t_topic_post (话题动态关联表)

**用途**: 动态与话题的多对多关联

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键ID |
| topic_id | BIGINT | NOT NULL, FK | 话题ID (t_topic.id) |
| post_id | BIGINT | NOT NULL, FK | 动态ID (t_timeline_post.id) |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 关联时间 |

**索引设计**:
- `uk_topic_post` (topic_id, post_id) - UNIQUE，防重复关联
- `idx_topic_post_topic` (topic_id, created_at) - 话题下动态列表
- `idx_topic_post_post` (post_id) - 动态关联的话题

**外键约束**:
- `fk_topic_post_topic`: topic_id -> t_topic.id ON DELETE CASCADE
- `fk_topic_post_post`: post_id -> t_timeline_post.id ON DELETE CASCADE

---

### 4.13 t_user_interest (用户兴趣表)

**用途**: 用户的兴趣标签设置

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键ID |
| user_id | BIGINT | NOT NULL, FK | 用户ID (t_user.id) |
| interest_tag | VARCHAR(30) | NOT NULL | 兴趣标签（如：#旅行#, #摄影#） |
| interest_level | TINYINT | DEFAULT 1 | 兴趣程度: 1-一般, 2-喜欢, 3-热爱 |
| sort_order | INT | DEFAULT 0 | 排序序号 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
| deleted | TINYINT | DEFAULT 0 | 软删除 |

**索引设计**:
- `uk_user_interest` (user_id, interest_tag, deleted) - UNIQUE，用户同一标签不重复
- `idx_interest_user` (user_id, sort_order) - 用户兴趣标签列表
- `idx_interest_tag` (interest_tag) - 兴趣标签聚合查询

**外键约束**:
- `fk_interest_user`: user_id -> t_user.id ON DELETE CASCADE

---

### 4.14 t_privacy_setting (隐私设置表)

**用途**: 用户个性化的隐私权限设置

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键ID |
| user_id | BIGINT | NOT NULL, FK | 用户ID (t_user.id) |
| setting_key | VARCHAR(50) | NOT NULL | 设置项标识 |
| setting_value | VARCHAR(200) | NOT NULL | 设置值 |
| scope | ENUM | DEFAULT 'FAMILY' | 适用范围: PUBLIC-公开, FAMILY-家族, PRIVATE-私有 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引设计**:
- `uk_privacy_setting` (user_id, setting_key) - UNIQUE，用户同一设置项唯一
- `idx_privacy_user` (user_id) - 用户所有设置查询

**外键约束**:
- `fk_privacy_user`: user_id -> t_user.id ON DELETE CASCADE

**预设隐私设置项**:
| setting_key | 说明 | 可选值 |
|-------------|------|--------|
| profile_visibility | 主页可见范围 | public/family/relative/private |
| post_default_visibility | 发布内容默认可见范围 | public/family/relative/private |
| allow_guestbook | 是否允许留言板 | true/false |
| allow_private_message | 是否允许私信 | true/false |
| allow_comment | 是否允许评论 | true/false/relative_only |
| show_birth_info | 是否展示生日信息 | true/false |
| show_occupation | 是否展示职业信息 | true/false |
| allow_tag_in_post | 是否允许被@提及 | true/false/relative_only |

---

## 五、数据关系说明

### 5.1 核心实体关系

```
t_family (1) ─── (N) t_user (1) ─── (0..1) t_user_profile (1) ─── (N) t_timeline_post
                       │                                            │
                       │                                            ├── (N) t_comment (通过post_id)
                       │                                            ├── (N) t_post_media
                       │                                            └── (M..N) t_topic (通过t_topic_post)
                       │
                       ├── (N) t_message_board (作为sender/owner)
                       ├── (N) t_message_session (作为user_id_1/user_id_2)
                       │        │
                       │        └── (N) t_private_message (通过session_id)
                       ├── (N) t_private_message (作为sender/receiver, 旧数据兼容)
                       ├── (N) t_notification (作为receiver/sender)
                       ├── (N) t_comment (作为评论者)
                       ├── (N) t_like_record (作为点赞者)
                       ├── (N) t_user_interest
                       └── (N) t_privacy_setting

t_member (N) ─── (0..1) t_user_profile (通过member_id关联)
```

### 5.2 亲属关系查询优化策略

**问题**: 族谱系统中需要频繁判定用户间的亲属关系，直接查询t_member的father_id/mother_id递归效率低。

**解决方案**:

1. **业务层缓存策略** (推荐):
   - 在用户登录时，预计算并缓存其同族谱成员列表到Redis
   - 缓存包含：{亲属ID, 关系类型, 代数差}
   - TTL设置为24小时，家族成员变更时主动失效

2. **冗余字段方案** (适用于中小规模家族):
   - 在t_user_profile增加 `family_members_json` JSON字段
   - 存储同家族成员ID列表及关系类型
   - 成员关系变更时更新此字段

3. **数据库查询优化**:
   - 通过t_user.family_id直接判定是否同家族
   - 通过t_member表的father_id/mother_id索引快速查询直系亲属
   - 使用MySQL 8.0 CTE递归查询旁系亲属

### 5.3 级联删除策略

| 主表 | 关联表 | 删除策略 | 说明 |
|------|--------|----------|------|
| t_user | t_user_profile | CASCADE | 用户删除时同步删除主页 |
| t_user | t_timeline_post | CASCADE | 用户删除时删除其动态 |
| t_timeline_post | t_post_media | CASCADE | 动态删除时删除媒体记录 |
| t_timeline_post | t_comment | CASCADE | 动态删除时删除评论 |
| t_timeline_post | t_like_record | 无FK | 业务层软删除处理 |
| t_comment | t_comment (自引用) | SET NULL | 父评论删除时子评论保留 |
| t_user | t_private_message | CASCADE | 用户删除时删除其消息 |
| t_message_session | t_private_message | SET NULL | 会话删除时消息保留但解除关联 |
| t_user | t_message_session | CASCADE | 用户删除时级联删除会话 |
| t_user | t_notification | CASCADE (receiver)/SET NULL (sender) | 接收者删除则删除通知，发送者删除保留通知 |

---

## 六、索引设计说明

### 6.1 索引总览

| 表名 | 索引数量 | 重点索引 | 优化目标 |
|------|----------|----------|----------|
| t_user_profile | 4 | uk_profile_user_id | 用户主页快速定位 |
| t_timeline_post | 9 | idx_timeline_user_status | 用户动态分页查询 |
| t_post_media | 4 | idx_media_post_id | 动态媒体查询 |
| t_post_category | 3 | idx_category_user_id | 用户分类列表 |
| t_comment | 8 | idx_comment_target, idx_comment_root_id | 评论树高效查询 |
| t_like_record | 4 | uk_like_record | 防重复点赞+快速查询 |
| t_message_board | 5 | idx_board_owner | 主页留言列表 |
| t_message_session | 4 | uk_session_key | 会话唯一标识+用户查询 |
| t_private_message | 7 | idx_pm_session_id | 会话内消息查询 |
| t_notification | 7 | idx_notification_receiver | 通知列表+未读数 |
| t_topic | 3 | uk_topic_name | 话题唯一性 |
| t_topic_post | 3 | uk_topic_post | 关联唯一性 |
| t_user_interest | 3 | uk_user_interest | 标签唯一性 |
| t_privacy_setting | 2 | uk_privacy_setting | 设置唯一性 |

### 6.2 关键查询场景索引覆盖

**场景1: 个人主页动态列表**
```sql
-- 查询某用户已发布的动态（按时间倒序，分页）
SELECT * FROM t_timeline_post
WHERE user_id = ? AND status = 'PUBLISHED' AND deleted = 0
ORDER BY created_at DESC
LIMIT 20 OFFSET 0;

-- 使用索引: idx_timeline_user_status (user_id, status, created_at)
```

**场景2: 动态详情页（含评论）**
```sql
-- 查询动态及其评论
SELECT * FROM t_timeline_post WHERE id = ? AND deleted = 0;
SELECT * FROM t_comment
WHERE post_id = ? AND status = 'VISIBLE' AND deleted = 0
ORDER BY created_at ASC;

-- 使用索引: idx_comment_post_id (post_id, status, created_at)
```

**场景3: 评论树查询**
```sql
-- 查询一级评论
SELECT * FROM t_comment
WHERE post_id = ? AND depth = 0 AND status = 'VISIBLE' AND deleted = 0
ORDER BY like_count DESC, created_at ASC;

-- 查询某评论的回复
SELECT * FROM t_comment
WHERE root_id = ? AND depth > 0 AND status = 'VISIBLE' AND deleted = 0
ORDER BY created_at ASC;

-- 使用索引: idx_comment_root_id (root_id, depth, created_at)
```

**场景4: 通知列表查询**
```sql
-- 查询用户未读通知
SELECT * FROM t_notification
WHERE receiver_id = ? AND is_read = 0 AND deleted = 0
ORDER BY created_at DESC;

-- 使用索引: idx_notification_receiver (receiver_id, is_read, created_at)
```

**场景5: 未读私信统计**
```sql
-- 统计未读私信数量
SELECT COUNT(*) FROM t_private_message
WHERE receiver_id = ? AND is_read = 0 AND deleted = 0 AND receiver_deleted = 0;

-- 使用索引: idx_pm_receiver_unread (receiver_id, is_read, created_at)
```

---

## 七、性能优化建议

### 7.1 表结构优化

1. **冗余计数**:
   - t_timeline_post的like_count, comment_count, view_count
   - t_comment的like_count
   - t_message_board的like_count, reply_count
   - t_topic的post_count, participant_count
   - 作用：避免实时COUNT聚合，提升列表查询性能

2. **JSON字段**:
   - t_user_profile.life_events: 存储人生大事记，避免单独建表
   - t_user_profile.stats_json: 缓存统计信息
   - t_notification.extra_data: 存储通知扩展信息
   - 作用：灵活存储非结构化数据，减少关联查询

### 7.2 索引优化

1. **覆盖索引**: 对于只读场景，设计覆盖索引避免回表查询
2. **联合索引**: 按查询条件顺序创建联合索引（等值在前，范围在后）
3. **避免过度索引**: 写频繁表（t_like_record, t_notification）控制索引数量

### 7.3 分区策略

对以下大数据量表建议启用分区（数据量超过阈值时）:

| 表名 | 分区阈值 | 分区策略 |
|------|----------|----------|
| t_timeline_post | 100万行 | 按年RANGE分区 |
| t_private_message | 500万行 | 按年RANGE分区 |
| t_notification | 500万行 | 按年RANGE分区 |

### 7.4 查询优化

1. **分页查询优化**: 对于深分页，使用游标分页（基于created_at）替代OFFSET
2. **评论树查询**: 采用邻接表模型（parent_id）+ root_id辅助，限制最大深度5层
3. **亲属关系查询**: 通过family_id+member_id关联，避免递归查询
4. **统计查询**: 使用冗余计数替代实时聚合

### 7.5 写入优化

1. **点赞操作**: 先写t_like_record，异步更新冗余计数
2. **通知生成**: 使用消息队列异步生成，避免阻塞主流程
3. **批量操作**: 私信、通知等高频写入场景使用批量INSERT

---

## 八、数据字典

### 8.1 枚举值说明

**post_type (动态类型)**:
| 值 | 说明 | 使用场景 |
|---|------|----------|
| TEXT | 纯文本 | 心情随笔、简短动态 |
| IMAGE | 图文 | 照片分享、配图动态 |
| VIDEO | 视频 | 视频分享 |
| LIFE_EVENT | 生平事件 | 人生重要节点 |

**visibility (可见范围)**:
| 值 | 说明 | 可见用户 |
|---|------|----------|
| PUBLIC | 公开 | 所有用户 |
| FAMILY | 全家族 | 同家族成员 |
| RELATIVE | 仅亲属 | 有亲属关系的成员 |
| PRIVATE | 仅自己 | 仅发布者本人 |

**notification_type (通知类型)**:
| 值 | 说明 |
|---|------|
| COMMENT | 评论通知 |
| REPLY | 回复通知 |
| LIKE | 点赞通知 |
| AT_MENTION | @提醒通知 |
| MESSAGE_BOARD | 留言通知 |
| PRIVATE_MESSAGE | 私信通知 |
| SYSTEM | 系统通知 |

### 8.2 状态字段说明

**status通用约定**:
- TINYINT类型: 1-正常/启用, 0-禁用/删除
- ENUM类型: 使用业务语义值（PUBLISHED, VISIBLE, ACTIVE等）

---

## 九、数据库变更记录

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-04-16 | 初始版本：核心3表（t_user, t_member, t_family） |
| v2.0 | 2026-04-17 | 新增14张表支持个人主页功能模块(含私信会话表) |

---

## 附录: 表变更SQL（从v1.0升级）

如需在现有v1.0数据库上增量升级，执行 `schema-v2.sql` 即可自动创建所有新增表。
无需修改现有表结构。

---

*文档结束 - 家族族谱系统V2.0数据库设计文档*
