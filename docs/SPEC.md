# 家族族谱系统 - 功能规格文档

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-04-16 | MVP版本：用户认证、成员管理、族谱展示（已完成） |
| v2.0 | 待定 | 完善版本：关系管理、搜索功能、多媒体 |
| v3.0 | 待定 | 扩展版本：导入导出、权限管理、多视图 |

---

## 一、v1.0 MVP版本

### 1.1 MVP目标 ✓ 已完成

聚焦核心功能，快速验证价值：
- ✓ 成员信息的增删改查
- ✓ 简单家族树展示
- ✓ 用户登录注册

### 1.2 MVP功能范围 ✓ 已完成

| 模块 | 功能 | 说明 | 状态 |
|------|------|------|------|
| 用户认证 | 注册、登录、退出 | 基础认证功能 | ✓ 已完成 |
| 成员管理 | 添加、编辑、删除、查看、列表 | 核心CRUD操作 | ✓ 已完成 |
| 族谱展示 | 树形图展示、搜索、筛选、小地图导航 | 完整族谱界面 | ✓ 已完成 |

### 1.3 模块详细规格

#### 1.3.1 用户认证模块

**功能列表：**

| 功能 | 说明 |
|------|------|
| 用户注册 | 手机号+密码注册 |
| 用户登录 | 手机号+密码登录，返回Token |
| 退出登录 | 清除登录状态 |
| 个人信息 | 查看和修改个人信息 |

**用户角色（v1.0简化版）：**

| 角色 | 说明 |
|------|------|
| 管理员 | 管理家族成员 |
| 成员 | 查看族谱、修改个人信息 |

**业务流程：**

```
注册流程：
开始 → 输入手机号 → 设置密码 → 验证手机号 → 完成注册

登录流程：
开始 → 输入手机号+密码 → 验证通过 → 返回Token → 结束
```

#### 1.3.2 成员管理模块

**功能列表：**

| 功能 | 接口 | 说明 |
|------|------|------|
| 添加成员 | POST /members | 添加新成员 |
| 编辑成员 | PUT /members/{id} | 修改成员信息 |
| 删除成员 | DELETE /members/{id} | 删除成员 |
| 查看成员 | GET /members/{id} | 查看成员详情 |
| 成员列表 | GET /members | 分页列表 |

**成员信息字段（v1.0核心字段）：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | String | 是 | 姓名，2-20字符 |
| gender | Enum | 是 | 男/女 |
| birthDate | Date | 否 | 出生日期 |
| fatherId | Long | 否 | 父亲ID |
| motherId | Long | 否 | 母亲ID |
| spouseName | String | 否 | 配偶姓名 |
| generation | Integer | 否 | 辈分，数字越大辈分越小 |
| status | Enum | 是 | 在世/去世 |

**成员信息字段（v2.0扩展字段）：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| portraitUrl | String | 否 | 头像URL |
| biography | Text | 否 | 个人简介 |
| birthplace | String | 否 | 出生地 |
| occupation | String | 否 | 职业 |

#### 1.3.3 族谱展示模块

**功能列表：**

| 功能 | 接口 | 说明 | 状态 |
|------|------|------|------|
| 获取族谱树 | GET /genealogy/tree | 获取族谱树数据 | ✓ 已完成 |
| 获取成员后代 | GET /genealogy/{id}/descendants | 获取某成员的后代 | ✓ 已完成 |
| 获取成员祖先 | GET /genealogy/{id}/ancestors | 获取某成员的祖先 | ✓ 已完成 |

**前端组件：**

| 组件 | 说明 | 状态 |
|------|------|------|
| GenealogyTreeView | 族谱展示主页面 | ✓ 已完成 |
| GenealogyNode | 族谱节点组件 | ✓ 已完成 |
| MemberDetailPanel | 成员详情侧边栏 | ✓ 已完成 |
| SearchBar | 搜索组件 | ✓ 已完成 |
| FilterPanel | 筛选组件 | ✓ 已完成 |
| MiniMap | 小地图导航 | ✓ 已完成 |

**族谱树结构（v1.0已完成）：**

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

## 二、v2.0 完善版本

