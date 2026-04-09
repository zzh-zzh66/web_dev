# 开发规范文档

## 1. 开发环境规范

### 1.1 环境配置

| 环境 | 用途 | JDK | 数据库 | Node |
|------|------|-----|--------|------|
| 开发环境 | 本地开发 | 17+ | MySQL 8.0 (Docker) | 18+ |
| 测试环境 | 功能测试 | 17+ | MySQL 8.0 | 18+ |
| 预生产环境 | 上线前验证 | 17+ | MySQL 8.0 | 18+ |
| 生产环境 | 正式运行 | 17+ | MySQL 8.0 主从 | 18+ |

### 1.2 开发工具

| 工具 | 版本 | 用途 |
|------|------|------|
| IDEA | 2023.2+ | Java开发 |
| VS Code | 1.85+ | 前端开发 |
| Git | 2.40+ | 版本控制 |
| Docker Desktop | 4.0+ | 容器化 |
| MySQL Workbench | 8.0+ | 数据库工具 |
| Postman | 10.0+ | API测试 |
| Redis Desktop | 2023+ | Redis客户端 |

## 2. Git工作流规范

### 2.1 分支策略

```
                    release/v1.0
                   /
master ──────────────────────────────────────▶
        \                       /
         feature/US-001 ───────/
              \
               fix/US-001-bug ──▶
```

| 分支类型 | 命名规则 | 合并目标 | 示例 |
|----------|----------|----------|------|
| master | master | - | master |
| release | release/v{version} | master | release/v1.0 |
| feature | feature/{ticket-id}-{desc} | dev | feature/US-001-add-member |
| bugfix | fix/{ticket-id}-{desc} | dev | fix/US-001-fix-login |
| hotfix | hotfix/{ticket-id}-{desc} | master | hotfix/US-002-security |
| dev | dev | master | dev |

### 2.2 分支管理规则

```
1. 所有新功能必须从dev分支创建feature分支
2. feature完成后必须合并回dev分支
3. release分支用于版本发布准备
4. master分支只接受来自dev和hotfix的合并
5. hotfix直接从master创建，合并后删除
6. 分支合并前必须经过代码审查
```

### 2.3 Commit规范

#### 提交信息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Type类型

| 类型 | 说明 | 示例 |
|------|------|------|
| feat | 新功能 | feat(member): 添加成员头像上传功能 |
| fix | Bug修复 | fix(login): 修复登录失败问题 |
| docs | 文档更新 | docs(api): 更新API文档 |
| style | 代码格式 | style(member): 格式化代码 |
| refactor | 重构 | refactor(auth): 重构认证模块 |
| perf | 性能优化 | perf(search): 优化搜索性能 |
| test | 测试相关 | test(member): 添加成员测试用例 |
| chore | 构建/工具 | chore(deps): 升级依赖版本 |
| ci | CI/CD | ci: 添加GitHub Actions配置 |

#### 提交示例

```
feat(member): 添加家庭成员关系映射功能

- 支持建立父子关系
- 支持建立配偶关系
- 支持关系类型校验

Closes #US-001
```

### 2.4 Pull Request规范

```
标题：[Feature] US-001 添加成员管理功能

概述：
本PR实现了家族成员管理的基本CRUD功能...

主要变更：
1. 新增Member实体和相关DTO
2. 实现MemberService服务层
3. 添加MemberController控制器
4. 编写单元测试

测试情况：
- 单元测试覆盖率 80%
- 集成测试通过
- 手动测试通过

影响范围：
- 新增API接口 /api/v1/members/*
- 新增数据库表 t_family_member

审查意见：
@张三 请审查...
@李四 请审查...
```

## 3. 编码规范

### 3.1 Java编码规范

#### 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 类名 | PascalCase | MemberController |
| 方法名 | camelCase | getMemberById |
| 变量名 | camelCase | memberName |
| 常量 | UPPER_SNAKE | MAX_PAGE_SIZE |
| 包名 | lowercase | com.family.genealogy |
| 枚举值 | UPPER_SNAKE | MALE, FEMALE |

#### 类结构顺序

```java
1. 类声明
2. 静态属性
3. 实例属性
4. 构造方法
5. 公共方法
6. 保护方法
7. 私有方法
8. 内部类
```

#### 方法规范

