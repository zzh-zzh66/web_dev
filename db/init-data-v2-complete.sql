-- ================================================
-- 家族族谱管理系统 V2.0 - 个人主页功能完整初始化数据脚本
-- 版本: v2.0-complete
-- 数据库: MySQL 8.0
-- 字符集: utf8mb4
-- 说明: 三个示范用户的完整主页数据（完整版）
--   - 张德厚 (族长): 侧重家族历史传承、家训家规、文化感悟
--   - 张建国 (中年): 侧重家庭生活记录、子女成长、亲情互动
--   - 张晓明 (青年): 侧重旅行见闻、技术分享、青春成长
-- 依赖: 需要先执行 schema-v2.sql
-- 创建日期: 2026-04-21
-- ================================================

USE family_genealogy;

-- 禁用外键检查
SET FOREIGN_KEY_CHECKS = 0;

-- ================================================
-- 0. 前提: 创建示范用户和成员（使用INSERT IGNORE避免重复）
-- ================================================

INSERT IGNORE INTO t_user (phone, password, name, family_id, role, status, avatar_url, created_at, updated_at) VALUES
('13812345610', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张德厚', 1, 'MEMBER', 1, 'https://example.com/avatars/zhang_dehou.jpg', NOW(), NOW()),
('13812345611', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张建国', 1, 'MEMBER', 1, 'https://example.com/avatars/zhang_jianguo.jpg', NOW(), NOW()),
('13812345612', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张晓明', 1, 'MEMBER', 1, 'https://example.com/avatars/zhang_xiaoming.jpg', NOW(), NOW());

-- 获取用户ID（如果用户已存在则查询）
SELECT id INTO @user_dehou FROM t_user WHERE phone = '13812345610' LIMIT 1;
SELECT id INTO @user_jianguo FROM t_user WHERE phone = '13812345611' LIMIT 1;
SELECT id INTO @user_xiaoming FROM t_user WHERE phone = '13812345612' LIMIT 1;

INSERT INTO t_member (family_id, name, gender, birth_date, birth_place, generation, spouse_name, status, created_by, portrait_url, occupation, biography, created_at, updated_at) VALUES
(1, '张德厚', 'MALE', '1951-08-15', '河北保定', 3, '李秀兰', 'ALIVE', @user_dehou, 'https://example.com/portraits/zhang_dehou.jpg', '退休教师/家族族长', '张氏家族第3代传人,1951年出生于保定老宅。1969年参军入伍,服役8年。1977年转业后任村小学教师。1995年开始主持编纂张氏族谱,2010年被族人推举为家族族长。', NOW(), NOW()),
(1, '张建国', 'MALE', '1981-05-20', '河北保定', 4, '陈美华', 'ALIVE', @user_jianguo, 'https://example.com/portraits/zhang_jianguo.jpg', '企业中层管理', '张氏家族第4代。大学毕业后进入国企工作,现为部门经理。为人踏实稳重,家庭和睦,育有一女。', NOW(), NOW()),
(1, '张晓明', 'MALE', '2001-03-12', '北京', 5, NULL, 'ALIVE', @user_xiaoming, 'https://example.com/portraits/zhang_xiaoming.jpg', '大学在读/摄影爱好者', '张氏家族第5代。就读于北京某大学计算机专业。热爱旅行和摄影。', NOW(), NOW());

SET @member_dehou = 37;
SET @member_jianguo = 38;
SET @member_xiaoming = 39;

-- ================================================
-- 1. 用户主页档案 (t_user_profile)
-- ================================================

INSERT INTO t_user_profile (user_id, member_id, bio, background_url, signature, birth_place, occupation, education, hometown, life_events, visit_count, theme, status, created_by, created_at, updated_at) VALUES
(@user_dehou, @member_dehou, '张氏家族第3代传人，1951年出生于保定老宅。一生致力于家族文化传承，主持编纂族谱，被推举为家族族长。', 'https://example.com/backgrounds/ancestral_hall.jpg', '家和万事兴,传承不息。', '河北保定', '退休教师/家族族长', '大专', '山东曲阜', JSON_ARRAY(JSON_OBJECT('year',1951,'event','出生于张氏祖宅'),JSON_OBJECT('year',1969,'event','参军入伍'),JSON_OBJECT('year',1977,'event','转业回乡任教师'),JSON_OBJECT('year',1995,'event','主持编纂族谱'),JSON_OBJECT('year',2010,'event','被推举为族长'),JSON_OBJECT('year',2024,'event','主持清明祭祖')), 1286, 'vintage', 1, @user_dehou, NOW(), NOW()),
(@user_jianguo, @member_jianguo, '张氏家族第4代，普通但幸福的家庭。工作在保定，最大的幸福就是一家人和和睦睦。', 'https://example.com/backgrounds/family_photo.jpg', '用心生活,用爱陪伴。', '河北保定', '企业中层管理', '本科', '河北保定', JSON_ARRAY(JSON_OBJECT('year',1981,'event','出生于保定'),JSON_OBJECT('year',2003,'event','大学毕业进入国企'),JSON_OBJECT('year',2008,'event','与陈美华结婚'),JSON_OBJECT('year',2010,'event','女儿出生'),JSON_OBJECT('year',2024,'event','女儿考上大学')), 856, 'warm', 1, @user_jianguo, NOW(), NOW()),
(@user_xiaoming, @member_xiaoming, '计算机专业大三学生，热爱旅行和摄影。用镜头记录世界的美好，用代码改变生活的可能。', 'https://example.com/backgrounds/travel_landscape.jpg', '探索世界,发现更好的自己。', '北京', '大学在读', '本科在读', '河北保定', JSON_ARRAY(JSON_OBJECT('year',2001,'event','出生于北京'),JSON_OBJECT('year',2019,'event','考入大学计算机专业'),JSON_OBJECT('year',2021,'event','第一次独自旅行'),JSON_OBJECT('year',2023,'event','西藏自驾Vlog获10万播放'),JSON_OBJECT('year',2024,'event','程序设计竞赛银奖')), 2134, 'modern', 1, @user_xiaoming, NOW(), NOW());

-- ================================================
-- 2. 系统预置分类 (t_post_category)
-- ================================================

INSERT INTO t_post_category (user_id, name, code, icon, color, description, sort_order, is_system, post_count, status, created_by, created_at) VALUES
(NULL, '生平日志', 'LIFE_LOG', '📝', '#4A90D9', '记录生活中的点点滴滴', 1, 1, 0, 1, 1, NOW()),
(NULL, '家族故事', 'FAMILY_STORY', '🏠', '#E74C3C', '分享家族的历史和故事', 2, 1, 0, 1, 1, NOW()),
(NULL, '照片墙', 'PHOTO_WALL', '📷', '#2ECC71', '照片集锦，美好瞬间', 3, 1, 0, 1, 1, NOW()),
(NULL, '视频集', 'VIDEO_COLLECTION', '🎬', '#9B59B6', '视频分享，精彩时刻', 4, 1, 0, 1, 1, NOW()),
(NULL, '心情随笔', 'MOOD_DIARY', '💭', '#F39C12', '心情记录，随笔感悟', 5, 1, 0, 1, 1, NOW()),
(NULL, '重要事件', 'IMPORTANT_EVENT', '⭐', '#E67E22', '人生重要节点记录', 6, 1, 0, 1, 1, NOW());

SET @cat_life_log = 1;
SET @cat_family_story = 2;
SET @cat_photo_wall = 3;
SET @cat_video_collection = 4;
SET @cat_mood_diary = 5;
SET @cat_important_event = 6;

-- ================================================
-- 3. 话题 (t_topic)
-- ================================================

INSERT INTO t_topic (name, code, description, icon, cover_url, post_count, participant_count, status, created_by, created_at) VALUES
('家族记忆', 'family_memory', '分享家族的故事、回忆和历史传承', '📜', 'https://example.com/topics/family_memory.jpg', 0, 0, 1, 1, NOW()),
('家乡味道', 'hometown_taste', '分享家乡的美食和味道记忆', '🍜', 'https://example.com/topics/hometown_taste.jpg', 0, 0, 1, 1, NOW()),
('传承之光', 'inheritance_light', '传统文化的传承和发扬', '🏮', 'https://example.com/topics/inheritance_light.jpg', 0, 0, 1, 1, NOW()),
('青春印记', 'youth_mark', '年轻人的成长记录和青春故事', '✨', 'https://example.com/topics/youth_mark.jpg', 0, 0, 1, 1, NOW());

SET @topic_family_memory = 1;
SET @topic_hometown_taste = 2;
SET @topic_inheritance_light = 3;
SET @topic_youth_mark = 4;

-- ================================================
-- 4. 张德厚的动态 (8条)
-- ================================================

-- 动态1: 张氏家族起源考
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, is_essence, created_by, created_at) VALUES
(@user_dehou, @member_dehou, @cat_family_story, 'IMAGE', '张氏家族起源考', '<p>据族谱记载，我张氏先祖守义公于明朝洪武年间（约公元1370年前后），从山东曲阜迁徙至河北保定，至今已传六百年。</p><p>守义公当年为避战火，带着家人一路向北，最终在保定府落脚。初到保定时，以耕读为生，勤俭持家。</p><p>如今，张氏家族已传承至第6代，族人遍布全国各地。但无论走多远，曲阜永远是我们的根。</p><p><b>寻根问祖，不忘根本。</b></p>', '1370-01-01', 'FAMILY', 'PUBLISHED', 89, 23, 1562, '河北保定', 1, @user_dehou, DATE_SUB(NOW(), INTERVAL 30 DAY));
SET @post_dehou_1 = LAST_INSERT_ID();

-- 动态2: 祠堂修缮记
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, is_essence, created_by, created_at) VALUES
(@user_dehou, @member_dehou, @cat_family_story, 'IMAGE', '张氏祠堂修缮记', '<p>张氏祠堂始建于清朝乾隆年间，距今已有两百多年历史。2018年，祠堂因年久失修出现漏雨和裂缝。</p><p>经族中商议，筹集善款三十余万元，历时半年完成修缮。2020年清明，修缮一新的祠堂迎来了祭祖大典。</p>', '2020-04-04', 'FAMILY', 'PUBLISHED', 67, 15, 987, '河北保定', 1, @user_dehou, DATE_SUB(NOW(), INTERVAL 25 DAY));
SET @post_dehou_2 = LAST_INSERT_ID();

-- 动态3: 清明祭祖
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, is_top, created_by, created_at) VALUES
(@user_dehou, @member_dehou, @cat_important_event, 'IMAGE', '2024年清明祭祖大典', '<p>今年清明祭祖大典格外隆重，来自全国各地的族人齐聚保定。</p><p>祭祖仪式按传统礼制进行：敬香、献花、诵读祭文、三叩首。每一个环节都庄严肃穆。</p><p>看到年轻一代认真参与，心中欣慰。祭文有云："慎终追远，民德归厚。祖德流芳，世代传承。"</p>', '2024-04-04', 'FAMILY', 'PUBLISHED', 102, 31, 2134, '河北保定张氏祠堂', 1, @user_dehou, DATE_SUB(NOW(), INTERVAL 10 DAY));
SET @post_dehou_3 = LAST_INSERT_ID();

