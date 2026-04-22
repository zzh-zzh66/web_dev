# 家族族谱系统 V2.0 - 个人主页功能架构设计文档

## 文档信息

| 属性 | 值 |
|------|------|
| 文档名称 | 个人主页功能模块架构设计文档 |
| 版本号 | V2.0 |
| 创建日期 | 2026-04-17 |
| 创建人 | 系统架构师 |
| 文档状态 | 待评审 |

---

## 版本历史

| 版本 | 日期 | 变更内容 | 变更人 |
|------|------|----------|--------|
| v2.0 | 2026-04-17 | V2.0个人主页功能模块整体架构设计 | 系统架构师 |

---

## 目录

1. [现有系统架构分析](#一现有系统架构分析)
2. [V2.0整体系统架构设计](#二v20整体系统架构设计)
3. [技术栈选型](#三技术栈选型)
4. [模块划分与职责定义](#四模块划分与职责定义)
5. [数据库扩展设计](#五数据库扩展设计)
6. [API接口设计规范](#六api接口设计规范)
7. [WebSocket实时通信设计](#七websocket实时通信设计)
8. [权限控制架构](#八权限控制架构)
9. [前后端交互流程](#九前后端交互流程)
10. [安全架构设计](#十安全架构设计)
11. [性能优化方案](#十一性能优化方案)
12. [扩展性设计](#十二扩展性设计)

---

## 一、现有系统架构分析

### 1.1 现有架构概览

```
┌──────────────────────────────────────────────────────────┐
│                    前端 (Vue 3)                           │
│  ┌─────────┐ ┌──────────┐ ┌─────────────┐ ┌──────────┐ │
│  │ Element  │ │ Vue      │ │ Pinia       │ │ Vue      │ │
│  │ Plus     │ │ Router   │ │ Store       │ │ Axios    │ │
│  └─────────┘ └──────────┘ └─────────────┘ └──────────┘ │
└──────────────────────────────────────────────────────────┘
                          │ HTTP/JSON
                          ▼
┌──────────────────────────────────────────────────────────┐
│               后端 (Spring Boot 3)                        │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐            │
│  │Controller │──│ Service   │──│  Mapper   │            │
│  │  层       │  │   层      │  │   层      │            │
│  └───────────┘  └───────────┘  └───────────┘            │
│       │               │               │                  │
│  ┌────┴────┐     ┌────┴────┐     ┌────┴────┐            │
│  │  DTO    │     │  Entity │     │ XML     │            │
│  │  对象   │     │  对象   │     │ Mapper  │            │
│  └─────────┘     └─────────┘     └─────────┘            │
└──────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────┐
│                    MySQL 8.0                              │
│  t_user │ t_member │ t_family                            │
└──────────────────────────────────────────────────────────┘
```

### 1.2 现有代码结构

```
backend/src/main/java/com/family/genealogy/
├── common/           # 通用组件（Result, ErrorCode）
├── config/           # 配置类（Security, MyBatis Plus）
├── controller/       # 控制器（Auth, Member, Genealogy）
├── dto/              # 数据传输对象
├── entity/           # 数据库实体
├── exception/        # 异常处理
├── filter/           # JWT认证过滤器
├── mapper/           # 数据访问层
├── service/          # 业务逻辑层
└── util/             # 工具类（JwtUtils）
```

### 1.3 现有API规范

- **URL模式**: `/api/v1/{module}` 或 `/api/v1/{module}/{id}`
- **认证方式**: `Authorization: Bearer {jwt_token}`
- **统一响应格式**: `{ "code": 200, "message": "success", "data": {...} }`
- **分页格式**: `{ "records": [...], "total": 100, "page": 1, "size": 20 }`

### 1.4 现有命名规范

- **表名**: `t_{entity}` （snake_case）
- **字段名**: `snake_case`
- **Java类名**: `PascalCase`
- **Java变量**: `camelCase`
- **索引命名**: `idx_{table}_{column}`

---

## 二、V2.0整体系统架构设计

### 2.1 系统整体架构图

```
┌──────────────────────────────────────────────────────────────────────┐
│                           客户端层                                     │
│  ┌────────────────┐    ┌────────────────┐    ┌──────────────────┐   │
│  │   PC浏览器      │    │   移动端浏览器   │    │   平板设备        │   │
│  │  (Vue 3 SPA)   │    │  (响应式适配)    │    │  (响应式适配)     │   │
│  └────────┬───────┘    └────────┬───────┘    └────────┬─────────┘   │
└───────────┼─────────────────────┼─────────────────────┼──────────────┘
            │                     │                     │
            └─────────────────────┼─────────────────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │  HTTP/REST API    │  WebSocket连接     │
              ▼                   ▼                   ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         Nginx 反向代理                                 │
│  ┌──────────────────────┐    ┌──────────────────────────────────┐   │
│  │ 静态资源 (前端打包)     │    │  /api/*  →  Spring Boot应用     │   │
│  │  /ws/*  → WebSocket  │    │  /upload/* → 文件存储            │   │
│  └──────────────────────┘    └──────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────┐
│                      应用层 (Spring Boot 3)                           │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                    Controller层（新增）                        │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │    │
│  │  │Profile   │ │Content   │ │Interact  │ │Message   │       │    │
│  │  │Controller│ │Controller│ │Controller│ │Controller│       │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐                    │    │
│  │  │Notify    │ │Relation  │ │File      │                    │    │
│  │  │Controller│ │Controller│ │Controller│                    │    │
│  │  └──────────┘ └──────────┘ └──────────┘                    │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                     Service层（新增）                          │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │    │
│  │  │Profile   │ │Content   │ │Interact  │ │Message   │       │    │
│  │  │Service   │ │Service   │ │Service   │ │Service   │       │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │    │
│  │  │Notify    │ │Relation  │ │File      │ │Permission│       │    │
│  │  │Service   │ │Service   │ │Service   │ │Service   │       │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                      Mapper层（新增）                          │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │    │
│  │  │Profile   │ │Content   │ │Comment   │ │Like      │       │    │
│  │  │Mapper    │ │Mapper    │ │Mapper    │ │Mapper    │       │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │    │
│  │  │Guestbook │ │Message   │ │Notify    │ │Content   │       │    │
│  │  │Mapper    │ │Mapper    │ │Mapper    │ │MediaMapper│      │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                   通用组件层（V1.0已有+扩展）                   │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │    │
│  │  │JWT认证   │ │异常处理  │ │统一响应  │ │权限拦截  │       │    │
│  │  │Filter    │ │Handler   │ │Result    │ │Interceptor│      │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                  WebSocket处理器（新增）                        │    │
│  │  ┌──────────────────────────────────────────────────────┐  │    │
│  │  │ WebSocketHandler - 实时通知推送、私信消息转发          │  │    │
│  │  └──────────────────────────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         数据层                                        │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐  │
│  │   MySQL 8.0     │    │   本地文件系统   │    │   Redis (可选)  │  │
│  │  结构化数据存储   │    │  图片/视频存储   │    │  缓存/会话管理   │  │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
```

### 2.2 V2.0新增模块标识说明

```
【已有】= V1.0已存在模块
【新增】= V2.0新增模块
【扩展】= V1.0模块的扩展

模块变更汇总:
┌─────────────────────────────────────────────────────┐
│ 模块类别        │ 模块名称        │ 状态   │ 说明   │
├─────────────────────────────────────────────────────┤
│ 认证模块        │ AuthController  │ 【已有】│ 不变   │
│ 成员管理        │ MemberController│ 【已有】│ 不变   │
│ 族谱展示        │ GenealogyCtrl   │ 【已有】│ 不变   │
├─────────────────────────────────────────────────────┤
│ 个人主页        │ ProfileCtrl     │ 【新增】│ 主页CRUD│
│ 内容管理        │ ContentCtrl     │ 【新增】│ 内容发布│
│ 互动系统        │ InteractCtrl    │ 【新增】│ 评论点赞│
│ 留言板          │ GuestbookCtrl   │ 【新增】│ 留言功能│
│ 私信系统        │ MessageCtrl     │ 【新增】│ 私信聊天│
│ 通知中心        │ NotifyCtrl      │ 【新增】│ 通知管理│
│ 亲属关系        │ RelationCtrl    │ 【新增】│ 关系判定│
│ 文件上传        │ FileCtrl        │ 【新增】│ 文件管理│
├─────────────────────────────────────────────────────┤
│ 权限控制        │ PermissionIntcp │ 【扩展】│ 新增权限│
│ WebSocket       │ WsHandler       │ 【新增】│ 实时推送│
└─────────────────────────────────────────────────────┘
```

### 2.3 V2.0后端包结构

```
backend/src/main/java/com/family/genealogy/
├── common/                    # 【已有】通用组件
│   ├── Result.java            # 统一响应封装
│   ├── ErrorCode.java         # 错误码定义【扩展】
│   └── PageResult.java        # 分页结果封装【新增】
│
├── config/                    # 【已有】配置类
│   ├── SecurityConfig.java    # 【已有】安全配置
│   ├── MybatisPlusConfig.java # 【已有】MyBatis配置
│   ├── WebSocketConfig.java   # 【新增】WebSocket配置
│   ├── FileStorageConfig.java # 【新增】文件存储配置
│   └── CorsConfig.java        # 【新增】跨域配置
│
├── controller/                # 控制器层
│   ├── AuthController.java    # 【已有】
│   ├── MemberController.java  # 【已有】
│   ├── GenealogyController.java # 【已有】
│   ├── ProfileController.java # 【新增】个人主页
│   ├── ContentController.java # 【新增】内容管理
│   ├── InteractionController.java # 【新增】互动（评论/点赞）
│   ├── GuestbookController.java   # 【新增】留言板
│   ├── MessageController.java # 【新增】私信
│   ├── NotificationController.java # 【新增】通知
│   ├── RelationshipController.java # 【新增】亲属关系
│   └── FileController.java    # 【新增】文件上传
│
├── service/                   # 业务逻辑层
│   ├── AuthService.java       # 【已有】
│   ├── MemberService.java     # 【已有】
│   ├── GenealogyService.java  # 【已有】
│   ├── ProfileService.java    # 【新增】
│   ├── ContentService.java    # 【新增】
│   ├── InteractionService.java # 【新增】
│   ├── GuestbookService.java  # 【新增】
│   ├── MessageService.java    # 【新增】
│   ├── NotificationService.java # 【新增】
│   ├── RelationshipService.java # 【新增】
│   ├── FileService.java       # 【新增】
│   └── PermissionService.java # 【新增】权限校验
│
├── mapper/                    # 数据访问层
│   ├── UserMapper.java        # 【已有】
│   ├── MemberMapper.java      # 【已有】
│   ├── FamilyMapper.java      # 【已有】
│   ├── ProfileMapper.java     # 【新增】
│   ├── ContentMapper.java     # 【新增】
│   ├── ContentMediaMapper.java # 【新增】
│   ├── CommentMapper.java     # 【新增】
│   ├── LikeMapper.java        # 【新增】
│   ├── GuestbookMapper.java   # 【新增】
│   ├── MessageMapper.java     # 【新增】
│   └── NotificationMapper.java # 【新增】
│
├── entity/                    # 数据库实体【全部新增】
│   ├── Profile.java
│   ├── Content.java
│   ├── ContentMedia.java
│   ├── Comment.java
│   ├── LikeRecord.java
│   ├── Guestbook.java
│   ├── Message.java
│   ├── MessageSession.java
│   └── Notification.java
│
├── dto/                       # 数据传输对象【全部新增】
│   ├── profile/               # 个人主页相关DTO
│   ├── content/               # 内容相关DTO
│   ├── interaction/           # 互动相关DTO
│   ├── message/               # 私信相关DTO
│   └── notification/          # 通知相关DTO
│
├── websocket/                 # 【新增】WebSocket相关
│   ├── WebSocketHandler.java
│   ├── WebSocketInterceptor.java
│   └── message/               # WebSocket消息定义
│
├── interceptor/               # 【新增】拦截器
│   └── PermissionInterceptor.java  # 权限校验拦截器
│
├── filter/                    # 【已有】过滤器
│   └── JwtAuthenticationFilter.java # 【已有】
│
├── exception/                 # 【已有】异常处理
│   ├── BusinessException.java # 【已有】
│   └── GlobalExceptionHandler.java # 【已有+扩展】
│
└── util/                      # 工具类
    ├── JwtUtils.java          # 【已有】
    ├── FileUtil.java          # 【新增】文件工具
    └── RelationshipUtil.java  # 【新增】关系计算工具
```

### 2.4 V2.0前端目录结构

```
frontend/src/
├── api/                       # API接口【扩展】
│   ├── auth.ts                # 【已有】
│   ├── member.ts              # 【已有】
│   ├── genealogy.ts           # 【已有】
│   ├── profile.ts             # 【新增】个人主页API
│   ├── content.ts             # 【新增】内容API
│   ├── interaction.ts         # 【新增】互动API
│   ├── guestbook.ts           # 【新增】留言板API
│   ├── message.ts             # 【新增】私信API
│   ├── notification.ts        # 【新增】通知API
│   └── file.ts                # 【新增】文件上传API
│
├── views/                     # 页面视图【新增】
│   ├── profile/
│   │   ├── MyProfileView.vue      # 我的主页
│   │   ├── UserProfileView.vue    # 他人主页
│   │   └── ProfileEditView.vue    # 编辑主页
│   ├── content/
│   │   ├── ContentPublishView.vue # 内容发布
│   │   └── ContentDetailView.vue  # 内容详情
│   ├── message/
│   │   ├── MessageListView.vue    # 私信列表
│   │   └── MessageChatView.vue    # 私信聊天
│   └── notification/
│       └── NotificationView.vue   # 通知中心
│
├── components/                # 公共组件【新增】
│   ├── profile/
│   │   ├── ProfileHeader.vue      # 主页头部
│   │   ├── ProfileSidebar.vue     # 侧边栏
│   │   └── ProfileNav.vue         # 主页导航Tab
│   ├── content/
│   │   ├── ContentCard.vue        # 内容卡片
│   │   ├── ContentEditor.vue      # 内容编辑器
│   │   ├── ImageGallery.vue       # 图片画廊
│   │   └── VideoPlayer.vue        # 视频播放器
│   ├── interaction/
│   │   ├── CommentSection.vue     # 评论区
│   │   ├── CommentItem.vue        # 评论项
│   │   ├── ReplyBox.vue           # 回复框
│   │   ├── LikeButton.vue         # 点赞按钮
│   │   └── GuestbookSection.vue   # 留言板
│   ├── message/
│   │   ├── ChatWindow.vue         # 聊天窗口
│   │   ├── MessageInput.vue       # 消息输入框
│   │   └── SessionList.vue        # 会话列表
│   └── notification/
│       ├── NotificationBadge.vue  # 通知角标
│       ├── NotificationList.vue   # 通知列表
│       └── NotificationItem.vue   # 通知项
│
├── store/                     # Pinia状态管理【扩展】
│   ├── user.ts                # 【已有】
│   ├── profile.ts             # 【新增】主页状态
│   ├── notification.ts        # 【新增】通知状态
│   ├── message.ts             # 【新增】私信状态
│   └── websocket.ts           # 【新增】WebSocket状态
│
├── composables/               # 【新增】组合式函数
│   ├── useWebSocket.ts        # WebSocket连接
│   ├── useInfiniteScroll.ts   # 无限滚动
│   └── useImageUpload.ts      # 图片上传
│
├── types/                     # TypeScript类型【扩展】
│   ├── genealogy.ts           # 【已有】
│   ├── profile.ts             # 【新增】
│   ├── content.ts             # 【新增】
│   ├── interaction.ts         # 【新增】
│   ├── message.ts             # 【新增】
│   └── notification.ts        # 【新增】
│
├── utils/                     # 工具函数【扩展】
│   ├── auth.ts                # 【已有】
│   ├── request.ts             # 【已有】
│   ├── websocket.ts           # 【新增】WebSocket工具
│   └── relationship.ts        # 【新增】关系计算工具
│
└── router/                    # 路由配置【扩展】
    └── index.ts               # 【扩展】新增V2.0路由
```

---

## 三、技术栈选型

### 3.1 后端技术栈

| 技术 | 版本 | 用途 | 选型理由 |
|------|------|------|----------|
| Spring Boot | 3.x | 应用框架 | 与V1.0保持一致，生态成熟 |
| Spring WebSocket | 3.x | 实时通信 | Spring生态内置，与Spring Boot无缝集成 |
| MyBatis Plus | 3.5+ | ORM框架 | 与V1.0保持一致，简化CRUD操作 |
| MySQL | 8.0 | 关系数据库 | 与V1.0保持一致，支持CTE递归查询（多层级评论） |
| Hibernate Validator | 8.x | 参数校验 | Spring生态标准校验方案 |
| 本地文件系统 | - | 文件存储 | V2.0初期方案，简单可靠，生产环境可替换为MinIO/OSS |

### 3.2 前端技术栈

| 技术 | 版本 | 用途 | 选型理由 |
|------|------|------|----------|
| Vue 3 | 3.4+ | 前端框架 | 与V1.0保持一致 |
| TypeScript | 5.x | 类型系统 | 与V1.0保持一致 |
| Element Plus | 2.x | UI组件库 | 与V1.0保持一致 |
| Pinia | 2.x | 状态管理 | Vue 3官方推荐状态管理 |
| Vue Router | 4.x | 路由管理 | Vue 3官方路由 |
| Axios | 1.x | HTTP客户端 | 与V1.0保持一致 |
| WebSocket API | 原生 | 实时通信 | 浏览器原生支持，无需额外依赖 |

### 3.3 WebSocket技术选型说明

**选择方案: Spring WebSocket (STOMP协议)**

```
优势:
1. 与Spring Boot 3完全兼容，零额外依赖
2. 内置STOMP协议支持，消息格式规范
3. 支持消息代理模式，可扩展为集群部署
4. 心跳检测内置，连接管理完善
5. 与现有JWT认证无缝集成

备选方案对比:
┌──────────────┬──────────┬──────────┬──────────┬──────────┐
│ 方案          │ 复杂度   │ 扩展性   │ 维护成本  │ 推荐度   │
├──────────────┼──────────┼──────────┼──────────┼──────────┤
│ Spring WS    │ 低       │ 中       │ 低       │ ★★★★★   │
│ Netty WS     │ 高       │ 高       │ 高       │ ★★★☆☆   │
│ SSE          │ 低       │ 低       │ 低       │ ★★★☆☆   │
│ 第三方服务    │ 中       │ 高       │ 中       │ ★★★★☆   │
└──────────────┴──────────┴──────────┴──────────┴──────────┘
```

### 3.4 文件存储方案

**V2.0初期: 本地文件系统存储**
```
优势:
1. 实现简单，无需额外服务
2. 开发环境友好
3. 生产环境可通过Nginx直接提供静态资源

存储路径规划:
e:\web_dev\web_dev\storage\
├── avatars\          # 用户头像
├── backgrounds\      # 主页背景图
├── content\          # 内容图片
│   ├── images\       # 压缩后的图片
│   └── originals\    # 原始图片
└── videos\           # 视频文件

URL访问模式:
GET /upload/{category}/{filename}
```

**生产环境升级路线: 可替换为阿里云OSS / MinIO**
```
只需替换FileService实现，不影响业务代码
通过接口抽象实现存储方案可插拔
```

---

## 四、模块划分与职责定义

### 4.1 模块总览

```
┌──────────────────────────────────────────────────────────────┐
│                        V2.0 功能模块                          │
├───────────┬──────────────────────────────────────────────────┤
│ 模块       │ 职责描述                                          │
├───────────┼──────────────────────────────────────────────────┤
│ 个人主页   │ 用户主页信息管理、展示、个性化设置                  │
│ 内容管理   │ 内容发布、编辑、删除、查询、分类管理                │
│ 社交互动   │ 评论、回复、点赞、留言等互动功能                    │
│ 消息通知   │ 实时通知推送、通知管理、@提醒                      │
│ 私信聊天   │ 用户间一对一私信通信                               │
│ 权限控制   │ 内容可见性、亲属关系判定、访问权限控制               │
│ 文件管理   │ 图片/视频上传、存储、访问、压缩                    │
│ 亲属关系   │ 族谱关系计算、关系标签生成、亲属判定                │
└───────────┴──────────────────────────────────────────────────┘
```

### 4.2 个人主页模块

```
┌────────────────────────────────────────────────────────┐
│                   个人主页模块                            │
├────────────────────────────────────────────────────────┤
│ Controller: ProfileController                           │
│ Service:    ProfileService                              │
│ Mapper:     ProfileMapper                               │
│ Entity:     Profile                                     │
├────────────────────────────────────────────────────────┤
│ 功能:                                                   │
│  1. 个人主页自动创建（用户首次访问时）                     │
│  2. 主页信息查询（自己的/他人的）                         │
│  3. 主页信息编辑（背景图、签名、兴趣标签）                 │
│  4. 主页统计数据（内容数、获赞数、留言数）                 │
│  5. 主页访问权限校验                                      │
├────────────────────────────────────────────────────────┤
│ 核心流程:                                                │
│  用户访问主页 → 检查是否存在 → 不存在则创建 → 返回信息     │
│  编辑主页 → 权限校验 → 更新信息 → 返回结果               │
└────────────────────────────────────────────────────────┘
```

### 4.3 内容管理模块

```
┌────────────────────────────────────────────────────────┐
│                   内容管理模块                            │
├────────────────────────────────────────────────────────┤
│ Controller: ContentController                           │
│ Service:    ContentService                              │
│ Mapper:     TimelinePostMapper, PostMediaMapper         │
│ Entity:     TimelinePost, PostMedia                     │
├────────────────────────────────────────────────────────┤
│ 功能:                                                   │
│  1. 动态发布（文本、图片、视频、生平事件）                │
│  2. 动态编辑/删除（仅作者）                              │
│  3. 动态查询（时间轴排序、分页加载）                      │
│  4. 动态分类筛选（通过t_post_category）                  │
│  5. 动态权限控制（公开、全家族、仅亲属、仅自己）          │
│  6. 动态媒体文件管理（图片关联、视频关联）                │
├────────────────────────────────────────────────────────┤
│ 核心流程:                                                │
│  发布动态 → 校验权限 → 保存动态 → 关联媒体 → 生成通知    │
│  查询动态 → 权限过滤 → 关联媒体 → 分页返回               │
└────────────────────────────────────────────────────────┘
```

### 4.4 社交互动模块

```
┌────────────────────────────────────────────────────────┐
│                   社交互动模块                            │
├────────────────────────────────────────────────────────┤
│ Controller: InteractionController, GuestbookController  │
│ Service:    InteractionService, GuestbookService         │
│ Mapper:     CommentMapper, LikeRecordMapper, MessageBoardMapper │
│ Entity:     Comment, LikeRecord, MessageBoard            │
├────────────────────────────────────────────────────────┤
│ 功能 - 评论系统:                                         │
│  1. 发布评论（支持@提醒）                                 │
│  2. 多层级回复（通过root_id + depth方案）                 │
│  3. 评论列表查询（时间排序/热度排序）                     │
│  4. 删除评论（作者/动态作者）                             │
│                                                          │
│ 功能 - 点赞系统:                                         │
│  1. 点赞/取消点赞（动态、评论、留言）                      │
│  2. 点赞状态查询                                         │
│  3. 点赞用户列表                                         │
│                                                          │
│ 功能 - 留言板:                                           │
│  1. 发布留言到他人主页                                   │
│  2. 留言列表查询                                         │
│  3. 删除留言（留言作者/主页主人）                         │
├────────────────────────────────────────────────────────┤
│ 核心流程:                                                │
│  发布评论 → 解析@提及 → 保存评论 → 生成通知 → 推送通知   │
│  点赞操作 → 检查状态 → 切换状态 → 更新计数 → 生成通知    │
└────────────────────────────────────────────────────────┘
```

### 4.5 消息通知模块

```
┌────────────────────────────────────────────────────────┐
│                   消息通知模块                            │
├────────────────────────────────────────────────────────┤
│ Controller: NotificationController                      │
│ Service:    NotificationService                         │
│ Mapper:     NotificationMapper                          │
│ Entity:     Notification                                │
│ WebSocket:  NotificationWebSocketHandler                │
├────────────────────────────────────────────────────────┤
│ 功能:                                                   │
│  1. 通知生成（评论、点赞、留言、@提醒、回复、私信）       │
│  2. 通知查询（分页、分类筛选）                            │
│  3. 通知已读标记                                         │
│  4. 一键全部已读                                         │
│  5. 实时推送（WebSocket）                                │
│  6. 未读计数统计                                         │
├────────────────────────────────────────────────────────┤
│ 通知类型:                                                │
│  COMMENT    - 评论通知                                   │
│  LIKE       - 点赞通知                                   │
│  GUESTBOOK  - 留言通知                                   │
│  MENTION    - @提醒通知                                  │
│  REPLY      - 回复通知                                   │
│  MESSAGE    - 私信通知                                   │
│  SYSTEM     - 系统通知                                   │
├────────────────────────────────────────────────────────┤
│ 核心流程:                                                │
│  互动行为 → 生成通知记录 → 查询在线用户 → WebSocket推送  │
│  用户拉取通知 → 标记已读 → 更新未读计数                   │
└────────────────────────────────────────────────────────┘
```

### 4.6 私信模块

```
┌────────────────────────────────────────────────────────┐
│                    私信模块                               │
├────────────────────────────────────────────────────────┤
│ Controller: MessageController                           │
│ Service:    MessageService                              │
│ Mapper:     MessageMapper                               │
│ Entity:     Message, MessageSession                     │
│ WebSocket:  MessageWebSocketHandler                     │
├────────────────────────────────────────────────────────┤
│ 功能:                                                   │
│  1. 私信会话管理（自动创建/查询）                        │
│  2. 发送私信（文本消息）                                 │
│  3. 私信列表（按最后消息时间排序）                       │
│  4. 私信会话详情（分页加载消息历史）                     │
│  5. 未读消息计数                                         │
│  6. 实时消息推送（WebSocket）                            │
│  7. 权限校验（仅同族谱成员可私信）                       │
├────────────────────────────────────────────────────────┤
│ 核心流程:                                                │
│  发送消息 → 权限校验 → 保存消息 → 更新会话 → WebSocket转发│
│  查询会话 → 加载消息列表 → 标记已读 → 返回               │
└────────────────────────────────────────────────────────┘
```

### 4.7 权限控制模块

```
┌────────────────────────────────────────────────────────┐
│                   权限控制模块                            │
├────────────────────────────────────────────────────────┤
│ Service:    PermissionService, RelationshipService      │
│ Interceptor: PermissionInterceptor                     │
├────────────────────────────────────────────────────────┤
│ 功能:                                                   │
│  1. 亲属关系判定（基于族谱数据）                         │
│  2. 内容可见性校验                                       │
│     - ALL: 全家族可见                                   │
│     - RELATIVE: 仅亲属可见                              │
│     - PRIVATE: 仅自己可见                               │
│  3. 操作权限校验（编辑/删除权限）                        │
│  4. 关系标签生成（叔侄、兄弟姐妹等）                     │
│  5. 跨族谱访问限制                                      │
├────────────────────────────────────────────────────────┤
│ 亲属判定逻辑:                                            │
│  同family_id + 通过father_id/mother_id可连通 = 亲属      │
│  使用BFS/DFS遍历族谱关系树判定连通性                     │
└────────────────────────────────────────────────────────┘
```

---

## 五、数据库扩展设计

### 5.1 新增数据表总览

```
┌──────────────────┬──────────────────────────┬──────────┬────────────┐
│ 表名              │ 说明                      │ 优先级   │ 依赖表      │
├──────────────────┼──────────────────────────┼──────────┼────────────┤
│ t_user_profile   │ 用户主页档案表             │ P0      │ t_user     │
│ t_timeline_post  │ 时间轴动态表               │ P0      │ t_user_profile│
│ t_post_media     │ 动态媒体关联表             │ P0      │ t_timeline_post│
│ t_post_category  │ 动态分类表                 │ P1      │ -          │
│ t_comment        │ 评论表                     │ P0      │ t_timeline_post│
│ t_like_record    │ 点赞记录表                 │ P0      │ -          │
│ t_message_board  │ 留言板表                   │ P0      │ t_user_profile│
│ t_private_message│ 私信消息表                 │ P1      │ t_user     │
│ t_message_session│ 私信会话表                 │ P1      │ t_user     │
│ t_notification   │ 通知表                     │ P0      │ t_user     │
│ t_topic          │ 话题表                     │ P2      │ -          │
│ t_topic_post     │ 话题动态关联表             │ P2      │ t_timeline_post│
│ t_user_interest  │ 用户兴趣表                 │ P2      │ t_user     │
│ t_privacy_setting│ 隐私设置表                 │ P2      │ t_user     │
└──────────────────┴──────────────────────────┴──────────┴────────────┘
```

### 5.2 表结构详细设计

#### 5.2.1 用户主页档案表 (t_user_profile)

```sql
CREATE TABLE t_user_profile (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主页ID',
    user_id         BIGINT NOT NULL UNIQUE COMMENT '关联用户ID',
    member_id       BIGINT COMMENT '关联成员ID',
    background_url  VARCHAR(500) COMMENT '主页背景图URL',
    signature       VARCHAR(200) COMMENT '个人签名',
    interests       VARCHAR(500) COMMENT '兴趣标签，逗号分隔',
    visit_count     BIGINT DEFAULT 0 COMMENT '访问次数',
    post_count      INT DEFAULT 0 COMMENT '动态数量',
    like_count      BIGINT DEFAULT 0 COMMENT '获赞总数',
    message_count   INT DEFAULT 0 COMMENT '留言数量',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user (user_id),
    INDEX idx_member (member_id),
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户主页档案表';
```

#### 5.2.2 时间轴动态表 (t_timeline_post)

```sql
CREATE TABLE t_timeline_post (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '动态ID',
    profile_id      BIGINT NOT NULL COMMENT '发布者主页ID',
    user_id         BIGINT NOT NULL COMMENT '发布者用户ID',
    post_type       ENUM('TEXT', 'IMAGE', 'VIDEO', 'LIFE_EVENT') DEFAULT 'TEXT' COMMENT '内容类型',
    category_id     BIGINT COMMENT '分类ID',
    title           VARCHAR(200) COMMENT '内容标题',
    content         TEXT COMMENT '文本内容',
    visibility      ENUM('PUBLIC', 'FAMILY', 'RELATIVE', 'PRIVATE') DEFAULT 'PUBLIC' COMMENT '可见范围',
    like_count      INT DEFAULT 0 COMMENT '点赞数',
    comment_count   INT DEFAULT 0 COMMENT '评论数',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_profile (profile_id),
    INDEX idx_user (user_id),
    INDEX idx_category (category_id),
    INDEX idx_created (created_at),
    INDEX idx_visibility (visibility),
    FOREIGN KEY (profile_id) REFERENCES t_user_profile(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES t_user(id),
    FOREIGN KEY (category_id) REFERENCES t_post_category(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='时间轴动态表';
```

#### 5.2.3 动态媒体关联表 (t_post_media)

```sql
CREATE TABLE t_post_media (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '媒体ID',
    post_id         BIGINT NOT NULL COMMENT '关联动态ID',
    type            ENUM('IMAGE', 'VIDEO') NOT NULL COMMENT '媒体类型',
    url             VARCHAR(500) NOT NULL COMMENT '媒体文件URL',
    thumbnail_url   VARCHAR(500) COMMENT '缩略图URL（视频用）',
    width           INT COMMENT '图片宽度',
    height          INT COMMENT '图片高度',
    file_size       BIGINT COMMENT '文件大小（字节）',
    sort_order      INT DEFAULT 0 COMMENT '排序顺序',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_post (post_id),
    FOREIGN KEY (post_id) REFERENCES t_timeline_post(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动态媒体关联表';
```

#### 5.2.4 动态分类表 (t_post_category)

```sql
CREATE TABLE t_post_category (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    name            VARCHAR(50) NOT NULL UNIQUE COMMENT '分类名称',
    icon            VARCHAR(50) COMMENT '分类图标',
    color           VARCHAR(20) COMMENT '分类颜色',
    sort_order      INT DEFAULT 0 COMMENT '排序顺序',
    is_system       TINYINT DEFAULT 0 COMMENT '是否系统预设：0-否，1-是',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_sort (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动态分类表';

-- 预置系统分类
INSERT INTO t_post_category (name, icon, color, is_system, sort_order) VALUES
('生平日志', '📝', '#409EFF', 1, 1),
('照片墙', '📷', '#67C23A', 1, 2),
('视频集', '🎬', '#E6A23C', 1, 3),
('心情随笔', '💭', '#F56C6C', 1, 4),
('家族故事', '🏠', '#909399', 1, 5);
```

#### 5.2.5 评论表 (t_comment)

```sql
CREATE TABLE t_comment (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评论ID',
    target_type     ENUM('POST', 'GUESTBOOK') NOT NULL COMMENT '评论目标类型',
    target_id       BIGINT NOT NULL COMMENT '关联目标ID',
    user_id         BIGINT NOT NULL COMMENT '评论者用户ID',
    parent_id       BIGINT DEFAULT 0 COMMENT '父评论ID，0表示顶级评论',
    root_id         BIGINT COMMENT '根评论ID，顶级评论时等于自身ID',
    reply_to_user_id BIGINT COMMENT '回复的目标用户ID',
    content         TEXT NOT NULL COMMENT '评论内容',
    like_count      INT DEFAULT 0 COMMENT '点赞数',
    depth           INT DEFAULT 0 COMMENT '嵌套层级，0为顶级',
    status          TINYINT DEFAULT 1 COMMENT '状态：1-正常，0-已删除',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_target (target_type, target_id),
    INDEX idx_user (user_id),
    INDEX idx_parent (parent_id),
    INDEX idx_root (root_id),
    FOREIGN KEY (user_id) REFERENCES t_user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';
```

> **设计说明**: 使用 `root_id + depth + parent_id` 方案优化多层级评论查询。`root_id` 标识所属的根评论，`depth` 表示嵌套层级。查询一级评论时按 `depth=0` 过滤，查询回复时按 `root_id` 筛选，方案更灵活且支持层级过滤。

#### 5.2.6 点赞记录表 (t_like_record)

```sql
CREATE TABLE t_like_record (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '点赞ID',
    user_id         BIGINT NOT NULL COMMENT '点赞用户ID',
    target_type     ENUM('POST', 'COMMENT', 'GUESTBOOK') NOT NULL COMMENT '点赞目标类型',
    target_id       BIGINT NOT NULL COMMENT '点赞目标ID',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_user_target (user_id, target_type, target_id),
    INDEX idx_target (target_type, target_id),
    FOREIGN KEY (user_id) REFERENCES t_user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='点赞记录表';
```

> **设计说明**: 使用唯一索引防止重复点赞，联合索引优化目标查询。

#### 5.2.7 留言板表 (t_message_board)

```sql
CREATE TABLE t_message_board (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '留言ID',
    profile_id      BIGINT NOT NULL COMMENT '被留言者主页ID',
    user_id         BIGINT NOT NULL COMMENT '留言者用户ID',
    content         TEXT NOT NULL COMMENT '留言内容',
    like_count      INT DEFAULT 0 COMMENT '点赞数',
    status          TINYINT DEFAULT 1 COMMENT '状态：1-正常，0-已删除',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_profile (profile_id),
    INDEX idx_user (user_id),
    FOREIGN KEY (profile_id) REFERENCES t_user_profile(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES t_user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='留言板表';
```

#### 5.2.8 私信会话表 (t_message_session)

```sql
CREATE TABLE t_message_session (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '会话ID',
    session_key     VARCHAR(50) NOT NULL UNIQUE COMMENT '会话唯一键: minId_maxId',
    user_id_1       BIGINT NOT NULL COMMENT '参与用户1',
    user_id_2       BIGINT NOT NULL COMMENT '参与用户2',
    last_message    VARCHAR(500) COMMENT '最后一条消息摘要',
    last_message_time DATETIME COMMENT '最后消息时间',
    unread_count_1  INT DEFAULT 0 COMMENT '用户1未读数',
    unread_count_2  INT DEFAULT 0 COMMENT '用户2未读数',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user1 (user_id_1),
    INDEX idx_user2 (user_id_2),
    INDEX idx_last_time (last_message_time),
    FOREIGN KEY (user_id_1) REFERENCES t_user(id),
    FOREIGN KEY (user_id_2) REFERENCES t_user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='私信会话表';
```

> **设计说明**: `session_key` 由 `min(userId1, userId2)_max(userId1, userId2)` 计算生成，确保任意两人之间的会话唯一。

#### 5.2.9 私信消息表 (t_private_message)

```sql
CREATE TABLE t_private_message (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '消息ID',
    session_id      BIGINT NOT NULL COMMENT '所属会话ID',
    sender_id       BIGINT NOT NULL COMMENT '发送者用户ID',
    receiver_id     BIGINT NOT NULL COMMENT '接收者用户ID',
    msg_type        ENUM('TEXT', 'IMAGE') DEFAULT 'TEXT' COMMENT '消息类型',
    content         TEXT COMMENT '文本内容',
    media_url       VARCHAR(500) COMMENT '媒体URL',
    is_read         TINYINT DEFAULT 0 COMMENT '是否已读：0-未读，1-已读',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_session (session_id),
    INDEX idx_sender (sender_id),
    INDEX idx_receiver (receiver_id),
    INDEX idx_session_created (session_id, created_at),
    FOREIGN KEY (session_id) REFERENCES t_message_session(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES t_user(id),
    FOREIGN KEY (receiver_id) REFERENCES t_user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='私信消息表';
```

#### 5.2.10 通知表 (t_notification)

```sql
CREATE TABLE t_notification (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '通知ID',
    user_id         BIGINT NOT NULL COMMENT '接收者用户ID',
    from_user_id    BIGINT COMMENT '触发者用户ID',
    type            ENUM('COMMENT', 'LIKE', 'GUESTBOOK', 'MENTION', 'REPLY', 'MESSAGE', 'SYSTEM') NOT NULL COMMENT '通知类型',
    target_type     ENUM('POST', 'COMMENT', 'GUESTBOOK', 'MESSAGE') COMMENT '关联目标类型',
    target_id       BIGINT COMMENT '关联目标ID',
    content         VARCHAR(500) COMMENT '通知文本摘要',
    is_read         TINYINT DEFAULT 0 COMMENT '是否已读：0-未读，1-已读',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user (user_id),
    INDEX idx_user_read (user_id, is_read),
    INDEX idx_user_type (user_id, type),
    INDEX idx_created (created_at),
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE,
    FOREIGN KEY (from_user_id) REFERENCES t_user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知表';
```

> **设计说明**: 通知类型新增 `REPLY` (回复通知)，共7种类型。`COMMENT` 用于评论通知，`REPLY` 用于回复评论通知，更细粒度区分。

### 5.3 表关系图

```
t_user ──1:1── t_user_profile
  │                │
  │                ├──1:N── t_timeline_post ──1:N── t_post_media
  │                │              │
  │                │              └──1:N── t_comment (target_type=POST) ──自关联(root_id+depth)
  │                │              │
  │                │              └──1:1── t_post_category (category_id)
  │                │              │
  │                │              └──N:M── t_like_record (target_type=POST)
  │                │              │
  │                │              └──M:N── t_topic_post (话题关联)
  │                │
  │                └──1:N── t_message_board ──N:M── t_like_record (target_type=GUESTBOOK)
  │                │              │
  │                │              └──1:N── t_comment (target_type=GUESTBOOK)
  │
  ├──1:N── t_like_record (用户发起的点赞)
  │
  ├──1:N── t_message_session (私信会话, 参与双方)
  │        └──1:N── t_private_message
  │
  ├──1:N── t_notification (作为接收者)
  │     └── (from_user_id 关联触发者)
  │
  ├──1:N── t_user_interest (用户兴趣)
  │
  └──1:1── t_privacy_setting (隐私设置)
```

#### 5.4 新增扩展表说明

以下表为V2.0预留的扩展功能表，可在后续迭代中实现：

**话题系统表 (t_topic, t_topic_post)**:
```sql
-- 话题表
CREATE TABLE t_topic (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(100) NOT NULL UNIQUE COMMENT '话题名称',
    description     VARCHAR(500) COMMENT '话题描述',
    post_count      INT DEFAULT 0 COMMENT '关联动态数',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='话题表';

-- 话题动态关联表
CREATE TABLE t_topic_post (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    topic_id        BIGINT NOT NULL,
    post_id         BIGINT NOT NULL,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_topic_post (topic_id, post_id),
    FOREIGN KEY (topic_id) REFERENCES t_topic(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES t_timeline_post(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='话题动态关联表';
```

**用户兴趣表 (t_user_interest)**:
```sql
CREATE TABLE t_user_interest (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id         BIGINT NOT NULL,
    interest_tag    VARCHAR(50) NOT NULL COMMENT '兴趣标签',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user (user_id),
    UNIQUE KEY uk_user_interest (user_id, interest_tag),
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户兴趣表';
```

**隐私设置表 (t_privacy_setting)**:
```sql
CREATE TABLE t_privacy_setting (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id         BIGINT NOT NULL UNIQUE,
    allow_view_profile TINYINT DEFAULT 1 COMMENT '允许查看主页：0-否，1-是',
    allow_message   TINYINT DEFAULT 1 COMMENT '允许接收私信：0-否，1-是',
    allow_guestbook TINYINT DEFAULT 1 COMMENT '允许留言：0-否，1-是',
    default_visibility VARCHAR(20) DEFAULT 'PUBLIC' COMMENT '默认可见范围',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='隐私设置表';
```

---

## 六、API接口设计规范

### 6.1 API通用规范

```
基础URL: /api/v1

认证方式: Bearer Token (JWT)
请求头:   Authorization: Bearer {token}
数据格式: application/json

统一响应格式:
{
  "code": 200,           // 业务状态码
  "message": "success",  // 提示信息
  "data": {...}          // 业务数据
}

分页响应格式:
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [...],    // 数据列表
    "total": 100,        // 总记录数
    "page": 1,           // 当前页码
    "size": 20           // 每页条数
  }
}

业务错误码格式:
{
  "code": 40001,         // 业务错误码
  "message": "参数校验失败",
  "data": null
}
```

### 6.2 业务错误码定义

| 错误码 | 模块 | 说明 |
|--------|------|------|
| 40001 | 通用 | 参数校验失败 |
| 40002 | 通用 | 资源不存在 |
| 40003 | 通用 | 操作无权限 |
| 40101 | 个人主页 | 主页不存在 |
| 40102 | 个人主页 | 无权编辑此主页 |
| 40103 | 个人主页 | 主页访问被拒绝 |
| 40201 | 动态管理 | 动态不存在 |
| 40202 | 动态管理 | 无权编辑此动态 |
| 40203 | 动态管理 | 动态可见性限制 |
| 40204 | 动态管理 | 分类不存在 |
| 40301 | 评论系统 | 评论不存在 |
| 40302 | 评论系统 | 评论层级超过限制 |
| 40303 | 评论系统 | 评论目标无效 |
| 40401 | 点赞系统 | 重复操作 |
| 40501 | 留言板 | 留言不存在 |
| 40601 | 私信系统 | 无权向此用户发送私信 |
| 40602 | 私信系统 | 会话不存在 |
| 40603 | 私信系统 | 消息不存在 |
| 40701 | 通知系统 | 通知不存在 |
| 40801 | 关系判定 | 非亲属关系 |
| 40802 | 关系判定 | 跨族谱访问限制 |
| 40901 | 文件上传 | 文件类型不支持 |
| 40902 | 文件上传 | 文件大小超限 |
| 41001 | 话题管理 | 话题不存在 |
| 41002 | 话题管理 | 话题名称已存在 |
| 41003 | 话题管理 | 无权管理此话题 |
| 41101 | 隐私设置 | 隐私设置不存在 |
| 41102 | 隐私设置 | 操作被隐私策略限制 |

### 6.3 个人主页模块 API

#### 6.3.1 获取个人主页信息

```
GET /api/v1/profiles/{userId}
```

**请求头**: `Authorization: Bearer {token}`

**路径参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| userId | Long | 是 | 用户ID |

**响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "userId": 1,
    "memberId": 1,
    "name": "张三",
    "gender": "MALE",
    "generation": 5,
    "familyName": "张氏家族",
    "backgroundUrl": "/upload/backgrounds/bg_001.jpg",
    "signature": "家和万事兴",
    "interests": ["旅行", "摄影", "读书"],
    "stats": {
      "visitCount": 128,
      "contentCount": 28,
      "likeCount": 156,
      "guestbookCount": 42
    },
    "relationshipLabel": null,
    "isOwner": true,
    "createdAt": "2026-04-15T10:00:00",
    "updatedAt": "2026-04-17T15:30:00"
  }
}
```

**说明**:
- 访问他人主页时，`relationshipLabel` 显示与访问者的关系（如"伯父"、"堂兄"）
- `isOwner` 标识是否为当前登录用户自己的主页
- 首次访问不存在的主页时，自动创建后返回

#### 6.3.2 编辑个人主页

```
PUT /api/v1/profiles/me
```

**请求头**: `Authorization: Bearer {token}`

**请求体**:

```json
{
  "backgroundUrl": "/upload/backgrounds/new_bg.jpg",
  "signature": "记录生活，传承家族",
  "interests": ["旅行", "摄影", "读书", "美食"]
}
```

**响应**:

```json
{
  "code": 200,
  "message": "主页信息更新成功",
  "data": {
    "id": 1,
    "backgroundUrl": "/upload/backgrounds/new_bg.jpg",
    "signature": "记录生活，传承家族",
    "interests": ["旅行", "摄影", "读书", "美食"],
    "updatedAt": "2026-04-17T16:00:00"
  }
}
```

### 6.4 内容管理模块 API

#### 6.4.1 发布内容

```
POST /api/v1/contents
```

**请求头**: `Authorization: Bearer {token}`

**请求体**:

```json
{
  "postType": "IMAGE",
  "categoryId": 2,
  "title": "家族聚会留念",
  "content": "今天家族聚会，大家都很开心...",
  "visibility": "PUBLIC",
  "mediaList": [
    { "url": "/upload/content/img_001.jpg", "type": "IMAGE" },
    { "url": "/upload/content/img_002.jpg", "type": "IMAGE" }
  ]
}
```

**请求体字段说明**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| postType | Enum | 是 | 内容类型：TEXT/IMAGE/VIDEO/LIFE_EVENT |
| categoryId | Long | 否 | 分类ID，关联t_post_category |
| title | String | 否 | 内容标题，最大200字符 |
| content | String | 是 | 文本内容 |
| visibility | Enum | 否 | 可见范围：PUBLIC/FAMILY/RELATIVE/PRIVATE |
| mediaList | Array | 否 | 媒体文件列表 |

**响应**:

```json
{
  "code": 200,
  "message": "动态发布成功",
  "data": {
    "id": 100,
    "postType": "IMAGE",
    "categoryId": 2,
    "title": "家族聚会留念",
    "createdAt": "2026-04-17T16:00:00"
  }
}
```

#### 6.4.2 获取内容列表（时间轴）

```
GET /api/v1/contents
```

**请求头**: `Authorization: Bearer {token}`

**Query参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| userId | Long | 否 | 用户ID，不传则获取当前用户内容 |
| categoryId | Long | 否 | 分类ID筛选 |
| year | Integer | 否 | 按年筛选 |
| month | Integer | 否 | 按月筛选 |
| page | Integer | 否 | 页码，默认1 |
| size | Integer | 否 | 每页条数，默认20，最大50 |
| sort | String | 否 | 排序：time_desc/time_asc，默认time_desc |

**响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 100,
        "profileId": 1,
        "userId": 1,
        "userName": "张三",
        "userAvatar": "/upload/avatars/avatar_001.jpg",
        "postType": "IMAGE",
        "categoryId": 2,
        "categoryName": "照片墙",
        "title": "家族聚会留念",
        "content": "今天家族聚会，大家都很开心...",
        "visibility": "PUBLIC",
        "mediaList": [
          {
            "id": 1,
            "type": "IMAGE",
            "url": "/upload/content/img_001.jpg",
            "thumbnailUrl": null,
            "width": 1920,
            "height": 1080
          }
        ],
        "likeCount": 12,
        "commentCount": 8,
        "isLiked": false,
        "createdAt": "2026-04-17T16:00:00",
        "relationshipLabel": null
      }
    ],
    "total": 28,
    "page": 1,
    "size": 20
  }
}
```

#### 6.4.3 获取内容详情

```
GET /api/v1/contents/{contentId}
```

**请求头**: `Authorization: Bearer {token}`

**响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 100,
    "profileId": 1,
    "userId": 1,
    "userName": "张三",
    "userAvatar": "/upload/avatars/avatar_001.jpg",
    "postType": "IMAGE",
    "categoryId": 2,
    "categoryName": "照片墙",
    "title": "家族聚会留念",
    "content": "今天家族聚会，大家都很开心...",
    "mediaList": [...],
    "likeCount": 12,
    "commentCount": 8,
    "isLiked": false,
    "createdAt": "2026-04-17T16:00:00",
    "relationshipLabel": null
  }
}
```

#### 6.4.4 编辑动态

```
PUT /api/v1/contents/{contentId}
```

**请求头**: `Authorization: Bearer {token}`

**请求体**: 同发布动态

**响应**:

```json
{
  "code": 200,
  "message": "动态更新成功",
  "data": {
    "id": 100,
    "updatedAt": "2026-04-17T18:00:00"
  }
}
```

#### 6.4.5 删除动态

```
DELETE /api/v1/contents/{contentId}
```

**请求头**: `Authorization: Bearer {token}`

**响应**:

```json
{
  "code": 200,
  "message": "内容删除成功"
}
```

### 6.5 评论系统 API

#### 6.5.1 发布评论

```
POST /api/v1/contents/{contentId}/comments
```

**请求头**: `Authorization: Bearer {token}`

**路径参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| contentId | Long | 是 | 内容ID |

**请求体**:

```json
{
  "content": "照片拍得真好！@李四 下次一起去",
  "parentId": 0,
  "replyToUserId": null
}
```

**请求体字段说明**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| content | String | 是 | 评论内容，支持@提及 |
| parentId | Long | 否 | 父评论ID，0或不传表示顶级评论 |
| replyToUserId | Long | 否 | 回复的目标用户ID |

**响应**:

```json
{
  "code": 200,
  "message": "评论发布成功",
  "data": {
    "id": 500,
    "targetType": "POST",
    "targetId": 100,
    "userId": 2,
    "userName": "李四",
    "userAvatar": "/upload/avatars/avatar_002.jpg",
    "content": "照片拍得真好！@李四 下次一起去",
    "parentId": 0,
    "rootId": 500,
    "replyToUserId": null,
    "replyToUserName": null,
    "depth": 0,
    "likeCount": 0,
    "createdAt": "2026-04-17T17:00:00"
  }
}
```

#### 6.5.2 获取评论列表

```
GET /api/v1/contents/{contentId}/comments
```

**请求头**: `Authorization: Bearer {token}`

**Query参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | Integer | 否 | 页码，默认1 |
| size | Integer | 否 | 每页条数，默认20 |
| sort | String | 否 | 排序：time（时间）/hot（热度），默认time |

**响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 500,
        "userId": 2,
        "userName": "李四",
        "userAvatar": "/upload/avatars/avatar_002.jpg",
        "content": "照片拍得真好！",
        "parentId": 0,
        "rootId": 500,
        "depth": 0,
        "likeCount": 5,
        "isLiked": false,
        "createdAt": "2026-04-17T17:00:00",
        "replies": [
          {
            "id": 501,
            "userId": 1,
            "userName": "张三",
            "userAvatar": "/upload/avatars/avatar_001.jpg",
            "content": "谢谢！下次一起拍",
            "parentId": 500,
            "rootId": 500,
            "replyToUserId": 2,
            "replyToUserName": "李四",
            "depth": 1,
            "likeCount": 2,
            "isLiked": true,
            "createdAt": "2026-04-17T17:05:00"
          }
        ],
        "replyCount": 1
      }
    ],
    "total": 8,
    "page": 1,
    "size": 20
  }
}
```

**说明**: 仅返回一级评论（depth=0），每条一级评论携带最多3条最新回复。点击"查看全部回复"可加载完整回复列表。

#### 6.5.3 获取评论的回复列表

```
GET /api/v1/comments/{rootId}/replies
```

**请求头**: `Authorization: Bearer {token}`

**Query参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | Integer | 否 | 页码，默认1 |
| size | Integer | 否 | 每页条数，默认20 |

**响应**: 格式同评论列表，返回该根评论下的所有回复（扁平化列表）。

**说明**: 接口使用 `rootId` 参数查询某根评论下的所有回复，采用 `SELECT * FROM t_comment WHERE root_id = ? AND depth > 0` 查询。

#### 6.5.4 删除评论

```
DELETE /api/v1/comments/{commentId}
```

**请求头**: `Authorization: Bearer {token}`

**响应**:

```json
{
  "code": 200,
  "message": "评论删除成功"
}
```

**权限规则**: 评论作者或内容作者可删除评论。

### 6.6 点赞系统 API

#### 6.6.1 切换点赞状态

```
POST /api/v1/likes
```

**请求头**: `Authorization: Bearer {token}`

**请求体**:

```json
{
  "targetType": "POST",
  "targetId": 100
}
```

**请求体字段说明**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| targetType | Enum | 是 | 目标类型：POST/COMMENT/GUESTBOOK |
| targetId | Long | 是 | 目标ID |

**响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "action": "LIKE",
    "likeCount": 13,
    "isLiked": true
  }
}
```

**说明**: 此接口为切换操作。已点赞则取消，未点赞则点赞。`action` 返回当前执行的操作（LIKE/UNLIKE）。

#### 6.6.2 获取点赞用户列表

```
GET /api/v1/likes/{targetType}/{targetId}/users
```

**请求头**: `Authorization: Bearer {token}`

**Query参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | Integer | 否 | 页码，默认1 |
| size | Integer | 否 | 每页条数，默认10 |

**响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "userId": 2,
        "userName": "李四",
        "userAvatar": "/upload/avatars/avatar_002.jpg"
      }
    ],
    "total": 13,
    "page": 1,
    "size": 10
  }
}
```

### 6.7 留言板 API

#### 6.7.1 发布留言

```
POST /api/v1/profiles/{userId}/guestbook
```

**请求头**: `Authorization: Bearer {token}`

**请求体**:

```json
{
  "content": "好久不见，最近怎么样？"
}
```

**响应**:

```json
{
  "code": 200,
  "message": "留言发布成功",
  "data": {
    "id": 200,
    "userId": 2,
    "userName": "李四",
    "userAvatar": "/upload/avatars/avatar_002.jpg",
    "content": "好久不见，最近怎么样？",
    "likeCount": 0,
    "createdAt": "2026-04-17T18:00:00"
  }
}
```

#### 6.7.2 获取留言列表

```
GET /api/v1/profiles/{userId}/guestbook
```

**请求头**: `Authorization: Bearer {token}`

**Query参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | Integer | 否 | 页码，默认1 |
| size | Integer | 否 | 每页条数，默认20 |

**响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 200,
        "userId": 2,
        "userName": "李四",
        "userAvatar": "/upload/avatars/avatar_002.jpg",
        "content": "好久不见，最近怎么样？",
        "likeCount": 3,
        "isLiked": false,
        "createdAt": "2026-04-17T18:00:00"
      }
    ],
    "total": 42,
    "page": 1,
    "size": 20
  }
}
```

#### 6.7.3 删除留言

```
DELETE /api/v1/guestbook/{guestbookId}
```

**请求头**: `Authorization: Bearer {token}`

**响应**:

```json
{
  "code": 200,
  "message": "留言删除成功"
}
```

**权限规则**: 留言作者或被留言主页的主人可删除留言。

### 6.8 私信系统 API

#### 6.8.1 获取私信会话列表

```
GET /api/v1/messages/sessions
```

**请求头**: `Authorization: Bearer {token}`

**Query参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | Integer | 否 | 页码，默认1 |
| size | Integer | 否 | 每页条数，默认20 |

**响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "sessionId": 10,
        "peerUserId": 2,
        "peerUserName": "李四",
        "peerUserAvatar": "/upload/avatars/avatar_002.jpg",
        "lastMessage": "好的，明天见！",
        "lastMessageTime": "2026-04-17T20:00:00",
        "unreadCount": 3
      }
    ],
    "total": 5,
    "page": 1,
    "size": 20
  }
}
```

#### 6.8.2 获取私信会话消息

```
GET /api/v1/messages/sessions/{sessionId}
```

**请求头**: `Authorization: Bearer {token}`

**Query参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | Integer | 否 | 页码，默认1 |
| size | Integer | 否 | 每页条数，默认50 |

**响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1000,
        "sessionId": 10,
        "senderId": 2,
        "senderName": "李四",
        "msgType": "TEXT",
        "content": "好的，明天见！",
        "isRead": true,
        "createdAt": "2026-04-17T20:00:00"
      }
    ],
    "total": 100,
    "page": 1,
    "size": 50,
    "peerUser": {
      "userId": 2,
      "userName": "李四",
      "userAvatar": "/upload/avatars/avatar_002.jpg"
    }
  }
}
```

#### 6.8.3 发送私信

```
POST /api/v1/messages
```

**请求头**: `Authorization: Bearer {token}`

**请求体**:

```json
{
  "receiverId": 2,
  "msgType": "TEXT",
  "content": "你好，在吗？"
}
```

**响应**:

```json
{
  "code": 200,
  "message": "消息发送成功",
  "data": {
    "id": 1001,
    "sessionId": 10,
    "senderId": 1,
    "receiverId": 2,
    "msgType": "TEXT",
    "content": "你好，在吗？",
    "createdAt": "2026-04-17T20:05:00"
  }
}
```

#### 6.8.4 标记消息已读

```
PUT /api/v1/messages/sessions/{sessionId}/read
```

**请求头**: `Authorization: Bearer {token}`

**响应**:

```json
{
  "code": 200,
  "message": "已标记为已读"
}
```

### 6.9 通知系统 API

#### 6.9.1 获取通知列表

```
GET /api/v1/notifications
```

**请求头**: `Authorization: Bearer {token}`

**Query参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| type | String | 否 | 通知类型筛选：COMMENT/LIKE/GUESTBOOK/MENTION/REPLY/MESSAGE/SYSTEM |
| page | Integer | 否 | 页码，默认1 |
| size | Integer | 否 | 每页条数，默认20 |

**响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 300,
        "fromUserId": 2,
        "fromUserName": "李四",
        "fromUserAvatar": "/upload/avatars/avatar_002.jpg",
        "type": "COMMENT",
        "content": "评论了你的动态 \"家族聚会留念\"",
        "targetType": "POST",
        "targetId": 100,
        "isRead": false,
        "createdAt": "2026-04-17T17:00:00"
      }
    ],
    "total": 15,
    "page": 1,
    "size": 20
  }
}
```

