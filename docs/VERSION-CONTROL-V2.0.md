# 版本管理规范文档 - 家族族谱系统 V2.0

## 概述

本文档定义了家族族谱系统的版本管理规范,包括Git分支策略、版本命名规范、提交信息规范、代码审查流程和发布流程。所有项目参与者都应遵循此规范,以确保版本管理的清晰性和可追溯性。

---

## 一、Git分支策略

### 1.1 分支模型

本项目采用 **Git Flow** 分支模型,主要包含以下分支:

| 分支名 | 用途 | 保护级别 | 生命周期 |
|--------|------|----------|----------|
| `main` | 主分支,存储稳定可发布的代码 | 严格保护,仅允许合并 | 永久存在 |
| `develop` | 开发分支,集成所有新功能 | 受保护,仅允许合并 | 永久存在 |
| `feature/*` | 功能分支,用于开发新功能 | 不受保护 | 临时,合并后删除 |
| `release/*` | 发布分支,用于发布前的集成测试和修复 | 受保护 | 临时,发布后删除 |
| `hotfix/*` | 热修复分支,用于紧急修复生产环境问题 | 受保护 | 临时,修复后删除 |

### 1.2 分支详细说明

#### main (主分支)
- **用途**: 存储生产环境的稳定代码
- **规则**:
  - 任何时候 main 分支的代码都应该可以正常部署
  - 只允许从 release 分支或 hotfix 分支合并
  - 禁止直接提交代码到 main 分支
  - 每次合并都必须打版本标签 (tag)

#### develop (开发分支)
- **用途**: 作为日常开发集成的分支
- **规则**:
  - 所有新功能都从 develop 分支创建
  - 功能开发完成后合并回 develop 分支
  - 禁止直接提交代码到 develop 分支,必须通过 Pull Request 合并

#### feature/* (功能分支)
- **命名格式**: `feature/<功能名称>`
- **示例**:
  - `feature/profile-v2` - V2.0个人主页功能
  - `feature/user-auth` - 用户认证功能
  - `feature/message-system` - 消息系统
- **规则**:
  - 从 develop 分支创建
  - 开发完成后通过 Pull Request 合并回 develop
  - 合并后删除功能分支

#### release/* (发布分支)
- **命名格式**: `release/<版本号>`
- **示例**:
  - `release/v2.0` - V2.0发布分支
  - `release/v2.1` - V2.1发布分支
- **规则**:
  - 从 develop 分支创建
  - 只允许进行 Bug 修复和发布相关修改
  - 不添加新功能
  - 发布完成后合并到 main 和 develop 分支
  - 打版本标签

#### hotfix/* (热修复分支)
- **命名格式**: `hotfix/<修复内容>-<版本号>`
- **示例**:
  - `hotfix/critical-security-fix-2.0.1`
  - `hotfix/fix-login-bug-2.0.2`
- **规则**:
  - 从 main 分支创建
  - 修复完成后同时合并到 main 和 develop 分支
  - 打版本标签

### 1.3 分支工作流程图

```
main ────────────────────────────┐
                                  │ 合并
                                  ▼
                         release/v2.0 ──► tag: v2.0.0
                        ↗               │
develop ────────────────┘                │
    │                                    │
    │ 合并                                │
    ▼                                    │
feature/profile-v2 ──────► PR审核 ──────► │
                                          │
    │                                    │
    ▼                                    │
feature/message-system ──► PR审核 ──────► │
```

---

## 二、版本命名规范

### 2.1 语义化版本控制 (Semantic Versioning)

采用 `主版本号.次版本号.修订号` (MAJOR.MINOR.PATCH) 格式。

**版本号格式**: `X.Y.Z`
- X: 主版本号 (Major)
- Y: 次版本号 (Minor)
- Z: 修订号 (Patch)

### 2.2 版本递增规则

