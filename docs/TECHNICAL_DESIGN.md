# 个人主页模块技术设计说明文档

## 版本历史

| 版本 | 日期 | 作者 | 说明 |
|------|------|------|------|
| v1.0 | 2026-04-16 | 产品项目经理 | 初始版本 |

---

## 1. 模块概述

### 1.1 模块名称
个人主页模块 (Profile Module)

### 1.2 模块定位
个人主页模块是家族族谱系统的社交核心功能，为每位家族成员提供独立的个人展示空间，支持生平记录发布、社交互动以及亲属间免好友直接互动。

### 1.3 设计目标
- 提供类似QQ空间的社交互动体验
- 实现亲属间免好友添加的直接互动机制
- 支持动态发布、评论、点赞、留言等社交功能
- 提供私信和通知系统

---

## 2. 技术架构

### 2.1 技术栈

#### 前端
- Vue 3.0 (Composition API)
- TypeScript
- Element Plus UI
- Pinia 状态管理
- Vue Router 4.0

#### 后端
- Spring Boot 3.0
- MyBatis Plus 3.5
- MySQL 8.0
- JWT 认证

### 2.2 项目结构

#### 前端结构
```
frontend/src/
├── api/
│   └── profile.ts          # 个人主页API接口
├── types/
│   └── profile.ts          # TypeScript类型定义
├── views/
│   └── profile/
│       ├── ProfileView.vue       # 个人主页视图
│       ├── MessagesView.vue      # 消息中心视图
│       └── components/
│           └── PostCard.vue      # 动态卡片组件
├── router/
│   └── index.ts            # 路由配置
└── store/
    └── user.ts             # 用户状态管理
```

#### 后端结构
```
backend/src/main/java/com/family/genealogy/
├── controller/
│   └── ProfileController.java   # 个人主页控制器
├── service/
│   └── ProfileService.java       # 个人主页服务
├── entity/
│   ├── Post.java                # 动态实体
│   ├── Comment.java             # 评论实体
│   ├── Like.java                # 点赞实体
│   ├── Guestbook.java           # 留言板实体
│   ├── Message.java             # 私信实体
│   ├── Notification.java        # 通知实体
│   └── UserProfile.java         # 用户资料实体
├── mapper/
│   ├── PostMapper.java
│   ├── CommentMapper.java
│   ├── LikeMapper.java
│   ├── GuestbookMapper.java
│   ├── MessageMapper.java
│   ├── NotificationMapper.java
│   └── UserProfileMapper.java
└── dto/
    ├── ProfileDTO.java
    ├── PostDTO.java
    ├── PostCreateRequest.java
    ├── CommentDTO.java
    ├── GuestbookDTO.java
    ├── MessageDTO.java
    ├── NotificationDTO.java
    └── ...
```

---

## 3. 数据库设计

### 3.1 核心表结构

| 表名 | 说明 | 主键 |
|------|------|------|
| t_post | 动态表 | id |
| t_comment | 评论表 | id |
| t_like | 点赞表 | id |
| t_guestbook | 留言板表 | id |
| t_message | 私信表 | id |
| t_notification | 通知表 | id |
| t_user_profile | 用户资料扩展表 | id |

### 3.2 实体关系图

```
User (1) ────── (1) Member
    │               │
    ├───── (N) Post
    │               │
    ├───── (N) Comment ──── (N) Comment (replies)
    │               │
    ├───── (N) Like
    │               │
    ├───── (N) Guestbook
    │               │
    ├───── (N) Message (sender)
    │               │
    └───── (N) Message (receiver)
            │
            └───── (N) Notification
```

### 3.3 索引设计

| 表名 | 索引名称 | 索引字段 | 类型 |
|------|----------|----------|------|
| t_post | idx_post_member_created | member_id, created_at | 复合索引 |
| t_post | idx_post_status | status | 单字段 |
| t_comment | idx_comment_post | post_id | 单字段 |
| t_like | uk_like_post_user | post_id, user_id | 唯一索引 |
| t_guestbook | idx_guestbook_owner | owner_member_id | 单字段 |
| t_message | idx_message_sender_created | sender_id, created_at | 复合索引 |
| t_message | idx_message_receiver_created | receiver_id, created_at | 复合索引 |
| t_notification | idx_notification_user_read | user_id, is_read, created_at | 复合索引 |

---

## 4. API接口设计

### 4.1 接口列表

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/v1/profile/{memberId} | 获取个人主页信息 |
| GET | /api/v1/profile/{memberId}/posts | 获取用户动态列表 |
| POST | /api/v1/profile/posts | 发布动态 |
| GET | /api/v1/profile/posts/{postId} | 获取动态详情 |
| DELETE | /api/v1/profile/posts/{postId} | 删除动态 |
| POST | /api/v1/profile/posts/{postId}/like | 点赞动态 |
| DELETE | /api/v1/profile/posts/{postId}/like | 取消点赞 |
| POST | /api/v1/profile/posts/{postId}/comments | 评论动态 |
| GET | /api/v1/profile/posts/{postId}/comments | 获取评论列表 |
| GET | /api/v1/profile/members/{memberId}/guestbook | 获取留言板 |
| POST | /api/v1/profile/members/{memberId}/guestbook | 添加留言 |
| DELETE | /api/v1/profile/guestbook/{guestbookId} | 删除留言 |
| GET | /api/v1/profile/messages | 获取私信列表 |
| POST | /api/v1/profile/messages | 发送私信 |
| GET | /api/v1/profile/notifications | 获取通知列表 |
| PUT | /api/v1/profile/notifications/{id}/read | 标记已读 |
| PUT | /api/v1/profile/notifications/read-all | 标记全部已读 |
| PUT | /api/v1/profile | 更新个人资料 |