#### 6.9.2 获取未读通知数量

```
GET /api/v1/notifications/unread-count
```

**请求头**: `Authorization: Bearer {token}`

**响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "totalCount": 15,
    "commentCount": 5,
    "replyCount": 2,
    "likeCount": 8,
    "guestbookCount": 1,
    "mentionCount": 1,
    "messageCount": 0,
    "systemCount": 0
  }
}
```

#### 6.9.3 标记通知已读

```
PUT /api/v1/notifications/{notificationId}/read
```

**请求头**: `Authorization: Bearer {token}`

**响应**:

```json
{
  "code": 200,
  "message": "已标记为已读"
}
```

#### 6.9.4 全部标记已读

```
PUT /api/v1/notifications/read-all
```

**请求头**: `Authorization: Bearer {token}`

**响应**:

```json
{
  "code": 200,
  "message": "全部已标记为已读"
}
```

### 6.10 亲属关系 API

#### 6.10.1 获取两个用户的关系

```
GET /api/v1/relationships/{userId}/to/{targetUserId}
```

**请求头**: `Authorization: Bearer {token}`

**响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "isRelative": true,
    "sameFamily": true,
    "relationshipLabel": "堂兄",
    "generationDiff": 0,
    "pathDescription": "通过祖父 → 伯父 → 堂兄 关联"
  }
}
```

