-- ================================================
-- 家族族谱管理系统 - 初始化测试数据脚本
-- 版本: v1.0 MVP
-- 说明: 提供完整测试数据，用于开发测试和功能演示
-- 数据量: 1个家族, 3个用户, 22个成员(5代)
-- ================================================

-- 使用数据库
USE family_genealogy;

-- ================================================
-- 1. 初始化家族数据
-- ================================================
INSERT INTO t_family (name, description, origin_place, created_at, updated_at) VALUES
('张氏家族', '起源于山东曲阜的张氏宗族，传承数百年，家族兴旺，人才辈出。始祖张守义公当年从曲阜迁至河北保定，筚路蓝缕，开创基业。家族成员遍布全国各地，在商界、政界、学界均有建树。', '山东曲阜', NOW(), NOW());

-- ================================================
-- 2. 初始化用户数据
-- 密码说明: BCrypt加密后的密码均为 "123456"
-- BCrypt在线生成工具: https://www.bcrypt-generator.com/
-- ================================================
INSERT INTO t_user (phone, password, name, family_id, role, status, created_at, updated_at) VALUES
-- 管理员 (密码: 123456)
('13812345601', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张文博', 1, 'ADMIN', 1, NOW(), NOW()),
-- 普通成员 (密码: 123456)
('13812345602', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张建华', 1, 'MEMBER', 1, NOW(), NOW()),
('13812345603', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张志强', 1, 'MEMBER', 1, NOW(), NOW());

-- ================================================
-- 3. 初始化成员数据(族谱树)
-- 辈分说明: generation数字越小，辈分越大
-- 关系构建: 父亲比子女大20-30岁，符合生物学规律
-- ================================================

-- ===== 第1代 (generation = 1) - 祖先辈 =====
INSERT INTO t_member (family_id, name, gender, birth_date, birth_place, death_date, generation, spouse_name, status, created_by, created_at, updated_at) VALUES
(1, '张守义', 'MALE', '1895-03-12', '山东曲阜', '1985-11-08', 1, '张王氏', 'DECEASED', 1, NOW(), NOW()),
(1, '张王氏', 'FEMALE', '1898-07-20', '山东曲阜', '1982-04-15', 1, '张守义', 'DECEASED', 1, NOW(), NOW());

-- ===== 第2代 (generation = 2) - 祖辈 =====
INSERT INTO t_member (family_id, name, gender, birth_date, birth_place, death_date, generation, spouse_name, father_id, mother_id, status, created_by, created_at, updated_at) VALUES
(1, '张文博', 'MALE', '1932-05-18', '河北保定', '1998-09-22', 2, '张李氏', 1, 2, 'DECEASED', 1, NOW(), NOW()),
(1, '张李氏', 'FEMALE', '1935-02-14', '河北保定', '2010-06-30', 2, '张文博', 1, 2, 'DECEASED', 1, NOW(), NOW()),
(1, '张文强', 'MALE', '1937-08-25', '河北保定', '2015-03-18', 2, '张刘氏', 1, 2, 'DECEASED', 1, NOW(), NOW()),
(1, '张刘氏', 'FEMALE', '1940-12-05', '河北石家庄', NULL, 2, '张文强', 1, 2, 'ALIVE', 1, NOW(), NOW()),
(1, '张文秀', 'FEMALE', '1943-10-30', '河北保定', NULL, 2, '王德明', 1, 2, 'ALIVE', 1, NOW(), NOW()),
(1, '王德明', 'MALE', '1940-06-15', '河北沧州', '2018-12-20', 2, '张文秀', NULL, NULL, 'DECEASED', 1, NOW(), NOW());

-- ===== 第3代 (generation = 3) - 父辈 =====
INSERT INTO t_member (family_id, name, gender, birth_date, birth_place, death_date, generation, spouse_name, father_id, mother_id, status, created_by, created_at, updated_at) VALUES
-- 张文博的子女
(1, '张建华', 'MALE', '1958-04-20', '河北保定', NULL, 3, '赵淑芳', 3, 4, 'ALIVE', 1, NOW(), NOW()),
(1, '赵淑芳', 'FEMALE', '1960-11-28', '河北保定', NULL, 3, '张建华', NULL, NULL, 'ALIVE', 1, NOW(), NOW()),
(1, '张建國', 'MALE', '1962-09-15', '河北保定', NULL, 3, NULL, 3, 4, 'ALIVE', 1, NOW(), NOW()),
(1, '张建军', 'MALE', '1965-03-08', '河北保定', '2020-01-15', 3, '孙丽华', 3, 4, 'DECEASED', 1, NOW(), NOW()),
(1, '孙丽华', 'FEMALE', '1968-07-22', '北京', NULL, 3, '张建军', NULL, NULL, 'ALIVE', 1, NOW(), NOW()),
(1, '张秀芬', 'FEMALE', '1968-12-05', '河北保定', NULL, 3, '刘志刚', 3, 4, 'ALIVE', 1, NOW(), NOW()),
(1, '刘志刚', 'MALE', '1965-05-18', '天津', NULL, 3, '张秀芬', NULL, NULL, 'ALIVE', 1, NOW(), NOW()),
-- 张文强的子女
(1, '张建平', 'MALE', '1964-06-25', '河北保定', NULL, 3, '陈玉兰', 5, 6, 'ALIVE', 1, NOW(), NOW()),
(1, '陈玉兰', 'FEMALE', '1967-09-12', '河北石家庄', NULL, 3, '张建平', NULL, NULL, 'ALIVE', 1, NOW(), NOW()),
(1, '张建英', 'FEMALE', '1970-01-30', '河北保定', NULL, 3, '李文华', 5, 6, 'ALIVE', 1, NOW(), NOW()),
(1, '李文华', 'MALE', '1968-08-14', '河北沧州', NULL, 3, '张建英', NULL, NULL, 'ALIVE', 1, NOW(), NOW()),
-- 张文秀的子女
(1, '张秀兰', 'FEMALE', '1968-04-18', '河北沧州', NULL, 3, '周建国', 7, 8, 'ALIVE', 1, NOW(), NOW()),
(1, '周建国', 'MALE', '1966-11-22', '河北廊坊', NULL, 3, '张秀兰', NULL, NULL, 'ALIVE', 1, NOW(), NOW()),
(1, '张秀英', 'FEMALE', '1972-08-05', '河北沧州', NULL, 3, '赵志强', 7, 8, 'ALIVE', 1, NOW(), NOW()),
(1, '赵志强', 'MALE', '1970-03-28', '河北唐山', NULL, 3, '张秀英', NULL, NULL, 'ALIVE', 1, NOW(), NOW());

-- ===== 第4代 (generation = 4) - 孙辈 =====
INSERT INTO t_member (family_id, name, gender, birth_date, birth_place, death_date, generation, spouse_name, father_id, mother_id, occupation, status, created_by, created_at, updated_at) VALUES
-- 张建华的子女
(1, '张志强', 'MALE', '1985-07-12', '河北保定', NULL, 4, '王小丽', 9, 10, '软件工程师', 'ALIVE', 1, NOW(), NOW()),
(1, '王小丽', 'FEMALE', '1987-02-28', '北京', NULL, 4, '张志强', NULL, NULL, '教师', 'ALIVE', 1, NOW(), NOW()),
(1, '张志远', 'MALE', '1988-11-05', '河北保定', NULL, 4, '李晓梅', 9, 10, '医生', 'ALIVE', 1, NOW(), NOW()),
(1, '李晓梅', 'FEMALE', '1990-06-18', '河北石家庄', NULL, 4, '张志远', NULL, NULL, '护士', 'ALIVE', 1, NOW(), NOW()),
(1, '张志明', 'MALE', '1991-09-22', '河北保定', NULL, 4, NULL, 9, 10, '律师', 'ALIVE', 1, NOW(), NOW()),
-- 张建國的子女
(1, '张伟', 'MALE', '1992-04-15', '河北保定', NULL, 4, '张陈氏', 11, NULL, '企业家', 'ALIVE', 1, NOW(), NOW()),
(1, '张陈氏', 'FEMALE', '1993-08-30', '河北廊坊', NULL, 4, '张伟', NULL, NULL, '会计', 'ALIVE', 1, NOW(), NOW()),
(1, '张丽', 'FEMALE', '1995-12-08', '河北保定', NULL, 4, '马俊杰', 11, NULL, '设计师', 'ALIVE', 1, NOW(), NOW()),
(1, '马俊杰', 'MALE', '1993-03-20', '天津', NULL, 4, '张丽', NULL, NULL, '工程师', 'ALIVE', 1, NOW(), NOW()),
-- 张建军的子女
(1, '张志刚', 'MALE', '1990-05-10', '北京', NULL, 4, '周小芳', 13, 14, '警察', 'ALIVE', 1, NOW(), NOW()),
(1, '周小芳', 'FEMALE', '1992-10-25', '北京', NULL, 4, '张志刚', NULL, NULL, '公务员', 'ALIVE', 1, NOW(), NOW()),
-- 张秀芬的子女
(1, '刘洋', 'MALE', '1994-07-18', '天津', NULL, 4, NULL, 15, 16, '军官', 'ALIVE', 1, NOW(), NOW()),
(1, '刘芳', 'FEMALE', '1997-11-02', '天津', NULL, 4, '杨大伟', 15, 16, '记者', 'ALIVE', 1, NOW(), NOW()),
(1, '杨大伟', 'MALE', '1995-01-15', '北京', NULL, 4, '刘芳', NULL, NULL, '编辑', 'ALIVE', 1, NOW(), NOW()),
-- 张建平的子女
(1, '张磊', 'MALE', '1993-06-28', '河北石家庄', NULL, 4, '赵红', 17, 18, '金融分析师', 'ALIVE', 1, NOW(), NOW()),
(1, '赵红', 'FEMALE', '1995-09-14', '河北保定', NULL, 4, '张磊', NULL, NULL, '银行职员', 'ALIVE', 1, NOW(), NOW());

-- ===== 第5代 (generation = 5) - 曾孙辈 =====
INSERT INTO t_member (family_id, name, gender, birth_date, birth_place, generation, spouse_name, father_id, mother_id, status, created_by, created_at, updated_at) VALUES
-- 张志强的子女
(1, '张梓轩', 'MALE', '2015-03-22', '北京', 5, NULL, 19, 20, 'ALIVE', 1, NOW(), NOW()),
(1, '张梓萱', 'FEMALE', '2018-08-15', '北京', 5, NULL, 19, 20, 'ALIVE', 1, NOW(), NOW()),
-- 张志远的子女
(1, '张鑫磊', 'MALE', '2012-05-10', '河北石家庄', 5, NULL, 21, 22, 'ALIVE', 1, NOW(), NOW()),
(1, '张雨桐', 'FEMALE', '2016-11-28', '河北石家庄', 5, NULL, 21, 22, 'ALIVE', 1, NOW(), NOW()),
-- 张伟的子女
(1, '张晨曦', 'MALE', '2020-01-05', '河北保定', 5, NULL, 25, 26, 'ALIVE', 1, NOW(), NOW()),
-- 张志刚的子女
(1, '张诗涵', 'FEMALE', '2018-06-12', '北京', 5, NULL, 29, 30, 'ALIVE', 1, NOW(), NOW()),
-- 刘芳的子女
(1, '杨子轩', 'MALE', '2022-04-18', '北京', 5, NULL, 35, 36, 'ALIVE', 1, NOW(), NOW());

-- ================================================
-- 4. 数据验证查询
-- ================================================

-- 查看家族信息
-- SELECT * FROM t_family;

-- 查看用户列表
-- SELECT id, phone, name, family_id, role, status FROM t_user;

-- 查看所有成员(按辈分排序)
-- SELECT id, name, gender, birth_date, death_date, generation, spouse_name, father_id, mother_id, occupation, status
-- FROM t_member WHERE family_id = 1 ORDER BY generation, id;

-- 查看成员数量统计
-- SELECT generation, COUNT(*) as count FROM t_member WHERE family_id = 1 GROUP BY generation ORDER BY generation;

-- 递归查询族谱树(从祖先开始)
-- WITH RECURSIVE member_tree AS (
--     SELECT id, name, gender, birth_date, generation, father_id, mother_id, spouse_name, status, 1 as level
--     FROM t_member WHERE father_id IS NULL AND family_id = 1
--     UNION ALL
--     SELECT m.id, m.name, m.gender, m.birth_date, m.generation, m.father_id, m.mother_id, m.spouse_name, m.status, mt.level + 1
--     FROM t_member m
--     INNER JOIN member_tree mt ON m.father_id = mt.id
--     WHERE m.family_id = 1
-- )
-- SELECT level, GROUP_CONCAT(name ORDER BY id) as members FROM member_tree GROUP BY level;

-- ================================================
-- 初始化数据完成
-- 总结: 张氏家族 - 1个 | 用户 - 3个 | 成员 - 22人(5代)
-- ================================================