### 4.2 认证机制
- 所有接口需要JWT Token认证
- Token通过Authorization Header传递: `Bearer {token}`
- Token包含用户ID信息，用于权限校验

---

## 5. 核心功能设计

### 5.1 动态发布

**流程:**
1. 用户填写动态内容，选择类型和可见范围
2. 系统验证用户权限
3. 保存动态记录，初始化统计数据
4. 返回成功响应

**可见范围:**
- PUBLIC: 公开
- FAMILY: 仅家族成员
- RELATIVES: 仅亲属
- PRIVATE: 仅自己

### 5.2 社交互动

**点赞机制:**
- 用户对同一动态只能点赞一次
- 点赞后实时更新动态的点赞数
- 点赞记录保存在t_like表

**评论机制:**
- 支持二级评论（回复）
- 评论时支持@提及家族成员
- 被@的成员会收到通知

### 5.3 亲属关系识别

**关系计算逻辑:**
1. 查询目标成员的父亲ID
2. 如果当前用户ID等于父亲ID，返回"父亲"
3. 如果当前用户是目标成员的父亲，返回"子女"
4. 如果配偶姓名匹配，返回"配偶"
5. 如果父亲相同，返回"兄弟/姐妹"
6. 其他情况返回"家族成员"

### 5.4 通知系统

**通知类型:**
| 类型 | 触发条件 |
|------|----------|
| COMMENT | 有人评论了你的动态 |
| REPLY | 有人回复了你的评论 |
| LIKE | 有人点赞了你的动态 |
| MESSAGE | 收到新私信 |
| MENTION | 有人@了你 |
| BIRTHDAY | 亲属生日提醒 |
| ANNIVERSARY | 家庭纪念日提醒 |

---

## 6. 前端组件设计

### 6.1 组件列表

| 组件 | 说明 | 位置 |
|------|------|------|
| ProfileView | 个人主页主视图 | views/profile/ProfileView.vue |
| PostCard | 动态卡片组件 | views/profile/components/PostCard.vue |
| MessagesView | 消息中心视图 | views/profile/MessagesView.vue |

### 6.2 页面路由

| 路径 | 组件 | 说明 |
|------|------|------|
| /profile/:memberId | ProfileView | 个人主页 |
| /messages | MessagesView | 消息中心 |

### 6.3 状态管理

使用Pinia进行状态管理，主要状态:
- 用户信息
- 当前登录用户
- 未读通知数量

---

## 7. 安全性设计

### 7.1 认证与授权
- JWT Token认证
- 用户只能操作自己的资源
- 动态/评论/留言的删除需要验证所有权

### 7.2 数据校验
- 输入内容长度限制
- XSS过滤
- SQL注入防护（使用MyBatis Plus）

### 7.3 隐私保护
- 用户可设置资料可见度
- 联系方式仅对亲属可见
- 私信可设置接收与否

---

## 8. 性能优化

### 8.1 数据库优化
- 合理使用索引
- 分页查询避免全表扫描
- 使用复合索引优化常见查询

### 8.2 前端优化
- 组件懒加载
- 图片懒加载
- 虚拟滚动（大数据列表）

### 8.3 缓存策略
- 热点数据缓存（可选）
- 静态资源CDN

---

## 9. 扩展性设计

### 9.1 功能扩展
- v3.0可扩展@提及功能
- v3.0可扩展分享功能
- v3.0可扩展高级隐私设置

### 9.2 架构扩展
- 微服务化改造
- 消息队列异步处理
- 搜索服务集成

---

## 10. 部署说明

### 10.1 环境要求
- JDK 17+
- Node.js 16+
- MySQL 8.0
- Maven 3.8+

### 10.2 启动顺序
1. 启动MySQL数据库
2. 执行数据库初始化脚本
3. 启动Spring Boot后端服务
4. 启动Vue前端开发服务器

### 10.3 配置文件
- 后端: application.yml
- 前端: .env.development, .env.production

---

## 11. 测试计划

### 11.1 单元测试
- Service层业务逻辑测试
- 工具类方法测试

### 11.2 集成测试
- API接口测试
- 数据库交互测试

### 11.3 功能测试
- 个人主页展示
- 动态发布/编辑/删除
- 评论/回复功能
- 点赞/取消点赞
- 留言板功能
- 私信发送/接收
- 通知生成/标记已读

---

## 12. 已知问题与限制

1. 图片上传功能暂未实现
2. @提及功能需要前端富文本编辑器支持
3. 亲属关系计算逻辑较为简单，需要完善
4. 通知的定时任务（如生日提醒）暂未实现

---

## 13. 参考文档

- [需求规格说明书](./SPEC.md)
- [UI设计稿](./UI_DESIGN.md)
- [API接口文档](./API.md)
- [数据库设计](./DATABASE.md)
