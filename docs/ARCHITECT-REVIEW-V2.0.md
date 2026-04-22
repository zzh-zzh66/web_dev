# 家族族谱系统 V2.0 - 架构师文档核对报告

## 文档信息

| 属性 | 值 |
|------|------|
| 文档名称 | V2.0设计文档交叉核对报告 |
| 核对人 | 系统架构师 |
| 核对日期 | 2026-04-17 |
| 核对范围 | 架构设计、数据库设计、UI设计三份文档 |

---

## 一、核对发现的问题清单

### 1.1 表名不一致 (严重)

| 问题编号 | 架构文档 | 数据库文档 | 统一方案 |
|----------|----------|------------|----------|
| T001 | `t_profile` | `t_user_profile` | ✅ 采用 **t_user_profile** |
| T002 | `t_content` | `t_timeline_post` | ✅ 采用 **t_timeline_post** |
| T003 | `t_content_media` | `t_post_media` | ✅ 采用 **t_post_media** |
| T004 | `t_like` | `t_like_record` | ✅ 采用 **t_like_record** |
| T005 | `t_guestbook` | `t_message_board` | ✅ 采用 **t_message_board** |
| T006 | `t_message` | `t_private_message` | ✅ 采用 **t_private_message** |
| T007 | `t_msg_session` | 无独立表(session_key计算) | ✅ **新增 t_message_session 表** |
| T008 | 无 | `t_post_category` | ✅ 新增到架构文档 |
| T009 | 无 | `t_topic`, `t_topic_post` | ✅ 新增到架构文档 |
| T010 | 无 | `t_user_interest` | ✅ 新增到架构文档 |
| T011 | 无 | `t_privacy_setting` | ✅ 新增到架构文档 |

### 1.2 字段命名不一致 (严重)

| 问题编号 | 架构文档字段 | 数据库文档字段 | 统一方案 |
|----------|-------------|---------------|----------|
| F001 | `profile_id` | 无(用user_id) | ✅ API响应使用 **userProfileId** |
| F002 | `type` | `post_type` | ✅ API使用 **postType** |
| F003 | `category` | `category_id` | ✅ API使用 **categoryId** |
| F004 | `text_content` | `content` | ✅ API使用 **content** |
| F005 | `textContent` | `content` | ✅ API/DTO统一使用 **content** |
| F006 | `visibility: ALL` | `visibility: PUBLIC/FAMILY/RELATIVE/PRIVATE` | ✅ 采用数据库方案 |
| F007 | `depth` (评论) | `depth` | ✅ 一致 |
| F008 | `path` (物化路径) | `root_id` | ✅ 采用 **root_id + depth** 方案 |

### 1.3 枚举值不一致 (中等)

| 问题编号 | 架构文档枚举 | 数据库文档枚举 | 统一方案 |
|----------|-------------|---------------|----------|
| E001 | `visibility: ALL/RELATIVE/PRIVATE` | `visibility: PUBLIC/FAMILY/RELATIVE/PRIVATE` | ✅ **PUBLIC/FAMILY/RELATIVE/PRIVATE** |
| E002 | `type: TEXT/IMAGE/VIDEO/MIXED` | `post_type: TEXT/IMAGE/VIDEO/LIFE_EVENT` | ✅ **TEXT/IMAGE/VIDEO/LIFE_EVENT** |
| E003 | `category: LIFE_LOG/...` | `category_id` (关联t_post_category) | ✅ 采用分类ID关联 |
| E004 | 通知类型6种 | 通知类型7种(含REPLY) | ✅ 采用数据库方案(7种) |

### 1.4 评论设计差异 (中等)

| 方案 | 架构文档 | 数据库文档 | 决策 |
|------|---------|-----------|------|
| 查询优化 | 物化路径(path) | root_id + depth | ✅ **采用 root_id + depth** |
| 理由 | 单次SQL获取子树 | 更灵活,支持层级过滤 | root_id方案更灵活且性能可接受 |

### 1.5 API响应格式不一致 (轻微)

架构文档API响应中的字段名需要与数据库表字段名保持一致:

