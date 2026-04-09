# API接口文档

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 待定 | MVP版本：核心接口 |
| v2.0 | 待定 | 完善版本：关系、搜索、媒体接口 |
| v3.0 | 待定 | 扩展版本：导入导出、管理接口 |

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

## 二、认证模块 API（v1.0）

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

## 三、成员管理 API（v1.0）

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
        "generation": 5
      }
    ],
    "total": 100,
    "page": 1,
    "size": 20
  }
}
```

---

## 四、族谱 API（v1.0）

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

## 五、关系管理 API（v2.0）

### 5.1 添加关系

```
POST /api/v1/relations
```

**Headers**: `Authorization: Bearer {token}`

**请求参数**
```json
{
  "memberAId": 1,
  "memberBId": 3,
  "relationType": "FATHER_CHILD"
}
```

**响应**
```json
{
  "code": 200,
  "message": "关系建立成功",
  "data": {
    "relationId": 1
  }
}
```

### 5.2 删除关系

```
DELETE /api/v1/relations/{relationId}
```

**Headers**: `Authorization: Bearer {token}`

**响应**
```json
{
  "code": 200,
  "message": "删除成功"
}
```

### 5.3 查看成员关系

```
GET /api/v1/members/{memberId}/relations
```

**Headers**: `Authorization: Bearer {token}`

**响应**
```json
{
  "code": 200,
  "data": {
    "father": {
      "memberId": 1,
      "name": "张三"
    },
    "mother": {
      "memberId": 2,
      "name": "王氏"
    },
    "spouse": {
      "memberId": 4,
      "name": "李氏"
    },
    "children": [
      {
        "memberId": 5,
        "name": "张六"
      }
    ]
  }
}
```

---

## 六、搜索 API（v2.0）

### 6.1 搜索成员

```
GET /api/v1/search?q={keyword}
```

**Headers**: `Authorization: Bearer {token}`

**Query参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| q | String | 是 | 搜索关键词 |
| page | Integer | 否 | 页码，默认1 |
| size | Integer | 否 | 每页条数，默认20 |

**响应**
```json
{
  "code": 200,
  "data": {
    "records": [
      {
        "memberId": 3,
        "name": "张四",
        "highlight": "张<b>四</b>"
      }
    ],
    "total": 5,
    "page": 1,
    "size": 20
  }
}
```

### 6.2 高级搜索

```
POST /api/v1/search/advanced
```

**Headers**: `Authorization: Bearer {token}`

**请求参数**
```json
{
  "name": "张",
  "gender": "MALE",
  "birthYearFrom": 1980,
  "birthYearTo": 2000,
  "generation": 6
}
```

---

## 七、媒体上传 API（v2.0）

### 7.1 上传头像

```
POST /api/v1/upload/avatar
Content-Type: multipart/form-data
```

**Headers**: `Authorization: Bearer {token}`

**Form参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | File | 是 | 头像文件 |
| memberId | Long | 是 | 成员ID |

**响应**
```json
{
  "code": 200,
  "data": {
    "fileUrl": "https://.../avatar.jpg"
  }
}
```

### 7.2 上传照片

```
POST /api/v1/upload/photo
Content-Type: multipart/form-data
```

**Headers**: `Authorization: Bearer {token}`

**Form参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | File | 是 | 照片文件 |
| memberId | Long | 是 | 成员ID |

### 7.3 查看成员照片

```
GET /api/v1/members/{memberId}/photos
```

**Headers**: `Authorization: Bearer {token}`

**响应**
```json
{
  "code": 200,
  "data": [
    {
      "photoId": 1,
      "photoUrl": "https://.../photo.jpg"
    }
  ]
}
```

---

## 八、导入导出 API（v3.0）

### 8.1 Excel导入

```
POST /api/v1/import/excel
Content-Type: multipart/form-data
```

**Headers**: `Authorization: Bearer {token}`

**Form参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | File | 是 | Excel文件 |

**响应**
```json
{
  "code": 200,
  "message": "导入成功",
  "data": {
    "successCount": 100,
    "failCount": 2
  }
}
```

### 8.2 Excel导出

```
GET /api/v1/export/excel
```

**Headers**: `Authorization: Bearer {token}`

**响应**: 文件下载

### 8.3 PDF导出

```
GET /api/v1/export/pdf
```

**Headers**: `Authorization: Bearer {token}`

**响应**: 文件下载

---

## 九、错误码定义

| 错误码 | 说明 |
|--------|------|
| AUTH_001 | 用户已存在 |
| AUTH_002 | 手机号已注册 |
| AUTH_003 | 用户名或密码错误 |
| AUTH_004 | Token已过期 |
| MEMBER_001 | 成员不存在 |
| MEMBER_002 | 成员姓名重复 |
| REL_001 | 关系已存在 |
| REL_002 | 不允许循环关系 |

---

## 十、API版本历史

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 待定 | 初始版本：认证、成员、族谱接口 |
| v2.0 | 待定 | 新增：关系、搜索、媒体接口 |
| v3.0 | 待定 | 新增：导入导出、管理接口 |