| 变更类型 | 递增规则 | 示例 |
|----------|----------|------|
| 重大功能更新,不兼容的API修改 | 主版本号递增,次版本号和修订号归零 | 1.x.x -> 2.0.0 |
| 向下兼容的功能性新增 | 次版本号递增,修订号归零 | 2.0.x -> 2.1.0 |
| 向下兼容的问题修正 | 修订号递增 | 2.0.0 -> 2.0.1 |

### 2.3 预发布版本

在正式版本号后添加连字符和标识符:

| 预发布类型 | 格式 | 示例 | 说明 |
|-----------|------|------|------|
| 内测版本 | `-alpha.N` | 2.0.0-alpha.1 | 早期测试版本,功能可能不完整 |
| 公测版本 | `-beta.N` | 2.0.0-beta.1 | 功能完成,用于外部测试 |
| 候选版本 | `-rc.N` | 2.0.0-rc.1 | 候选发布版本,无重大bug即可发布 |

**预发布版本排序规则**: alpha < beta < rc < 正式版本

### 2.4 V2.0版本规划

| 版本 | 类型 | 预计日期 | 说明 |
|------|------|----------|------|
| 2.0.0-alpha.1 | 内测版 | 2026-03-01 | 个人主页核心功能 |
| 2.0.0-alpha.2 | 内测版 | 2026-03-15 | 社交互动系统 |
| 2.0.0-beta.1 | 公测版 | 2026-04-01 | 完整功能集成 |
| 2.0.0-rc.1 | 候选版 | 2026-04-10 | 发布候选 |
| 2.0.0 | 正式版 | 2026-04-17 | 正式发布 |

---

## 三、提交信息规范

### 3.1 Conventional Commits 规范

采用 Conventional Commits 规范,所有提交信息必须遵循以下格式:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### 3.2 Type 类型说明

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | feat(profile): 添加个人生平时间轴功能 |
| `fix` | Bug修复 | fix(auth): 修复JWT token过期处理问题 |
| `docs` | 文档更新 | docs(api): 更新API接口文档 |
| `style` | 代码格式 (不影响代码逻辑) | style(profile): 统一代码缩进格式 |
| `refactor` | 代码重构 | refactory(service): 重构用户服务层代码 |
| `perf` | 性能优化 | perf(db): 优化数据库查询性能 |
| `test` | 测试相关 | test(profile): 添加个人主页单元测试 |
| `chore` | 构建/工具相关 | chore: 更新maven依赖版本 |
| `ci` | CI/CD相关 | ci: 添加GitHub Actions配置 |
| `build` | 构建系统 | build: 更新webpack配置 |
| `revert` | 回滚提交 | revert: 回滚feat(profile)提交 |

### 3.3 Scope 范围说明

根据项目模块定义 scope:

| Scope | 说明 |
|-------|------|
| `profile` | 个人主页模块 |
| `auth` | 认证授权模块 |
| `member` | 成员管理模块 |
| `genealogy` | 族谱树模块 |
| `interaction` | 互动功能模块 |
| `message` | 消息系统模块 |
| `notification` | 通知系统模块 |
| `upload` | 文件上传模块 |
| `db` | 数据库相关 |
| `ui` | 用户界面相关 |
| `api` | API接口相关 |
| `config` | 配置相关 |

### 3.4 Description 描述规则

- 使用中文描述
- 使用祈使句,第一人称现在时
- 不要大写首字母
- 结尾不要加句号
- 描述要简洁明了,建议不超过50个字符

### 3.5 Body 和 Footer

**Body (可选)**:
- 详细描述变更内容和原因
- 说明变更的影响范围

**Footer (可选)**:
- 关联 Issue: `Closes #123`
- 破坏性变更: `BREAKING CHANGE: 详细说明`
- 参考: `Refs #456`

### 3.6 提交信息示例