### 6.11 文件上传 API

#### 6.11.1 上传图片

```
POST /api/v1/files/images
```

**请求头**: `Authorization: Bearer {token}`
**Content-Type**: `multipart/form-data`

**请求参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | File | 是 | 图片文件 |

**限制**: 单文件最大10MB，支持jpg/png/gif/webp格式。

**响应**:

```json
{
  "code": 200,
  "message": "上传成功",
  "data": {
    "url": "/upload/content/2026/04/img_abc123.jpg",
    "width": 1920,
    "height": 1080,
    "fileSize": 2048000
  }
}
```

#### 6.11.2 上传视频

```
POST /api/v1/files/videos
```

**请求头**: `Authorization: Bearer {token}`
**Content-Type**: `multipart/form-data`

**请求参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | File | 是 | 视频文件 |

**限制**: 单文件最大500MB，支持mp4格式。

**响应**:

```json
{
  "code": 200,
  "message": "上传成功",
  "data": {
    "url": "/upload/videos/2026/04/video_xyz789.mp4",
    "thumbnailUrl": "/upload/videos/2026/04/video_xyz789_thumb.jpg",
    "duration": 932,
    "fileSize": 104857600
  }
}
```

#### 6.11.3 上传头像/背景图

```
POST /api/v1/files/avatars
POST /api/v1/files/backgrounds
```