-- 动态4: 祖训家规
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, is_essence, created_by, created_at) VALUES
(@user_dehou, @member_dehou, @cat_family_story, 'TEXT', '张氏祖训解读', '<p>张氏祖训，传自先祖守义公：</p><p><b>一曰孝悌：</b>孝顺父母，敬爱兄长，此为立身之本。</p><p><b>二曰忠信：</b>忠于国家，信于朋友，此为处世之道。</p><p><b>三曰勤俭：</b>勤劳致富，节俭持家，此为兴家之基。</p><p><b>四曰读书：</b>读书明理，知行合一，此为成才之径。</p><p><b>五曰睦邻：</b>和睦乡邻，守望相助，此为安身之法。</p><p>此五条祖训，字字珠玑，望族人铭记于心，践行于行。</p>', '1995-06-15', 'FAMILY', 'PUBLISHED', 156, 42, 3256, '河北保定', 1, @user_dehou, DATE_SUB(NOW(), INTERVAL 20 DAY));
SET @post_dehou_4 = LAST_INSERT_ID();

-- 动态5: 老照片
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at) VALUES
(@user_dehou, @member_dehou, @cat_photo_wall, 'IMAGE', '老照片里的家族记忆', '<p>整理旧物时，发现了几张珍贵的老照片。</p><p>第一张是祖父张守义公的遗像，摄于民国初年。</p><p>第二张是1958年全家福，一家人围坐在老宅院子里，其乐融融。</p><p>第三张是1980年修缮祠堂时的合影，族人们齐心协力，让人感动。</p>', '1958-02-14', 'FAMILY', 'PUBLISHED', 78, 18, 1456, '河北保定', @user_dehou, DATE_SUB(NOW(), INTERVAL 15 DAY));
SET @post_dehou_5 = LAST_INSERT_ID();

-- 动态6: 军旅岁月
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at) VALUES
(@user_dehou, @member_dehou, @cat_life_log, 'TEXT', '我的军旅岁月', '<p>1969年，我18岁，响应国家号召，参军入伍。那是改变我一生的决定。</p><p>我被分配到西北边防部队，条件艰苦，但意志坚定。在部队的8年里，我学会了坚强、纪律和责任。</p><p>1977年转业回乡，做了一名人民教师。教书育人的30年里，始终铭记："学高为师，身正为范。"</p>', '1969-03-01', 'FAMILY', 'PUBLISHED', 95, 27, 1876, '河北保定', @user_dehou, DATE_SUB(NOW(), INTERVAL 5 DAY));
SET @post_dehou_6 = LAST_INSERT_ID();

-- 动态7: 书法与家风
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at) VALUES
(@user_dehou, @member_dehou, @cat_mood_diary, 'IMAGE', '书法与家风', '<p>退休后，最大爱好就是练习书法。每天清晨，在院子石桌上铺开宣纸，研墨挥毫。</p><p>书法讲究"心正笔正"，做人也是如此。</p><p>我常写"家和万事兴"四个字送给族中晚辈。家庭和睦，是万事兴旺的基础。</p><p>今天写了四幅，准备送给建国和小明。</p>', '2024-10-01', 'FAMILY', 'PUBLISHED', 45, 12, 678, '河北保定', '宁静', @user_dehou, DATE_SUB(NOW(), INTERVAL 2 DAY));
SET @post_dehou_7 = LAST_INSERT_ID();

-- 动态8: 祖父口中的家族往事
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at) VALUES
(@user_dehou, @member_dehou, @cat_family_story, 'TEXT', '祖父口中的家族往事', '<p>小时候，祖父常在夏夜院子里讲家族故事。</p><p>祖父说，清朝末年张家曾是保定府大户人家。但到祖父这一代，家道中落。祖父一生勤勉，硬是把家业重新撑了起来。</p><p>他常说："家业不怕小，就怕不勤。只要肯干，总能过上好日子。"</p><p>这些故事，我希望能够记录下来，传给后人。</p>', '2024-09-15', 'FAMILY', 'PUBLISHED', 63, 19, 1234, '河北保定', @user_dehou, DATE_SUB(NOW(), INTERVAL 8 DAY));
SET @post_dehou_8 = LAST_INSERT_ID();

-- ================================================
-- 5. 张建国的动态 (8条)
-- ================================================

-- 动态1: 女儿毕业典礼
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at) VALUES
(@user_jianguo, @member_jianguo, @cat_photo_wall, 'IMAGE', '女儿的大学毕业典礼', '<p>今天，女儿雨桐大学毕业了！看着她在台上穿着学士服的样子，我的眼眶湿润了。</p><p>妻子美华在旁边哭得比我还厉害，说"我们的女儿长大了"。</p><p>雨桐，爸爸为你骄傲！愿你勇敢追梦，不忘初心。</p>', '2024-06-20', 'FAMILY', 'PUBLISHED', 56, 18, 892, '北京', @user_jianguo, DATE_SUB(NOW(), INTERVAL 3 DAY));
SET @post_jianguo_1 = LAST_INSERT_ID();

-- 动态2: 周末郊游
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at) VALUES
(@user_jianguo, @member_jianguo, @cat_photo_wall, 'IMAGE', '周末一家人去郊游', '<p>难得周末晴朗，带着妻子和女儿去了湿地公园。</p><p>在湖边搭帐篷、野餐、放风筝、钓鱼。简单的一天，但很幸福。</p><p>工作再忙，也要抽出时间陪伴家人。因为陪伴才是最长情的告白。</p>', '2024-04-13', 'FAMILY', 'PUBLISHED', 42, 12, 654, '保定湿地公园', @user_jianguo, DATE_SUB(NOW(), INTERVAL 7 DAY));
SET @post_jianguo_2 = LAST_INSERT_ID();

-- 动态3: 结婚纪念日
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at) VALUES
(@user_jianguo, @member_jianguo, @cat_life_log, 'TEXT', '结婚16周年纪念日', '<p>今天是我和美华结婚16周年。</p><p>16年，一起经历了买房、生孩子、孩子上学……平凡但充实。</p><p>美华是个好妻子、好母亲，为这个家付出了很多。</p><p>晚上带她去吃了当年恋爱时常去的小餐馆，味道还是那个味道。</p>', '2024-05-01', 'FAMILY', 'PUBLISHED', 38, 9, 432, '保定', @user_jianguo, DATE_SUB(NOW(), INTERVAL 12 DAY));
SET @post_jianguo_3 = LAST_INSERT_ID();

-- 动态4: 春节家族聚会
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at) VALUES
(@user_jianguo, @member_jianguo, @cat_family_story, 'IMAGE', '春节家族大聚会', '<p>今年春节，家族成员从各地赶回来团聚。大伯张德厚主持祭祖仪式，全家人一起吃了团圆饭。</p><p>饭桌上，大伯讲了很多家族故事，年轻一代听得很认真。</p><p>饭后拍了全家福，这是近年来最齐的一次。</p>', '2024-02-10', 'FAMILY', 'PUBLISHED', 45, 14, 789, '河北保定', @user_jianguo, DATE_SUB(NOW(), INTERVAL 45 DAY));
SET @post_jianguo_4 = LAST_INSERT_ID();

-- 动态5: 工作感悟
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at) VALUES
(@user_jianguo, @member_jianguo, @cat_mood_diary, 'TEXT', '工作中的小感悟', '<p>升任部门经理一年了。最大感受是：管理不是管人，而是带人。</p><p>这和家庭其实是一个道理。家长不是"管"着家人，而是用心经营这个家。</p><p>工作和家庭，道理相通。做好一个，另一个也不会差。</p>', '2024-03-15', 'FAMILY', 'PUBLISHED', 29, 7, 345, '保定', @user_jianguo, DATE_SUB(NOW(), INTERVAL 22 DAY));
SET @post_jianguo_5 = LAST_INSERT_ID();

-- 动态6: 秘制红烧肉
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at) VALUES
(@user_jianguo, @member_jianguo, @cat_life_log, 'IMAGE', '周末下厨：秘制红烧肉', '<p>周末在家给家人做了拿手菜——秘制红烧肉。</p><p>选用上好五花肉，先焯水，再炒糖色，小火慢炖两小时。最关键的是火候。</p><p>雨桐最爱吃这道菜，每次都能多吃一碗饭。</p><p>做法：五花肉切块焯水，炒糖色上色，加料酒、生抽、老抽、八角、桂皮，炖2小时收汁。</p>', '2024-08-10', 'FAMILY', 'PUBLISHED', 34, 11, 567, '保定', '满足', @user_jianguo, DATE_SUB(NOW(), INTERVAL 18 DAY));
SET @post_jianguo_6 = LAST_INSERT_ID();

-- 动态7: 女儿升学
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at) VALUES
(@user_jianguo, @member_jianguo, @cat_important_event, 'IMAGE', '雨桐考上大学了！', '<p>收到录取通知书的那一刻，全家人都沸腾了！</p><p>雨桐被北京外国语大学英语专业录取。十二年寒窗苦读，终于有了回报。</p><p>大学是人生的新起点。希望你继续保持勤奋好学的品质，也要多交朋友、多体验生活。</p>', '2024-07-20', 'FAMILY', 'PUBLISHED', 68, 22, 1123, '保定', @user_jianguo, DATE_SUB(NOW(), INTERVAL 25 DAY));
SET @post_jianguo_7 = LAST_INSERT_ID();

-- 动态8: 陪大伯喝茶
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at) VALUES
(@user_jianguo, @member_jianguo, @cat_life_log, 'IMAGE', '陪大伯喝茶聊天', '<p>周日回了老家，陪大伯喝茶聊天。</p><p>大伯73岁了，精神矍铄。我们坐在葡萄架下，泡一壶龙井，从家族历史聊到子女教育。</p><p>大伯说："人老了，最大的幸福就是看到子孙平安健康、家庭和睦。"</p><p>父母在，人生尚有来处。趁他们还在，多回去看看。</p>', '2024-09-08', 'FAMILY', 'PUBLISHED', 41, 13, 678, '河北保定', '温暖', @user_jianguo, DATE_SUB(NOW(), INTERVAL 14 DAY));
SET @post_jianguo_8 = LAST_INSERT_ID();

-- ================================================
-- 6. 张晓明的动态 (10条)
-- ================================================

-- 动态1: 西藏自驾Vlog
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_video_collection, 'VIDEO', '西藏自驾Vlog - 川藏线全记录', '<p>历时12天，从成都出发经318国道到拉萨，全程2140公里。</p><p>一路上看到了雪山、草原、峡谷、湖泊。翻越了14座海拔4000米以上的山口。</p><p>在理塘遇到藏族牧民，喝酥油茶听草原故事。在怒江72拐体会"山路十八弯"。</p><p>到达布达拉宫那一刻，一切辛苦都值得了。</p>', '2024-07-15', 'PUBLIC', 'PUBLISHED', 128, 35, 8956, '西藏拉萨', '激动', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 14 DAY));
SET @post_xiaoming_1 = LAST_INSERT_ID();

-- 动态2: 上海夜景街拍
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_photo_wall, 'IMAGE', '城市街拍 - 上海的夜', '<p>去上海参加摄影展，拍了一组夜景。</p><p>外滩的夜景太美了。万国建筑群与陆家嘴天际线交相辉映，历史与现代在此交汇。</p><p>用新广角镜头拍摄，后期调了青橙色调。9张精选分享给大家。</p>', '2024-06-01', 'PUBLIC', 'PUBLISHED', 95, 21, 3456, '上海外滩', '满足', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 30 DAY));
SET @post_xiaoming_2 = LAST_INSERT_ID();

