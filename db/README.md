# 数据库使用指南

## 概述
本文档说明如何使用数据库脚本快速搭建完整的族谱系统演示环境。

## 前置要求
- MySQL 8.0 已安装并运行
- 可以使用 mysql 命令行或 GUI 工具（如 Navicat、DataGrip）

## 快速开始

### 方式一：命令行执行

```bash
# 1. 以root用户登录MySQL
mysql -u root -p

# 2. 执行schema脚本（创建表结构）
source e:/web_dev/web_dev/db/schema.sql;

# 3. 执行初始化数据脚本（插入测试数据）
source e:/web_dev/web_dev/db/init_data.sql;

# 4. 验证数据
SELECT * FROM t_family;
SELECT COUNT(*) as member_count FROM t_member;
SELECT COUNT(*) as user_count FROM t_user;
```

### 方式二：GUI工具执行

1. 打开 Navicat 或 DataGrip
2. 连接到 MySQL
3. 打开 `e:\web_dev\web_dev\db\schema.sql` 并执行
4. 打开 `e:\web_dev\web_dev\db\init_data.sql` 并执行

## 测试账号

| 手机号 | 密码 | 角色 | 姓名 |
|--------|------|------|------|
| 13812345601 | 123456 | ADMIN | 张文博 |
| 13812345602 | 123456 | MEMBER | 张建华 |
| 13812345603 | 123456 | MEMBER | 张志强 |

## 数据统计

| 类型 | 数量 |
|------|------|
| 家族 | 1个（张氏家族） |
| 用户 | 3个 |
| 成员 | 22人（5代） |

## 族谱结构

```
第1代 (2人): 张守义、张王氏（祖先）
    │
    └── 第2代 (6人): 张文博、张文强、张文秀 等
            │
            └── 第3代 (14人): 张建华、张建國、张建军 等
                    │
                    └── 第4代 (16人): 张志强、张志远、张伟 等
                            │
                            └── 第5代 (7人): 张梓轩、张梓萱 等
```

## 常用查询

### 查看族谱树（MySQL 8.0递归CTE）
```sql
USE family_genealogy;

WITH RECURSIVE genealogy_tree AS (
    -- 祖先（没有父亲）
    SELECT id, name, gender, birth_date, death_date, generation,
           father_id, mother_id, spouse_name, occupation, status, 1 as level
    FROM t_member
    WHERE father_id IS NULL AND family_id = 1

    UNION ALL

    -- 子孙
    SELECT m.id, m.name, m.gender, m.birth_date, m.death_date, m.generation,
           m.father_id, m.mother_id, m.spouse_name, m.occupation, m.status, gt.level + 1
    FROM t_member m
    INNER JOIN genealogy_tree gt ON m.father_id = gt.id
    WHERE m.family_id = 1
)
SELECT level, id, name, gender, generation, spouse_name, occupation
FROM genealogy_tree
ORDER BY level, id;
```

### 按辈分统计成员数量
```sql
SELECT generation,
       COUNT(*) as count,
       CASE generation
           WHEN 1 THEN '祖先辈'
           WHEN 2 THEN '祖辈'
           WHEN 3 THEN '父辈'
           WHEN 4 THEN '孙辈'
           WHEN 5 THEN '曾孙辈'
       END as generation_name
FROM t_member
WHERE family_id = 1
GROUP BY generation
ORDER BY generation;
```

### 查找某人的所有后代
```sql
WITH RECURSIVE descendants AS (
    SELECT id, name, father_id, 1 as depth
    FROM t_member
    WHERE father_id = 1  -- 替换为要查询的人的ID

    UNION ALL

    SELECT m.id, m.name, m.father_id, d.depth + 1
    FROM t_member m
    INNER JOIN descendants d ON m.father_id = d.id
)
SELECT * FROM descendants;
```

### 查找某人的所有祖先
```sql
WITH RECURSIVE ancestors AS (
    SELECT id, name, father_id, mother_id, 1 as depth
    FROM t_member
    WHERE id = 25  -- 替换为要查询的人的ID

    UNION ALL

    SELECT m.id, m.name, m.father_id, m.mother_id, a.depth + 1
    FROM t_member m
    INNER JOIN ancestors a ON m.id = a.father_id OR m.id = a.mother_id
)
SELECT * FROM ancestors WHERE depth > 1 ORDER BY depth;
```

## 数据库配置

Spring Boot 配置文件 `application.yml` 中的数据库配置：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/family_genealogy?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: your_password  # 替换为你的MySQL密码
    driver-class-name: com.mysql.cj.jdbc.Driver
```

## 故障排除

### 问题：外键约束错误
**原因**：插入成员的顺序不对，father_id/mother_id 引用的成员还未插入
**解决**：按代际顺序插入，先插入祖先，再插入后代

### 问题：字符集乱码
**原因**：MySQL 字符集配置不正确
**解决**：确保使用 utf8mb4 字符集，创建数据库时指定：
```sql
CREATE DATABASE IF NOT EXISTS family_genealogy
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;
```

### 问题：BCrypt密码不匹配
**原因**：init_data.sql 中的密码哈希值不正确
**解决**：使用在线 BCrypt 工具重新生成 "123456" 的哈希值