请求/响应格式同上传图片。

---

## 七、WebSocket实时通信设计

### 7.1 WebSocket连接架构

```
┌──────────────────────────────────────────────────────────┐
│                    客户端 (Vue 3)                         │
│                                                           │
│  1. 建立连接: ws://host/ws?token={jwt_token}             │
│  2. 发送订阅: { type: "SUBSCRIBE", channel: "user_{id}" }│
│  3. 接收消息: { type: "NOTIFICATION", data: {...} }      │
│  4. 发送心跳: { type: "PING" }                           │
│  5. 接收心跳: { type: "PONG" }                           │
└──────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────┐
│              Spring WebSocket Handler                     │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ WebSocketInterceptor: JWT认证 + 用户身份绑定         │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ SessionManager: 管理在线用户会话映射                 │ │
│  │   userId -> WebSocketSession                        │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ MessageDispatcher: 消息分发路由                      │ │
│  │   SUBSCRIBE  → 订阅频道                              │ │
│  │   PING       → 响应PONG                             │ │
│  │   MESSAGE    → 转发私信                              │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

### 7.2 WebSocket连接配置

```
连接URL: ws://{host}/ws
认证参数: ?token={jwt_token}

心跳机制:
- 客户端每30秒发送 PING
- 服务端响应 PONG
- 超过90秒无心跳则断开连接

