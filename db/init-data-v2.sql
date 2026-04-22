-- ================================================
-- 家族族谱管理系统 V2.0 - 个人主页功能初始化数据脚本
-- 版本: v2.0
-- 数据库: MySQL 8.0
-- 字符集: utf8mb4
-- 说明: 提供三个示范用户的完整主页数据
--   - 张德厚 (族长): 侧重家族历史传承
--   - 张建国 (中年): 侧重家庭生活记录
--   - 张晓明 (青年): 侧重旅行见闻和兴趣爱好
-- 依赖: 需要先执行 schema.sql 和 init_data.sql
-- ================================================

USE family_genealogy;

-- ================================================
-- 0. 前提: 创建示范用户和成员
-- 说明: 假设init_data.sql已执行,此处新增3个示范用户及对应成员
-- ================================================

-- 新增示范用户 (密码均为 123456)
INSERT INTO t_user (phone, password, name, family_id, role, status, avatar_url, created_at, updated_at) VALUES
('13812345610', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张德厚', 1, 'MEMBER', 1, 'https://example.com/avatars/zhang_dehou.jpg', NOW(), NOW()),
('13812345611', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张建国', 1, 'MEMBER', 1, 'https://example.com/avatars/zhang_jianguo.jpg', NOW(), NOW()),
('13812345612', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张晓明', 1, 'MEMBER', 1, 'https://example.com/avatars/zhang_xiaoming.jpg', NOW(), NOW());

-- 获取新用户ID (假设按顺序为4, 5, 6)
SET @user_dehou = 4;
SET @user_jianguo = 5;
SET @user_xiaoming = 6;

-- 新增对应族谱成员
INSERT INTO t_member (family_id, name, gender, birth_date, birth_place, generation, spouse_name, status, created_by, portrait_url, occupation, biography, created_at, updated_at) VALUES
-- 张德厚: 第3代长辈, 家族族长
(1, '张德厚', 'MALE', '1951-08-15', '河北保定', 3, '李秀兰', 'ALIVE', @user_dehou, 'https://example.com/portraits/zhang_dehou.jpg', '退休教师/家族族长', '张氏家族第3代传人,1951年出生于保定老宅。1969年参军入伍,服役8年。1977年转业后任村小学教师,桃李满天下。1995年开始主持编纂张氏族谱,2010年被族人推举为家族族长。一生致力于家族文化传承,是家族的精神支柱。', NOW(), NOW()),
-- 张建国: 第4代中坚
(1, '张建国', 'MALE', '1981-05-20', '河北保定', 4, '陈美华', 'ALIVE', @user_jianguo, 'https://example.com/portraits/zhang_jianguo.jpg', '企业中层管理', '张氏家族第4代,张建国的长子。大学毕业后进入国企工作,现为部门经理。为人踏实稳重,家庭和睦,育有一女。周末喜欢带家人郊游,记录生活中的温馨时刻。', NOW(), NOW()),
-- 张晓明: 第5代青年
(1, '张晓明', 'MALE', '2001-03-12', '北京', 5, NULL, 'ALIVE', @user_xiaoming, 'https://example.com/portraits/zhang_xiaoming.jpg', '大学在读/摄影爱好者', '张氏家族第5代,张志强的侄子。就读于北京某大学计算机专业。热爱旅行和摄影,足迹遍布祖国大好河山。性格开朗活泼,善于用镜头记录生活中的美好瞬间。', NOW(), NOW());

-- 获取成员ID
SET @member_dehou = 37;
SET @member_jianguo = 38;
SET @member_xiaoming = 39;


-- ================================================
-- 1. 初始化用户主页档案 (t_user_profile)
-- ================================================

-- 张德厚主页 - 厚重古朴风格
INSERT INTO t_user_profile (user_id, member_id, bio, background_url, signature, birth_place, occupation, education, hometown, life_events, visit_count, theme, status, created_by, created_at, updated_at) VALUES
(@user_dehou, @member_dehou,
'张氏家族第3代传人，1951年出生于保定老宅。一生致力于家族文化传承，主持编纂族谱，被推举为家族族长。坚信"家族兴旺，在于传承；文化延续，在于教育"。',
'https://example.com/backgrounds/ancestral_hall.jpg',
'传承家族文化，凝聚家族力量。家和万事兴。',
'河北保定', '退休教师/家族族长', '大专', '山东曲阜',
JSON_ARRAY(
    JSON_OBJECT('year', 1951, 'event', '出生于张氏祖宅'),
    JSON_OBJECT('year', 1969, 'event', '参军入伍，保家卫国'),
    JSON_OBJECT('year', 1977, 'event', '转业回乡，任村小学教师'),
    JSON_OBJECT('year', 1980, 'event', '牵头修缮家族祠堂'),
    JSON_OBJECT('year', 1995, 'event', '开始主持编纂张氏族谱'),
    JSON_OBJECT('year', 2010, 'event', '被推举为张氏家族族长'),
    JSON_OBJECT('year', 2020, 'event', '家族祠堂修缮工程竣工'),
    JSON_OBJECT('year', 2024, 'event', '主持清明祭祖大典')
),
1286, 'vintage', 1, @user_dehou, NOW(), NOW());

-- 张建国主页 - 温馨家庭风格
INSERT INTO t_user_profile (user_id, member_id, bio, background_url, signature, birth_place, occupation, education, hometown, life_events, visit_count, theme, status, created_by, created_at, updated_at) VALUES
(@user_jianguo, @member_jianguo,
'张氏家族第4代，普通但幸福的家庭。工作在保定，生活在保定。最大的幸福就是看着女儿一天天长大，一家人和和睦睦。',
'https://example.com/backgrounds/family_photo.jpg',
'陪伴是最长情的告白，家是最温暖的港湾。',
'河北保定', '企业中层管理', '本科', '河北保定',
JSON_ARRAY(
    JSON_OBJECT('year', 1981, 'event', '出生于保定'),
    JSON_OBJECT('year', 1999, 'event', '考入河北大学'),
    JSON_OBJECT('year', 2003, 'event', '大学毕业，进入国企工作'),
    JSON_OBJECT('year', 2008, 'event', '与陈美华结婚'),
    JSON_OBJECT('year', 2010, 'event', '女儿张雨桐出生'),
    JSON_OBJECT('year', 2018, 'event', '晋升为部门经理'),
    JSON_OBJECT('year', 2024, 'event', '女儿考上大学')
),
856, 'warm', 1, @user_jianguo, NOW(), NOW());

-- 张晓明主页 - 年轻活力风格
INSERT INTO t_user_profile (user_id, member_id, bio, background_url, signature, birth_place, occupation, education, hometown, life_events, visit_count, theme, status, created_by, created_at, updated_at) VALUES
(@user_xiaoming, @member_xiaoming,
'计算机专业大三学生，热爱旅行和摄影。用镜头记录世界的美好，用代码改变生活的可能。永远在路上！',
'https://example.com/backgrounds/travel_landscape.jpg',
'世界那么大，我想去看看。趁年轻，去探索！',
'北京', '大学在读/摄影爱好者', '本科在读', '河北保定',
JSON_ARRAY(
    JSON_OBJECT('year', 2001, 'event', '出生于北京'),
    JSON_OBJECT('year', 2019, 'event', '考入北京科技大学计算机专业'),
    JSON_OBJECT('year', 2021, 'event', '第一次独自旅行，川藏线骑行'),
    JSON_OBJECT('year', 2022, 'event', '摄影作品获校摄影展一等奖'),
    JSON_OBJECT('year', 2023, 'event', '暑期西藏自驾Vlog获得10万播放'),
    JSON_OBJECT('year', 2024, 'event', '获得全国大学生程序设计竞赛银奖')
),
2134, 'modern', 1, @user_xiaoming, NOW(), NOW());


-- ================================================
-- 2. 初始化系统预置分类 (t_post_category)
-- ================================================

INSERT INTO t_post_category (user_id, name, code, icon, color, description, sort_order, is_system, post_count, status, created_by, created_at) VALUES
(NULL, '生平日志', 'LIFE_LOG', '📝', '#4A90D9', '记录生活中的点点滴滴', 1, 1, 0, 1, 1, NOW()),
(NULL, '家族故事', 'FAMILY_STORY', '🏠', '#E74C3C', '分享家族的历史和故事', 2, 1, 0, 1, 1, NOW()),
(NULL, '照片墙', 'PHOTO_WALL', '📷', '#2ECC71', '照片集锦，美好瞬间', 3, 1, 0, 1, 1, NOW()),
(NULL, '视频集', 'VIDEO_COLLECTION', '🎬', '#9B59B6', '视频分享，精彩时刻', 4, 1, 0, 1, 1, NOW()),
(NULL, '心情随笔', 'MOOD_DIARY', '💭', '#F39C12', '心情记录，随笔感悟', 5, 1, 0, 1, 1, NOW()),
(NULL, '重要事件', 'IMPORTANT_EVENT', '⭐', '#E67E22', '人生重要节点记录', 6, 1, 0, 1, 1, NOW());

-- 获取系统分类ID
SET @cat_life_log = 1;
SET @cat_family_story = 2;
SET @cat_photo_wall = 3;
SET @cat_video_collection = 4;
SET @cat_mood_diary = 5;
SET @cat_important_event = 6;


-- ================================================
-- 3. 初始化话题 (t_topic)
-- ================================================

INSERT INTO t_topic (name, code, description, icon, cover_url, post_count, participant_count, status, created_by, created_at) VALUES
('家族历史', 'family_history', '探索和分享家族的历史故事', '📜', 'https://example.com/topics/family_history.jpg', 0, 0, 1, 1, NOW()),
('祖训家规', 'family_rules', '传承和讨论家族的家规祖训', '📋', 'https://example.com/topics/family_rules.jpg', 0, 0, 1, 1, NOW()),
('传统节日', 'traditional_festival', '清明祭祖、春节团圆等传统节日活动', '🏮', 'https://example.com/topics/traditional_festival.jpg', 0, 0, 1, 1, NOW()),
('家族聚会', 'family_gathering', '家族聚餐、聚会活动记录', '🍻', 'https://example.com/topics/family_gathering.jpg', 0, 0, 1, 1, NOW()),
('旅行见闻', 'travel_experience', '旅行中的见闻和感受', '✈️', 'https://example.com/topics/travel.jpg', 0, 0, 1, 1, NOW()),
('美食分享', 'food_share', '各地美食和家常菜分享', '🍜', 'https://example.com/topics/food.jpg', 0, 0, 1, 1, NOW());

SET @topic_family_history = 1;
SET @topic_family_rules = 2;
SET @topic_traditional_festival = 3;
SET @topic_family_gathering = 4;
SET @topic_travel = 5;
SET @topic_food = 6;


-- ================================================
-- 4. 初始化张德厚的动态内容 (族长 - 侧重家族历史传承)
-- ================================================

-- 张德厚的动态1: 张氏家族起源考
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at, updated_at) VALUES
(@user_dehou, @member_dehou, @cat_family_story, 'IMAGE',
'张氏家族起源考',
'<p>据族谱记载，我张氏先祖守义公于明朝洪武年间（约公元1370年前后），从山东曲阜迁徙至河北保定，至今已传六百年。</p>
<p>守义公当年为何离开曲阜，族谱中记载甚少。据村中老人相传，当时中原战乱频繁，为避战火，守义公带着家人一路向北，最终在保定府落脚。</p>
<p>初到保定时，守义公以耕读为生，勤俭持家，逐渐在保定扎根。到清朝康熙年间，张家已在保定繁衍数代，成为当地的名门望族。</p>
<p>如今，张氏家族已传承至第6代，族人遍布全国各地。但无论走多远，曲阜永远是我们的根。</p>
<p><b>寻根问祖，不忘根本。这是我们张氏家族传承数百年的信念。</b></p>',
'1370-01-01', 'FAMILY', 'PUBLISHED', 89, 23, 1562, '河北保定', @user_dehou, DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY));

SET @post_dehou_1 = LAST_INSERT_ID();

-- 张德厚的动态2: 祠堂修缮记
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at, updated_at) VALUES
(@user_dehou, @member_dehou, @cat_family_story, 'IMAGE',
'张氏祠堂修缮记',
'<p>张氏祠堂始建于清朝乾隆年间，距今已有两百多年历史。2018年，祠堂因年久失修，部分屋顶出现漏雨，墙体也有裂缝。</p>
<p>作为族长，我责无旁贷。经族中商议，决定筹集资金进行修缮。族人们积极响应，共筹得善款三十余万元。</p>
<p>修缮工程历时半年，请来了专业的古建修复团队。在保持原有风貌的前提下，对祠堂进行了全面修复。</p>
<p>2020年清明，修缮一新的祠堂迎来了祭祖大典。看着祠堂重现昔日光彩，心中感慨万千。</p>',
'2020-04-04', 'FAMILY', 'PUBLISHED', 67, 15, 987, '河北保定', @user_dehou, DATE_SUB(NOW(), INTERVAL 25 DAY), DATE_SUB(NOW(), INTERVAL 25 DAY));