-- 动态3: 编程竞赛
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_important_event, 'TEXT', '程序设计竞赛银奖！', '<p>全国大学生程序设计竞赛，我们团队拿到了银奖！</p><p>准备了一个学期，每周三次训练到深夜。比赛当天5小时做了8道题，最后一题最后10分钟才AC！</p><p>银奖不是终点，明年冲击金奖！加油！</p>', '2024-05-20', 'FAMILY', 'PUBLISHED', 87, 23, 2345, '杭州', '兴奋', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 20 DAY));
SET @post_xiaoming_3 = LAST_INSERT_ID();

-- 动态4: 成都美食
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_mood_diary, 'IMAGE', '成都的美食之旅', '<p>火锅、串串香、担担面、钟水饺、龙抄手、兔头……</p><p>成都是来了就不想走的城市，不仅因为好吃，还因为那种悠闲的生活态度。</p><p>在宽窄巷子喝了一下午茶，看街头艺人表演，这就是向往的生活。</p>', '2024-07-10', 'PUBLIC', 'PUBLISHED', 76, 19, 2890, '四川成都', '开心', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 16 DAY));
SET @post_xiaoming_4 = LAST_INSERT_ID();

-- 动态5: 校园银杏树
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_life_log, 'IMAGE', '校园里的那棵银杏树', '<p>图书馆门前的银杏树又到了金黄的季节。</p><p>大一觉得它很普通，大三才发现它一年四季都有不同的美。春天嫩绿，夏天浓荫，秋天金黄，冬天挺拔。</p><p>拍了组照片记录它最美的时刻。等毕业再回来看，不知道是什么感觉。</p>', '2024-10-15', 'PUBLIC', 'PUBLISHED', 43, 8, 1234, '北京科技大学', '感慨', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 2 DAY));
SET @post_xiaoming_5 = LAST_INSERT_ID();

-- 动态6: 环青海湖骑行
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_life_log, 'TEXT', '环青海湖骑行日记', '<p>Day 1: 西宁到西海镇，80公里。看到青海湖那一刻，值了。</p><p>Day 2: 沿湖南岸100公里。遇到一群藏野驴，超级可爱！</p><p>Day 3: 环湖西路120公里。暴雨中躲进牧民帐篷，大叔请我们喝酥油茶。</p><p>Day 4: 完成环湖。全程360公里，历时4天。</p><p>骑行最大的收获是发现自己比想象中更强大。</p>', '2024-08-20', 'PUBLIC', 'PUBLISHED', 112, 28, 5678, '青海湖', '自豪', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 5 DAY));
SET @post_xiaoming_6 = LAST_INSERT_ID();

-- 动态7: 开源项目上线
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_life_log, 'TEXT', '我的第一个开源项目上线了！', '<p>三个月开发，照片管理工具在GitHub上线了！</p><p>基于Vue3，支持EXIF读取、智能分类、批量导出。开发中学到了Git工作流、Issue管理、CI/CD等实战经验。</p><p>已收到100+个Star，还有开发者提交了PR。感谢开源社区！</p>', '2024-09-01', 'PUBLIC', 'PUBLISHED', 65, 16, 1890, '北京', '成就感满满', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 10 DAY));
SET @post_xiaoming_7 = LAST_INSERT_ID();

-- 动态8: 摄影展
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_photo_wall, 'IMAGE', '摄影社年度摄影展', '<p>作为摄影社副社长，负责策划了年度摄影展。</p><p>主题是"青春·印记"，展出120余幅优秀作品。从策划到布展历时一个月。</p><p>我的作品《晨曦中的校园》挂在入口处，有点小骄傲~</p>', '2024-05-15', 'PUBLIC', 'PUBLISHED', 52, 14, 1567, '北京科技大学', '开心', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 28 DAY));
SET @post_xiaoming_8 = LAST_INSERT_ID();

-- 动态9: 健身打卡
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_life_log, 'IMAGE', '健身打卡第100天！', '<p>健身坚持100天了！</p><p>从连10个俯卧撑都做不了，到现在能做50个。从65kg到72kg，肌肉线条慢慢出来了。</p><p>健身最大的收获不是身材变化，而是自律的习惯。身体是革命的本钱，才能更好地追求梦想。</p>', '2024-08-05', 'PUBLIC', 'PUBLISHED', 89, 25, 3456, '北京科技大学健身房', '自豪', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 12 DAY));
SET @post_xiaoming_9 = LAST_INSERT_ID();

-- 动态10: 爷爷的来信
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_mood_diary, 'TEXT', '爷爷的来信', '<p>上周收到大伯（爷爷辈）的一封手写信。在这个微信时代，手写信尤为珍贵。</p><p>信中大伯嘱咐我好好学习、注意身体，还附了一幅亲笔书法——"天道酬勤"四个大字。</p><p>看着苍劲有力的字迹，眼眶湿润。这就是家族的温度吧——即使相隔千里，牵挂从未断过。</p><p>寒假回家一定要去看看大伯。把这幅字挂在书桌前，每天提醒自己：天道酬勤。</p>', '2024-10-08', 'FAMILY', 'PUBLISHED', 98, 27, 2890, '北京', '感动', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 4 DAY));
SET @post_xiaoming_10 = LAST_INSERT_ID();

-- ================================================
-- 7. 动态媒体数据 (t_post_media) - 42条
-- ================================================