重连策略:
- 断开后指数退避重连（1s, 2s, 4s, 8s...最大30s）
- 重连后自动重新订阅频道
```

### 7.3 WebSocket消息格式

#### 7.3.1 客户端 → 服务端消息

```json
{
  "type": "SUBSCRIBE",
  "channel": "user_1",
  "timestamp": 1713340800000
}
```

```json
{
  "type": "MESSAGE",
  "channel": "user_2",
  "data": {
    "sessionId": 10,
    "msgType": "TEXT",
    "content": "你好"
  },
  "timestamp": 1713340800000
}
```

```json
{
  "type": "PING",
  "timestamp": 1713340800000
}
```

#### 7.3.2 服务端 → 客户端消息

```json
{
  "type": "PONG",
  "timestamp": 1713340800000
}
```

```json
{
  "type": "SUBSCRIBED",
  "channel": "user_1",
  "message": "订阅成功",
  "timestamp": 1713340800000
}
```

```json
{
  "type": "NOTIFICATION",
  "data": {
    "id": 300,
    "type": "COMMENT",
    "fromUserId": 2,
    "fromUserName": "李四",
    "fromUserAvatar": "/upload/avatars/avatar_002.jpg",
    "content": "评论了你的动态",
    "targetType": "POST",
    "targetId": 100,
    "createdAt": "2026-04-17T17:00:00"
  },
  "timestamp": 1713340860000
}
```

```json
{
  "type": "MESSAGE",
  "data": {
    "id": 1001,
    "sessionId": 10,
    "senderId": 2,
    "senderName": "李四",
    "msgType": "TEXT",
    "content": "你好",
    "createdAt": "2026-04-17T20:05:00"
  },
  "timestamp": 1713340900000
}
```

### 7.4 WebSocket事件类型定义

| 事件类型 | 方向 | 说明 |
|----------|------|------|
| CONNECT | 客户端→服务端 | 建立连接（URL参数认证） |
| SUBSCRIBE | 客户端→服务端 | 订阅用户频道 |
| SUBSCRIBED | 服务端→客户端 | 订阅成功确认 |
| UNSUBSCRIBE | 客户端→服务端 | 取消订阅 |
| PING | 客户端→服务端 | 心跳检测 |
| PONG | 服务端→客户端 | 心跳响应 |
| NOTIFICATION | 服务端→客户端 | 推送通知 |
| MESSAGE | 双向 | 私信消息传输 |
| ERROR | 服务端→客户端 | 错误信息 |
| DISCONNECT | 客户端→服务端 | 断开连接 |

### 7.5 实时推送流程图

```
用户A 评论 用户B的内容
        │
        ▼
