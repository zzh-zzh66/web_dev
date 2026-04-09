# 数据库设计文档

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 待定 | MVP版本：核心3表（用户、成员、家族） |
| v2.0 | 待定 | 完善版本：增加关系表、媒体表 |
| v3.0 | 待定 | 扩展版本：增加权限表、日志表 |

---

## 一、数据库信息

| 属性 | 值 |
|------|---|
| 数据库类型 | MySQL 8.0 |
| 字符集 | utf8mb4 |
| 排序规则 | utf8mb4_unicode_ci |
| 数据库名称 | family_genealogy |

---

## 二、命名规范

```
表命名：t_{entity}
  - t_user           # 用户表
  - t_member         # 成员表
  - t_family         # 家族表

字段命名：snake_case
  - user_name
  - create_time

索引命名：idx_{table}_{column}
  - idx_member_name
```

---

## 三、v1.0 MVP 核心表结构

### 3.1 家族表 (t_family)

```sql
CREATE TABLE t_family (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '家族ID',
    name            VARCHAR(100) NOT NULL COMMENT '家族名称',
    description     TEXT COMMENT '家族描述',
    origin_place    VARCHAR(200) COMMENT '家族起源地',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='家族表';
```

### 3.2 用户表 (t_user)

```sql
CREATE TABLE t_user (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    phone           VARCHAR(20) NOT NULL COMMENT '手机号',
    password        VARCHAR(255) NOT NULL COMMENT '密码（加密）',
    name            VARCHAR(50) COMMENT '姓名',
    family_id       BIGINT COMMENT '所属家族ID',
    role            ENUM('ADMIN', 'MEMBER') DEFAULT 'MEMBER' COMMENT '角色',
    status          TINYINT DEFAULT 1 COMMENT '状态：1-正常，0-禁用',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_phone (phone),
    INDEX idx_family (family_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';
```

### 3.3 成员表 (t_member)

```sql
CREATE TABLE t_member (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '成员ID',
    family_id       BIGINT NOT NULL COMMENT '所属家族ID',
    name            VARCHAR(50) NOT NULL COMMENT '姓名',
    gender          ENUM('MALE', 'FEMALE') NOT NULL COMMENT '性别',
    birth_date      DATE COMMENT '出生日期',
    death_date      DATE COMMENT '去世日期',
    generation      INT COMMENT '辈分，数字越大辈分越小',
    spouse_name     VARCHAR(50) COMMENT '配偶姓名',
    father_id       BIGINT COMMENT '父亲ID',
    mother_id       BIGINT COMMENT '母亲ID',
    status          ENUM('ALIVE', 'DECEASED') DEFAULT 'ALIVE' COMMENT '状态',
    created_by      BIGINT COMMENT '创建人',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_member_family (family_id),
    INDEX idx_member_name (name),
    INDEX idx_member_father (father_id),
    INDEX idx_member_generation (generation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='家族成员表';
```

---

## 四、v2.0 新增表结构

### 4.1 关系表 (t_relation)

```sql
CREATE TABLE t_relation (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '关系ID',
    member_a_id     BIGINT NOT NULL COMMENT '成员A ID',
    member_b_id     BIGINT NOT NULL COMMENT '成员B ID',
    relation_type   VARCHAR(20) NOT NULL COMMENT '关系类型',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_relation_members (member_a_id, member_b_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='关系表';

-- 关系类型枚举值
-- FATHER_CHILD: 父子
-- MOTHER_CHILD: 母子
-- SPOUSE: 配偶
```

### 4.2 媒体文件表 (t_media)

```sql
CREATE TABLE t_media (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '文件ID',
    member_id       BIGINT COMMENT '关联成员ID',
    file_name       VARCHAR(200) NOT NULL COMMENT '文件名',
    file_url        VARCHAR(500) COMMENT '访问URL',
    file_type       VARCHAR(20) COMMENT '文件类型',
    file_size       BIGINT COMMENT '文件大小(字节)',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
    INDEX idx_media_member (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='媒体文件表';
```

---

## 五、v3.0 新增表结构（权限扩展）

### 5.1 角色表 (t_role)

```sql
CREATE TABLE t_role (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '角色ID',
    role_name       VARCHAR(50) NOT NULL COMMENT '角色名称',
    role_code       VARCHAR(50) NOT NULL COMMENT '角色编码',
    description     VARCHAR(200) COMMENT '角色描述',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_role_code (role_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

-- 角色数据
INSERT INTO t_role (role_name, role_code, description) VALUES
('超级管理员', 'SUPER_ADMIN', '系统超级管理员'),
('家族管理员', 'FAMILY_ADMIN', '家族管理者'),
('家族成员', 'FAMILY_MEMBER', '普通家族成员'),
('访客', 'GUEST', '访客用户');
```

### 5.2 操作日志表 (t_log)

```sql
CREATE TABLE t_log (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    user_id         BIGINT COMMENT '操作用户ID',
    operation       VARCHAR(50) COMMENT '操作类型',
    method          VARCHAR(100) COMMENT '请求方法',
    request_url     VARCHAR(500) COMMENT '请求URL',
    ip_address      VARCHAR(50) COMMENT 'IP地址',
    execution_time  INT COMMENT '执行时间(毫秒)',
    status          TINYINT COMMENT '状态：1-成功，0-失败',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    INDEX idx_log_user (user_id),
    INDEX idx_log_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';
```

---

## 六、数据库变更记录

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 待定 | 初始版本：核心3表 |
| v2.0 | 待定 | 新增关系表、媒体表 |
| v3.0 | 待定 | 新增角色表、日志表 |