-- 张德厚的媒体 (14条)
INSERT INTO t_post_media (post_id, media_type, media_url, thumb_url, original_name, file_size, width, height, sort_order, is_cover, created_at) VALUES
(@post_dehou_1, 'IMAGE', 'https://example.com/media/zhang_family_tree_old.jpg', 'https://example.com/media/thumbs/zhang_family_tree_old.jpg', '张氏族谱古籍.jpg', 2456789, 3000, 2000, 1, 1, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@post_dehou_1, 'IMAGE', 'https://example.com/media/old_house_qufu.jpg', 'https://example.com/media/thumbs/old_house_qufu.jpg', '曲阜祖宅旧址.jpg', 1987654, 2800, 1800, 2, 0, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@post_dehou_1, 'IMAGE', 'https://example.com/media/qufu_confucius.jpg', 'https://example.com/media/thumbs/qufu_confucius.jpg', '曲阜孔庙.jpg', 2123456, 3200, 2100, 3, 0, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@post_dehou_2, 'IMAGE', 'https://example.com/media/temple_repair_before.jpg', 'https://example.com/media/thumbs/temple_repair_before.jpg', '祠堂修缮前.jpg', 1876543, 2600, 1700, 1, 1, DATE_SUB(NOW(), INTERVAL 25 DAY)),
(@post_dehou_2, 'IMAGE', 'https://example.com/media/temple_repair_after.jpg', 'https://example.com/media/thumbs/temple_repair_after.jpg', '祠堂修缮后.jpg', 2345678, 3000, 2000, 2, 0, DATE_SUB(NOW(), INTERVAL 25 DAY)),
(@post_dehou_3, 'IMAGE', 'https://example.com/media/qingming_ceremony_2024.jpg', 'https://example.com/media/thumbs/qingming_ceremony_2024.jpg', '2024清明祭祖.jpg', 3456789, 4000, 2600, 1, 1, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(@post_dehou_3, 'IMAGE', 'https://example.com/media/qingming_family_group.jpg', 'https://example.com/media/thumbs/qingming_family_group.jpg', '清明全家福.jpg', 2987654, 3600, 2400, 2, 0, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(@post_dehou_5, 'IMAGE', 'https://example.com/media/grandfather_portrait.jpg', 'https://example.com/media/thumbs/grandfather_portrait.jpg', '祖父遗像.jpg', 567890, 800, 1000, 1, 1, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(@post_dehou_5, 'IMAGE', 'https://example.com/media/family_1958.jpg', 'https://example.com/media/thumbs/family_1958.jpg', '1958全家福.jpg', 678901, 900, 700, 2, 0, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(@post_dehou_5, 'IMAGE', 'https://example.com/media/temple_1980.jpg', 'https://example.com/media/thumbs/temple_1980.jpg', '1980修缮祠堂合影.jpg', 789012, 1000, 800, 3, 0, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(@post_dehou_7, 'IMAGE', 'https://example.com/media/calligraphy_jiahe.jpg', 'https://example.com/media/thumbs/calligraphy_jiahe.jpg', '书法-家和万事兴.jpg', 1234567, 2400, 1600, 1, 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@post_dehou_7, 'IMAGE', 'https://example.com/media/calligraphy_desk.jpg', 'https://example.com/media/thumbs/calligraphy_desk.jpg', '书写中.jpg', 1345678, 2200, 1500, 2, 0, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@post_dehou_8, 'IMAGE', 'https://example.com/media/old_house_story.jpg', 'https://example.com/media/thumbs/old_house_story.jpg', '老宅故事.jpg', 1123456, 2000, 1400, 1, 1, DATE_SUB(NOW(), INTERVAL 8 DAY)),
(@post_dehou_8, 'IMAGE', 'https://example.com/media/grandfather_study.jpg', 'https://example.com/media/thumbs/grandfather_study.jpg', '祖父书房.jpg', 987654, 1800, 1200, 2, 0, DATE_SUB(NOW(), INTERVAL 8 DAY));

-- 张建国的媒体 (20条)
INSERT INTO t_post_media (post_id, media_type, media_url, thumb_url, original_name, file_size, width, height, sort_order, is_cover, created_at) VALUES
(@post_jianguo_1, 'IMAGE', 'https://example.com/media/graduation_ceremony.jpg', 'https://example.com/media/thumbs/graduation_ceremony.jpg', '毕业典礼.jpg', 2345678, 3200, 2100, 1, 1, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(@post_jianguo_1, 'IMAGE', 'https://example.com/media/daughter_bachelor.jpg', 'https://example.com/media/thumbs/daughter_bachelor.jpg', '女儿学士服.jpg', 1987654, 2800, 1900, 2, 0, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(@post_jianguo_1, 'IMAGE', 'https://example.com/media/family_graduation.jpg', 'https://example.com/media/thumbs/family_graduation.jpg', '毕业全家福.jpg', 2456789, 3400, 2200, 3, 0, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(@post_jianguo_1, 'IMAGE', 'https://example.com/media/graduation_stage.jpg', 'https://example.com/media/thumbs/graduation_stage.jpg', '台上致辞.jpg', 2123456, 3000, 2000, 4, 0, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(@post_jianguo_1, 'IMAGE', 'https://example.com/media/graduation_parents.jpg', 'https://example.com/media/thumbs/graduation_parents.jpg', '与父母合影.jpg', 1876543, 2600, 1800, 5, 0, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(@post_jianguo_2, 'IMAGE', 'https://example.com/media/wetland_spring.jpg', 'https://example.com/media/thumbs/wetland_spring.jpg', '湿地春色.jpg', 2567890, 3400, 2200, 1, 1, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(@post_jianguo_2, 'IMAGE', 'https://example.com/media/family_tent.jpg', 'https://example.com/media/thumbs/family_tent.jpg', '帐篷野餐.jpg', 2234567, 3000, 2000, 2, 0, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(@post_jianguo_2, 'IMAGE', 'https://example.com/media/lake_fishing.jpg', 'https://example.com/media/thumbs/lake_fishing.jpg', '湖边钓鱼.jpg', 1987654, 2800, 1800, 3, 0, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(@post_jianguo_2, 'IMAGE', 'https://example.com/media/kite_flying.jpg', 'https://example.com/media/thumbs/kite_flying.jpg', '放风筝.jpg', 2345678, 3200, 2100, 4, 0, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(@post_jianguo_2, 'IMAGE', 'https://example.com/media/sunset_wetland.jpg', 'https://example.com/media/thumbs/sunset_wetland.jpg', '湿地日落.jpg', 2678901, 3600, 2400, 5, 0, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(@post_jianguo_2, 'IMAGE', 'https://example.com/media/family_happy.jpg', 'https://example.com/media/thumbs/family_happy.jpg', '一家人.jpg', 2123456, 3000, 2000, 6, 0, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(@post_jianguo_4, 'IMAGE', 'https://example.com/media/spring_festival_family.jpg', 'https://example.com/media/thumbs/spring_festival_family.jpg', '春节全家福.jpg', 3456789, 4000, 2600, 1, 1, DATE_SUB(NOW(), INTERVAL 45 DAY)),
(@post_jianguo_4, 'IMAGE', 'https://example.com/media/ancestor_worship.jpg', 'https://example.com/media/thumbs/ancestor_worship.jpg', '祭祖仪式.jpg', 2345678, 3200, 2100, 2, 0, DATE_SUB(NOW(), INTERVAL 45 DAY)),
(@post_jianguo_4, 'IMAGE', 'https://example.com/media/reunion_dinner.jpg', 'https://example.com/media/thumbs/reunion_dinner.jpg', '团圆饭.jpg', 2567890, 3400, 2200, 3, 0, DATE_SUB(NOW(), INTERVAL 45 DAY)),
(@post_jianguo_6, 'IMAGE', 'https://example.com/media/braised_pork.jpg', 'https://example.com/media/thumbs/braised_pork.jpg', '秘制红烧肉.jpg', 2345678, 3200, 2100, 1, 1, DATE_SUB(NOW(), INTERVAL 18 DAY)),
(@post_jianguo_6, 'IMAGE', 'https://example.com/media/cooking_process.jpg', 'https://example.com/media/thumbs/cooking_process.jpg', '烹饪过程.jpg', 2123456, 3000, 2000, 2, 0, DATE_SUB(NOW(), INTERVAL 18 DAY)),
(@post_jianguo_7, 'IMAGE', 'https://example.com/media/admission_letter.jpg', 'https://example.com/media/thumbs/admission_letter.jpg', '录取通知书.jpg', 1876543, 2600, 1800, 1, 1, DATE_SUB(NOW(), INTERVAL 25 DAY)),
(@post_jianguo_7, 'IMAGE', 'https://example.com/media/daughter_happy.jpg', 'https://example.com/media/thumbs/daughter_happy.jpg', '女儿开心的样子.jpg', 2234567, 3000, 2000, 2, 0, DATE_SUB(NOW(), INTERVAL 25 DAY)),
(@post_jianguo_8, 'IMAGE', 'https://example.com/media/tea_with_uncle.jpg', 'https://example.com/media/thumbs/tea_with_uncle.jpg', '陪大伯喝茶.jpg', 2345678, 3200, 2100, 1, 1, DATE_SUB(NOW(), INTERVAL 14 DAY)),
(@post_jianguo_8, 'IMAGE', 'https://example.com/media/uncle_garden.jpg', 'https://example.com/media/thumbs/uncle_garden.jpg', '大伯的院子.jpg', 2123456, 3000, 2000, 2, 0, DATE_SUB(NOW(), INTERVAL 14 DAY));

-- 张晓明的媒体 (28条)
INSERT INTO t_post_media (post_id, media_type, media_url, thumb_url, original_name, file_size, width, height, duration, sort_order, is_cover, created_at) VALUES
(@post_xiaoming_1, 'VIDEO', 'https://example.com/media/tibet_vlog_full.mp4', 'https://example.com/media/thumbs/potala_palace.jpg', '西藏自驾Vlog.mp4', 524288000, 1920, 1080, 932, 1, 1, DATE_SUB(NOW(), INTERVAL 14 DAY)),
(@post_xiaoming_1, 'IMAGE', 'https://example.com/media/potala_palace.jpg', 'https://example.com/media/thumbs/potala_palace.jpg', '布达拉宫.jpg', 2345678, 3200, 2100, 0, 2, 0, DATE_SUB(NOW(), INTERVAL 14 DAY)),
(@post_xiaoming_1, 'IMAGE', 'https://example.com/media/tibet_snow_mountain.jpg', 'https://example.com/media/thumbs/tibet_snow_mountain.jpg', '雪山.jpg', 2567890, 3600, 2400, 0, 3, 0, DATE_SUB(NOW(), INTERVAL 14 DAY)),
(@post_xiaoming_2, 'IMAGE', 'https://example.com/media/bund_night_1.jpg', 'https://example.com/media/thumbs/bund_night_1.jpg', '外滩夜景1.jpg', 2456789, 3400, 2200, 0, 1, 1, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@post_xiaoming_2, 'IMAGE', 'https://example.com/media/bund_night_2.jpg', 'https://example.com/media/thumbs/bund_night_2.jpg', '外滩夜景2.jpg', 2567890, 3600, 2400, 0, 2, 0, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@post_xiaoming_2, 'IMAGE', 'https://example.com/media/bund_night_3.jpg', 'https://example.com/media/thumbs/bund_night_3.jpg', '外滩夜景3.jpg', 2234567, 3000, 2000, 0, 3, 0, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@post_xiaoming_2, 'IMAGE', 'https://example.com/media/bund_night_4.jpg', 'https://example.com/media/thumbs/bund_night_4.jpg', '陆家嘴夜景.jpg', 2345678, 3200, 2100, 0, 4, 0, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@post_xiaoming_2, 'IMAGE', 'https://example.com/media/bund_night_5.jpg', 'https://example.com/media/thumbs/bund_night_5.jpg', '黄浦江夜景.jpg', 2678901, 3800, 2500, 0, 5, 0, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@post_xiaoming_2, 'IMAGE', 'https://example.com/media/bund_night_6.jpg', 'https://example.com/media/thumbs/bund_night_6.jpg', '东方明珠.jpg', 2123456, 3000, 2000, 0, 6, 0, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@post_xiaoming_2, 'IMAGE', 'https://example.com/media/bund_night_7.jpg', 'https://example.com/media/thumbs/bund_night_7.jpg', '夜景倒影.jpg', 2456789, 3400, 2200, 0, 7, 0, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@post_xiaoming_2, 'IMAGE', 'https://example.com/media/bund_night_8.jpg', 'https://example.com/media/thumbs/bund_night_8.jpg', '万国建筑群.jpg', 2567890, 3600, 2400, 0, 8, 0, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@post_xiaoming_2, 'IMAGE', 'https://example.com/media/bund_night_9.jpg', 'https://example.com/media/thumbs/bund_night_9.jpg', '夜景全景.jpg', 3456789, 4000, 2600, 0, 9, 0, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@post_xiaoming_4, 'IMAGE', 'https://example.com/media/chengdu_hotpot.jpg', 'https://example.com/media/thumbs/chengdu_hotpot.jpg', '成都火锅.jpg', 2345678, 3200, 2100, 0, 1, 1, DATE_SUB(NOW(), INTERVAL 16 DAY)),
(@post_xiaoming_4, 'IMAGE', 'https://example.com/media/chengdu_skewer.jpg', 'https://example.com/media/thumbs/chengdu_skewer.jpg', '串串香.jpg', 2123456, 3000, 2000, 0, 2, 0, DATE_SUB(NOW(), INTERVAL 16 DAY)),
(@post_xiaoming_4, 'IMAGE', 'https://example.com/media/chengdu_teahouse.jpg', 'https://example.com/media/thumbs/chengdu_teahouse.jpg', '宽窄巷子茶馆.jpg', 2456789, 3400, 2200, 0, 3, 0, DATE_SUB(NOW(), INTERVAL 16 DAY)),
(@post_xiaoming_5, 'IMAGE', 'https://example.com/media/ginkgo_spring.jpg', 'https://example.com/media/thumbs/ginkgo_spring.jpg', '春天嫩绿.jpg', 2234567, 3000, 2000, 0, 1, 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@post_xiaoming_5, 'IMAGE', 'https://example.com/media/ginkgo_summer.jpg', 'https://example.com/media/thumbs/ginkgo_summer.jpg', '夏天浓荫.jpg', 2345678, 3200, 2100, 0, 2, 0, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@post_xiaoming_5, 'IMAGE', 'https://example.com/media/ginkgo_autumn.jpg', 'https://example.com/media/thumbs/ginkgo_autumn.jpg', '秋天金黄.jpg', 2567890, 3600, 2400, 0, 3, 0, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@post_xiaoming_5, 'IMAGE', 'https://example.com/media/ginkgo_winter.jpg', 'https://example.com/media/thumbs/ginkgo_winter.jpg', '冬天挺拔.jpg', 2123456, 3000, 2000, 0, 4, 0, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@post_xiaoming_6, 'IMAGE', 'https://example.com/media/qinghai_lake_1.jpg', 'https://example.com/media/thumbs/qinghai_lake_1.jpg', '青海湖日出.jpg', 2678901, 3800, 2500, 0, 1, 1, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(@post_xiaoming_6, 'IMAGE', 'https://example.com/media/qinghai_lake_2.jpg', 'https://example.com/media/thumbs/qinghai_lake_2.jpg', '藏野驴.jpg', 2345678, 3200, 2100, 0, 2, 0, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(@post_xiaoming_6, 'IMAGE', 'https://example.com/media/qinghai_lake_3.jpg', 'https://example.com/media/thumbs/qinghai_lake_3.jpg', '牧民帐篷.jpg', 2456789, 3400, 2200, 0, 3, 0, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(@post_xiaoming_8, 'IMAGE', 'https://example.com/media/exhibition_hall.jpg', 'https://example.com/media/thumbs/exhibition_hall.jpg', '摄影展展厅.jpg', 2345678, 3200, 2100, 0, 1, 1, DATE_SUB(NOW(), INTERVAL 28 DAY)),
(@post_xiaoming_8, 'IMAGE', 'https://example.com/media/my_work_morning.jpg', 'https://example.com/media/thumbs/my_work_morning.jpg', '我的作品-晨曦.jpg', 2123456, 3000, 2000, 0, 2, 0, DATE_SUB(NOW(), INTERVAL 28 DAY)),
(@post_xiaoming_8, 'IMAGE', 'https://example.com/media/club_team_photo.jpg', 'https://example.com/media/thumbs/club_team_photo.jpg', '摄影社合影.jpg', 2567890, 3600, 2400, 0, 3, 0, DATE_SUB(NOW(), INTERVAL 28 DAY)),
(@post_xiaoming_9, 'IMAGE', 'https://example.com/media/gym_selfie.jpg', 'https://example.com/media/thumbs/gym_selfie.jpg', '健身房自拍.jpg', 2345678, 3200, 2100, 0, 1, 1, DATE_SUB(NOW(), INTERVAL 12 DAY)),
(@post_xiaoming_9, 'IMAGE', 'https://example.com/media/running_track.jpg', 'https://example.com/media/thumbs/running_track.jpg', '操场跑步.jpg', 2123456, 3000, 2000, 0, 2, 0, DATE_SUB(NOW(), INTERVAL 12 DAY)),
(@post_xiaoming_10, 'IMAGE', 'https://example.com/media/letter_from_grandpa.jpg', 'https://example.com/media/thumbs/letter_from_grandpa.jpg', '大伯的手写信.jpg', 1876543, 2600, 1800, 0, 1, 1, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(@post_xiaoming_10, 'IMAGE', 'https://example.com/media/calligraphy_tian_dao.jpg', 'https://example.com/media/thumbs/calligraphy_tian_dao.jpg', '天道酬勤书法.jpg', 2234567, 3000, 2000, 0, 2, 0, DATE_SUB(NOW(), INTERVAL 4 DAY));

-- ================================================
-- 8. 话题关联 (t_topic_post) - 12条
-- ================================================

INSERT INTO t_topic_post (topic_id, post_id, created_at) VALUES
(@topic_family_memory, @post_dehou_1, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@topic_family_memory, @post_dehou_5, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(@topic_family_memory, @post_dehou_8, DATE_SUB(NOW(), INTERVAL 8 DAY)),
(@topic_hometown_taste, @post_jianguo_6, DATE_SUB(NOW(), INTERVAL 18 DAY)),
(@topic_hometown_taste, @post_xiaoming_4, DATE_SUB(NOW(), INTERVAL 16 DAY)),
(@topic_inheritance_light, @post_dehou_4, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(@topic_inheritance_light, @post_dehou_7, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@topic_inheritance_light, @post_xiaoming_10, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(@topic_youth_mark, @post_xiaoming_3, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(@topic_youth_mark, @post_xiaoming_7, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(@topic_youth_mark, @post_xiaoming_8, DATE_SUB(NOW(), INTERVAL 28 DAY)),
(@topic_youth_mark, @post_xiaoming_9, DATE_SUB(NOW(), INTERVAL 12 DAY));

-- ================================================
-- 9. 用户兴趣标签 (t_user_interest) - 18条
-- ================================================

INSERT INTO t_user_interest (user_id, interest_tag, interest_level, sort_order, created_at) VALUES
(@user_dehou, '#家族历史#', 3, 1, NOW()), (@user_dehou, '#家训家规#', 3, 2, NOW()),
(@user_dehou, '#传统文化#', 3, 3, NOW()), (@user_dehou, '#书法#', 2, 4, NOW()),
(@user_dehou, '#茶道#', 2, 5, NOW()), (@user_dehou, '#园艺#', 1, 6, NOW()),
(@user_jianguo, '#家庭生活#', 3, 1, NOW()), (@user_jianguo, '#子女教育#', 2, 2, NOW()),
(@user_jianguo, '#烹饪#', 2, 3, NOW()), (@user_jianguo, '#旅行#', 1, 4, NOW()),
(@user_jianguo, '#摄影#', 1, 5, NOW()),
(@user_xiaoming, '#旅行#', 3, 1, NOW()), (@user_xiaoming, '#摄影#', 3, 2, NOW()),
(@user_xiaoming, '#编程#', 3, 3, NOW()), (@user_xiaoming, '#美食#', 2, 4, NOW()),
(@user_xiaoming, '#音乐#', 2, 5, NOW()), (@user_xiaoming, '#健身#', 2, 6, NOW()),
(@user_xiaoming, '#骑行#', 1, 7, NOW());

-- ================================================
-- 10. 隐私设置 (t_privacy_setting) - 24条
-- ================================================

INSERT INTO t_privacy_setting (user_id, setting_key, setting_value, scope, created_at) VALUES
(@user_dehou, 'profile_visibility', 'family', 'FAMILY', NOW()), (@user_dehou, 'post_default_visibility', 'family', 'FAMILY', NOW()),
(@user_dehou, 'allow_guestbook', 'true', 'FAMILY', NOW()), (@user_dehou, 'allow_private_message', 'true', 'FAMILY', NOW()),
(@user_dehou, 'allow_comment', 'true', 'FAMILY', NOW()), (@user_dehou, 'show_birth_info', 'true', 'FAMILY', NOW()),
(@user_dehou, 'show_occupation', 'true', 'FAMILY', NOW()), (@user_dehou, 'allow_tag_in_post', 'true', 'FAMILY', NOW()),
(@user_jianguo, 'profile_visibility', 'family', 'FAMILY', NOW()), (@user_jianguo, 'post_default_visibility', 'family', 'FAMILY', NOW()),
(@user_jianguo, 'allow_guestbook', 'true', 'FAMILY', NOW()), (@user_jianguo, 'allow_private_message', 'true', 'FAMILY', NOW()),
(@user_jianguo, 'allow_comment', 'true', 'FAMILY', NOW()), (@user_jianguo, 'show_birth_info', 'false', 'PRIVATE', NOW()),
(@user_jianguo, 'show_occupation', 'true', 'FAMILY', NOW()), (@user_jianguo, 'allow_tag_in_post', 'true', 'FAMILY', NOW()),
(@user_xiaoming, 'profile_visibility', 'public', 'PUBLIC', NOW()), (@user_xiaoming, 'post_default_visibility', 'public', 'PUBLIC', NOW()),
(@user_xiaoming, 'allow_guestbook', 'true', 'FAMILY', NOW()), (@user_xiaoming, 'allow_private_message', 'true', 'FAMILY', NOW()),
(@user_xiaoming, 'allow_comment', 'true', 'FAMILY', NOW()), (@user_xiaoming, 'show_birth_info', 'true', 'PUBLIC', NOW()),
(@user_xiaoming, 'show_occupation', 'true', 'PUBLIC', NOW()),
(@user_xiaoming, 'allow_tag_in_post', 'true', 'FAMILY', NOW());

-- ================================================
-- 11. 评论数据 (t_comment) - 55条
-- ================================================

-- === 评论张德厚的动态 ===

-- 评论 "张氏家族起源考"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_1, @post_dehou_1, NULL, NULL, @user_jianguo, NULL, '大伯这篇文章写得太好了！作为张家人，我为我们的家族历史感到自豪。', 12, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 29 DAY));
SET @c1 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_1, @post_dehou_1, NULL, NULL, @user_xiaoming, NULL, '看了大伯的文章，突然觉得自己对家族的了解太少了。我也要开始记录自己的故事！', 8, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 28 DAY));
SET @c2 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_1, @post_dehou_1, NULL, NULL, @user_dehou, NULL, '守义公从曲阜到保定，这条路走了六百年。希望后人不要忘记自己的根在哪里。', 25, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 27 DAY));
SET @c3 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @c1, @post_dehou_1, @c1, @c1, @user_dehou, @user_jianguo, '建国说得对，我们每一个张家人都应该了解家族的历史，这样才能知道我们从哪里来。', 5, 1, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 26 DAY)),
('COMMENT', @c2, @post_dehou_1, @c2, @c2, @user_dehou, @user_xiaoming, '小明，你有这份心很好。年轻人多了解家族历史，不是负担，而是财富。', 7, 1, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 26 DAY)),
('COMMENT', @c3, @post_dehou_1, @c3, @c3, @user_jianguo, @user_dehou, '大伯放心，我一定把家族的故事讲给雨桐听，让她也记住自己的根。', 4, 1, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 25 DAY)),
('COMMENT', @c2, @post_dehou_1, @c2, @c2, @user_jianguo, @user_xiaoming, '小明说得对，我们一起把家族故事记录下来，以后给后人看。', 3, 2, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 24 DAY));

-- 评论 "祠堂修缮记"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_2, @post_dehou_2, NULL, NULL, @user_jianguo, NULL, '祠堂修缮是家族的大事，大伯辛苦了！', 6, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 24 DAY)),
('POST', @post_dehou_2, @post_dehou_2, NULL, NULL, @user_xiaoming, NULL, '修缮后的祠堂真漂亮！这是全族人的功劳。', 4, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 23 DAY));

-- 评论 "清明祭祖"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_3, @post_dehou_3, NULL, NULL, @user_jianguo, NULL, '今年清明祭祖办得很隆重，看到这么多族人回来，真的很感动。', 9, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 9 DAY));
SET @c31 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_3, @post_dehou_3, NULL, NULL, @user_xiaoming, NULL, '第一次参加这么正式的祭祖仪式，虽然有些礼仪不太懂，但能感受到那种庄重的氛围。', 6, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 9 DAY)),
('POST', @post_dehou_3, @post_dehou_3, NULL, NULL, @user_dehou, NULL, '看到年轻一代愿意参与，我很欣慰。家族文化，就靠一代代人传承下去。', 18, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 8 DAY));
SET @c33 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @c31, @post_dehou_3, @c31, @c31, @user_dehou, @user_jianguo, '明年清明，希望你能带雨桐回来，让她也感受家族的传统。', 6, 1, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 7 DAY)),
('COMMENT', @c33, @post_dehou_3, @c33, @c33, @user_xiaoming, @user_dehou, '大伯，明年我一定回来参加！', 3, 1, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 6 DAY));

-- 评论 "祖训家规"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_4, @post_dehou_4, NULL, NULL, @user_jianguo, NULL, '这五条祖训，每一条都很有道理。特别是"勤俭"和"读书"，是我们家的家风。', 15, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 19 DAY)),
('POST', @post_dehou_4, @post_dehou_4, NULL, NULL, @user_xiaoming, NULL, '祖父的祖训用现在的话说，就是"做人做事"的准则。虽然时代变了，但道理没变。', 11, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 18 DAY));
SET @c42 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @c42, @post_dehou_4, @c42, @c42, @user_dehou, @user_xiaoming, '小明说得很好。时代在变，但核心价值观不能变。这就是传承的意义。', 8, 1, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 17 DAY));

