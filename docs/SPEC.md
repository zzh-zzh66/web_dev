# 家族族谱系统 - 功能规格文档

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-04-16 | MVP版本：用户认证、成员管理、族谱展示 |

---

## 一、v1.0 MVP版本

### 1.1 MVP目标

聚焦核心功能，快速验证价值：
- 用户登录注册
- 成员信息的增删改查
- 家族树展示

### 1.2 MVP功能范围

| 模块 | 功能 | 说明 | 状态 |
|------|------|------|------|
| 用户认证 | 注册、登录、退出 | 基础认证功能 | ✓ 已完成 |
| 成员管理 | 添加、编辑、删除、查看、列表 | 核心CRUD操作 | ✓ 已完成 |
| 族谱展示 | 树形图展示、搜索、筛选、固定视口缩放拖动 | 完整族谱界面 | ✓ 已完成 |

### 1.3 模块详细规格

#### 1.3.1 用户认证模块

**功能列表：**

| 功能 | 说明 |
|------|------|
| 用户注册 | 手机号注册账号 |
| 用户登录 | 手机号+密码登录 |
| 退出登录 | 清除登录状态 |

#### 1.3.2 成员管理模块

**功能列表：**

| 功能 | 接口 | 说明 |
|------|------|------|
| 添加成员 | POST /api/v1/members | 添加新成员 |
| 编辑成员 | PUT /api/v1/members/{id} | 修改成员信息 |
| 删除成员 | DELETE /api/v1/members/{id} | 删除成员 |
| 成员详情 | GET /api/v1/members/{id} | 查看成员详细信息 |
| 成员列表 | GET /api/v1/members | 分页列表查询 |

**成员信息字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| name | String | 姓名 |
| gender | Enum | 性别：MALE/FEMALE |
| birthDate | Date | 出生日期 |
| deathDate | Date | 去世日期 |
| generation | Integer | 辈分 |
| spouseName | String | 配偶姓名 |
| fatherId | Long | 父亲ID |
| motherId | Long | 母亲ID |
| status | Enum | 状态：ALIVE/DECEASED |
| portraitUrl | String | 头像URL |
| biography | String | 生平简介 |
| birthplace | String | 出生地 |
| occupation | String | 职业 |

#### 1.3.3 族谱展示模块

**功能列表：**

| 功能 | 接口 | 说明 |
|------|------|------|
| 获取族谱树 | GET /api/v1/genealogy/tree | 获取族谱树数据 |
| 获取成员后代 | GET /api/v1/genealogy/{id}/descendants | 获取某成员的后代 |
| 获取成员祖先 | GET /api/v1/genealogy/{id}/ancestors | 获取某成员的祖先 |

**前端组件：**

| 组件 | 说明 | 状态 |
|------|------|------|
| GenealogyTreeView | 族谱展示主页面 | ✓ 已完成 |
| GenealogyNode | 族谱节点组件 | ✓ 已完成 |
| MemberDetailPanel | 成员详情侧边栏 | ✓ 已完成 |
| SearchBar | 搜索组件 | ✓ 已完成 |
| FilterPanel | 筛选组件 | ✓ 已完成 |
| MiniMap | 小地图导航 | P2 |

**族谱树结构：**

```json
{
  "memberId": 1,
  "name": "张三",
  "gender": "MALE",
  "generation": 1,
  "status": "ALIVE",
  "birthDate": "1950-01-01",
  "spouseName": "李氏",
  "fatherId": null,
  "motherId": null,
  "children": [
    {
      "memberId": 2,
      "name": "张四",
      "gender": "MALE",
      "generation": 2,
      "status": "ALIVE",
      "children": []
    }
  ]
}
```

---

## 二、接口总览

### 2.1 接口列表