| API端点 | 需要调整的响应字段 |
|---------|-------------------|
| GET /api/v1/profiles/{userId} | `backgroundUrl` → 对应 `background_url` |
| GET /api/v1/contents | `textContent` → `content`, `type` → `postType`, `publishTime` → `createdAt` |
| GET /api/v1/contents/{id}/comments | 增加 `rootId` 字段 |
| POST /api/v1/likes | `targetType` 枚举值更新 |

### 1.6 UI设计组件与架构文档匹配度 (良好)

| 组件 | UI文档 | 架构文档 | 状态 |
|------|--------|---------|------|
| ProfileHeader | ✅ | ✅ | 一致 |
| ContentCard | ✅ | ✅ | 一致 |
| CommentSection | ✅ | ✅ | 一致 |
| LikeButton | ✅ | ✅ | 一致 |
| Guestbook | ✅ | ✅ | 一致 |
| NotificationItem | ✅ | ✅ | 一致 |
| MessageChat | ✅ | ✅ | 一致 |
| PrivacySettings | ✅ | ✅ | 一致 |

---

## 二、统一决策方案

### 2.1 表名统一

所有文档统一使用数据库设计师定义的表名:

```
t_user_profile      - 用户主页档案表
t_timeline_post     - 时间轴动态表
t_post_media        - 动态媒体表
t_post_category     - 动态分类表
t_comment           - 评论表
t_like_record       - 点赞记录表
t_message_board     - 留言板表
t_private_message   - 私信表
t_message_session   - 私信会话表 (新增)
t_notification      - 通知表
t_topic             - 话题表
t_topic_post        - 话题动态关联表
t_user_interest     - 用户兴趣表
t_privacy_setting   - 隐私设置表
```

### 2.2 评论表统一方案

采用数据库文档的 `root_id + depth + parent_id` 设计:

```sql
-- 一级评论
SELECT * FROM t_comment WHERE target_id = ? AND depth = 0;

-- 某评论的回复
SELECT * FROM t_comment WHERE root_id = ? AND depth > 0 ORDER BY created_at;
```

### 2.3 枚举值统一

**可见范围 (visibility):**
```
PUBLIC   - 公开(所有用户可见)
FAMILY   - 全家族可见
RELATIVE - 仅亲属可见
PRIVATE  - 仅自己可见
```

**内容类型 (post_type):**
```
TEXT       - 纯文本
IMAGE      - 图文
VIDEO      - 视频
LIFE_EVENT - 生平事件
```

### 2.4 新增私信会话表

数据库设计师采用session_key计算方案,但架构文档需要独立会话表。统一方案:

```sql
CREATE TABLE t_message_session (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '会话ID',
    session_key     VARCHAR(50) NOT NULL UNIQUE COMMENT '会话唯一键: minId_maxId',
    user_id_1       BIGINT NOT NULL COMMENT '参与用户1',
    user_id_2       BIGINT NOT NULL COMMENT '参与用户2',
    last_message    VARCHAR(500) COMMENT '最后一条消息',
    last_message_time DATETIME COMMENT '最后消息时间',
    unread_count_1  INT DEFAULT 0 COMMENT '用户1未读数',
    unread_count_2  INT DEFAULT 0 COMMENT '用户2未读数',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user1 (user_id_1),
    INDEX idx_user2 (user_id_2),
    INDEX idx_last_time (last_message_time),
    FOREIGN KEY (user_id_1) REFERENCES t_user(id),
    FOREIGN KEY (user_id_2) REFERENCES t_user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='私信会话表';
```

### 2.5 API响应格式统一

所有API响应字段采用 `camelCase` 格式,与数据库 `snake_case` 字段对应:

| 数据库字段 | API响应字段 |
|-----------|------------|
| post_type | postType |
| category_id | categoryId |
| content | content |
| created_at | createdAt |
| updated_at | updatedAt |
| like_count | likeCount |
| comment_count | commentCount |
| user_id | userId |

---

## 三、需要更新的文档清单

### 3.1 ARCHITECTURE-DESIGN-V2.0.md 需更新