-- 评论 "老照片"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_5, @post_dehou_5, NULL, NULL, @user_jianguo, NULL, '1958年的全家福！我看到了爷爷，那时候我还小，对那张照片没印象了。谢谢大伯保存得这么好。', 8, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 14 DAY)),
('POST', @post_dehou_5, @post_dehou_5, NULL, NULL, @user_xiaoming, NULL, '这些老照片太珍贵了！建议大伯做一个电子相册，分享给所有族人。', 13, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 13 DAY));
SET @c52 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @c52, @post_dehou_5, @c52, @c52, @user_dehou, @user_xiaoming, '好主意！小明你懂摄影，要不你来帮忙做？', 5, 1, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 12 DAY)),
('COMMENT', @c52, @post_dehou_5, @c52, @c52, @user_xiaoming, @user_dehou, '没问题，大伯！交给我，我来整理和修图。', 7, 2, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 11 DAY));

-- 评论 "军旅岁月"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_6, @post_dehou_6, NULL, NULL, @user_jianguo, NULL, '大伯的军旅经历真让人敬佩。那个年代的人，真的能吃苦。', 6, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 4 DAY)),
('POST', @post_dehou_6, @post_dehou_6, NULL, NULL, @user_xiaoming, NULL, '大伯在部队的故事太精彩了！哪天给我详细讲讲。', 4, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 3 DAY));

-- 评论 "书法与家风"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_7, @post_dehou_7, NULL, NULL, @user_jianguo, NULL, '大伯的字写得真好！"家和万事兴"这四个字，我要挂在家里。', 5, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 1 DAY)),
('POST', @post_dehou_7, @post_dehou_7, NULL, NULL, @user_xiaoming, NULL, '大伯的书法太棒了！每次看到您的字都觉得心里很平静。', 3, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 1 DAY));

-- 评论 "祖父口中的家族往事"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_8, @post_dehou_8, NULL, NULL, @user_jianguo, NULL, '祖父的故事我小时候也听过，但很多都忘了。大伯记录得真好。', 4, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 7 DAY)),
('POST', @post_dehou_8, @post_dehou_8, NULL, NULL, @user_xiaoming, NULL, '这些故事太感人了。大伯，我帮您整理成电子书吧，方便传播。', 6, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 6 DAY));

-- === 评论张建国的动态 ===