SET @post_dehou_2 = LAST_INSERT_ID();

-- 张德厚的动态3: 清明祭祖
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at, updated_at) VALUES
(@user_dehou, @member_dehou, @cat_important_event, 'IMAGE',
'2024年清明祭祖大典',
'<p>又是一年清明时。今年的祭祖大典格外隆重，来自全国各地的族人齐聚保定，共襄盛举。</p>
<p>祭祖仪式按照传统礼制进行：敬香、献花、诵读祭文、三叩首。每一个环节都庄严肃穆，令人肃然起敬。</p>
<p>看到年轻一代的族人认真参与祭祖，心中甚是欣慰。家族文化的传承，就在于这一代又一代人的坚守。</p>
<p>祭文有云："慎终追远，民德归厚。祖德流芳，世代传承。"愿我张氏家族，枝繁叶茂，世代兴旺。</p>',
'2024-04-04', 'FAMILY', 'PUBLISHED', 102, 31, 2134, '河北保定张氏祠堂', @user_dehou, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY));

SET @post_dehou_3 = LAST_INSERT_ID();

-- 张德厚的动态4: 祖训家规
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at, updated_at) VALUES
(@user_dehou, @member_dehou, @cat_family_rules, 'TEXT',
'张氏祖训',
'<p>张氏祖训，传自先祖守义公，世代相传，至今仍有现实意义：</p>
<p><b>一曰孝悌：</b>孝顺父母，敬爱兄长，此为立身之本。</p>
<p><b>二曰忠信：</b>忠于国家，信于朋友，此为处世之道。</p>
<p><b>三曰勤俭：</b>勤劳致富，节俭持家，此为兴家之基。</p>
<p><b>四曰读书：</b>读书明理，知行合一，此为成才之径。</p>
<p><b>五曰睦邻：</b>和睦乡邻，守望相助，此为安身之法。</p>
<p>此五条祖训，字字珠玑，望族人铭记于心，践行于行。</p>',
'1995-06-15', 'FAMILY', 'PUBLISHED', 156, 42, 3256, '河北保定', @user_dehou, DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY));

SET @post_dehou_4 = LAST_INSERT_ID();