### 2.1 v2.0目标

增强用户体验，添加关系管理和搜索功能

### 2.2 新增功能

#### 2.2.1 关系管理

| 功能 | 接口 | 说明 |
|------|------|------|
| 添加关系 | POST /relations | 建立成员关系 |
| 删除关系 | DELETE /relations/{id} | 解除关系 |
| 查看关系 | GET /members/{id}/relations | 查看成员所有关系 |

**关系类型（v2.0简化版）：**

| 关系 | 说明 |
|------|------|
| 父子 | 父亲-子女 |
| 母子 | 母亲-子女 |
| 配偶 | 夫妻 |

**关系校验规则（v2.0简化版）：**

```
规则1：不能形成循环父子关系
  A是B的父亲 → B不能是A的父亲

规则2：年龄逻辑校验
  父亲的出生日期必须早于子女
```

#### 2.2.2 搜索功能

| 功能 | 接口 | 说明 |
|------|------|------|
| 搜索成员 | GET /search?q={keyword} | 按姓名搜索 |
| 高级搜索 | GET /search/advanced | 多条件组合搜索 |

**搜索条件（v2.0）：**

| 字段 | 类型 | 说明 |
|------|------|------|
| name | 模糊匹配 | 姓名 |
| birthYear | 范围查询 | 出生年份范围 |
| generation | 精确查询 | 辈分 |
| birthplace | 模糊匹配 | 出生地 |

#### 2.2.3 多媒体支持

| 功能 | 接口 | 说明 |
|------|------|------|
| 上传头像 | POST /upload/avatar | 上传成员头像 |
| 上传照片 | POST /upload/photo | 上传成员照片 |
| 查看相册 | GET /members/{id}/photos | 查看成员照片列表 |

---

## 三、v3.0 扩展版本

### 3.1 v3.0目标

企业级功能，支持数据管理和多视图展示

### 3.2 新增功能

#### 3.2.1 数据导入导出

| 功能 | 接口 | 说明 |
|------|------|------|
| Excel导入 | POST /import/excel | 批量导入成员 |
| Excel导出 | GET /export/excel | 导出成员数据 |
| 族谱PDF导出 | GET /export/pdf | 导出族谱PDF |

#### 3.2.2 多视图展示

| 视图类型 | 说明 |
|----------|------|
| 竖向树形图 | 传统族谱样式，自上而下 |
| 横向树形图 | 自左向右展开 |
| 时间轴视图 | 按时间顺序展示 |

#### 3.2.3 权限管理

| 角色 | 编码 | 说明 |
|------|------|------|
| 超级管理员 | SUPER_ADMIN | 系统最高权限 |
| 家族管理员 | FAMILY_ADMIN | 家族管理者 |
| 家族成员 | FAMILY_MEMBER | 普通成员 |
| 访客 | GUEST | 只读权限 |

---

## 四、接口总览

### 4.1 v1.0 MVP接口

| 接口编号 | 方法 | 路径 | 说明 |
|----------|------|------|------|
| AUTH-001 | POST | /auth/register | 用户注册 |
| AUTH-002 | POST | /auth/login | 用户登录 |
| AUTH-003 | POST | /auth/logout | 退出登录 |
| AUTH-004 | GET | /auth/profile | 获取个人信息 |
| AUTH-005 | PUT | /auth/profile | 修改个人信息 |
| MEMBER-001 | POST | /members | 添加成员 |
| MEMBER-002 | PUT | /members/{id} | 编辑成员 |
| MEMBER-003 | DELETE | /members/{id} | 删除成员 |
| MEMBER-004 | GET | /members/{id} | 查看成员详情 |
| MEMBER-005 | GET | /members | 成员列表 |
| GENE-001 | GET | /genealogy/tree | 获取族谱树 |

### 4.2 v2.0 新增接口

| 接口编号 | 方法 | 路径 | 说明 |
|----------|------|------|------|
| REL-001 | POST | /relations | 添加关系 |
| REL-002 | DELETE | /relations/{id} | 删除关系 |
| REL-003 | GET | /members/{id}/relations | 查看成员关系 |
| SEARCH-001 | GET | /search?q={keyword} | 搜索成员 |
| SEARCH-002 | GET | /search/advanced | 高级搜索 |
| MEDIA-001 | POST | /upload/avatar | 上传头像 |
| MEDIA-002 | POST | /upload/photo | 上传照片 |
| MEDIA-003 | GET | /members/{id}/photos | 查看照片 |