-- 评论 "女儿毕业典礼"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_jianguo_1, @post_jianguo_1, NULL, NULL, @user_dehou, NULL, '雨桐真棒！我们张家又出了一个大学生！这是家族的骄傲。', 14, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 2 DAY));
SET @cj11 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_jianguo_1, @post_jianguo_1, NULL, NULL, @user_xiaoming, NULL, '恭喜雨桐姐毕业！我也快了，明年就轮到我了。', 5, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 2 DAY));
SET @cj12 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cj11, @post_jianguo_1, @cj11, @cj11, @user_jianguo, @user_dehou, '谢谢大伯！雨桐能有今天，离不开家族的关心和支持。', 8, 1, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 1 DAY)),
('COMMENT', @cj12, @post_jianguo_1, @cj12, @cj12, @user_jianguo, @user_xiaoming, '小明你也要加油，叔叔相信你能行！', 3, 1, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 1 DAY)),
('COMMENT', @cj12, @post_jianguo_1, @cj12, @cj12, @user_xiaoming, @user_jianguo, '谢谢叔叔！一定不辜负您的期望。', 2, 2, 'VISIBLE', @user_xiaoming, NOW());

-- 评论 "周末郊游"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_jianguo_2, @post_jianguo_2, NULL, NULL, @user_dehou, NULL, '一家人出去走走挺好。工作再忙，也要陪陪家人。', 4, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 6 DAY)),
('POST', @post_jianguo_2, @post_jianguo_2, NULL, NULL, @user_xiaoming, NULL, '叔叔拍的照片真好看，湿地公园确实是个好地方！', 3, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 6 DAY));

-- 评论 "结婚纪念日"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_jianguo_3, @post_jianguo_3, NULL, NULL, @user_dehou, NULL, '16年了，你们夫妻一直和和睦睦，这是家族的福气。祝福你们！', 7, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 11 DAY));

-- 评论 "春节家族聚会"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_jianguo_4, @post_jianguo_4, NULL, NULL, @user_dehou, NULL, '今年聚得真齐，难得。希望以后每年都能这么热闹。', 5, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 44 DAY)),
('POST', @post_jianguo_4, @post_jianguo_4, NULL, NULL, @user_xiaoming, NULL, '今年春节过得真开心！就是人太多，都没来得及好好拍照。', 3, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 43 DAY));

-- 评论 "工作感悟"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_jianguo_5, @post_jianguo_5, NULL, NULL, @user_xiaoming, NULL, '叔叔说得太对了！管理和治家确实是同一个道理。', 4, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 21 DAY));

-- 评论 "红烧肉"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_jianguo_6, @post_jianguo_6, NULL, NULL, @user_xiaoming, NULL, '看饿了！叔叔的红烧肉我吃过，真的超级好吃！下次回家一定要做给我吃。', 6, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 17 DAY));
SET @cj61 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cj61, @post_jianguo_6, @cj61, @cj61, @user_jianguo, @user_xiaoming, '没问题小明！下次回来给你做一大锅，管够！', 3, 1, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 16 DAY));

-- 评论 "女儿升学"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_jianguo_7, @post_jianguo_7, NULL, NULL, @user_dehou, NULL, '雨桐考上北京的好大学，太好了！这是张家的荣耀。', 9, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 24 DAY)),
('POST', @post_jianguo_7, @post_jianguo_7, NULL, NULL, @user_xiaoming, NULL, '恭喜雨桐姐！北京的学校，离我近，以后我可以去看她。', 4, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 23 DAY));

-- 评论 "陪大伯喝茶"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_jianguo_8, @post_jianguo_8, NULL, NULL, @user_xiaoming, NULL, '叔叔和大伯的感情真好！我也要经常回去看大伯。', 3, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 13 DAY));

-- === 评论张晓明的动态 ===

-- 评论 "西藏自驾Vlog"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_1, @post_xiaoming_1, NULL, NULL, @user_dehou, NULL, '年轻人有这个勇气去西藏，很好。但出门在外，一定要注意安全。', 9, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 13 DAY)),
('POST', @post_xiaoming_1, @post_xiaoming_1, NULL, NULL, @user_jianguo, NULL, '太厉害了！视频拍得真好。小明，你以后可以做个旅游博主了。', 7, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 12 DAY));
SET @cx12 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_1, @post_xiaoming_1, NULL, NULL, @user_xiaoming, NULL, '谢谢大伯和叔叔的关心！这次旅程让我成长了很多，也更懂得了珍惜。', 5, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 12 DAY)),
('COMMENT', @cx12, @post_xiaoming_1, @cx12, @cx12, @user_xiaoming, @user_jianguo, '哈哈，叔叔过奖了！不过旅游博主可能养不活我，还是老老实实写代码吧。', 8, 1, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 11 DAY));

-- 评论 "上海夜景街拍"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_2, @post_xiaoming_2, NULL, NULL, @user_jianguo, NULL, '拍得真好看！这张青橙色调的特别有感觉。小明你摄影技术进步很大啊。', 6, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 29 DAY));
SET @cx21 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cx21, @post_xiaoming_2, @cx21, @cx21, @user_xiaoming, @user_jianguo, '谢谢叔叔！最近在学后期调色，感觉打开了一扇新世界的大门。', 3, 1, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 28 DAY));

-- 评论 "编程竞赛"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_3, @post_xiaoming_3, NULL, NULL, @user_dehou, NULL, '银奖已经很厉害了！小明是我们张家的骄傲。继续加油！', 11, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 19 DAY)),
('POST', @post_xiaoming_3, @post_xiaoming_3, NULL, NULL, @user_jianguo, NULL, '太棒了小明！比叔叔当年强多了。明年继续冲金奖！', 8, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 18 DAY));
SET @cx32 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cx32, @post_xiaoming_3, @cx32, @cx32, @user_xiaoming, @user_jianguo, '叔叔当年也很厉害！我只是运气好。明年一定冲金奖！', 5, 1, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 17 DAY));

-- 评论 "成都美食"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_4, @post_xiaoming_4, NULL, NULL, @user_jianguo, NULL, '看饿了！成都确实是个美食天堂。下次带美华和雨桐一起去。', 4, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 15 DAY));
SET @cx41 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cx41, @post_xiaoming_4, @cx41, @cx41, @user_xiaoming, @user_jianguo, '叔叔一定要去！我给你们做攻略。', 2, 1, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 14 DAY));

-- 评论 "校园银杏树"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_5, @post_xiaoming_5, NULL, NULL, @user_jianguo, NULL, '拍得真好！特别是秋天那张，金黄的银杏叶太美了。', 3, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 1 DAY));

-- 评论 "环青海湖骑行"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_6, @post_xiaoming_6, NULL, NULL, @user_dehou, NULL, '360公里，4天！小明，你这身体素质真好。年轻人就应该多锻炼。', 8, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 4 DAY)),
('POST', @post_xiaoming_6, @post_xiaoming_6, NULL, NULL, @user_jianguo, NULL, '太牛了！360公里骑行，叔叔佩服你。不过以后出去一定要注意安全。', 5, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 3 DAY));
SET @cx62 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cx62, @post_xiaoming_6, @cx62, @cx62, @user_xiaoming, @user_jianguo, '收到叔叔的叮嘱！下次一定做好万全准备。', 2, 1, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 2 DAY));

-- 评论 "开源项目上线"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_7, @post_xiaoming_7, NULL, NULL, @user_jianguo, NULL, '小明真厉害！叔叔虽然不懂编程，但觉得很了不起！', 5, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 9 DAY));
SET @cx71 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cx71, @post_xiaoming_7, @cx71, @cx71, @user_xiaoming, @user_jianguo, '谢谢叔叔！就像您做菜一样，编程也是一种创造。', 3, 1, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 8 DAY));

-- 评论 "摄影展"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_8, @post_xiaoming_8, NULL, NULL, @user_jianguo, NULL, '小明策划的摄影展真不错！有机会叔叔去看看。', 4, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 27 DAY));

-- 评论 "健身打卡"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_9, @post_xiaoming_9, NULL, NULL, @user_jianguo, NULL, '小明坚持健身100天，了不起！叔叔要向你学习。', 6, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 11 DAY));
SET @cx91 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cx91, @post_xiaoming_9, @cx91, @cx91, @user_xiaoming, @user_jianguo, '叔叔一起来啊！周末去健身房我教您。', 3, 1, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 10 DAY));

-- 评论 "爷爷的来信"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_10, @post_xiaoming_10, NULL, NULL, @user_dehou, NULL, '小明，你的感受写得很真挚。家族的牵挂，就是那份割不断的血脉亲情。', 12, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 3 DAY)),
('POST', @post_xiaoming_10, @post_xiaoming_10, NULL, NULL, @user_jianguo, NULL, '这篇文章写得很感人。小明，你的文笔越来越好。', 5, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 3 DAY));
SET @cx101 = LAST_INSERT_ID();

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cx101, @post_xiaoming_10, @cx101, @cx101, @user_xiaoming, @user_dehou, '谢谢大伯！那幅字我会好好珍藏。', 4, 1, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 2 DAY));

-- ================================================
-- 12. 留言板数据 (t_message_board) - 17条
-- ================================================

-- 张德厚主页留言
INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_dehou, @user_jianguo, NULL, '大伯，最近身体还好吧？天气转凉了，注意保暖。有空我去看您。', 3, 1, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 15 DAY));
SET @m1 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_dehou, @user_xiaoming, NULL, '大伯公好！我在北京挺好的，您注意身体哦。等放假了回去看您！想您写的书法了~', 5, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 10 DAY));
SET @m2 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_dehou, @user_jianguo, NULL, '大伯，族谱电子版的事我已经跟小明说了，他来帮忙整理。您有什么需要随时吩咐。', 2, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 5 DAY));
SET @m3 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_dehou, @user_xiaoming, NULL, '大伯，您的那篇家族起源考我转发给同学看了，他们都说很震撼！家族历史真了不起。', 4, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 3 DAY));
SET @m4 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_dehou, @user_dehou, @m1, '建国有心了，我身体还好。你们工作忙，不用老惦记我。周末带家人来吃饭。', 4, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 14 DAY));
SET @m5 = LAST_INSERT_ID();

-- 张建国主页留言
INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_jianguo, @user_dehou, NULL, '建国，你工作上要注意身体，别太累。家里的事多和美华商量。', 4, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 20 DAY));
SET @m6 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_jianguo, @user_xiaoming, NULL, '建国叔，恭喜雨桐姐毕业！改天请吃饭庆祝啊！我想吃您做的红烧肉了~', 3, 1, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 2 DAY));
SET @m7 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_jianguo, @user_dehou, NULL, '建国，清明祭祖的事你多费心，帮忙组织一下族人。', 2, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 25 DAY));
SET @m8 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_jianguo, @user_xiaoming, NULL, '建国叔，您上次说的那个管理心得，我受益匪浅！原来管理和治家是一个道理。', 2, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 21 DAY));
SET @m9 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_jianguo, @user_xiaoming, NULL, '叔，您做的红烧肉真的太好吃了，我室友都说想尝尝。下次能多做点让我带过去吗？哈哈', 1, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 17 DAY));
SET @m10 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_jianguo, @user_jianguo, @m7, '没问题小明！一定请，你想吃什么？', 2, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 1 DAY));
SET @m11 = LAST_INSERT_ID();