-- 张德厚的动态5: 老照片
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at, updated_at) VALUES
(@user_dehou, @member_dehou, @cat_photo_wall, 'IMAGE',
'老照片里的家族记忆',
'<p>整理旧物时，发现了几张珍贵的老照片。这些照片记录了家族不同时期的面貌，是家族历史的重要见证。</p>
<p>第一张是祖父张守义公的遗像，摄于民国初年。照片中的祖父身着长衫，面容慈祥。</p>
<p>第二张是1958年全家福，那时父亲张文博还在世，一家人围坐在老宅院子里，其乐融融。</p>
<p>第三张是1980年修缮祠堂时的合影，族人们齐心协力，让人感动。</p>
<p>这些老照片，是家族最宝贵的财富。我已将它们数字化保存，希望后代子孙能够看到。</p>',
'1958-02-14', 'FAMILY', 'PUBLISHED', 78, 18, 1456, '河北保定', @user_dehou, DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY));

SET @post_dehou_5 = LAST_INSERT_ID();

-- 张德厚的动态6: 回忆录
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at, updated_at) VALUES
(@user_dehou, @member_dehou, @cat_life_log, 'TEXT',
'我的军旅岁月',
'<p>1969年，我18岁，响应国家号召，参军入伍。那是改变我一生的决定。</p>
<p>我被分配到西北边防部队，条件艰苦，但意志坚定。在部队的8年里，我学会了坚强、纪律和责任。</p>
<p>还记得第一次实弹射击时的紧张，第一次野外拉练时的疲惫，第一次立功受奖时的激动。</p>
<p>部队是我人生的大学校，在那里学到的东西，受益终生。</p>
<p>1977年转业回乡，我将部队的作风带到了工作中，做了一名人民教师。教书育人的30年里，我始终铭记："学高为师，身正为范。"</p>',
'1969-03-01', 'FAMILY', 'PUBLISHED', 95, 27, 1876, '河北保定', @user_dehou, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY));

SET @post_dehou_6 = LAST_INSERT_ID();


-- ================================================
-- 5. 初始化张建国的动态内容 (中年 - 侧重家庭生活记录)
-- ================================================

-- 张建国的动态1: 女儿毕业典礼
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at, updated_at) VALUES
(@user_jianguo, @member_jianguo, @cat_photo_wall, 'IMAGE',
'女儿的大学毕业典礼',
'<p>今天，女儿雨桐大学毕业了！看着她在台上穿着学士服的样子，我的眼眶湿润了。</p>
<p>还记得18年前，她刚出生时那么小一点，现在已经是亭亭玉立的大姑娘了。</p>
<p>妻子美华在旁边哭得比我还厉害，说"我们的女儿长大了"。</p>
<p>雨桐，爸爸为你骄傲！愿你在未来的道路上，勇敢追梦，不忘初心。</p>
<p>今天是我们全家的节日，晚上去吃了大餐庆祝！</p>',
'2024-06-20', 'FAMILY', 'PUBLISHED', 56, 18, 892, '北京', @user_jianguo, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY));

SET @post_jianguo_1 = LAST_INSERT_ID();

-- 张建国的动态2: 周末郊游
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at, updated_at) VALUES
(@user_jianguo, @member_jianguo, @cat_photo_wall, 'IMAGE',
'周末一家人去郊游',
'<p>难得的周末，天气晴朗。带着妻子和女儿去了郊外的湿地公园。</p>
<p>春天的湿地真美，到处都是花。女儿拿着相机不停地拍照，比我拍得还好。</p>
<p>我们在湖边搭了帐篷，野餐、放风筝、钓鱼。简单的一天，但很幸福。</p>
<p>工作再忙，也要抽出时间陪伴家人。因为陪伴，才是最长情的告白。</p>',
'2024-04-13', 'FAMILY', 'PUBLISHED', 42, 12, 654, '保定湿地公园', @user_jianguo, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY));

SET @post_jianguo_2 = LAST_INSERT_ID();

-- 张建国的动态3: 结婚纪念日
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at, updated_at) VALUES
(@user_jianguo, @member_jianguo, @cat_life_log, 'TEXT',
'结婚16周年纪念日',
'<p>今天是我和美华结婚16周年纪念日。</p>
<p>16年，说长不长，说短不短。我们一起经历了买房、生孩子、孩子上学……平凡但充实。</p>
<p>美华是个好妻子、好母亲。她为了这个家付出了很多，但从不抱怨。</p>
<p>晚上带她去吃了当年恋爱时常去的那家小餐馆，味道还是那个味道。</p>
<p>美华，谢谢你16年的陪伴。未来的日子，我们继续一起走。</p>',
'2024-05-01', 'FAMILY', 'PUBLISHED', 38, 9, 432, '保定', @user_jianguo, DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 12 DAY));

SET @post_jianguo_3 = LAST_INSERT_ID();

-- 张建国的动态4: 家族聚会
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at, updated_at) VALUES
(@user_jianguo, @member_jianguo, @cat_family_story, 'IMAGE',
'春节家族大聚会',
'<p>今年春节，家族 members 从各地赶回来团聚。大伯张德厚主持了祭祖仪式，全家人一起吃了团圆饭。</p>
<p>饭桌上，大伯讲了很多家族的故事，年轻一代听得很认真。看到家族文化在传承，心里很踏实。</p>
<p>饭后大家一起拍了全家福，这是近年来最齐的一次。</p>
<p>家和万事兴。希望张氏家族越来越好！</p>',
'2024-02-10', 'FAMILY', 'PUBLISHED', 45, 14, 789, '河北保定', @user_jianguo, DATE_SUB(NOW(), INTERVAL 45 DAY), DATE_SUB(NOW(), INTERVAL 45 DAY));

SET @post_jianguo_4 = LAST_INSERT_ID();

-- 张建国的动态5: 工作感悟
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, created_by, created_at, updated_at) VALUES
(@user_jianguo, @member_jianguo, @cat_mood_diary, 'TEXT',
'工作中的小感悟',
'<p>今年升任部门经理已经一年了。最大的感受是：管理不是管人，而是带人。</p>
<p>以前做技术的时候，觉得把事做好就行。现在带团队才明白，让每个人都发挥所长，才是管理的真谛。</p>
<p>这和家庭其实是一个道理。家长不是"管"着家人，而是用心经营这个家。</p>
<p>工作和家庭，道理相通。做好一个，另一个也不会差。</p>',
'2024-03-15', 'FAMILY', 'PUBLISHED', 29, 7, 345, '保定', @user_jianguo, DATE_SUB(NOW(), INTERVAL 22 DAY), DATE_SUB(NOW(), INTERVAL 22 DAY));

SET @post_jianguo_5 = LAST_INSERT_ID();


-- ================================================
-- 6. 初始化张晓明的动态内容 (青年 - 侧重旅行见闻和兴趣)
-- ================================================

-- 张晓明的动态1: 西藏自驾Vlog
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at, updated_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_video_collection, 'VIDEO',
'西藏自驾Vlog - 川藏线全记录',
'<p>历时12天，从成都出发，经318国道到达拉萨，全程2140公里。</p>
<p>这趟旅程，是我大学期间最疯狂的决定，也是最正确的决定。</p>
<p>一路上，看到了雪山、草原、峡谷、湖泊。翻越了14座海拔4000米以上的山口。</p>
<p>在理塘遇到了藏族牧民，在他们的帐篷里喝酥油茶，听他们讲草原上的故事。</p>
<p>在怒江72拐，体会到了什么叫"山路十八弯"。</p>
<p>最终到达布达拉宫的那一刻，觉得一切辛苦都值得了。</p>
<p>完整Vlog已上传，点击观看我的西藏之旅！</p>',
'2024-07-15', 'PUBLIC', 'PUBLISHED', 128, 35, 8956, '西藏拉萨', '激动', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 14 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY));