```bash
# 新功能
feat(profile): 添加个人生平时间轴功能

实现时间轴视图组件,支持按时间顺序展示个人经历
支持文本、图片、视频多种内容类型

Closes #45

# Bug修复
fix(auth): 修复JWT token过期后自动刷新问题

当token过期时,自动调用刷新接口获取新token
避免用户需要重新登录

# 文档更新
docs(api): 更新个人主页API接口文档

补充评论和点赞相关接口的详细说明

# 破坏性变更
feat(profile)!: 重构个人主页数据结构

BREAKING CHANGE: 个人主页API响应格式已变更,
旧版本客户端需要适配新的数据结构
```

### 3.7 提交检查

提交前使用以下命令检查:

```bash
# 查看提交历史
git log --oneline -10

# 检查当前提交信息格式
git log -1 --pretty=%B
```

---

## 四、代码审查流程

### 4.1 审查流程

```
功能开发 ──► 自测通过 ──► 提交PR ──► 代码审查 ──► 修改建议 ──► 合并到develop
                                    │                              │
                                    ▼                              │
                              审查不通过 ──► 修改代码 ──────────────┘
                                    │
                                    ▼
                              审查通过 ──► 合并 ──► 删除功能分支
```

### 4.2 Pull Request 规范

#### 4.2.1 PR 标题格式

```
[type](scope): 功能简述
```

示例:
- `feat(profile): V2.0个人主页功能`
- `fix(auth): 修复JWT token过期问题`

#### 4.2.2 PR 描述模板

```markdown
## 变更类型
- [ ] 新功能 (feat)
- [ ] Bug修复 (fix)
- [ ] 文档更新 (docs)
- [ ] 代码重构 (refactor)
- [ ] 性能优化 (perf)
- [ ] 测试相关 (test)

## 变更说明
简要描述本次变更的内容和目的。

## 关联Issue
Closes #XX

## 测试情况
- [ ] 单元测试通过
- [ ] 集成测试通过
- [ ] 手动测试通过

## 截图 (如适用)
[添加截图]

## 注意事项
[需要审查者特别注意的事项]
```

### 4.3 审查要求

#### 4.3.1 审查人员
- 至少需要 **1名** 核心开发者审查通过
- 涉及核心功能的变更建议 **2名** 审查者
- 审查者不能是该功能的直接开发者

#### 4.3.2 审查检查项

**功能完整性**:
- [ ] 功能是否按需求实现
- [ ] 边界条件是否处理
- [ ] 错误处理是否完善

**代码质量**:
- [ ] 代码结构是否清晰
- [ ] 命名是否规范
- [ ] 是否有重复代码
- [ ] 是否遵循项目编码规范

**安全性**:
- [ ] 是否有SQL注入风险
- [ ] 权限控制是否正确
- [ ] 敏感数据是否加密
- [ ] 输入验证是否完善

**性能**:
- [ ] 是否有性能瓶颈
- [ ] 数据库查询是否优化
- [ ] 是否有不必要的计算

**测试**:
- [ ] 是否包含单元测试
- [ ] 测试覆盖率是否达标
- [ ] 测试用例是否完整

#### 4.3.3 审查评论规范

- 评论要具体明确,指出问题所在
- 提供改进建议或示例代码
- 使用建设性的语气
- 区分必须修改和建议修改

### 4.4 合并策略

- 使用 **Squash and Merge** 保持提交历史简洁
- 合并后自动删除功能分支
- 合并信息中保留PR编号

---

## 五、发布流程

### 5.1 发布流程图

```
develop分支 ──► 创建release分支 ──► 集成测试 ──► 修复问题 ──► 打标签
                      │                                          │
                      ▼                                          ▼
                 测试发现问题                               合并到main分支
                      │                                          │
                      ▼                                          ▼
                  修复问题 ───────────────────────────────► 删除release分支
                                                              │
                                                              ▼
                                                         发布部署
```

### 5.2 发布步骤

#### 步骤1: 创建发布分支

```bash
# 确保develop分支是最新的
git checkout develop
git pull origin develop

# 创建发布分支
git checkout -b release/v2.0
git push -u origin release/v2.0
```

