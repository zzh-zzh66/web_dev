# 数据库设计文档

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-04-16 | MVP版本：核心表结构（用户、成员、家族） |

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

## 四、数据库变更记录

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-04-16 | 初始版本：核心3表（用户、成员、家族） |
