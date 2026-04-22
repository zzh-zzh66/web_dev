# API接口文档

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-04-16 | MVP版本：核心接口（已完成） |

---

## 一、API规范

### 1.1 基本规范

- **协议**: HTTPS
- **数据格式**: JSON
- **认证方式**: Bearer Token (JWT)
- **版本控制**: URL Path `/api/v1/`

### 1.2 请求格式

```
GET/POST/PUT/DELETE /api/v1/{module}/{action}

Headers:
  Content-Type: application/json
  Authorization: Bearer {token}
```

### 1.3 响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": { }
}
```

### 1.4 状态码

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 201 | 创建成功 |
| 400 | 参数错误 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器错误 |

---

## 二、认证模块 API

### 2.1 用户注册

```
POST /api/v1/auth/register
```

**请求参数**
```json
{
  "phone": "13800138000",
  "password": "Abc123456",
  "name": "张三"
}
```

**响应**
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "userId": 1
  }
}
```

### 2.2 用户登录

```
POST /api/v1/auth/login
```

**请求参数**
```json
{
  "phone": "13800138000",
  "password": "Abc123456"
}
```

**响应**
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "userId": 1,
      "phone": "13800138000",
      "name": "张三",
      "role": "ADMIN"
    }
  }
}
```

### 2.3 退出登录

```
POST /api/v1/auth/logout
```

**Headers**: `Authorization: Bearer {token}`

**响应**
```json
{
  "code": 200,
  "message": "退出成功"
}
```

### 2.4 获取个人信息

```
GET /api/v1/auth/profile
```

**Headers**: `Authorization: Bearer {token}`

**响应**
```json
{
  "code": 200,
  "data": {
    "userId": 1,
    "phone": "13800138000",
    "name": "张三",
    "role": "ADMIN",
    "familyId": 1
  }
}
```

### 2.5 修改个人信息

```
PUT /api/v1/auth/profile
```

**Headers**: `Authorization: Bearer {token}`

**请求参数**
```json
{
  "name": "张三"
}
```

---

## 三、成员管理 API

### 3.1 添加成员

```
POST /api/v1/members
```

**Headers**: `Authorization: Bearer {token}`

**请求参数**
```json
{
  "name": "张四",
  "gender": "MALE",
  "birthDate": "1990-05-15",
  "generation": 6,
  "spouseName": "李氏",
  "fatherId": 1,
  "motherId": 2,
  "status": "ALIVE"
}
```

**响应**
```json
{
  "code": 200,
  "message": "添加成功",
  "data": {
    "memberId": 3
  }
}
```

### 3.2 编辑成员

```
PUT /api/v1/members/{memberId}
```

**Headers**: `Authorization: Bearer {token}`

**请求参数**
```json
{
  "name": "张四",
  "occupation": "工程师"
}
```

**响应**
```json
{
  "code": 200,
  "message": "修改成功"
}
```

### 3.3 删除成员

```
DELETE /api/v1/members/{memberId}
```

**Headers**: `Authorization: Bearer {token}`

**响应**
```json
{
  "code": 200,
  "message": "删除成功"
}
```

### 3.4 获取成员详情

```
GET /api/v1/members/{memberId}
```

**Headers**: `Authorization: Bearer {token}`

**响应**
```json
{
  "code": 200,
  "data": {
    "memberId": 3,
    "name": "张四",
    "gender": "MALE",
    "birthDate": "1990-05-15",
    "generation": 6,
    "spouseName": "李氏",
    "fatherId": 1,
    "fatherName": "张三",
    "motherId": 2,
    "motherName": "王氏",
    "status": "ALIVE"
  }
}
```

### 3.5 成员列表

```
GET /api/v1/members
```

**Headers**: `Authorization: Bearer {token}`

**Query参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | Integer | 否 | 页码，默认1 |
| size | Integer | 否 | 每页条数，默认20 |
| name | String | 否 | 姓名（模糊查询） |
| generation | Integer | 否 | 辈分 |

**响应**
```json
{
  "code": 200,
  "data": {
    "records": [
      {
        "memberId": 1,
        "name": "张三",
        "gender": "MALE",
        "generation": 5,
        "status": "ALIVE"
      }
    ],
    "total": 100,
    "page": 1,
    "size": 20
  }
}
```

---

## 四、族谱 API

### 4.1 获取族谱树

```
GET /api/v1/genealogy/tree
```

**Headers**: `Authorization: Bearer {token}`

**Query参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| rootMemberId | Long | 否 | 根节点成员ID |

**响应**
```json
{
  "code": 200,
  "data": {
    "memberId": 1,
    "name": "张三",
    "gender": "MALE",
    "generation": 1,
    "children": [
      {
        "memberId": 2,
        "name": "张四",
        "gender": "MALE",
        "generation": 2,
        "children": []
      }
    ]
  }
}
```

> **注意**: 族谱树结构为嵌套结构，children字段包含下级成员信息

### 4.2 获取成员后代

```
GET /api/v1/genealogy/{memberId}/descendants
```

**Headers**: `Authorization: Bearer {token}`

**响应**
```json
{
  "code": 200,
  "data": [
    {
      "memberId": 3,
      "name": "张五",
      "generation": 3
    }
  ]
}
```

### 4.3 获取成员祖先

```
GET /api/v1/genealogy/{memberId}/ancestors
```

**Headers**: `Authorization: Bearer {token}`

**响应**
```json
{
  "code": 200,
  "data": [
    {
      "memberId": 1,
      "name": "张三",
      "generation": 1
    }
  ]
}
```

---

## 五、错误码定义

| 错误码 | 说明 |
|--------|------|
| AUTH_001 | 用户已存在 |
| AUTH_002 | 手机号已注册 |
| AUTH_003 | 用户名或密码错误 |
| AUTH_004 | Token已过期 |
| MEMBER_001 | 成员不存在 |
| MEMBER_002 | 成员姓名重复 |