SET @post_xiaoming_1 = LAST_INSERT_ID();

-- 张晓明的动态2: 上海夜景街拍
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at, updated_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_photo_wall, 'IMAGE',
'城市街拍 - 上海的夜',
'<p>周末去上海参加了摄影展，顺便拍了一组夜景。</p>
<p>外滩的夜景真的太美了。黄浦江两岸，一边是百年历史的万国建筑群，一边是现代化的陆家嘴天际线。历史与现代，在这条江上交相辉映。</p>
<p>这次拍摄用了新的广角镜头，效果非常棒。后期调了青橙色调，大家看看怎么样？</p>
<p>一共拍了9张，精选了这组分享给大家。</p>',
'2024-06-01', 'PUBLIC', 'PUBLISHED', 95, 21, 3456, '上海外滩', '满足', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY));

SET @post_xiaoming_2 = LAST_INSERT_ID();

-- 张晓明的动态3: 编程竞赛
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at, updated_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_important_event, 'TEXT',
'程序设计竞赛银奖！',
'<p>太开心了！今年的全国大学生程序设计竞赛，我们团队拿到了银奖！</p>
<p>比赛准备了整整一个学期。每周三次训练，每次到深夜。刷题刷到看到代码就想吐……</p>
<p>比赛当天，5个小时做了8道题。最后一题到最后10分钟才AC，真的是心跳加速。</p>
<p>感谢队友们的努力，也感谢指导老师的付出。</p>
<p>不过银奖不是终点，明年还要冲击金奖！加油！</p>',
'2024-05-20', 'FAMILY', 'PUBLISHED', 87, 23, 2345, '杭州', '兴奋', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY));

SET @post_xiaoming_3 = LAST_INSERT_ID();

-- 张晓明的动态4: 美食分享
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at, updated_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_mood_diary, 'IMAGE',
'成都的美食之旅',
'<p>去成都吃了好多好吃的！火锅、串串香、担担面、钟水饺、龙抄手、兔头……</p>
<p>成都真的是一座来了就不想走的城市，不仅因为好吃，还因为那种悠闲的生活态度。</p>
<p>在宽窄巷子喝了一下午的茶，看街头艺人表演，这就是向往的生活啊。</p>
<p>推荐几家我吃过觉得特别棒的店，去成都的同学可以参考~</p>',
'2024-07-10', 'PUBLIC', 'PUBLISHED', 76, 19, 2890, '四川成都', '开心', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 16 DAY), DATE_SUB(NOW(), INTERVAL 16 DAY));

SET @post_xiaoming_4 = LAST_INSERT_ID();

-- 张晓明的动态5: 校园生活
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at, updated_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_life_log, 'IMAGE',
'校园里的那棵银杏树',
'<p>图书馆门前那棵银杏树，又到了金黄的季节。</p>
<p>大一刚来的时候，觉得它很普通。现在大三了，才发现它一年四季都有不同的美。</p>
<p>春天嫩绿，夏天浓荫，秋天金黄，冬天挺拔。就像大学生活一样，每个阶段都有不同的精彩。</p>
<p>拍了组照片记录它最美的时刻。等毕业了再回来看它，不知道是什么感觉。</p>',
'2024-10-15', 'PUBLIC', 'PUBLISHED', 43, 8, 1234, '北京科技大学', '感慨', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY));

SET @post_xiaoming_5 = LAST_INSERT_ID();

-- 张晓明的动态6: 骑行日记
INSERT INTO t_timeline_post (user_id, member_id, category_id, post_type, title, content, event_date, visibility, status, like_count, comment_count, view_count, location, mood, created_by, created_at, updated_at) VALUES
(@user_xiaoming, @member_xiaoming, @cat_life_log, 'TEXT',
'环青海湖骑行日记',
'<p>Day 1: 西宁出发，到西海镇，80公里。腿已经快废了，但看到青海湖的那一刻，值了。</p>
<p>Day 2: 沿湖南岸骑行，100公里。遇到了一群藏野驴，超级可爱！</p>
<p>Day 3: 环湖西路，120公里。遇到了暴雨，躲在牧民帐篷里避雨。牧民大叔热情地请我们喝酥油茶。</p>
<p>Day 4: 完成环湖，回到起点。全程360公里，历时4天。</p>
<p>骑行最大的收获不是看到了多美的风景，而是发现自己比想象中更强大。</p>',
'2024-08-20', 'PUBLIC', 'PUBLISHED', 112, 28, 5678, '青海湖', '自豪', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY));

SET @post_xiaoming_6 = LAST_INSERT_ID();


-- ================================================
-- 7. 初始化动态媒体数据 (t_post_media)
-- ================================================

-- 张德厚的媒体
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
(@post_dehou_5, 'IMAGE', 'https://example.com/media/temple_1980.jpg', 'https://example.com/media/thumbs/temple_1980.jpg', '1980修缮祠堂合影.jpg', 789012, 1000, 800, 3, 0, DATE_SUB(NOW(), INTERVAL 15 DAY));

-- 张建国的媒体
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
(@post_jianguo_4, 'IMAGE', 'https://example.com/media/reunion_dinner.jpg', 'https://example.com/media/thumbs/reunion_dinner.jpg', '团圆饭.jpg', 2567890, 3400, 2200, 3, 0, DATE_SUB(NOW(), INTERVAL 45 DAY));

-- 张晓明的媒体
INSERT INTO t_post_media (post_id, media_type, media_url, thumb_url, original_name, file_size, width, height, duration, sort_order, is_cover, created_at) VALUES
(@post_xiaoming_1, 'VIDEO', 'https://example.com/media/tibet_vlog_full.mp4', 'https://example.com/media/thumbs/potala_palace.jpg', '西藏自驾Vlog.mp4', 524288000, 1920, 1080, 932, 1, 1, DATE_SUB(NOW(), INTERVAL 14 DAY)),
(@post_xiaoming_1, 'IMAGE', 'https://example.com/media/potala_palace.jpg', 'https://example.com/media/thumbs/potala_palace.jpg', '布达拉宫.jpg', 2345678, 3200, 2100, 0, 2, 0, DATE_SUB(NOW(), INTERVAL 14 DAY)),

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
(@post_xiaoming_6, 'IMAGE', 'https://example.com/media/qinghai_lake_3.jpg', 'https://example.com/media/thumbs/qinghai_lake_3.jpg', '牧民帐篷.jpg', 2456789, 3400, 2200, 0, 3, 0, DATE_SUB(NOW(), INTERVAL 5 DAY));


-- ================================================
-- 8. 初始化话题关联 (t_topic_post)
-- ================================================