```java
// 推荐：方法参数不超过5个
public MemberDTO getMemberById(Long memberId, String include) {
    // ...
}

// 推荐：返回类型明确，避免返回null
public List<MemberDTO> getChildren(Long parentId) {
    if (parentId == null) {
        return Collections.emptyList();
    }
    // ...
}

// 推荐：使用Optional处理可能为空的情况
public Optional<Member> findById(Long id) {
    return Optional.ofNullable(memberRepository.findById(id));
}
```

### 3.2 前端编码规范

#### Vue组件规范

```vue
<!-- 1. 组件名：PascalCase -->
<template>
  <!-- 2. 模板结构清晰，根元素唯一 -->
  <div class="member-card">
    <!-- 3. 指令按顺序：v-if, v-else, v-for, v-on, v-bind -->
    <div v-if="loading" class="loading">加载中...</div>
    <template v-else>
      <img
        v-for="img in images"
        :key="img.id"
        :src="img.url"
        @click="handleImageClick"
      />
    </template>
  </div>
</template>

<script>
// 4. 按顺序导入
import { ref, computed, onMounted } from 'vue'
import { useMemberStore } from '@/store/member'

// 5. 组件名
export default {
  name: 'MemberCard',
  // 6. Props定义带类型验证
  props: {
    memberId: {
      type: Number,
      required: true
    }
  },
  emits: ['select'],
  setup(props, { emit }) {
    // 7. Composition API逻辑
    const loading = ref(false)
    const member = computed(() => useMemberStore().getMember(props.memberId))

    const handleImageClick = () => {
      emit('select', props.memberId)
    }

    onMounted(async () => {
      loading.value = true
      await useMemberStore().fetchMember(props.memberId)
      loading.value = false
    })

    return {
      loading,
      member,
      handleImageClick
    }
  }
}
</script>

<style scoped>
/* 8. 样式使用scoped */
.member-card {
  padding: 16px;
}
</style>
```

#### 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 组件名 | PascalCase | MemberList.vue |
| 变量 | camelCase | memberList |
| 常量 | UPPER_SNAKE | API_BASE_URL |
| CSS类名 | kebab-case | member-card |
| 路由路径 | kebab-case | /member-list |
| Store模块 | kebab-case | member-store |

### 3.3 SQL规范

```sql
-- 1. 关键字大写
SELECT member_id, name, gender
FROM t_family_member
WHERE family_id = 1 AND status = 1;

-- 2. 表名和字段名使用反引号
SELECT `member_id`, `name`
FROM `t_family_member`;

-- 3. 避免SELECT *
SELECT `member_id`, `name`, `gender`
FROM `t_family_member`;

-- 4. 使用有意义别名
SELECT
    m.member_id AS id,
    m.name AS memberName,
    f.family_name AS familyName
FROM t_family_member m
LEFT JOIN t_family f ON m.family_id = f.family_id;

-- 5. 复杂查询添加注释
-- 查询某家族的所有男性成员
SELECT *
FROM t_family_member
WHERE family_id = 1
  AND gender = 1  -- 1表示男性
ORDER BY generation, birth_date;
```

## 4. API设计规范

### 4.1 URL规范

```
协议://域名/版本/模块/资源/{id}/{子资源}/{动作}

示例：
GET    /api/v1/members              # 获取成员列表
POST   /api/v1/members              # 创建成员
GET    /api/v1/members/{id}         # 获取成员详情
PUT    /api/v1/members/{id}         # 更新成员
DELETE /api/v1/members/{id}         # 删除成员
GET    /api/v1/members/{id}/spouse  # 获取成员配偶
POST   /api/v1/members/{id}/photo   # 上传成员照片
```

### 4.2 版本控制

```
URL路径版本：/api/v1/
Header版本：X-API-Version: 1.0
```

### 4.3 响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": "2026-04-09T12:00:00Z",
  "traceId": "abc123"
}
```

## 5. 代码审查规范

### 5.1 审查清单

| 类别 | 检查项 |
|------|--------|
| 功能 | 代码实现了需求功能 |
| 功能 | 边界条件和异常处理 |
| 功能 | 单元测试覆盖 |
| 性能 | 数据库查询优化 |
| 性能 | 避免N+1查询 |
| 安全 | 输入参数校验 |
| 安全 | SQL注入防护 |
| 安全 | 敏感信息处理 |
| 代码 | 命名规范 |
| 代码 | 代码复杂度 |
| 代码 | 重复代码 |
| 代码 | 注释完整性 |
| 代码 | 日志记录 |

### 5.2 审查标准

| 指标 | 要求 |
|------|------|
| 覆盖率 | 新增代码覆盖 ≥ 80% |
| 圈复杂度 | 方法复杂度 ≤ 10 |
| 重复代码 | 新增代码重复率 < 5% |
| 注释率 | 关键逻辑有注释 |
| 规范符合 | 通过SonarQube扫描 |

### 5.3 审查流程

```
开发者提交PR
    ↓