┌──────────────────┐
│ 评论保存成功      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ 生成通知记录      │────▶│ 写入 t_notification│
│ (异步)           │     └──────────────────┘
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ 检查用户B是否在线 │────▶│ WebSocketSession │
│                  │     │ 存在？            │
└────────┬─────────┘     └────────┬─────────┘
         │                        │
         │ 是                     │ 否
         ▼                        ▼
┌──────────────────┐     ┌──────────────────┐
│ 通过WS推送通知    │     │ 通知已持久化      │
│ 用户B实时收到     │     │ 用户上线时拉取    │
└──────────────────┘     └──────────────────┘
```

---

## 八、权限控制架构

### 8.1 权限控制层次

```
┌─────────────────────────────────────────────────────────────┐
│                      权限控制层次                             │
│                                                              │
│  第一层: JWT认证过滤 (JwtAuthenticationFilter)                │
│  ├─ 验证Token有效性                                          │
│  ├─ 提取用户ID                                               │
│  └─ 放入SecurityContext                                      │
│                                                              │
│  第二层: URL权限拦截 (PermissionInterceptor)                  │
│  ├─ 校验资源访问权限                                          │
│  ├─ 校验内容可见性                                            │
│  └─ 校验操作权限                                              │
│                                                              │
│  第三层: 业务级权限校验 (PermissionService)                   │
│  ├─ 亲属关系判定                                              │
│  ├─ 跨族谱访问限制                                            │
│  └─ 内容/评论/留言操作权限                                     │
└─────────────────────────────────────────────────────────────┘
```

### 8.2 内容可见性控制

```
内容可见范围枚举:

PUBLIC (公开):
  - 所有用户可见
  - 默认可见范围

FAMILY (全家族可见):
  - 同family_id的所有用户可见

RELATIVE (仅亲属可见):
  - 需要通过族谱关系判定是否为亲属
  - 同family_id且通过father_id/mother_id连通的成员
  - 使用BFS遍历族谱树判定

PRIVATE (仅自己可见):
  - 仅内容发布者可查看
  - 管理员不可见（尊重隐私）

判定流程:
  请求访问内容
       │
       ▼
  检查内容visibility
       │
       ├── PUBLIC ─────→ 所有人可访问
       │
       ├── FAMILY ─────→ 检查是否同family_id ──是──→ 允许访问
       │                                          └──否──→ 拒绝
       │
       ├── RELATIVE ──→ 检查是否亲属 ─────────是──→ 允许访问
       │                                        └──否──→ 拒绝
       │
       └── PRIVATE ──→ 检查是否为内容作者 ────是──→ 允许访问
                                              └──否──→ 拒绝
```

### 8.3 操作权限矩阵

```
┌──────────────┬──────────┬──────────┬──────────┬──────────┐
│ 操作          │ 内容作者  │ 亲属     │ 同族成员  │ 其他用户  │
├──────────────┼──────────┼──────────┼──────────┼──────────┤
│ 查看主页      │ ✅       │ ✅      │ ✅      │ 受限    │
│ 查看动态(PUB) │ ✅       │ ✅      │ ✅      │ ✅      │
│ 查看动态(FAM) │ ✅       │ ✅      │ ✅      │ ❌      │
│ 查看动态(REL) │ ✅       │ ✅      │ ❌      │ ❌      │
│ 查看动态(PRV) │ ✅       │ ❌      │ ❌      │ ❌      │
│ 编辑动态      │ ✅       │ ❌      │ ❌      │ ❌      │
│ 删除动态      │ ✅       │ ❌      │ ❌      │ ❌      │
│ 评论          │ -        │ ✅      │ ✅      │ ❌      │
│ 点赞          │ -        │ ✅      │ ✅      │ ❌      │
│ 留言          │ -        │ ✅      │ ✅      │ ❌      │
│ 私信          │ -        │ ✅      │ ✅      │ ❌      │
│ 删除评论      │ ✅       │ ❌      │ ❌      │ ❌      │
│ 删除留言      │ ✅(主页) │ ❌      │ ❌      │ ❌      │
└──────────────┴──────────┴──────────┴──────────┴──────────┘