INSERT INTO t_topic_post (topic_id, post_id, created_at) VALUES
(@topic_family_history, @post_dehou_1, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@topic_family_history, @post_dehou_5, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(@topic_family_rules, @post_dehou_4, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(@topic_traditional_festival, @post_dehou_3, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(@topic_traditional_festival, @post_jianguo_4, DATE_SUB(NOW(), INTERVAL 45 DAY)),
(@topic_family_gathering, @post_jianguo_4, DATE_SUB(NOW(), INTERVAL 45 DAY)),
(@topic_family_gathering, @post_dehou_3, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(@topic_travel, @post_xiaoming_1, DATE_SUB(NOW(), INTERVAL 14 DAY)),
(@topic_travel, @post_xiaoming_6, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(@topic_food, @post_xiaoming_4, DATE_SUB(NOW(), INTERVAL 16 DAY));


-- ================================================
-- 9. 初始化用户兴趣标签 (t_user_interest)
-- ================================================

-- 张德厚的兴趣
INSERT INTO t_user_interest (user_id, interest_tag, interest_level, sort_order, created_at) VALUES
(@user_dehou, '#家族历史#', 3, 1, NOW()),
(@user_dehou, '#家训家规#', 3, 2, NOW()),
(@user_dehou, '#传统文化#', 3, 3, NOW()),
(@user_dehou, '#书法#', 2, 4, NOW()),
(@user_dehou, '#园艺#', 1, 5, NOW());

-- 张建国的兴趣
INSERT INTO t_user_interest (user_id, interest_tag, interest_level, sort_order, created_at) VALUES
(@user_jianguo, '#家庭生活#', 3, 1, NOW()),
(@user_jianguo, '#子女教育#', 2, 2, NOW()),
(@user_jianguo, '#烹饪#', 2, 3, NOW()),
(@user_jianguo, '#钓鱼#', 1, 4, NOW());

-- 张晓明的兴趣
INSERT INTO t_user_interest (user_id, interest_tag, interest_level, sort_order, created_at) VALUES
(@user_xiaoming, '#旅行#', 3, 1, NOW()),
(@user_xiaoming, '#摄影#', 3, 2, NOW()),
(@user_xiaoming, '#编程#', 3, 3, NOW()),
(@user_xiaoming, '#美食#', 2, 4, NOW()),
(@user_xiaoming, '#骑行#', 2, 5, NOW()),
(@user_xiaoming, '#音乐#', 1, 6, NOW());


-- ================================================
-- 10. 初始化隐私设置 (t_privacy_setting)
-- ================================================

-- 张德厚的隐私设置 (开放家族内部)
INSERT INTO t_privacy_setting (user_id, setting_key, setting_value, scope, created_at) VALUES
(@user_dehou, 'profile_visibility', 'family', 'FAMILY', NOW()),
(@user_dehou, 'post_default_visibility', 'family', 'FAMILY', NOW()),
(@user_dehou, 'allow_guestbook', 'true', 'FAMILY', NOW()),
(@user_dehou, 'allow_private_message', 'true', 'FAMILY', NOW()),
(@user_dehou, 'allow_comment', 'true', 'FAMILY', NOW()),
(@user_dehou, 'show_birth_info', 'true', 'FAMILY', NOW()),
(@user_dehou, 'show_occupation', 'true', 'FAMILY', NOW()),
(@user_dehou, 'allow_tag_in_post', 'true', 'FAMILY', NOW());

-- 张建国的隐私设置 (半开放)
INSERT INTO t_privacy_setting (user_id, setting_key, setting_value, scope, created_at) VALUES
(@user_jianguo, 'profile_visibility', 'family', 'FAMILY', NOW()),
(@user_jianguo, 'post_default_visibility', 'family', 'FAMILY', NOW()),
(@user_jianguo, 'allow_guestbook', 'true', 'FAMILY', NOW()),
(@user_jianguo, 'allow_private_message', 'true', 'FAMILY', NOW()),
(@user_jianguo, 'allow_comment', 'true', 'FAMILY', NOW()),
(@user_jianguo, 'show_birth_info', 'false', 'PRIVATE', NOW()),
(@user_jianguo, 'show_occupation', 'true', 'FAMILY', NOW()),
(@user_jianguo, 'allow_tag_in_post', 'true', 'FAMILY', NOW());

-- 张晓明的隐私设置 (相对公开)
INSERT INTO t_privacy_setting (user_id, setting_key, setting_value, scope, created_at) VALUES
(@user_xiaoming, 'profile_visibility', 'public', 'PUBLIC', NOW()),
(@user_xiaoming, 'post_default_visibility', 'public', 'PUBLIC', NOW()),
(@user_xiaoming, 'allow_guestbook', 'true', 'FAMILY', NOW()),
(@user_xiaoming, 'allow_private_message', 'true', 'FAMILY', NOW()),
(@user_xiaoming, 'allow_comment', 'true', 'FAMILY', NOW()),
(@user_xiaoming, 'show_birth_info', 'true', 'PUBLIC', NOW()),
(@user_xiaoming, 'show_occupation', 'true', 'PUBLIC', NOW()),
(@user_xiaoming, 'allow_tag_in_post', 'true', 'FAMILY', NOW());


-- ================================================
-- 11. 初始化评论数据 (t_comment)
-- ================================================

-- 评论张德厚的"张氏家族起源考"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_1, @post_dehou_1, NULL, NULL, @user_jianguo, NULL, '大伯这篇文章写得太好了！作为张家人，我为我们的家族历史感到自豪。', 12, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 29 DAY)),
('POST', @post_dehou_1, @post_dehou_1, NULL, NULL, @user_xiaoming, NULL, '看了大伯的文章，突然觉得自己对家族的了解太少了。我也要开始记录自己的故事！', 8, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 28 DAY)),
('POST', @post_dehou_1, @post_dehou_1, NULL, NULL, @user_dehou, NULL, '守义公从曲阜到保定，这条路走了六百年。希望后人不要忘记自己的根在哪里。', 25, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 27 DAY));

SET @cmt_dehou_1_1 = (SELECT id FROM t_comment WHERE post_id = @post_dehou_1 AND user_id = @user_jianguo LIMIT 1);
SET @cmt_dehou_1_2 = (SELECT id FROM t_comment WHERE post_id = @post_dehou_1 AND user_id = @user_xiaoming LIMIT 1);
SET @cmt_dehou_1_3 = (SELECT id FROM t_comment WHERE post_id = @post_dehou_1 AND user_id = @user_dehou LIMIT 1);

-- 回复张德厚的评论
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cmt_dehou_1_1, @post_dehou_1, @cmt_dehou_1_1, @cmt_dehou_1_1, @user_dehou, @user_jianguo, '建国说得对，我们每一个张家人都应该了解家族的历史，这样才能知道我们从哪里来。', 5, 1, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 26 DAY)),
('COMMENT', @cmt_dehou_1_2, @post_dehou_1, @cmt_dehou_1_2, @cmt_dehou_1_2, @user_dehou, @user_xiaoming, '小明，你有这份心很好。年轻人多了解家族历史，不是负担，而是财富。', 7, 1, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 26 DAY)),
('COMMENT', @cmt_dehou_1_3, @post_dehou_1, @cmt_dehou_1_3, @cmt_dehou_1_3, @user_jianguo, @user_dehou, '大伯放心，我一定把家族的故事讲给雨桐听，让她也记住自己的根。', 4, 1, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 25 DAY));

-- 评论张德厚的"清明祭祖"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_3, @post_dehou_3, NULL, NULL, @user_jianguo, NULL, '今年清明祭祖办得很隆重，看到这么多族人回来，真的很感动。', 9, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 9 DAY)),
('POST', @post_dehou_3, @post_dehou_3, NULL, NULL, @user_xiaoming, NULL, '第一次参加这么正式的祭祖仪式，虽然有些礼仪不太懂，但能感受到那种庄重的氛围。', 6, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 9 DAY)),
('POST', @post_dehou_3, @post_dehou_3, NULL, NULL, @user_dehou, NULL, '看到年轻一代愿意参与，我很欣慰。家族文化，就靠一代代人传承下去。', 18, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 8 DAY));

SET @cmt_dehou_3_1 = (SELECT id FROM t_comment WHERE post_id = @post_dehou_3 AND user_id = @user_jianguo LIMIT 1);
SET @cmt_dehou_3_3 = (SELECT id FROM t_comment WHERE post_id = @post_dehou_3 AND user_id = @user_dehou LIMIT 1);

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cmt_dehou_3_1, @post_dehou_3, @cmt_dehou_3_1, @cmt_dehou_3_1, @user_dehou, @user_jianguo, '明年清明，希望你能带雨桐回来，让她也感受家族的传统。', 6, 1, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 7 DAY)),
('COMMENT', @cmt_dehou_3_3, @post_dehou_3, @cmt_dehou_3_3, @cmt_dehou_3_3, @user_xiaoming, @user_dehou, '大伯，明年我一定回来参加！', 3, 1, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 6 DAY));