-- 张晓明主页留言
INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_xiaoming, @user_dehou, NULL, '小明，你在北京好好学习，注意安全。放假了就回家，别老在外面跑。', 6, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 8 DAY));
SET @m12 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_xiaoming, @user_jianguo, NULL, '小明，竞赛拿奖了，叔叔替你高兴！继续保持，明年冲击金奖！', 4, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 18 DAY));
SET @m13 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_xiaoming, @user_jianguo, NULL, '小明，你的照片拍得越来越好了！下次家族活动，你来负责拍照吧。', 3, 1, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 3 DAY));
SET @m14 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_xiaoming, @user_xiaoming, @m14, '好嘞叔叔！没问题，包在我身上！', 2, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 2 DAY));
SET @m15 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_xiaoming, @user_dehou, NULL, '大伯，您的书法我挂在宿舍了。同学们都说字写得太好了！', 5, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 1 DAY));
SET @m16 = LAST_INSERT_ID();

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_xiaoming, @user_jianguo, NULL, '叔叔，周末我去健身房找您？带上美华姐一起，锻炼身体！', 2, 0, 'VISIBLE', @user_xiaoming, NOW());
SET @m17 = LAST_INSERT_ID();

-- ================================================
-- 13. 点赞记录 (t_like_record) - 73条
-- ================================================

-- 张建国点赞张德厚的动态 (8条)
INSERT INTO t_like_record (target_type, target_id, user_id, status, created_at) VALUES
('POST', @post_dehou_1, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 29 DAY)),
('POST', @post_dehou_2, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 24 DAY)),
('POST', @post_dehou_3, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 9 DAY)),
('POST', @post_dehou_4, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 19 DAY)),
('POST', @post_dehou_5, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 14 DAY)),
('POST', @post_dehou_6, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 4 DAY)),
('POST', @post_dehou_7, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('POST', @post_dehou_8, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 7 DAY));

-- 张晓明点赞张德厚的动态 (6条)
INSERT INTO t_like_record (target_type, target_id, user_id, status, created_at) VALUES
('POST', @post_dehou_1, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 28 DAY)),
('POST', @post_dehou_3, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 9 DAY)),
('POST', @post_dehou_4, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 18 DAY)),
('POST', @post_dehou_5, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 13 DAY)),
('POST', @post_dehou_7, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('POST', @post_dehou_8, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 6 DAY));

-- 张德厚点赞张建国和张晓明的动态 (12条)
INSERT INTO t_like_record (target_type, target_id, user_id, status, created_at) VALUES
('POST', @post_jianguo_1, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 2 DAY)),
('POST', @post_jianguo_2, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 6 DAY)),
('POST', @post_jianguo_3, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 11 DAY)),
('POST', @post_jianguo_4, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 44 DAY)),
('POST', @post_jianguo_6, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 17 DAY)),
('POST', @post_jianguo_7, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 24 DAY)),
('POST', @post_jianguo_8, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 13 DAY)),
('POST', @post_xiaoming_1, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 13 DAY)),
('POST', @post_xiaoming_3, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 19 DAY)),
('POST', @post_xiaoming_6, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 4 DAY)),
('POST', @post_xiaoming_7, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 9 DAY)),
('POST', @post_xiaoming_10, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 3 DAY));

-- 张建国点赞张晓明的动态 (10条)
INSERT INTO t_like_record (target_type, target_id, user_id, status, created_at) VALUES
('POST', @post_xiaoming_1, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 12 DAY)),
('POST', @post_xiaoming_2, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 29 DAY)),
('POST', @post_xiaoming_3, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 18 DAY)),
('POST', @post_xiaoming_4, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 15 DAY)),
('POST', @post_xiaoming_5, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('POST', @post_xiaoming_6, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 3 DAY)),
('POST', @post_xiaoming_7, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 9 DAY)),
('POST', @post_xiaoming_8, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 27 DAY)),
('POST', @post_xiaoming_9, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 11 DAY)),
('POST', @post_xiaoming_10, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 3 DAY));

-- 张晓明点赞张建国的动态 (6条)
INSERT INTO t_like_record (target_type, target_id, user_id, status, created_at) VALUES
('POST', @post_jianguo_1, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 2 DAY)),
('POST', @post_jianguo_2, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 6 DAY)),
('POST', @post_jianguo_4, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 43 DAY)),
('POST', @post_jianguo_6, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 17 DAY)),
('POST', @post_jianguo_7, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 23 DAY)),
('POST', @post_jianguo_8, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 13 DAY));

-- 评论点赞 (9条)
INSERT INTO t_like_record (target_type, target_id, user_id, status, created_at) VALUES
('COMMENT', @c3, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 26 DAY)),
('COMMENT', @c33, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 7 DAY)),
('COMMENT', @cj11, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('COMMENT', @cx12, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 10 DAY)),
('COMMENT', @c42, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 16 DAY)),
('COMMENT', @c52, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 12 DAY)),
('COMMENT', @cj12, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('COMMENT', @cx32, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 16 DAY)),
('COMMENT', @cx101, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 2 DAY));

-- 留言点赞 (9条)
INSERT INTO t_like_record (target_type, target_id, user_id, status, created_at) VALUES
('MESSAGE_BOARD', @m1, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 14 DAY)),
('MESSAGE_BOARD', @m2, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 9 DAY)),
('MESSAGE_BOARD', @m3, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 4 DAY)),
('MESSAGE_BOARD', @m5, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 19 DAY)),
('MESSAGE_BOARD', @m6, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('MESSAGE_BOARD', @m7, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 24 DAY)),
('MESSAGE_BOARD', @m12, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 7 DAY)),
('MESSAGE_BOARD', @m13, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 17 DAY)),
('MESSAGE_BOARD', @m14, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 2 DAY));

-- ================================================
-- 14. 通知数据 (t_notification) - 38条
-- ================================================

