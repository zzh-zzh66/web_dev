# 变更日志 (CHANGELOG)

> 所有重要的项目变更记录。

**格式说明**: 基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)
**版本控制**: 基于 [语义化版本控制](https://semver.org/lang/zh-CN/)

---

## [2.0.0] - 2026-04-17

### 新增

#### 个人主页功能
- 个人生平记录与兴趣内容展示
- 时间轴组织个人经历和事件
- 支持文本、图片、视频多种内容类型
- 个人资料编辑和管理
- 内容分类管理 (生活、工作、旅行等)
- 图片网格布局展示

#### 社交互动系统
- 多层级评论回复功能
- 点赞计数与取消点赞
- 留言板管理 (创建、回复、删除)
- 评论和留言的富文本支持

#### 亲属互动机制
- 免好友添加直接互动 (基于亲属关系)
- 基于亲属关系的权限控制
- 隐私设置管理 (公开、仅亲属、仅自己)

#### 用户间互动
- 私信聊天功能 (一对一)
- 私信会话管理
- @提醒功能 (评论和留言中)
- 通知中心 (统一通知管理)
- 兴趣话题 (创建、参与、关注)
- 未读消息实时计数

#### 实时功能
- WebSocket实时通知推送
- 实时点赞状态更新
- 新消息实时提醒

#### 文件上传
- 图片上传和展示
- 视频链接嵌入
- 文件大小和类型校验
- 上传进度显示

#### 响应式设计
- PC端三栏布局 (个人信息、内容、互动)
- 移动端适配
- 平板端适配
- 横竖屏自适应

### 技术改进

#### 后端
- Spring Boot 框架升级
- MyBatis Plus 数据访问层
- WebSocket实时通信支持
- 统一异常处理机制
- 统一响应格式 (Result类)
- JWT认证集成
- RESTful API设计

#### 前端
- Vue 3 + TypeScript 技术栈
- Vite 构建工具
- Pinia 状态管理
- Element Plus UI组件库
- 组件化开发
- 路由懒加载
- WebSocket管理器

#### 数据库
- 新增14张数据表:
  - `user_profile` - 用户资料
  - `timeline_post` - 时间轴内容
  - `post_media` - 内容媒体
  - `post_category` - 内容分类
  - `comment` - 评论
  - `like_record` - 点赞记录
  - `message_board` - 留言板
  - `private_message` - 私信
  - `message_session` - 私信会话
  - `notification` - 通知
  - `topic` - 话题
  - `topic_post` - 话题帖子
  - `user_interest` - 用户兴趣
  - `privacy_setting` - 隐私设置

### API

#### 新增API (40+个)
- 个人资料CRUD接口
- 时间轴内容CRUD接口
- 评论和回复接口
- 点赞接口
- 留言板接口
- 私信接口
- 通知接口
- 话题接口
- 文件上传接口

### 文档

- 新增产品需求文档 (PRODUCT-REQUIREMENTS-V2.0.md)
- 新增架构设计文档 (ARCHITECTURE-DESIGN-V2.0.md)
- 新增数据库设计文档 (DATABASE-DESIGN-V2.0.md)
- 新增UI设计文档 (UI-DESIGN-V2.0.md)
- 新增版本控制规范 (VERSION-CONTROL-V2.0.md)
- 新增发布说明 (RELEASE-NOTES-V2.0.md)
- 更新API文档 (API.md)
- 更新部署文档 (DEPLOYMENT.md)
- 更新测试文档 (TESTING.md)

---

## [1.0.0] - 初始版本

### 新增

#### 族谱管理基础功能
- 族谱树可视化展示
- 成员管理 (增删改查)
- 成员关系管理
- 成员信息记录
- 家族管理

#### 用户系统
- 用户注册
- 用户登录
- JWT Token认证
- 用户权限管理

#### 基础架构
- Spring Boot 后端框架
- Vue 3 前端框架
- MySQL 数据库
- RESTful API
- 基础CI/CD配置

### 数据库

- `user` - 用户表
- `family` - 家族表
- `member` - 成员表
- `relationship` - 关系表

### 文档

- 产品需求文档 (PRODUCT-REQUIREMENTS-V2.0.md)
- 架构设计文档 (ARCHITECTURE.md)
- 数据库设计文档 (DATABASE.md)
- UI设计文档 (UI_DESIGN.md)
- API文档 (API.md)
- 部署文档 (DEPLOYMENT.md)
- 开发文档 (DEVELOPMENT.md)
- 用户指南 (USER_GUIDE.md)

---

## 版本说明

### 标签含义

- `新增` - 新增的功能
- `变更` - 现有功能的变更
- `废弃` - 即将移除的功能
- `移除` - 已移除的功能
- `修复` - Bug修复
- `安全` - 安全相关的修复或改进

### 获取完整变更

可以通过以下命令查看两个版本间的完整变更:

```bash
git log v1.0.0..v2.0.0 --oneline
```

---

**格式参考**: [Keep a Changelog](https://keepachangelog.com/)
**版本规范**: [Semantic Versioning](https://semver.org/)