-- 评论张德厚的"祖训家规"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_4, @post_dehou_4, NULL, NULL, @user_jianguo, NULL, '这五条祖训，每一条都很有道理。特别是"勤俭"和"读书"，是我们家的家风。', 15, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 19 DAY)),
('POST', @post_dehou_4, @post_dehou_4, NULL, NULL, @user_xiaoming, NULL, '祖父的祖训用现在的话说，就是"做人做事"的准则。虽然时代变了，但道理没变。', 11, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 18 DAY));

-- 评论张德厚的"老照片"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_5, @post_dehou_5, NULL, NULL, @user_jianguo, NULL, '1958年的全家福！我看到了爷爷，那时候我还小，对那张照片没印象了。谢谢大伯保存得这么好。', 8, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 14 DAY)),
('POST', @post_dehou_5, @post_dehou_5, NULL, NULL, @user_xiaoming, NULL, '这些老照片太珍贵了！建议大伯做一个电子相册，分享给所有族人。', 13, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 13 DAY));

SET @cmt_dehou_5_2 = (SELECT id FROM t_comment WHERE post_id = @post_dehou_5 AND user_id = @user_xiaoming LIMIT 1);

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cmt_dehou_5_2, @post_dehou_5, @cmt_dehou_5_2, @cmt_dehou_5_2, @user_dehou, @user_xiaoming, '好主意！小明你懂摄影，要不你来帮忙做？', 5, 1, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 12 DAY)),
('COMMENT', @cmt_dehou_5_2, @post_dehou_5, @cmt_dehou_5_2, @cmt_dehou_5_2, @user_xiaoming, @user_dehou, '没问题，大伯！交给我，我来整理和修图。', 7, 2, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 11 DAY));

-- 评论张德厚的"军旅岁月"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_dehou_6, @post_dehou_6, NULL, NULL, @user_jianguo, NULL, '大伯的军旅经历真让人敬佩。那个年代的人，真的能吃苦。', 6, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 4 DAY));

-- 评论张建国的"女儿毕业典礼"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_jianguo_1, @post_jianguo_1, NULL, NULL, @user_dehou, NULL, '雨桐真棒！我们张家又出了一个大学生，还是本科毕业！这是家族的骄傲。', 14, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 2 DAY)),
('POST', @post_jianguo_1, @post_jianguo_1, NULL, NULL, @user_xiaoming, NULL, '恭喜雨桐姐毕业！我也快了，明年就轮到我了。', 5, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 2 DAY));

SET @cmt_jianguo_1_1 = (SELECT id FROM t_comment WHERE post_id = @post_jianguo_1 AND user_id = @user_dehou LIMIT 1);

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cmt_jianguo_1_1, @post_jianguo_1, @cmt_jianguo_1_1, @cmt_jianguo_1_1, @user_jianguo, @user_dehou, '谢谢大伯！雨桐能有今天，离不开家族的关心和支持。', 8, 1, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 1 DAY));

-- 评论张建国的"周末郊游"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_jianguo_2, @post_jianguo_2, NULL, NULL, @user_dehou, NULL, '一家人出去走走挺好。工作再忙，也要陪陪家人。', 4, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 6 DAY));

-- 评论张建国的"结婚纪念日"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_jianguo_3, @post_jianguo_3, NULL, NULL, @user_dehou, NULL, '16年了，你们夫妻一直和和睦睦，这是家族的福气。祝福你们！', 7, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 11 DAY));

-- 评论张晓明的"西藏自驾Vlog"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_1, @post_xiaoming_1, NULL, NULL, @user_dehou, NULL, '年轻人有这个勇气和能力去西藏，很好。但出门在外，一定要注意安全。', 9, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 13 DAY)),
('POST', @post_xiaoming_1, @post_xiaoming_1, NULL, NULL, @user_jianguo, NULL, '太厉害了！视频拍得真好。小明，你以后可以做个旅游博主了。', 7, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 12 DAY)),
('POST', @post_xiaoming_1, @post_xiaoming_1, NULL, NULL, @user_xiaoming, NULL, '谢谢大伯和叔叔的关心！这次旅程让我成长了很多，也更懂得了珍惜。', 5, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 12 DAY));

SET @cmt_xiaoming_1_2 = (SELECT id FROM t_comment WHERE post_id = @post_xiaoming_1 AND user_id = @user_jianguo LIMIT 1);

INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('COMMENT', @cmt_xiaoming_1_2, @post_xiaoming_1, @cmt_xiaoming_1_2, @cmt_xiaoming_1_2, @user_xiaoming, @user_jianguo, '哈哈，叔叔过奖了！不过旅游博主可能养不活我，还是老老实实写代码吧。', 8, 1, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 11 DAY));

-- 评论张晓明的"上海夜景街拍"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_2, @post_xiaoming_2, NULL, NULL, @user_jianguo, NULL, '拍得真好看！这张青橙色调的特别有感觉。小明你摄影技术进步很大啊。', 6, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 29 DAY));

-- 评论张晓明的"编程竞赛"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_3, @post_xiaoming_3, NULL, NULL, @user_dehou, NULL, '银奖已经很厉害了！小明是我们张家的骄傲。继续加油！', 11, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 19 DAY)),
('POST', @post_xiaoming_3, @post_xiaoming_3, NULL, NULL, @user_jianguo, NULL, '太棒了小明！比叔叔当年强多了。明年继续冲金奖！', 8, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 18 DAY));

-- 评论张晓明的"美食分享"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_4, @post_xiaoming_4, NULL, NULL, @user_jianguo, NULL, '看饿了！成都确实是个美食天堂。下次带美华和雨桐一起去。', 4, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 15 DAY));

-- 评论张晓明的"校园银杏树"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_5, @post_xiaoming_5, NULL, NULL, @user_jianguo, NULL, '拍得真好！特别是秋天那张，金黄的银杏叶太美了。', 3, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 1 DAY));

-- 评论张晓明的"环青海湖骑行"
INSERT INTO t_comment (target_type, target_id, post_id, parent_id, root_id, user_id, reply_to_user_id, content, like_count, depth, status, created_by, created_at) VALUES
('POST', @post_xiaoming_6, @post_xiaoming_6, NULL, NULL, @user_dehou, NULL, '360公里，4天！小明，你这身体素质真好。年轻人就应该多锻炼。', 8, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 4 DAY)),
('POST', @post_xiaoming_6, @post_xiaoming_6, NULL, NULL, @user_jianguo, NULL, '太牛了！360公里骑行，叔叔佩服你。不过以后出去一定要注意安全，带够装备。', 5, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 3 DAY));


-- ================================================
-- 12. 初始化留言板数据 (t_message_board)
-- ================================================

-- 张德厚主页的留言
INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_dehou, @user_jianguo, NULL, '大伯，最近身体还好吧？天气转凉了，注意保暖。有空我去看您。', 3, 1, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(@user_dehou, @user_xiaoming, NULL, '爷爷（大伯公）好！我在北京挺好的，您注意身体哦。等放假了回去看您！', 5, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(@user_dehou, @user_jianguo, NULL, '大伯，族谱电子版的事我已经跟小明说了，他来帮忙整理。您有什么需要随时吩咐。', 2, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 5 DAY));

SET @msg_dehou_1 = (SELECT id FROM t_message_board WHERE owner_user_id = @user_dehou AND sender_id = @user_jianguo AND parent_id IS NULL ORDER BY created_at DESC LIMIT 1);

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_dehou, @user_dehou, @msg_dehou_1, '建国有心了，我身体还好。你们工作忙，不用老惦记我。周末带家人来吃饭。', 4, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 14 DAY));