| 章节 | 更新内容 |
|------|---------|
| 5.1 新增数据表总览 | 更新所有表名为数据库文档方案 |
| 5.2 表结构详细设计 | 统一使用数据库文档的表结构 |
| 6.x API接口示例 | 更新响应字段名(camelCase对应数据库字段) |
| 6.2 错误码定义 | 增加分类、话题相关错误码 |
| 6.6 点赞API | 更新targetType枚举值 |
| 8.2 内容可见性 | 更新为PUBLIC/FAMILY/RELATIVE/PRIVATE |

### 3.2 DATABASE-DESIGN-V2.0.md 需更新

| 章节 | 更新内容 |
|------|---------|
| 4.8 t_private_message | 增加 session_key 字段说明 |
| 新增 | 增加 t_message_session 表定义 |
| 5.2 数据关系图 | 更新会话表关系 |

### 3.3 UI-DESIGN-V2.0.md 需更新

| 章节 | 更新内容 |
|------|---------|
| 2.3 内容发布对话框 | 更新分类选择为从 t_post_category 获取 |
| 4.1.4 内容分类色彩 | 与 t_post_category 预置分类对齐 |
| 无重大不匹配 | UI组件命名与架构一致 |

---

## 四、接口匹配性验证

### 4.1 前端组件 → 后端API 映射

| 前端组件 | 调用API | 数据字段 | 匹配状态 |
|---------|---------|---------|---------|
| ProfileHeader | GET /api/v1/profiles/{userId} | backgroundUrl, signature, interests | ✅ 匹配 |
| ContentCard | GET /api/v1/contents | content, postType, mediaList, likeCount | ✅ 需更新字段名 |
| CommentSection | GET /api/v1/contents/{id}/comments | content, rootId, depth, parentId | ✅ 匹配 |
| LikeButton | POST /api/v1/likes | targetType, targetId | ✅ 需更新枚举 |
| Guestbook | GET /api/v1/profiles/{userId}/guestbook | content, likeCount | ✅ 匹配 |
| NotificationItem | GET /api/v1/notifications | type, content, targetType | ✅ 匹配 |
| MessageChat | GET /api/v1/messages/sessions/{id} | content, msgType, isRead | ✅ 匹配 |

### 4.2 后端API → 数据库表 映射

| API模块 | 数据库表 | 字段映射 | 匹配状态 |
|---------|---------|---------|---------|
| Profile | t_user_profile | 1:1映射 | ✅ 需更新API响应格式 |
| Content | t_timeline_post | type→postType, textContent→content | ✅ 需更新 |
| Media | t_post_media | 1:1映射 | ✅ 匹配 |
| Comment | t_comment | 增加rootId字段 | ✅ 需更新 |
| Like | t_like_record | 1:1映射 | ✅ 匹配 |
| Guestbook | t_message_board | 1:1映射 | ✅ 匹配 |
| Message | t_private_message + t_message_session | 双表关联 | ✅ 需增加会话表 |
| Notification | t_notification | 1:1映射 | ✅ 匹配 |

---

## 五、文档定稿检查清单

- [x] 表名统一完成
- [x] 字段命名统一完成
- [x] 枚举值统一完成
- [x] 评论设计方案统一
- [x] API响应格式规范定义
- [x] 私信会话表补充设计
- [x] 前端组件与API映射验证
- [x] API与数据库表映射验证
- [ ] ARCHITECTURE-DESIGN-V2.0.md 更新
- [ ] DATABASE-DESIGN-V2.0.md 更新  
- [ ] 三份文档最终版本确认

---

## 六、总结

经过详细核对,三份设计文档整体设计思路一致,但在以下方面需要统一:

1. **表名**: 11处不一致 → 统一采用数据库文档方案
2. **字段名**: 8处不一致 → 统一API使用camelCase对应数据库字段
3. **枚举值**: 4处不一致 → 统一采用数据库文档方案
4. **评论设计**: 方案不同 → 统一采用root_id + depth方案
5. **缺失表**: 架构文档缺少5张表 → 补充到架构文档
6. **会话表**: 需要新增t_message_session表

完成以上更新后,三份文档即可定稿,作为后续开发的权威依据。

---

*核对完成 - 待各文档按本核对报告更新后即可定稿*