### 4.3 v3.0 新增接口

| 接口编号 | 方法 | 路径 | 说明 |
|----------|------|------|------|
| IMP-001 | POST | /import/excel | Excel导入 |
| EXP-001 | GET | /export/excel | Excel导出 |
| EXP-002 | GET | /export/pdf | PDF导出 |
| GENE-002 | GET | /genealogy/horizontal | 横向树形图 |
| GENE-003 | GET | /genealogy/timeline | 时间轴视图 |
| SYS-001 | GET | /admin/users | 用户管理 |
| SYS-002 | GET | /admin/logs | 操作日志 |

---

## 五、数据库设计（v1.0）

### 5.1 核心表结构

**用户表 (users)**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BigInt | 主键 |
| phone | VARCHAR(20) | 手机号，唯一 |
| password | VARCHAR(255) | 密码（加密） |
| name | VARCHAR(50) | 姓名 |
| role | ENUM | 角色：ADMIN/MEMBER |
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
| created_at | DATETIME | 创建时间 |
| updated_at | DATETIME | 更新时间 |

---

## 六、用户故事

### 6.1 v1.0 MVP用户故事

#### US-001: 添加家族成员

```
作为 家族管理员
我希望 添加新家族成员
以便 记录新的家族成员信息

验收标准：
- 能够录入成员的姓名、性别、出生日期
- 能够选择成员的父亲和母亲
- 成员添加后能够立即在族谱中显示
```

#### US-002: 查看家族族谱

```
作为 系统用户
我希望 查看家族族谱
以便 了解家族成员结构

验收标准：
- 能够看到以树形图展示的家族谱系
- 能够点击成员查看详细信息
- 能够看到成员之间的父子关系
```

#### US-003: 用户登录

```
作为 系统用户
我希望 登录系统
以便 使用族谱管理功能

验收标准：
- 输入正确的手机号和密码能够登录
- 登录成功获得Token
- Token用于后续接口访问认证
```

### 6.2 v2.0 新增用户故事

#### US-004: 搜索家族成员

```
作为 系统用户
我希望 搜索家族成员
以便 快速找到特定成员

验收标准：
- 输入姓名能够搜索到相关成员
- 支持模糊匹配
- 显示搜索结果列表
```

#### US-005: 上传成员照片

```
作为 家族管理员
我希望 上传成员照片
以便 保存成员影像资料

验收标准：
- 支持上传jpg/png格式图片
- 照片能够关联到指定成员
- 能够在成员详情页看到照片
```

### 6.3 v3.0 新增用户故事

#### US-006: 批量导入成员

```
作为 家族管理员
我希望 批量导入成员数据
以便 快速初始化族谱数据

验收标准：
- 能够上传Excel文件批量导入成员
- 系统自动处理数据格式
- 显示导入结果和错误信息
```

#### US-007: 导出族谱PDF

```
作为 系统用户
我希望 导出局谱PDF
以便 保存或分享族谱

验收标准：
- 能够将族谱导出为PDF文件
- PDF包含成员信息和关系图
- 导出的PDF格式整齐美观
```

---

## 七、技术约束（v1.0简化版）

### 7.1 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| 后端 | Spring Boot | Java 17 |
| 数据库 | MySQL 8.0 | 关系数据库 |
| 前端 | Vue 3 | 渐进式框架 |
| 移动端 | 暂不考虑 | v3.0再规划 |

### 7.2 安全要求

| 要求 | 说明 |
|------|------|
| 密码存储 | BCrypt加密 |
| 接口认证 | JWT Token |
| 传输安全 | HTTPS |

### 7.3 性能要求（v1.0基线）

| 指标 | 要求 |
|------|------|
| 登录响应时间 | ≤1s |
| 列表查询响应时间 | ≤500ms |
| 族谱树加载时间 | ≤2s（100人规模） |