-- 张建国主页的留言
INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_jianguo, @user_dehou, NULL, '建国，你工作上要注意身体，别太累。家里的事多和美华商量。', 4, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(@user_jianguo, @user_xiaoming, NULL, '建国叔，恭喜雨桐姐毕业！改天请吃饭庆祝啊！', 3, 1, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@user_jianguo, @user_dehou, NULL, '建国，清明祭祖的事你多费心，帮忙组织一下族人。', 2, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 25 DAY));

SET @msg_jianguo_2 = (SELECT id FROM t_message_board WHERE owner_user_id = @user_jianguo AND sender_id = @user_xiaoming AND parent_id IS NULL ORDER BY created_at DESC LIMIT 1);

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_jianguo, @user_jianguo, @msg_jianguo_2, '没问题小明！一定请，你想吃什么？', 2, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 1 DAY));

-- 张晓明主页的留言
INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_xiaoming, @user_dehou, NULL, '小明，你在北京好好学习，注意安全。放假了就回家，别老在外面跑。', 6, 0, 'VISIBLE', @user_dehou, DATE_SUB(NOW(), INTERVAL 8 DAY)),
(@user_xiaoming, @user_jianguo, NULL, '小明，竞赛拿奖了，叔叔替你高兴！继续保持，明年冲击金奖！', 4, 0, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 18 DAY)),
(@user_xiaoming, @user_jianguo, NULL, '小明，你的照片拍得越来越好了！下次家族活动，你来负责拍照吧。', 3, 1, 'VISIBLE', @user_jianguo, DATE_SUB(NOW(), INTERVAL 3 DAY));

SET @msg_xiaoming_3 = (SELECT id FROM t_message_board WHERE owner_user_id = @user_xiaoming AND sender_id = @user_jianguo ORDER BY created_at DESC LIMIT 1);

INSERT INTO t_message_board (owner_user_id, sender_id, parent_id, content, like_count, reply_count, status, created_by, created_at) VALUES
(@user_xiaoming, @user_xiaoming, @msg_xiaoming_3, '好嘞叔叔！没问题，包在我身上！', 2, 0, 'VISIBLE', @user_xiaoming, DATE_SUB(NOW(), INTERVAL 2 DAY));


-- ================================================
-- 13. 初始化点赞记录 (t_like_record)
-- ================================================

-- 张建国点赞张德厚的动态
INSERT INTO t_like_record (target_type, target_id, user_id, status, created_at) VALUES
('POST', @post_dehou_1, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 29 DAY)),
('POST', @post_dehou_3, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 9 DAY)),
('POST', @post_dehou_4, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 19 DAY)),
('POST', @post_dehou_5, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 14 DAY)),
('POST', @post_dehou_6, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 4 DAY));

-- 张晓明点赞张德厚的动态
INSERT INTO t_like_record (target_type, target_id, user_id, status, created_at) VALUES
('POST', @post_dehou_1, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 28 DAY)),
('POST', @post_dehou_3, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 9 DAY)),
('POST', @post_dehou_4, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 18 DAY)),
('POST', @post_dehou_5, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 13 DAY));

-- 张德厚点赞张建国和张晓明的动态
INSERT INTO t_like_record (target_type, target_id, user_id, status, created_at) VALUES
('POST', @post_jianguo_1, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 2 DAY)),
('POST', @post_jianguo_2, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 6 DAY)),
('POST', @post_jianguo_3, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 11 DAY)),
('POST', @post_jianguo_4, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 44 DAY)),
('POST', @post_xiaoming_1, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 13 DAY)),
('POST', @post_xiaoming_3, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 19 DAY)),
('POST', @post_xiaoming_6, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 4 DAY));

-- 张建国点赞张晓明的动态
INSERT INTO t_like_record (target_type, target_id, user_id, status, created_at) VALUES
('POST', @post_xiaoming_1, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 12 DAY)),
('POST', @post_xiaoming_2, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 29 DAY)),
('POST', @post_xiaoming_3, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 18 DAY)),
('POST', @post_xiaoming_4, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 15 DAY)),
('POST', @post_xiaoming_5, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('POST', @post_xiaoming_6, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 3 DAY));

-- 张晓明点赞张建国的动态
INSERT INTO t_like_record (target_type, target_id, user_id, status, created_at) VALUES
('POST', @post_jianguo_1, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 2 DAY)),
('POST', @post_jianguo_2, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 6 DAY));

