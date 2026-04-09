# 测试策略文档

## 1. 测试概述

### 1.1 测试目标

- 确保产品质量符合需求规格
- 缺陷早发现、早修复
- 保障系统稳定性和性能
- 验证用户体验

### 1.2 测试范围

| 测试类型 | 覆盖范围 |
|----------|----------|
| 单元测试 | 核心业务逻辑、工具类 |
| 集成测试 | 模块间交互、API接口 |
| 系统测试 | 完整业务流程 |
| 验收测试 | 用户需求满足度 |

### 1.3 测试环境

| 环境 | 用途 | 数据 |
|------|------|------|
| 开发环境 | 本地单元测试 | 模拟数据 |
| 测试环境 | 功能/集成测试 | 测试数据 |
| 预生产环境 | UAT/性能测试 | 生产脱敏数据 |
| 生产环境 | 最终验证 | 真实数据 |

## 2. 测试类型

### 2.1 单元测试

#### 测试框架

| 框架 | 版本 | 用途 |
|------|------|------|
| JUnit 5 | 5.10.x | Java单元测试 |
| Mockito | 5.x | 模拟对象 |
| AssertJ | 3.24.x | 断言库 |
| Spring Test | 6.x | Spring集成测试 |

#### 测试规范

```java
// 标准单元测试结构
@DisplayName("MemberService 测试")
class MemberServiceTest {

    @Mock
    private MemberRepository memberRepository;

    @InjectMocks
    private MemberService memberService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("根据ID查询成员 - 成功")
    void testGetMemberById_Success() {
        // Given
        Long memberId = 1L;
        Member expected = Member.builder()
                .id(memberId)
                .name("张三")
                .gender(Gender.MALE)
                .build();
        when(memberRepository.findById(memberId)).thenReturn(Optional.of(expected));

        // When
        Member result = memberService.getMemberById(memberId);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getName()).isEqualTo("张三");
        verify(memberRepository, times(1)).findById(memberId);
    }

    @Test
    @DisplayName("根据ID查询成员 - 成员不存在")
    void testGetMemberById_NotFound() {
        // Given
        Long memberId = 999L;
        when(memberRepository.findById(memberId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> memberService.getMemberById(memberId))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("成员不存在");
    }
}
```

#### 覆盖率要求

| 模块 | 最低覆盖率 |
|------|------------|
| Service层 | ≥ 80% |
| Controller层 | ≥ 70% |
| 工具类 | ≥ 90% |
| 整体 | ≥ 70% |

### 2.2 集成测试

#### API集成测试

```java
@WebMvcTest(MemberController.class)
@DisplayName("MemberController 集成测试")
class MemberControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private MemberService memberService;

    @Test
    @DisplayName("创建成员 - 成功")
    void testCreateMember_Success() throws Exception {
        // Given
        CreateMemberRequest request = CreateMemberRequest.builder()
                .name("张三")
                .gender("MALE")
                .birthDate("1990-01-01")
                .build();

        MemberDTO response = MemberDTO.builder()
                .memberId(1L)
                .name("张三")
                .build();

        when(memberService.createMember(any())).thenReturn(response);

        // When & Then
        mockMvc.perform(post("/api/v1/members")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.memberId").value(1))
                .andExpect(jsonPath("$.data.name").value("张三"));
    }

    @Test
    @DisplayName("创建成员 - 参数校验失败")
    void testCreateMember_ValidationFailed() throws Exception {
        // Given - 空姓名
        CreateMemberRequest request = CreateMemberRequest.builder()
                .name("")
                .gender("MALE")
                .build();

        // When & Then
        mockMvc.perform(post("/api/v1/members")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400));
    }
}
```

#### 数据库集成测试