#### 步骤2: 版本准备

- 更新版本号
- 更新 CHANGELOG.md
- 更新 README.md (如需要)
- 确认所有文档已更新

```bash
# 提交版本准备
git add .
git commit -m "chore(release): 准备V2.0.0发布"
git push origin release/v2.0
```

#### 步骤3: 集成测试

- 执行完整的集成测试
- 记录测试发现的问题
- 在 release 分支上修复问题

```bash
# 修复问题后提交
git add .
git commit -m "fix(release): 修复集成测试发现的问题"
git push origin release/v2.0
```

#### 步骤4: 合并到主分支

```bash
# 合并到main分支
git checkout main
git pull origin main
git merge release/v2.0 --no-ff
git push origin main

# 合并回develop分支
git checkout develop
git pull origin develop
git merge release/v2.0 --no-ff
git push origin develop
```

#### 步骤5: 打标签

```bash
# 创建版本标签
git tag -a v2.0.0 -m "发布V2.0.0 - 个人主页功能"
git push origin v2.0.0
```

#### 步骤6: 删除发布分支

```bash
# 删除远程分支
git push origin --delete release/v2.0

# 删除本地分支
git branch -d release/v2.0
```

### 5.3 热修复流程

当生产环境发现紧急问题时:

```bash
# 从main创建hotfix分支
git checkout main
git checkout -b hotfix/fix-critical-bug-2.0.1

# 修复问题
# ... 修改代码 ...

# 提交修复
git add .
git commit -m "fix: 修复生产环境紧急问题"

# 合并到main
git checkout main
git merge hotfix/fix-critical-bug-2.0.1 --no-ff
git tag -a v2.0.1 -m "热修复V2.0.1"
git push origin main --tags

# 合并到develop
git checkout develop
git merge hotfix/fix-critical-bug-2.0.1 --no-ff
git push origin develop

# 删除hotfix分支
git branch -d hotfix/fix-critical-bug-2.0.1
git push origin --delete hotfix/fix-critical-bug-2.0.1
```

---

## 六、版本标签管理

### 6.1 标签命名

- 正式版本: `vX.Y.Z` (如 v2.0.0)
- 预发布版本: `vX.Y.Z-类型.N` (如 v2.0.0-beta.1)

### 6.2 标签操作

```bash
# 查看标签
git tag
git tag -l "v2.*"

# 查看标签详情
git show v2.0.0

# 创建轻量标签
git tag v2.0.0

# 创建附注标签 (推荐)
git tag -a v2.0.0 -m "发布V2.0.0 - 个人主页功能"

# 推送标签
git push origin v2.0.0
git push origin --tags  # 推送所有标签

# 删除标签
git tag -d v2.0.0
git push origin --delete v2.0.0
```

---

## 七、版本回滚

### 7.1 回滚场景

- 发布后发现严重Bug
- 新功能导致系统不稳定
- 性能严重下降

### 7.2 回滚方法

#### 方法1: 使用 revert (推荐)

```bash
# 回滚指定提交
git revert <commit-hash>

# 回滚多个提交
git revert <oldest-commit-hash>^..<newest-commit-hash>
```

#### 方法2: 回退到指定标签

```bash
# 创建回滚分支
git checkout -b rollback/v2.0.0 v2.0.0

# 强制推送 (谨慎使用)
git push origin rollback/v2.0.0 --force
```

#### 方法3: reset 回退 (仅限本地)

```bash
# 回退到指定提交
git reset --hard <commit-hash>

# 强制推送 (危险,仅在所有开发者同意时使用)
git push origin main --force
```

### 7.3 回滚注意事项

- 优先使用 `revert` 而不是 `reset --hard`
- `reset --hard` 会丢失提交历史,需要团队协调
- 回滚后及时通知相关人员
- 记录回滚原因和影响

---

## 八、日常Git操作建议

### 8.1 开始新功能