| 接口编号 | 方法 | 路径 | 说明 |
|----------|------|------|------|
| AUTH-001 | POST | /api/v1/auth/register | 用户注册 |
| AUTH-002 | POST | /api/v1/auth/login | 用户登录 |
| AUTH-003 | POST | /api/v1/auth/logout | 退出登录 |
| AUTH-004 | GET | /api/v1/auth/profile | 获取个人信息 |
| AUTH-005 | PUT | /api/v1/auth/profile | 修改个人信息 |
| MEMBER-001 | POST | /api/v1/members | 添加成员 |
| MEMBER-002 | PUT | /api/v1/members/{id} | 编辑成员 |
| MEMBER-003 | DELETE | /api/v1/members/{id} | 删除成员 |
| MEMBER-004 | GET | /api/v1/members/{id} | 查看成员详情 |
| MEMBER-005 | GET | /api/v1/members | 成员列表 |
| GENE-001 | GET | /api/v1/genealogy/tree | 获取族谱树 |
| GENE-002 | GET | /api/v1/genealogy/{id}/descendants | 获取成员后代 |
| GENE-003 | GET | /api/v1/genealogy/{id}/ancestors | 获取成员祖先 |

---

## 三、数据库设计

### 3.1 核心表结构

**用户表 (users)**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BigInt | 主键 |
| phone | VARCHAR(20) | 手机号，唯一 |
| password | VARCHAR(255) | 密码（加密） |
| name | VARCHAR(50) | 姓名 |
| role | ENUM | 角色：ADMIN/MEMBER |
| family_id | BigInt | 家族ID |
| created_at | DATETIME | 创建时间 |
| updated_at | DATETIME | 更新时间 |

**成员表 (members)**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BigInt | 主键 |
| family_id | BigInt | 家族ID |
| name | VARCHAR(50) | 姓名 |
| gender | ENUM | 性别：MALE/FEMALE |
| birth_date | DATE | 出生日期 |
| death_date | DATE | 去世日期 |
| father_id | BigInt | 父亲ID |
| mother_id | BigInt | 母亲ID |
| spouse_name | VARCHAR(50) | 配偶姓名 |
| generation | INT | 辈分 |
| status | ENUM | 状态：ALIVE/DECEASED |
| portrait_url | VARCHAR(500) | 头像URL |
| biography | TEXT | 生平简介 |
| birthplace | VARCHAR(100) | 出生地 |
| occupation | VARCHAR(100) | 职业 |
| created_at | DATETIME | 创建时间 |
| updated_at | DATETIME | 更新时间 |

**家族表 (families)**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BigInt | 主键 |
| name | VARCHAR(100) | 家族名称 |
| description | TEXT | 家族描述 |
| created_at | DATETIME | 创建时间 |
| updated_at | DATETIME | 更新时间 |

---

## 四、用户故事

### US-001: 添加家族成员

```
作为 家族管理员
我希望 添加新家族成员
以便 记录新的家族成员信息

验收标准：
- 能够录入成员的姓名、性别、出生日期
- 能够选择成员的父亲和母亲
- 成员添加后能够立即在族谱中显示
```

### US-002: 查看家族族谱

```
作为 系统用户
我希望 查看家族族谱
以便 了解家族成员结构

验收标准：
- 能够看到以树形图展示的家族谱系
- 能够点击成员查看详细信息
- 能够看到成员之间的父子关系
```

### US-003: 用户登录

```
作为 系统用户
我希望 登录系统
以便 使用族谱管理功能

验收标准：
- 输入正确的手机号和密码能够登录
- 登录成功获得Token
- Token用于后续接口访问认证
```

---

## 五、技术约束

### 5.1 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| 后端 | Spring Boot | Java 17 |
| 数据库 | MySQL 8.0 | 关系数据库 |
| 前端 | Vue 3 | 渐进式框架 |
| UI框架 | Element Plus | Vue 3 组件库 |
| 状态管理 | Pinia | Vue 状态管理 |
| 构建工具 | Vite | 前端构建工具 |

### 5.2 安全要求

| 项目 | 要求 |
|------|------|
| 密码加密 | BCrypt |
| 接口认证 | JWT Token |
| 传输安全 | HTTPS |

### 5.3 性能要求

| 指标 | 要求 |
|------|------|
| 登录响应时间 | ≤1s |
| 列表查询响应时间 | ≤500ms |
| 族谱树加载时间 | ≤2s（100人规模） |