```java
@DataJpaTest
@DisplayName("MemberRepository 集成测试")
class MemberRepositoryIntegrationTest {

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    @DisplayName("按家族查询成员列表")
    void testFindByFamilyId() {
        // Given
        Family family = entityManager.persist(Family.builder()
                .familyName("测试家族")
                .build());

        entityManager.persist(Member.builder()
                .family(family)
                .name("张三")
                .build());
        entityManager.persist(Member.builder()
                .family(family)
                .name("李四")
                .build());
        entityManager.flush();

        // When
        List<Member> members = memberRepository.findByFamilyId(family.getId());

        // Then
        assertThat(members).hasSize(2);
        assertThat(members).extracting(Member::getName)
                .containsExactlyInAnyOrder("张三", "李四");
    }
}
```

### 2.3 系统测试

#### 测试用例示例

| 用例ID | 用例名称 | 前置条件 | 测试步骤 | 预期结果 |
|--------|----------|----------|----------|----------|
| SYS-001 | 用户登录 | 用户已注册 | 1.输入用户名密码<br>2.点击登录 | 登录成功，进入首页 |
| SYS-002 | 添加成员 | 已登录为管理员 | 1.进入成员管理<br>2.点击添加<br>3.填写信息<br>4.保存 | 成员添加成功 |
| SYS-003 | 建立关系 | 存在两个成员 | 1.选择成员A<br>2.选择关系类型<br>3.选择成员B<br>4.保存 | 关系建立成功 |
| SYS-004 | 族谱展示 | 存在家族数据 | 1.进入族谱页面<br>2.选择根节点<br>3.查看族谱树 | 族谱正确展示 |

#### 关键业务流程测试

```
1. 用户注册 → 登录 → 完善资料 → 创建家族
2. 管理员添加成员 → 建立关系 → 查看族谱
3. 成员上传照片 → 管理照片 → 下载照片
4. 数据导入 → 数据导出 → 打印族谱
```

### 2.4 性能测试

#### 性能指标

| 指标 | 目标值 | 说明 |
|------|--------|------|
| 登录响应时间 | ≤ 500ms | P95 |
| 列表查询响应 | ≤ 200ms | 10万数据量 |
| 族谱树加载 | ≤ 2s | 100人规模 |
| 并发用户数 | ≥ 100 | 同时在线 |
| 系统吞吐量 | ≥ 50 TPS | 事务每秒 |

#### 性能测试工具

| 工具 | 用途 |
|------|------|
| JMeter | 负载测试、压力测试 |
| Gatling | 性能测试脚本 |
| Arthas | Java应用诊断 |
| SkyWalking | 分布式追踪 |

#### 测试场景

```yaml
# JMeter测试计划
scenarios:
  - name: 登录场景
    requests:
      - endpoint: /api/v1/auth/login
        concurrency: 100
        duration: 300s

  - name: 成员查询场景
    requests:
      - endpoint: /api/v1/members
        params:
          page: 1
          size: 20
        concurrency: 50
        duration: 300s

  - name: 族谱加载场景
    requests:
      - endpoint: /api/v1/genealogy/tree
        params:
          maxDepth: 10
        concurrency: 30
        duration: 300s
```

### 2.5 安全测试

| 测试项 | 测试方法 | 通过标准 |
|--------|----------|----------|
| SQL注入 | 使用SQL注入Payload测试 | 无注入漏洞 |
| XSS攻击 | 提交Script标签测试 | 输出转义 |
| CSRF | 检查Token验证 | Token有效 |
| 暴力破解 | 多次错误登录测试 | 账户锁定 |
| 敏感数据 | 检查日志和响应 | 无明文敏感数据 |
| 越权访问 | 尝试访问其他家族数据 | 权限校验生效 |

### 2.6 兼容性测试

| 测试项 | 测试范围 |
|--------|----------|
| 浏览器兼容 | Chrome、Firefox、Safari、Edge |
| 操作系统兼容 | Windows、macOS、Linux |
| 移动端兼容 | iOS Safari、Android Browser |
| 屏幕尺寸兼容 | 1920x1080、1366x768、移动端 |
| 分辨率兼容 | 100%、125%、150%缩放 |