-- 评论点赞
INSERT INTO t_like_record (target_type, target_id, user_id, status, created_at) VALUES
('COMMENT', @cmt_dehou_1_3, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 26 DAY)),
('COMMENT', @cmt_dehou_3_3, @user_xiaoming, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 7 DAY)),
('COMMENT', @cmt_jianguo_1_1, @user_dehou, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('COMMENT', @cmt_xiaoming_1_2, @user_jianguo, 'ACTIVE', DATE_SUB(NOW(), INTERVAL 10 DAY));


-- ================================================
-- 14. 初始化通知数据 (t_notification)
-- ================================================

-- 张德厚收到的通知
INSERT INTO t_notification (receiver_id, sender_id, type, target_type, target_id, content, is_read, created_at) VALUES
(@user_dehou, @user_jianguo, 'COMMENT', 'POST', @post_dehou_1, '张建国评论了您的内容 "张氏家族起源考"', 1, DATE_SUB(NOW(), INTERVAL 29 DAY)),
(@user_dehou, @user_xiaoming, 'COMMENT', 'POST', @post_dehou_1, '张晓明评论了您的内容 "张氏家族起源考"', 1, DATE_SUB(NOW(), INTERVAL 28 DAY)),
(@user_dehou, @user_jianguo, 'LIKE', 'POST', @post_dehou_1, '张建国赞了您的内容 "张氏家族起源考"', 1, DATE_SUB(NOW(), INTERVAL 29 DAY)),
(@user_dehou, @user_xiaoming, 'LIKE', 'POST', @post_dehou_1, '张晓明赞了您的内容 "张氏家族起源考"', 1, DATE_SUB(NOW(), INTERVAL 28 DAY)),
(@user_dehou, @user_jianguo, 'COMMENT', 'POST', @post_dehou_3, '张建国评论了您的内容 "2024年清明祭祖大典"', 1, DATE_SUB(NOW(), INTERVAL 9 DAY)),
(@user_dehou, @user_xiaoming, 'COMMENT', 'POST', @post_dehou_3, '张晓明评论了您的内容 "2024年清明祭祖大典"', 1, DATE_SUB(NOW(), INTERVAL 9 DAY)),
(@user_dehou, @user_jianguo, 'MESSAGE_BOARD', NULL, NULL, '张建国在您的主页留言', 1, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(@user_dehou, @user_xiaoming, 'MESSAGE_BOARD', NULL, NULL, '张晓明在您的主页留言', 1, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(@user_dehou, @user_jianguo, 'REPLY', 'COMMENT', @cmt_dehou_1_1, '张建国回复了您的评论', 0, DATE_SUB(NOW(), INTERVAL 25 DAY)),
(@user_dehou, @user_xiaoming, 'REPLY', 'COMMENT', @cmt_dehou_5_2, '张晓明回复了您的评论', 0, NOW());

-- 张建国收到的通知
INSERT INTO t_notification (receiver_id, sender_id, type, target_type, target_id, content, is_read, created_at) VALUES
(@user_jianguo, @user_dehou, 'COMMENT', 'POST', @post_jianguo_1, '张德厚评论了您的内容 "女儿的大学毕业典礼"', 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@user_jianguo, @user_xiaoming, 'COMMENT', 'POST', @post_jianguo_1, '张晓明评论了您的内容 "女儿的大学毕业典礼"', 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@user_jianguo, @user_dehou, 'LIKE', 'POST', @post_jianguo_1, '张德厚赞了您的内容 "女儿的大学毕业典礼"', 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@user_jianguo, @user_dehou, 'COMMENT', 'POST', @post_jianguo_3, '张德厚评论了您的内容 "结婚16周年纪念日"', 1, DATE_SUB(NOW(), INTERVAL 11 DAY)),
(@user_jianguo, @user_dehou, 'MESSAGE_BOARD', NULL, NULL, '张德厚在您的主页留言', 1, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(@user_jianguo, @user_xiaoming, 'MESSAGE_BOARD', NULL, NULL, '张晓明在您的主页留言', 0, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@user_jianguo, @user_dehou, 'AT_MENTION', 'COMMENT', @cmt_dehou_3_1, '张德厚在评论中提到了您', 1, DATE_SUB(NOW(), INTERVAL 7 DAY));

-- 张晓明收到的通知
INSERT INTO t_notification (receiver_id, sender_id, type, target_type, target_id, content, is_read, created_at) VALUES
(@user_xiaoming, @user_dehou, 'COMMENT', 'POST', @post_xiaoming_1, '张德厚评论了您的内容 "西藏自驾Vlog"', 1, DATE_SUB(NOW(), INTERVAL 13 DAY)),
(@user_xiaoming, @user_jianguo, 'COMMENT', 'POST', @post_xiaoming_1, '张建国评论了您的内容 "西藏自驾Vlog"', 1, DATE_SUB(NOW(), INTERVAL 12 DAY)),
(@user_xiaoming, @user_dehou, 'LIKE', 'POST', @post_xiaoming_1, '张德厚赞了您的内容 "西藏自驾Vlog"', 1, DATE_SUB(NOW(), INTERVAL 13 DAY)),
(@user_xiaoming, @user_jianguo, 'LIKE', 'POST', @post_xiaoming_1, '张建国赞了您的内容 "西藏自驾Vlog"', 1, DATE_SUB(NOW(), INTERVAL 12 DAY)),
(@user_xiaoming, @user_dehou, 'COMMENT', 'POST', @post_xiaoming_3, '张德厚评论了您的内容 "程序设计竞赛银奖！"', 1, DATE_SUB(NOW(), INTERVAL 19 DAY)),
(@user_xiaoming, @user_jianguo, 'COMMENT', 'POST', @post_xiaoming_3, '张建国评论了您的内容 "程序设计竞赛银奖！"', 1, DATE_SUB(NOW(), INTERVAL 18 DAY)),
(@user_xiaoming, @user_dehou, 'MESSAGE_BOARD', NULL, NULL, '张德厚在您的主页留言', 1, DATE_SUB(NOW(), INTERVAL 8 DAY)),
(@user_xiaoming, @user_jianguo, 'MESSAGE_BOARD', NULL, NULL, '张建国在您的主页留言', 0, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(@user_xiaoming, @user_jianguo, 'REPLY', 'COMMENT', @cmt_xiaoming_1_2, '张建国回复了您的评论', 1, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(@user_xiaoming, @user_dehou, 'AT_MENTION', 'COMMENT', @cmt_dehou_5_2, '张德厚在评论中提到了您', 0, NOW());


-- ================================================
-- 15. 初始化私信数据 (t_private_message)
-- ================================================

-- 张德厚与张建国之间的私信
INSERT INTO t_private_message (sender_id, receiver_id, content, msg_type, is_read, status, created_by, created_at) VALUES
(@user_dehou, @user_jianguo, '建国，最近工作怎么样？身体还好吧？', 'TEXT', 1, 1, @user_dehou, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(@user_jianguo, @user_dehou, '大伯，我挺好的。工作挺忙的，但还能应付。您身体怎么样？', 'TEXT', 1, 1, @user_jianguo, DATE_SUB(NOW(), INTERVAL 29 DAY)),
(@user_dehou, @user_jianguo, '我还好。就是族谱电子版的事，你跟小明说一下，让他帮忙弄。', 'TEXT', 1, 1, @user_dehou, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(@user_jianguo, @user_dehou, '好的，我跟他说了。他说没问题，等放假了就回去弄。', 'TEXT', 1, 1, @user_jianguo, DATE_SUB(NOW(), INTERVAL 19 DAY)),
(@user_dehou, @user_jianguo, '那就好。周末有空带家人来吃饭。', 'TEXT', 1, 1, @user_dehou, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(@user_jianguo, @user_dehou, '好的大伯，周末我们回去看您。', 'TEXT', 0, 1, @user_jianguo, DATE_SUB(NOW(), INTERVAL 4 DAY));

-- 张建国与张晓明之间的私信
INSERT INTO t_private_message (sender_id, receiver_id, content, msg_type, is_read, status, created_by, created_at) VALUES
(@user_jianguo, @user_xiaoming, '小明，你竞赛拿奖了，太厉害了！叔叔替你高兴。', 'TEXT', 1, 1, @user_jianguo, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(@user_xiaoming, @user_jianguo, '谢谢叔叔！运气好而已，哈哈。', 'TEXT', 1, 1, @user_xiaoming, DATE_SUB(NOW(), INTERVAL 19 DAY)),
(@user_jianguo, @user_xiaoming, '下次家族活动你来拍照吧，你拍的照片好看。', 'TEXT', 1, 1, @user_jianguo, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(@user_xiaoming, @user_jianguo, '没问题叔叔！包在我身上。', 'TEXT', 1, 1, @user_xiaoming, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(@user_jianguo, @user_xiaoming, '雨桐毕业典礼你来了吧？没来太可惜了。', 'TEXT', 0, 1, @user_jianguo, DATE_SUB(NOW(), INTERVAL 1 DAY));


-- ================================================
-- 16. 更新冗余计数
-- ================================================

-- 更新话题计数
UPDATE t_topic SET post_count = 2, participant_count = 2 WHERE id = @topic_family_history;
UPDATE t_topic SET post_count = 1, participant_count = 2 WHERE id = @topic_family_rules;
UPDATE t_topic SET post_count = 2, participant_count = 3 WHERE id = @topic_traditional_festival;
UPDATE t_topic SET post_count = 2, participant_count = 3 WHERE id = @topic_family_gathering;
UPDATE t_topic SET post_count = 2, participant_count = 2 WHERE id = @topic_travel;
UPDATE t_topic SET post_count = 1, participant_count = 2 WHERE id = @topic_food;

-- 更新分类计数
UPDATE t_post_category SET post_count = 3 WHERE id = @cat_family_story;
UPDATE t_post_category SET post_count = 2 WHERE id = @cat_photo_wall;
UPDATE t_post_category SET post_count = 2 WHERE id = @cat_important_event;
UPDATE t_post_category SET post_count = 1 WHERE id = @cat_family_rules;
UPDATE t_post_category SET post_count = 1 WHERE id = @cat_video_collection;
UPDATE t_post_category SET post_count = 2 WHERE id = @cat_life_log;
UPDATE t_post_category SET post_count = 2 WHERE id = @cat_mood_diary;


-- ================================================
-- V2.0 初始化数据完成
-- 统计:
--   示范用户: 3个 (张德厚-族长, 张建国-中年, 张晓明-青年)
--   用户主页档案: 3个
--   动态分类: 6个(系统预置)
--   话题: 6个
--   动态内容: 17个 (张德厚6个, 张建国5个, 张晓明6个)
--   动态媒体: 37个 (图片34个, 视频1个)
--   话题关联: 10个
--   兴趣标签: 14个
--   隐私设置: 24个
--   评论: 30+个
--   点赞记录: 30+个
--   留言: 9+个
--   通知: 27个
--   私信: 11个
-- ================================================