注: ✅ = 允许, ❌ = 拒绝, - = 不适用
```

### 8.4 亲属关系判定算法

```
判定两个用户是否为亲属:

Input: userId1, userId2
Output: isRelative, relationshipLabel, generationDiff

Algorithm:
1. 获取userId1对应的memberId
2. 获取userId2对应的memberId
3. 检查两个member的family_id是否相同
   - 不同 → 非亲属（除非跨族谱关系未来支持）
4. 使用BFS从member1开始遍历族谱关系树
   - 通过father_id/mother_id向上遍历
   - 通过子节点向下遍历（需预先建立反向索引）
5. 如果遍历中找到member2，则为亲属
6. 根据遍历路径计算关系标签

关系标签计算规则:
┌──────────────┬──────────────────────────────────────┐
│ 关系          │ 判定条件                              │
├──────────────┼──────────────────────────────────────┤
│ 父母          │ 直接father_id/mother_id关联            │
│ 子女          │ 反向father_id/mother_id关联            │
│ 兄弟姐妹      │ 同父母（father_id和mother_id相同）     │
│ 祖父母        │ 父亲的父亲/母亲                        │
│ 叔伯/姑姑     │ 祖父的子女（非父母）                    │
│ 堂兄弟姐妹    │ 叔伯的子女                            │
│ 表兄弟姐妹    │ 姑姑的子女                            │
│ 配偶          │ member.spouse_name匹配                │
└──────────────┴──────────────────────────────────────┘

性能优化:
- 亲属关系预计算缓存（Redis或本地缓存）
- 关系判定结果TTL: 1小时
- 族谱变更时清除相关缓存
```

---

## 九、前后端交互流程

### 9.1 个人主页访问流程

```
┌──────┐              ┌──────┐              ┌──────┐              ┌──────┐
│浏览器 │              │前端   │              │后端   │              │数据库 │
└──┬───┘              └──┬───┘              └──┬───┘              └──┬───┘
   │                     │                     │                     │
   │  访问主页 /profile/1│                     │                     │
   │────────────────────▶│                     │                     │
   │                     │  GET /api/v1/profiles/1                    │
   │                     │────────────────────▶│                     │
   │                     │                     │  检查主页是否存在     │
   │                     │                     │────────────────────▶│
   │                     │                     │                     │
   │                     │                     │  不存在则创建        │
   │                     │                     │◀────────────────────│
   │                     │                     │                     │
   │                     │                     │  查询权限校验        │
   │                     │                     │────────────────────▶│
   │                     │                     │◀────────────────────│
   │                     │                     │                     │
   │                     │  {code:200, data: { │                     │
   │                     │   profile info }}   │                     │
   │                     │◀────────────────────│                     │
   │  渲染主页页面        │                     │                     │
   │◀────────────────────│                     │                     │
   │                     │                     │                     │
   │  加载内容列表        │                     │                     │
   │────────────────────▶│                     │                     │
   │                     │  GET /api/v1/contents?userId=1&page=1    │
   │                     │────────────────────▶│                     │
   │                     │                     │  权限过滤 + 分页查询 │
   │                     │                     │────────────────────▶│
   │                     │                     │◀────────────────────│
   │                     │  {records: [...]}   │                     │
   │                     │◀────────────────────│                     │
   │  渲染时间轴内容      │                     │                     │
   │◀────────────────────│                     │                     │
```

### 9.2 内容发布流程

```
┌──────┐              ┌──────┐              ┌──────┐              ┌──────┐
│浏览器 │              │前端   │              │后端   │              │数据库 │
└──┬───┘              └──┬───┘              └──┬───┘              └──┬───┘
   │                     │                     │                     │
   │  1. 上传图片/视频    │                     │                     │
   │────────────────────▶│                     │                     │
   │                     │  POST /api/v1/files/images               │
   │                     │────────────────────▶│                     │
   │                     │                     │  文件校验 + 存储     │
   │                     │                     │────────────────────▶│
   │                     │  {url: "..."}      │                     │
   │                     │◀────────────────────│                     │
   │  显示上传预览        │                     │                     │
   │◀────────────────────│                     │                     │
   │                     │                     │                     │
   │  2. 填写内容并发布   │                     │                     │
   │────────────────────▶│                     │                     │
   │                     │  POST /api/v1/contents                   │
   │                     │────────────────────▶│                     │
   │                     │                     │  保存内容记录        │
   │                     │                     │────────────────────▶│
   │                     │                     │  关联媒体文件        │
   │                     │                     │────────────────────▶│
   │                     │                     │  更新统计计数        │
   │                     │                     │────────────────────▶│
   │                     │                     │                     │
   │                     │  {code:200, data}   │                     │
   │                     │◀────────────────────│                     │
   │  刷新时间轴          │                     │                     │
   │◀────────────────────│                     │                     │
   │                     │                     │                     │
```

### 9.3 评论发布与通知推送流程

```
┌──────┐              ┌──────┐              ┌──────┐     ┌──────┐     ┌──────┐
│用户A  │              │前端A  │              │后端   │     │WebSocket│  │用户B │
└──┬───┘              └──┬───┘              └──┬───┘     └──┬────┘     └──┬───┘
   │                     │                     │            │            │
   │  发布评论            │                     │            │            │
   │────────────────────▶│                     │            │            │
   │                     │  POST /contents/{id}/comments     │            │
   │                     │────────────────────▶│            │            │
   │                     │                     │            │            │
   │                     │                     │ 解析@提及   │            │
   │                     │                     │ 保存评论    │            │
   │                     │                     │ 更新计数    │            │
   │                     │                     │            │            │
   │                     │                     │ 生成通知记录│            │
   │                     │                     │───────────▶│            │
   │                     │                     │            │            │
   │                     │                     │ 检查用户B  │            │
   │                     │                     │ 是否在线   │            │
   │                     │                     │            │            │
   │                     │                     │ 在线       │            │
   │                     │                     │───────────▶│            │
   │                     │  {code:200, data}  │            │  NOTIFICATION│
   │                     │◀────────────────────│            │◀───────────│
   │                     │                     │            │            │
   │  评论成功，页面更新   │                     │            │  实时收到通知│
   │◀────────────────────│                     │            │◀───────────│
   │                     │                     │            │            │
   │                     │                     │            │  不在线      │
   │                     │                     │            │            │
   │                     │                     │            │  通知已持久化 │
   │                     │                     │            │  上线时拉取   │
   │                     │                     │            │◀───────────│
```

### 9.4 私信实时聊天流程

```
┌──────┐              ┌──────┐              ┌──────┐     ┌──────┐     ┌──────┐
│用户A  │              │前端A  │              │后端   │     │WebSocket│  │用户B │
└──┬───┘              └──┬───┘              └──┬───┘     └──┬────┘     └──┬───┘
   │                     │                     │            │            │
   │  建立WS连接          │                     │            │            │
   │                     │──ws连接─────────────▶│            │            │
   │                     │  SUBSCRIBE user_1   │            │            │
   │                     │─────────────────────▶│            │            │
   │                     │                     │◀──ws连接───│            │
   │                     │                     │  SUBSCRIBE user_2       │
   │                     │                     │            │            │
   │                     │                     │            │            │
   │  输入消息发送        │                     │            │            │
   │────────────────────▶│                     │            │            │
   │                     │  WS: MESSAGE        │            │            │
   │                     │─────────────────────▶│            │            │
   │                     │                     │            │            │
   │                     │                     │ 权限校验    │            │
   │                     │                     │ 保存消息    │            │
   │                     │                     │ 更新会话    │            │
   │                     │                     │            │            │
   │                     │                     │ 推送给用户B │            │
   │                     │                     │───────────▶│            │
   │                     │                     │            │            │
   │  发送成功确认        │                     │            │  MESSAGE   │
   │◀────────────────────│                     │            │◀───────────│
   │                     │                     │            │            │
   │                     │                     │            │  展示消息   │
   │                     │                     │            │◀───────────│
```

### 9.5 无限滚动加载流程

```
┌──────┐              ┌──────┐              ┌──────┐
│浏览器 │              │前端   │              │后端   │
└──┬───┘              └──┬───┘              └──┬───┘
   │                     │                     │
   │  首次加载 page=1    │                     │
   │────────────────────▶│                     │
   │                     │  GET /contents?userId=1&page=1&size=20 │
   │                     │────────────────────▶│
   │                     │  {records:[1..20], total:100}          │
   │                     │◀────────────────────│
   │  渲染前20条内容      │                     │
   │◀────────────────────│                     │
   │                     │                     │
   │  滚动到底部          │                     │
   │  自动触发下一页      │                     │
   │────────────────────▶│                     │
   │                     │  GET /contents?userId=1&page=2&size=20 │
   │                     │────────────────────▶│
   │                     │  {records:[21..40], total:100}         │
   │                     │◀────────────────────│
   │  追加渲染21-40条     │                     │
   │◀────────────────────│                     │
   │                     │                     │
   │  重复直到加载完毕    │                     │
   │  (total条数)        │                     │
   │                     │                     │
```

---

## 十、安全架构设计

### 10.1 安全分层架构

```
┌─────────────────────────────────────────────────────────────┐
│                       安全防护体系                            │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 传输层安全                                            │    │
│  │  - 生产环境强制HTTPS                                  │    │
│  │  - WebSocket over WSS                                │    │
│  │  - HSTS响应头                                         │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 认证与授权                                            │    │
│  │  - JWT Token认证（已有）                              │    │
│  │  - Token过期自动刷新                                 │    │
│  │  - WebSocket连接Token验证                            │    │
│  │  - 操作级权限校验                                     │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 输入校验与防护                                        │    │
│  │  - Hibernate Validator参数校验                       │    │
│  │  - XSS防护（评论内容过滤）                           │    │
│  │  - SQL注入防护（MyBatis参数化查询）                   │    │
│  │  - 文件类型白名单校验                                 │    │
│  │  - 文件大小限制                                      │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 数据安全                                              │    │
│  │  - 敏感内容可见性控制                                 │    │
│  │  - 私信内容端到权限隔离                               │    │
│  │  - 密码BCrypt加密（已有）                             │    │
│  │  - 文件访问权限控制                                   │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 接口防护                                              │    │
│  │  - 频率限制（评论/点赞/私信）                         │    │
│  │  - 防重复提交（幂等性）                               │    │
│  │  - 批量操作限制                                      │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### 10.2 XSS防护方案

```
风险场景:
- 用户发布内容中注入<script>标签
- 评论内容中包含恶意JavaScript代码
- 个人签名中嵌入XSS攻击

防护措施:
1. 后端输出过滤
   - 使用HtmlUtils.htmlEscape()对用户输入进行HTML转义
   - 存储时保留原始内容，输出时转义

2. 前端渲染防护
   - 使用Vue的{{}}插值（自动转义）而非v-html
   - 富文本编辑器使用白名单过滤HTML标签
   - 评论内容使用textContent而非innerHTML

3. CSP响应头
   - Content-Security-Policy: default-src 'self'
   - 限制内联脚本执行
```

### 10.3 文件上传安全

```
安全检查清单:
1. 文件类型校验
   - 通过MIME类型 + 文件扩展名双重校验
   - 白名单模式：仅允许 jpg/png/gif/webp/mp4

2. 文件大小限制
   - 图片：最大10MB
   - 视频：最大500MB
   - 配置Spring Boot的multipart.max-file-size

3. 文件名安全
   - 重命名为UUID格式，避免路径穿越
   - 格式：{UUID}_{original_extension}

4. 存储路径隔离
   - 不同类别文件存储在不同目录
   - 禁止访问storage目录外的文件

5. 图片压缩
   - 上传后自动生成缩略图
   - 大图压缩为适合Web展示的尺寸
```