## 3. 测试数据管理

### 3.1 测试数据策略

```
开发环境：Mock数据
测试环境：独立数据库，定时刷新
预生产环境：生产脱敏数据
```

### 3.2 测试数据构建

```java
// 使用TestDataBuilder构建测试数据
class TestDataBuilder {

    public static Family createFamily() {
        return Family.builder()
                .familyName("测试家族")
                .description("用于测试")
                .build();
    }

    public static Member createMember(Family family) {
        return Member.builder()
                .family(family)
                .name("测试成员_" + UUID.randomUUID())
                .gender(Gender.MALE)
                .birthDate(LocalDate.of(1990, 1, 1))
                .generation(1)
                .build();
    }
}
```

## 4. 缺陷管理

### 4.1 缺陷等级

| 等级 | 定义 | 响应时间 | 修复时间 |
|------|------|----------|----------|
| P0 | 系统崩溃，数据丢失 | 立即 | 4小时 |
| P1 | 核心功能不可用 | 2小时 | 24小时 |
| P2 | 功能缺陷，影响业务 | 4小时 | 72小时 |
| P3 | 界面问题，体验不佳 | 24小时 | 1周 |
| P4 | 优化建议 | 48小时 | 2周 |

### 4.2 缺陷报告模板

```markdown
## 缺陷标题

**缺陷ID**: BUG-001
**严重级别**: P1
**发现日期**: 2026-04-09
**发现人**: 测试工程师
**指派给**: 开发工程师

### 环境信息
- 环境：测试环境
- 浏览器：Chrome 120
- 操作系统：Windows 11
- 版本：v1.0.0

### 复现步骤
1. 登录系统
2. 进入成员管理页面
3. 点击"添加成员"按钮
4. 填写必填信息后点击"保存"

### 预期结果
显示"成员添加成功"提示

### 实际结果
页面报错：500 Internal Server Error

### 错误日志
```
2026-04-09 10:00:00 ERROR - NullPointerException at MemberService.java:100
```

### 附件
- 截图1.png
- 录屏.mp4
```

## 5. 测试流程

### 5.1 测试阶段流程

```
需求分析
    ↓
测试计划制定
    ↓
测试用例设计
    ↓
用例评审
    ↓
测试环境准备
    ↓
冒烟测试
    ↓
执行测试
    ↓
缺陷提交与跟踪
    ↓
回归测试
    ↓
测试报告编写
    ↓
测试验收
```

### 5.2 自动化测试集成

```yaml
# GitHub Actions CI/CD
name: Test

on:
  pull_request:
    branches: [main, dev]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: test
          MYSQL_DATABASE: test_db
        ports:
          - 3306:3306

    steps:
      - uses: actions/checkout@v3

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Run tests
        run: mvn test -Dspring.profiles.active=test

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## 6. 测试工具清单

| 工具 | 版本 | 用途 |
|------|------|------|
| JUnit | 5.10.x | 单元测试框架 |
| Mockito | 5.x | Mock框架 |
| Spring Test | 6.x | Spring测试 |
| Jest | 29.x | 前端单元测试 |
| Cypress | 12.x | 端到端测试 |
| Postman | 10.x | API测试 |
| JMeter | 5.6.x | 性能测试 |
| SonarQube | 10.x | 代码质量 |

## 7. 测试交付物

| 交付物 | 说明 | 评审时间 |
|--------|------|----------|
| 测试计划 | 测试范围、策略、资源 | 每个迭代开始 |
| 测试用例 | 功能覆盖说明 | 用例设计完成后 |
| 测试报告 | 执行结果、缺陷统计 | 每个迭代结束 |
| 性能报告 | 性能测试结果 | 发布前 |
| 用户验收报告 | UAT结果 | 发布前 |

## 8. 文档更新记录

| 版本 | 日期 | 更新内容 | 作者 |
|------|------|----------|------|
| v1.0 | 2026-04-09 | 初始版本 | AI Assistant |