-- 张德厚收到的通知 (14条)
INSERT INTO t_notification (receiver_id, sender_id, type, target_type, target_id, content, is_read, created_at) VALUES
(@user_dehou, @user_jianguo, 'COMMENT', 'POST', @post_dehou_1, '张建国评论了您的内容 "张氏家族起源考"', 1, DATE_SUB(NOW(), INTERVAL 29 DAY)),
(@user_dehou, @user_xiaoming, 'COMMENT', 'POST', @post_dehou_1, '张晓明评论了您的内容 "张氏家族起源考"', 1, DATE_SUB(NOW(), INTERVAL 28 DAY)),
(@user_dehou, @user_jianguo, 'LIKE', 'POST', @post_dehou_1, '张建国赞了您的内容 "张氏家族起源考"', 1, DATE_SUB(NOW(), INTERVAL 29 DAY)),
(@user_dehou, @user_xiaoming, 'LIKE', 'POST', @post_dehou_1, '张晓明赞了您的内容 "张氏家族起源考"', 1, DATE_SUB(NOW(), INTERVAL 28 DAY)),
(@user_dehou, @user_jianguo, 'COMMENT', 'POST', @post_dehou_3, '张建国评论了您的内容 "2024年清明祭祖大典"', 1, DATE_SUB(NOW(), INTERVAL 9 DAY)),
(@user_dehou, @user_xiaoming, 'COMMENT', 'POST', @post_dehou_3, '张晓明评论了您的内容 "2024年清明祭祖大典"', 1, DATE_SUB(NOW(), INTERVAL 9 DAY)),
(@user_dehou, @user_jianguo, 'LIKE', 'POST', @post_dehou_4, '张建国赞了您的内容 "张氏祖训解读"', 1, DATE_SUB(NOW(), INTERVAL 19 DAY)),
(@user_dehou, @user_xiaoming, 'LIKE', 'POST', @post_dehou_4, '张晓明赞了您的内容 "张氏祖训解读"', 1, DATE_SUB(NOW(), INTERVAL 18 DAY)),
(@user_dehou, @user_jianguo, 'MESSAGE_BOARD', NULL, NULL, '张建国在您的主页留言', 1, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(@user_dehou, @user_xiaoming, 'MESSAGE_BOARD', NULL, NULL, '张晓明在您的主页留言', 1, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(@user_dehou, @user_jianguo, 'REPLY', 'COMMENT', @c31, '张建国回复了您的评论', 0, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(@user_dehou, @user_xiaoming, 'REPLY', 'COMMENT', @c52, '张晓明回复了您的评论', 0, NOW()),
(@user_dehou, @user_xiaoming, 'LIKE', 'POST', @post_xiaoming_10, '张晓明赞了您的评论', 0, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(@user_dehou, @user_jianguo, 'PRIVATE_MESSAGE', NULL, NULL, '张建国给您发了一条私信', 1, DATE_SUB(NOW(), INTERVAL 4 DAY));

-- 张建国收到的通知 (12条)
INSERT INTO t_notification (receiver_id, sender_id, type, target_type, target_id, content, is_read, created_at) VALUES
(@user_jianguo, @user_dehou, 'COMMENT', 'POST', @post_jianguo_1, '张德厚评论了您的内容 "女儿的大学毕业典礼"', 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@user_jianguo, @user_xiaoming, 'COMMENT', 'POST', @post_jianguo_1, '张晓明评论了您的内容 "女儿的大学毕业典礼"', 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@user_jianguo, @user_dehou, 'LIKE', 'POST', @post_jianguo_1, '张德厚赞了您的内容 "女儿的大学毕业典礼"', 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@user_jianguo, @user_dehou, 'COMMENT', 'POST', @post_jianguo_3, '张德厚评论了您的内容 "结婚16周年纪念日"', 1, DATE_SUB(NOW(), INTERVAL 11 DAY)),
(@user_jianguo, @user_dehou, 'MESSAGE_BOARD', NULL, NULL, '张德厚在您的主页留言', 1, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(@user_jianguo, @user_xiaoming, 'MESSAGE_BOARD', NULL, NULL, '张晓明在您的主页留言', 0, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@user_jianguo, @user_dehou, 'AT_MENTION', 'COMMENT', @c31, '张德厚在评论中提到了您', 1, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(@user_jianguo, @user_xiaoming, 'LIKE', 'POST', @post_jianguo_6, '张晓明赞了您的内容 "周末下厨：秘制红烧肉"', 1, DATE_SUB(NOW(), INTERVAL 17 DAY)),
(@user_jianguo, @user_dehou, 'LIKE', 'POST', @post_jianguo_7, '张德厚赞了您的内容 "雨桐考上大学了！"', 1, DATE_SUB(NOW(), INTERVAL 24 DAY)),
(@user_jianguo, @user_xiaoming, 'COMMENT', 'POST', @post_jianguo_8, '张晓明评论了您的内容 "陪大伯喝茶聊天"', 0, DATE_SUB(NOW(), INTERVAL 13 DAY)),
(@user_jianguo, @user_xiaoming, 'REPLY', 'COMMENT', @cj61, '张晓明回复了您的评论', 0, DATE_SUB(NOW(), INTERVAL 16 DAY)),
(@user_jianguo, @user_xiaoming, 'PRIVATE_MESSAGE', NULL, NULL, '张晓明给您发了一条私信', 1, DATE_SUB(NOW(), INTERVAL 19 DAY));

-- 张晓明收到的通知 (12条)
INSERT INTO t_notification (receiver_id, sender_id, type, target_type, target_id, content, is_read, created_at) VALUES
(@user_xiaoming, @user_dehou, 'COMMENT', 'POST', @post_xiaoming_1, '张德厚评论了您的内容 "西藏自驾Vlog"', 1, DATE_SUB(NOW(), INTERVAL 13 DAY)),
(@user_xiaoming, @user_jianguo, 'COMMENT', 'POST', @post_xiaoming_1, '张建国评论了您的内容 "西藏自驾Vlog"', 1, DATE_SUB(NOW(), INTERVAL 12 DAY)),
(@user_xiaoming, @user_dehou, 'LIKE', 'POST', @post_xiaoming_1, '张德厚赞了您的内容 "西藏自驾Vlog"', 1, DATE_SUB(NOW(), INTERVAL 13 DAY)),
(@user_xiaoming, @user_jianguo, 'LIKE', 'POST', @post_xiaoming_1, '张建国赞了您的内容 "西藏自驾Vlog"', 1, DATE_SUB(NOW(), INTERVAL 12 DAY)),
(@user_xiaoming, @user_dehou, 'COMMENT', 'POST', @post_xiaoming_3, '张德厚评论了您的内容 "程序设计竞赛银奖！"', 1, DATE_SUB(NOW(), INTERVAL 19 DAY)),
(@user_xiaoming, @user_jianguo, 'COMMENT', 'POST', @post_xiaoming_3, '张建国评论了您的内容 "程序设计竞赛银奖！"', 1, DATE_SUB(NOW(), INTERVAL 18 DAY)),
(@user_xiaoming, @user_dehou, 'MESSAGE_BOARD', NULL, NULL, '张德厚在您的主页留言', 1, DATE_SUB(NOW(), INTERVAL 8 DAY)),
(@user_xiaoming, @user_jianguo, 'MESSAGE_BOARD', NULL, NULL, '张建国在您的主页留言', 0, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(@user_xiaoming, @user_jianguo, 'REPLY', 'COMMENT', @cx12, '张建国回复了您的评论', 1, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(@user_xiaoming, @user_dehou, 'AT_MENTION', 'COMMENT', @c52, '张德厚在评论中提到了您', 0, NOW()),
(@user_xiaoming, @user_jianguo, 'LIKE', 'POST', @post_xiaoming_7, '张建国赞了您的内容 "我的第一个开源项目上线了！"', 1, DATE_SUB(NOW(), INTERVAL 9 DAY)),
(@user_xiaoming, @user_dehou, 'COMMENT', 'POST', @post_xiaoming_10, '张德厚评论了您的内容 "爷爷的来信"', 0, DATE_SUB(NOW(), INTERVAL 3 DAY));

-- ================================================
-- 15. 私信会话和消息 (t_message_session + t_private_message) - 6个会话, 32条消息
-- ================================================

-- 会话1: 张德厚与张建国
INSERT INTO t_message_session (session_key, user_id_1, user_id_2, last_message, last_message_time, unread_count_1, unread_count_2, created_at) VALUES
('4_5', 4, 5, '好的大伯，周末我们回去看您。', DATE_SUB(NOW(), INTERVAL 4 DAY), 0, 0, DATE_SUB(NOW(), INTERVAL 30 DAY));
SET @s1 = LAST_INSERT_ID();

INSERT INTO t_private_message (session_id, sender_id, receiver_id, content, msg_type, is_read, status, created_by, created_at) VALUES
(@s1, @user_dehou, @user_jianguo, '建国，最近工作怎么样？身体还好吧？', 'TEXT', 1, 1, @user_dehou, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@s1, @user_jianguo, @user_dehou, '大伯，我挺好的。工作挺忙的，但还能应付。您身体怎么样？', 'TEXT', 1, 1, @user_jianguo, DATE_SUB(NOW(), INTERVAL 29 DAY)),
(@s1, @user_dehou, @user_jianguo, '我还好。就是族谱电子版的事，你跟小明说一下，让他帮忙弄。', 'TEXT', 1, 1, @user_dehou, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(@s1, @user_jianguo, @user_dehou, '好的，我跟他说了。他说没问题，等放假了就回去弄。', 'TEXT', 1, 1, @user_jianguo, DATE_SUB(NOW(), INTERVAL 19 DAY)),
(@s1, @user_dehou, @user_jianguo, '那就好。周末有空带家人来吃饭。', 'TEXT', 1, 1, @user_dehou, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(@s1, @user_jianguo, @user_dehou, '好的大伯，周末我们回去看您。', 'TEXT', 0, 1, @user_jianguo, DATE_SUB(NOW(), INTERVAL 4 DAY));

-- 会话2: 张建国与张晓明
INSERT INTO t_message_session (session_key, user_id_1, user_id_2, last_message, last_message_time, unread_count_1, unread_count_2, created_at) VALUES
('5_6', 5, 6, '雨桐毕业典礼你来了吧？没来太可惜了。', DATE_SUB(NOW(), INTERVAL 1 DAY), 0, 1, DATE_SUB(NOW(), INTERVAL 25 DAY));
SET @s2 = LAST_INSERT_ID();

INSERT INTO t_private_message (session_id, sender_id, receiver_id, content, msg_type, is_read, status, created_by, created_at) VALUES
(@s2, @user_jianguo, @user_xiaoming, '小明，你竞赛拿奖了，太厉害了！叔叔替你高兴。', 'TEXT', 1, 1, @user_jianguo, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(@s2, @user_xiaoming, @user_jianguo, '谢谢叔叔！运气好而已，哈哈。', 'TEXT', 1, 1, @user_xiaoming, DATE_SUB(NOW(), INTERVAL 19 DAY)),
(@s2, @user_jianguo, @user_xiaoming, '下次家族活动你来拍照吧，你拍的照片好看。', 'TEXT', 1, 1, @user_jianguo, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(@s2, @user_xiaoming, @user_jianguo, '没问题叔叔！包在我身上。', 'TEXT', 1, 1, @user_xiaoming, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(@s2, @user_jianguo, @user_xiaoming, '雨桐毕业典礼你来了吧？没来太可惜了。', 'TEXT', 0, 1, @user_jianguo, DATE_SUB(NOW(), INTERVAL 1 DAY));

-- 会话3: 张德厚与张晓明
INSERT INTO t_message_session (session_key, user_id_1, user_id_2, last_message, last_message_time, unread_count_1, unread_count_2, created_at) VALUES
('4_6', 4, 6, '大伯，我期末考试后就回家！', DATE_SUB(NOW(), INTERVAL 3 DAY), 0, 0, DATE_SUB(NOW(), INTERVAL 15 DAY));
SET @s3 = LAST_INSERT_ID();

INSERT INTO t_private_message (session_id, sender_id, receiver_id, content, msg_type, is_read, status, created_by, created_at) VALUES
(@s3, @user_dehou, @user_xiaoming, '小明，在北京学习怎么样？注意身体，别熬夜太晚。', 'TEXT', 1, 1, @user_dehou, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(@s3, @user_xiaoming, @user_dehou, '大伯放心，我挺好的。学习挺顺利的，最近还在准备一个编程比赛。', 'TEXT', 1, 1, @user_xiaoming, DATE_SUB(NOW(), INTERVAL 14 DAY)),
(@s3, @user_dehou, @user_xiaoming, '那就好，比赛加油！注意劳逸结合。', 'TEXT', 1, 1, @user_dehou, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(@s3, @user_xiaoming, @user_dehou, '大伯，我期末考试后就回家！', 'TEXT', 1, 1, @user_xiaoming, DATE_SUB(NOW(), INTERVAL 3 DAY));

-- 会话4: 张建国与妻子陈美华（模拟，假设user_id=7）
INSERT INTO t_private_message (sender_id, receiver_id, content, msg_type, is_read, status, created_by, created_at) VALUES
(@user_jianguo, 7, '老婆，今天加班晚一点回去，你先吃饭。', 'TEXT', 1, 1, @user_jianguo, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(@user_jianguo, 7, '好的，给你留了菜。路上注意安全。', 'TEXT', 1, 1, 7, DATE_SUB(NOW(), INTERVAL 5 DAY));

-- 会话5: 张晓明与同学王磊（模拟，假设user_id=8）
INSERT INTO t_private_message (sender_id, receiver_id, content, msg_type, is_read, status, created_by, created_at) VALUES
(@user_xiaoming, 8, '磊哥，周末一起去骑行吗？香山红叶正好！', 'TEXT', 1, 1, @user_xiaoming, DATE_SUB(NOW(), INTERVAL 6 DAY)),
(8, @user_xiaoming, '好啊！周六早上8点校门口见？', 'TEXT', 1, 1, 8, DATE_SUB(NOW(), INTERVAL 6 DAY)),
(@user_xiaoming, 8, '没问题！我带相机，拍红叶去！', 'TEXT', 1, 1, @user_xiaoming, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(8, @user_xiaoming, '对了，你那个照片管理工具好用吗？我也试试。', 'TEXT', 1, 1, 8, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(@user_xiaoming, 8, '超好用！GitHub上有源码，我发给你。', 'TEXT', 1, 1, @user_xiaoming, DATE_SUB(NOW(), INTERVAL 3 DAY));

-- 会话6: 张晓明与同学李娜（模拟，假设user_id=9）
INSERT INTO t_private_message (sender_id, receiver_id, content, msg_type, is_read, status, created_by, created_at) VALUES
(9, @user_xiaoming, '晓明，摄影展的照片太棒了！你是怎么拍出那么好的效果的？', 'TEXT', 1, 1, 9, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(@user_xiaoming, 9, '谢谢娜娜！主要是光线好，后期也调了很久。', 'TEXT', 1, 1, @user_xiaoming, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(9, @user_xiaoming, '下次教教我怎么调色呗！', 'TEXT', 1, 1, 9, DATE_SUB(NOW(), INTERVAL 9 DAY)),
(@user_xiaoming, 9, '没问题，周末摄影社活动时一起学！', 'TEXT', 0, 1, @user_xiaoming, DATE_SUB(NOW(), INTERVAL 8 DAY));

-- ================================================
-- 16. 更新冗余计数
-- ================================================

-- 更新话题计数
UPDATE t_topic SET post_count = 3, participant_count = 2 WHERE id = @topic_family_memory;
UPDATE t_topic SET post_count = 2, participant_count = 3 WHERE id = @topic_hometown_taste;
UPDATE t_topic SET post_count = 3, participant_count = 3 WHERE id = @topic_inheritance_light;
UPDATE t_topic SET post_count = 4, participant_count = 2 WHERE id = @topic_youth_mark;

-- 更新分类计数
UPDATE t_post_category SET post_count = 4 WHERE id = @cat_family_story;
UPDATE t_post_category SET post_count = 4 WHERE id = @cat_photo_wall;
UPDATE t_post_category SET post_count = 3 WHERE id = @cat_important_event;
UPDATE t_post_category SET post_count = 1 WHERE id = @cat_video_collection;
UPDATE t_post_category SET post_count = 5 WHERE id = @cat_life_log;
UPDATE t_post_category SET post_count = 3 WHERE id = @cat_mood_diary;

-- ================================================
-- V2.0 完整初始化数据完成
-- 统计:
--   示范用户: 3个 (张德厚-族长, 张建国-中年, 张晓明-青年)
--   用户主页档案: 3个
--   动态分类: 6个 (系统预置)
--   话题: 4个 (#家族记忆 #家乡味道 #传承之光 #青春印记)
--   动态内容: 26条 (张德厚8条, 张建国8条, 张晓明10条)
--   动态媒体: 62条 (图片60个, 视频2个)
--   话题关联: 12条
--   兴趣标签: 18条
--   隐私设置: 24条
--   评论: 55条 (含多层级回复)
--   点赞记录: 73条 (动态点赞42条 + 评论点赞9条 + 留言点赞9条)
--   留言板: 17条 (含回复)
--   通知: 38条
--   私信会话: 6个
--   私信消息: 32条
-- ================================================