### 10.4 接口频率限制

```
频率限制规则:

┌────────────────────┬────────────────┬────────────────┐
│ 接口               │ 限制规则        │ 超限响应        │
├────────────────────┼────────────────┼────────────────┤
│ 发布内容           │ 10次/小时      │ 429 Too Many   │
│ 发布评论           │ 30次/小时      │ 429 Too Many   │
│ 点赞操作           │ 60次/小时      │ 429 Too Many   │
│ 发布留言           │ 20次/小时      │ 429 Too Many   │
│ 发送私信           │ 30次/小时      │ 429 Too Many   │
│ 文件上传           │ 20次/小时      │ 429 Too Many   │
└────────────────────┴────────────────┴────────────────┘

实现方案 (V2.0):
- 使用本地内存Map记录用户操作时间戳
- 简化实现，无需引入Redis

生产环境升级:
- 引入Redis + 滑动窗口算法
- 更精确的分布式限流
```

### 10.5 隐私保护

```
隐私保护规则:
1. 内容可见性
   - PRIVATE内容仅作者可见，包括管理员
   - 通过PermissionInterceptor强制校验

2. 私信隐私
   - 仅参与会话的双方可查看消息
   - 无法通过API越权访问他人私信

3. 个人信息保护
   - 手机号等敏感信息不在API中返回
   - 用户ID与对外展示ID分离（未来可扩展）

4. 数据删除
   - 用户请求删除内容时软删除（status=0）
   - 保留数据用于审计，对外不再展示
```

---

## 十一、性能优化方案

### 11.1 数据库层优化

#### 11.1.1 索引策略

```
高频查询场景索引覆盖:

1. 动态列表查询（时间轴）
   - idx_profile (profile_id)
   - idx_created (created_at)
   - 复合索引建议: idx_profile_created (profile_id, created_at DESC)

2. 评论列表查询
   - idx_target (target_type, target_id) - 评论目标查询
   - idx_root (root_id) - 用于root_id查询回复

3. 通知查询
   - idx_user_read (user_id, is_read) - 未读通知查询
   - idx_user_type (user_id, type) - 按类型筛选

4. 私信会话
   - idx_user1_last_time (user_id_1, last_message_time DESC)
   - 确保会话列表按时间排序高效

5. 点赞查询
   - idx_target (target_type, target_id) - 查询某内容的点赞
   - uk_user_target - 唯一索引，防重复点赞
```

#### 11.1.2 多层级评论查询优化

```
问题: 多层级嵌套评论的递归查询性能差

解决方案: root_id + depth 方案

表设计:
t_comment.root_id 字段存储根评论ID
t_comment.depth 字段存储嵌套层级

查询一级评论:
SELECT * FROM t_comment WHERE target_id = ? AND target_type = 'POST' AND depth = 0
ORDER BY like_count DESC, created_at DESC LIMIT 20;

查询某评论的回复:
SELECT * FROM t_comment WHERE root_id = ? AND depth > 0
ORDER BY created_at ASC;

优势:
- 无需递归查询，单次SQL即可获取子树
- root_id使用等值查询，索引效率高
- depth支持层级过滤，灵活控制展示深度
- 插入时root_id取父评论的root_id（或自身ID），开销极小
```

#### 11.1.3 分页优化

```
深分页问题: offset过大导致查询慢

解决方案: 游标分页 (Cursor-based Pagination)

传统分页 (慢):
SELECT * FROM t_timeline_post WHERE profile_id = 1
ORDER BY created_at DESC LIMIT 20 OFFSET 10000;

游标分页 (快):
SELECT * FROM t_timeline_post WHERE profile_id = 1
AND created_at < '2026-03-01 10:00:00'
ORDER BY created_at DESC LIMIT 20;

前端传递上一页最后一条的createdAt作为游标。
```

### 11.2 应用层优化

#### 11.2.1 缓存策略

```
V2.0缓存方案 (内存缓存):

┌─────────────────────────────────────────────────────┐
│ 缓存内容              │ TTL    │ 更新策略            │
├─────────────────────────────────────────────────────┤
│ 用户主页基本信息       │ 30分钟  │ 编辑时失效         │
│ 亲属关系判定结果       │ 1小时   │ 族谱变更时失效     │
│ 内容点赞数             │ 5分钟   │ 定时刷新           │
│ 未读通知计数           │ 1分钟   │ 新通知时失效       │
│ 热点内容详情           │ 10分钟  │ 编辑/删除时失效    │
└─────────────────────────────────────────────────────┘

实现: 使用Spring Cache + ConcurrentMap缓存
```

#### 11.2.2 异步处理

```
异步操作清单:

1. 通知生成与推送
   - 互动操作完成后，异步生成通知记录
   - 使用@Async注解或ApplicationEventPublisher
   - 不阻塞主流程响应

2. 内容统计更新
   - 点赞/评论计数更新异步执行
   - 避免锁竞争

3. 图片处理
   - 上传图片后异步生成缩略图
   - 异步压缩大图

异步实现:
- Spring @Async + 线程池
- 线程池配置: 核心4线程，最大8线程，队列100
```

#### 11.2.3 批量查询优化

```
N+1查询问题:
加载内容列表时，每条内容单独查询作者信息、媒体列表、点赞状态

解决方案: 批量查询

优化前 (N+1):
for (Content content : contents) {
    User user = userService.getById(content.getUserId());
    List<Media> media = mediaService.getByContentId(content.getId());
    boolean liked = likeService.isLiked(userId, content.getId());
}

优化后 (批量):
List<Long> userIds = contents.stream().map(Content::getUserId).toList();
Map<Long, User> userMap = userService.getByIds(userIds);

List<Long> contentIds = contents.stream().map(Content::getId).toList();
Map<Long, List<Media>> mediaMap = mediaService.getByContentIds(contentIds);
Set<Long> likedIds = likeService.getLikedIds(userId, contentIds);
```

### 11.3 前端层优化

#### 11.3.1 加载性能

```
优化策略:

1. 图片懒加载
   - 使用IntersectionObserver API
   - 仅视口内的图片才加载
   - 缩略图先行，原图按需加载

2. 内容分页加载
   - 首次加载20条
   - 滚动到底部自动加载下一页
   - 使用vue3的IntersectionObserver实现

3. 路由懒加载
   - 个人主页相关页面按需加载
   - 使用Vue Router的动态import

4. WebSocket连接复用
   - 全局单一WebSocket连接
   - 通过频道订阅实现多路复用
   - 页面切换不断开连接
```

#### 11.3.2 渲染性能

```
优化策略:

1. 虚拟列表
   - 长列表（通知、私信）使用虚拟滚动
   - 仅渲染可视区域内的DOM节点
   - 使用vue-virtual-scroller库

2. 组件按需加载
   - 评论区、留言板等非首屏内容按需加载
   - 使用Vue的defineAsyncComponent

3. 防抖与节流
   - 搜索输入防抖（300ms）
   - 滚动事件节流（200ms）
   - 点赞按钮防重复点击
```

### 11.4 性能目标与指标

```
┌──────────────────────────────────┬───────────┬───────────┐
│ 指标                              │ 目标值     │ 测量方式   │
├──────────────────────────────────┼───────────┼───────────┤
│ 个人主页首屏加载时间              │ ≤ 1.5秒   │ Chrome Dev│
│ 内容列表接口响应时间              │ ≤ 500ms   │ 后端日志   │
│ 评论列表接口响应时间              │ ≤ 300ms   │ 后端日志   │
│ 图片上传完成时间（10MB内）        │ ≤ 3秒     │ 前端计时   │
│ 通知推送延迟                      │ ≤ 500ms   │ 端到端计时│
│ 并发在线用户数                    │ ≥ 1000    │ 压力测试   │
│ WebSocket连接稳定率               │ ≥ 99.9%   │ 监控日志   │
│ 数据库慢查询（>1s）比例           │ < 1%      │ MySQL慢查询│
└──────────────────────────────────┴───────────┴───────────┘
```

---

## 十二、扩展性设计

### 12.1 架构扩展性

```
未来可扩展方向:

1. 文件存储升级
   当前: 本地文件系统
   未来: 阿里云OSS / 腾讯云COS / MinIO
   方案: FileService接口抽象，实现可插拔

2. 缓存升级
   当前: 内存缓存 (ConcurrentMap)
   未来: Redis分布式缓存
   方案: Spring Cache抽象层，切换实现类

3. 消息队列引入
   当前: 直接方法调用
   未来: RabbitMQ / Kafka (通知异步处理)
   方案: ApplicationEvent事件驱动

4. 搜索引擎引入
   当前: MySQL LIKE模糊查询
   未来: Elasticsearch (全文搜索)
   方案: 内容同步到ES，查询路由切换

5. CDN加速
   当前: Nginx静态资源服务
   未来: CDN分发静态资源
   方案: 文件URL切换为CDN域名
```

### 12.2 接口扩展性

```
API版本管理:
- 当前版本: /api/v1/
- 未来版本: /api/v2/
- 向后兼容原则，旧版本持续维护

WebHook扩展:
- 预留WebHook机制
- 内容发布/互动事件可触发外部通知
- 用于未来与第三方系统集成
```

### 12.3 数据库扩展性

```
分库分表预留:
- t_timeline_post表按user_id分片
- t_notification表按user_id分片
- t_private_message表按session_id分片
- 使用MyBatis Plus的分片插件支持

读写分离:
- MySQL主从复制
- MyBatis Plus动态数据源
- 写操作走主库，读操作走从库
```

---

## 附录

### A. 技术选型决策记录

| 决策项 | 选择 | 备选 | 选择理由 |
|--------|------|------|----------|
| WebSocket方案 | Spring WebSocket | Netty | 与Spring Boot集成最简单 |
| 文件存储 | 本地文件系统 | MinIO | V2.0初期简化部署 |
| 评论层级结构 | root_id + depth | 物化路径 | 查询灵活，支持层级过滤，索引效率高 |
| 前端状态管理 | Pinia | Vuex | Vue 3官方推荐 |
| 缓存方案 | Spring Cache | 手动实现 | 标准化、易切换 |
| 分类方案 | t_post_category关联表 | 枚举字段 | 支持动态扩展分类，可配置 |
| 可见范围 | PUBLIC/FAMILY/RELATIVE/PRIVATE | ALL/RELATIVE/PRIVATE | 更细粒度控制可见性 |

### B. 与现有系统兼容性

```
兼容性保证:
1. API URL: 新接口遵循 /api/v1/ 前缀规范
2. 响应格式: 统一使用 Result<T> 封装
3. 认证机制: 复用现有JWT认证流程
4. 异常处理: 复用现有GlobalExceptionHandler
5. 数据库: 复用现有MySQL实例，新增表独立
6. 前端: 复用现有Element Plus组件库
7. 路由: 新页面挂载在现有路由体系下
```

### C. 开发注意事项

```
1. 命名规范
   - 所有新增类/接口/方法遵循现有驼峰命名规范
   - 数据库表遵循 t_{entity} 命名
   - 字段遵循 snake_case 命名

2. 代码分层
   - Controller仅负责参数接收和响应封装
   - 业务逻辑必须在Service层实现
   - 数据访问仅在Mapper层

3. 事务管理
   - 涉及多表写操作的方法添加@Transactional
   - 通知生成使用异步，不纳入主事务

4. 日志记录
   - 关键操作记录INFO级别日志
   - 异常情况记录ERROR级别日志
   - 使用@Slf4j注解

5. 单元测试
   - Service层核心业务逻辑编写单元测试
   - 覆盖率目标≥70%
```

---

*文档结束 - 家族族谱系统V2.0个人主页功能架构设计文档*