```bash
# 切换到develop分支并更新
git checkout develop
git pull origin develop

# 创建功能分支
git checkout -b feature/新功能名称

# 开始开发...
```

### 8.2 提交代码

```bash
# 查看变更
git status
git diff

# 添加文件
git add <file>
git add -A  # 添加所有变更

# 提交
git commit -m "feat(scope): 功能描述"

# 推送
git push origin feature/新功能名称
```

### 8.3 同步develop更新

```bash
# 在功能分支上
git fetch origin
git rebase origin/develop

# 如果有冲突,解决后继续
git rebase --continue
```

### 8.4 提交前检查

```bash
# 查看提交历史
git log --oneline -10

# 查看变更统计
git diff --stat

# 检查是否有未提交的变更
git status
```

---

## 九、团队协作规范

### 9.1 分支保护规则

- main 分支: 禁止直接推送,必须通过PR合并
- develop 分支: 禁止直接推送,必须通过PR合并
- release/* 分支: 仅允许发布相关修改

### 9.2 提交频率

- 建议每天至少提交一次
- 每个功能点完成后提交
- 不要积累大量未提交的代码

### 9.3 冲突解决

- 及时同步 develop 分支的最新代码
- 解决冲突后充分测试
- 复杂冲突与相关开发者沟通确认

### 9.4 代码审查责任

- 审查者应在24小时内完成审查
- 审查意见要明确具体
- 开发者应及时响应审查意见

---

## 十、文档维护

### 10.1 文档清单

| 文档 | 路径 | 说明 |
|------|------|------|
| 版本控制规范 | docs/VERSION-CONTROL-V2.0.md | 本文档 |
| 发布说明 | docs/RELEASE-NOTES-V2.0.md | 版本发布说明 |
| 变更日志 | CHANGELOG.md | 版本变更历史 |
| 产品需求 | docs/PRODUCT-REQUIREMENTS-V2.0.md | 产品需求文档 |
| 架构设计 | docs/ARCHITECTURE-DESIGN-V2.0.md | 系统架构文档 |
| 数据库设计 | docs/DATABASE-DESIGN-V2.0.md | 数据库设计文档 |
| API文档 | docs/API.md | API接口文档 |
| UI设计 | docs/UI-DESIGN-V2.0.md | UI设计文档 |
| 测试文档 | docs/TESTING.md | 测试计划文档 |
| 部署文档 | docs/DEPLOYMENT.md | 部署指南 |

### 10.2 文档更新规则

- 功能开发完成后同步更新相关文档
- API变更必须更新API文档
- 数据库变更必须更新数据库设计文档
- 文档更新作为PR的一部分进行审查

---

## 附录: 常用Git命令速查

```bash
# 分支操作
git branch                    # 查看本地分支
git branch -a                 # 查看所有分支
git checkout -b <branch>      # 创建并切换分支
git branch -d <branch>        # 删除本地分支
git push origin --delete <branch>  # 删除远程分支

# 标签操作
git tag                       # 查看标签
git tag -a <tag> -m "msg"     # 创建附注标签
git push origin <tag>         # 推送标签
git tag -d <tag>              # 删除本地标签

# 历史查看
git log --oneline             # 简洁日志
git log --graph --oneline     # 图形化日志
git log --since="2026-04-01"  # 按时间过滤
git log --author="name"       # 按作者过滤

# 差异查看
git diff                      # 查看未暂存的变更
git diff --staged             # 查看已暂存的变更
git diff <commit1> <commit2>  # 查看两个提交间的差异

# 撤销操作
git reset --soft <commit>     # 撤销提交,保留变更
git reset --hard <commit>     # 撤销提交,丢弃变更
git checkout -- <file>        # 撤销文件修改
git revert <commit>           # 创建反向提交
```

---

**文档版本**: 1.0.0
**创建日期**: 2026-04-17
**最后更新**: 2026-04-17
**维护者**: 版本管理专家