自动化检查（CI）
  - 编译检查
  - 单元测试
  - 代码扫描
    ↓
代码审查（至少1人）
    ↓
审查通过
    ↓
合并到目标分支
```

## 6. 日志规范

### 6.1 日志级别

| 级别 | 使用场景 |
|------|----------|
| ERROR | 程序异常，影响业务流程 |
| WARN | 潜在问题，需要关注 |
| INFO | 关键业务节点 |
| DEBUG | 调试信息（生产环境关闭） |

### 6.2 日志格式

```java
// Spring Boot日志配置
LOG_PATTERN = "%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n"

// 示例输出
2026-04-09 12:00:00.123 [http-nio-8080-exec-1] INFO  c.f.g.service.MemberService - Member created: id=1001, name=张三
```

### 6.3 日志记录规范

```java
// 推荐：使用@Slf4j
@Slf4j
@Service
public class MemberService {

    public void createMember(MemberDTO dto) {
        try {
            // INFO：业务关键节点
            log.info("Creating member: name={}, familyId={}", dto.getName(), dto.getFamilyId());

            // 业务逻辑...

            log.info("Member created successfully: id={}", memberId);
        } catch (BusinessException e) {
            // WARN：业务异常
            log.warn("Member creation failed: name={}, reason={}", dto.getName(), e.getMessage());
            throw e;
        } catch (Exception e) {
            // ERROR：系统异常
            log.error("Member creation error: name={}", dto.getName(), e);
            throw new SystemException("创建成员失败");
        }
    }
}
```

### 6.4 敏感信息处理

```java
// 禁止记录以下敏感信息
// - 用户密码
// - 身份证号
// - 银行卡号
// - 手机号（脱敏处理）

// 正确示例
log.info("User login: username={}, phone={}", username, phone.replaceAll("(\\d{3})\\d{4}(\\d{4})", "$1****$2"));
```

## 7. 异常处理规范

### 7.1 异常分类

| 异常类型 | 包路径 | 说明 |
|----------|--------|------|
| BusinessException | com.family.genealogy.core.exception | 业务异常 |
| ValidateException | com.family.genealogy.core.exception | 校验异常 |
| ResourceException | com.family.genealogy.core.exception | 资源异常 |
| SystemException | com.family.genealogy.core.exception | 系统异常 |

### 7.2 异常处理

```java
// 全局异常处理
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public Result<?> handleBusinessException(BusinessException e) {
        log.warn("Business exception: code={}, message={}", e.getCode(), e.getMessage());
        return Result.fail(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(ValidateException.class)
    public Result<?> handleValidateException(ValidateException e) {
        log.warn("Validation exception: field={}, message={}", e.getField(), e.getMessage());
        return Result.fail(400, e.getMessage());
    }

    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e) {
        log.error("System error", e);
        return Result.fail(500, "系统繁忙，请稍后重试");
    }
}
```

## 8. 配置管理规范

### 8.1 环境配置优先级

```
命令行参数 > 环境变量 > application-{profile}.yml > application.yml
```

### 8.2 敏感配置

```yaml
# application-prod.yml
spring:
  datasource:
    password: ${DB_PASSWORD}  # 使用环境变量
  redis:
    password: ${REDIS_PASSWORD}

# 禁止在配置文件中明文存储密码
```

### 8.3 多环境配置

```
src/main/resources/
├── application.yml          # 公共配置
├── application-dev.yml       # 开发环境
├── application-test.yml      # 测试环境
├── application-preprod.yml   # 预生产环境
└── application-prod.yml      # 生产环境
```

## 9. 文档更新记录

| 版本 | 日期 | 更新内容 | 作者 |
|------|------|----------|------|
| v1.0 | 2026-04-09 | 初始版本 | AI Assistant |
