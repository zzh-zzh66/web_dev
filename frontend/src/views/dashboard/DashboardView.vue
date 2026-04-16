<template>
  <div class="dashboard">
    <div class="dashboard-header">
      <div class="header-content">
        <h1 class="page-title">欢迎回来</h1>
        <p class="page-subtitle">这里是您的家族数据概览</p>
      </div>
    </div>

    <div class="stats-grid">
      <div class="stat-card stat-card-primary" @click="$router.push('/members')">
        <div class="stat-icon-wrapper">
          <div class="stat-icon-bg"></div>
          <div class="stat-icon">
            <el-icon :size="28"><User /></el-icon>
          </div>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ stats.memberCount }}</div>
          <div class="stat-label">成员总数</div>
          <div class="stat-trend">
            <span class="trend-badge">+12</span>
            <span class="trend-text">较上月</span>
          </div>
        </div>
      </div>

      <div class="stat-card stat-card-success" @click="$router.push('/members?status=ALIVE')">
        <div class="stat-icon-wrapper">
          <div class="stat-icon-bg"></div>
          <div class="stat-icon">
            <el-icon :size="28"><CircleCheck /></el-icon>
          </div>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ stats.aliveCount }}</div>
          <div class="stat-label">在世成员</div>
          <div class="stat-progress">
            <div class="progress-bar">
              <div class="progress-fill" :style="{ width: alivePercentage + '%' }"></div>
            </div>
            <span class="progress-text">{{ alivePercentage }}%</span>
          </div>
        </div>
      </div>

      <div class="stat-card stat-card-muted" @click="$router.push('/members?status=DECEASED')">
        <div class="stat-icon-wrapper">
          <div class="stat-icon-bg"></div>
          <div class="stat-icon">
            <el-icon :size="28"><CircleClose /></el-icon>
          </div>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ stats.deceasedCount }}</div>
          <div class="stat-label">已故成员</div>
        </div>
      </div>

      <div class="stat-card stat-card-warning" @click="$router.push('/genealogy')">
        <div class="stat-icon-wrapper">
          <div class="stat-icon-bg"></div>
          <div class="stat-icon">
            <el-icon :size="28"><Star /></el-icon>
          </div>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ stats.generationCount }}</div>
          <div class="stat-label">辈分数量</div>
          <div class="stat-generations">
            <span v-for="i in Math.min(stats.generationCount, 5)" :key="i" class="generation-dot"></span>
          </div>
        </div>
      </div>
    </div>

    <div class="content-grid">
      <div class="recent-card">
        <div class="card-header">
          <div class="header-left">
            <h3 class="card-title">最近添加</h3>
            <span class="card-subtitle">最新家族成员</span>
          </div>
          <router-link to="/members" class="view-all-link">
            查看全部
            <el-icon><ArrowRight /></el-icon>
          </router-link>
        </div>
        <div class="member-list">
          <div
            v-for="member in recentMembers"
            :key="member.memberId"
            class="member-item"
            @click="$router.push(`/members/${member.memberId}`)"
          >
            <div class="member-avatar">
              <el-avatar :size="44" :style="{ background: getAvatarColor(member.gender) }">
                {{ member.name?.charAt(0) }}
              </el-avatar>
              <span class="gender-indicator" :class="member.gender === 'MALE' ? 'male' : 'female'">
                {{ member.gender === 'MALE' ? '男' : '女' }}
              </span>
            </div>
            <div class="member-info">
              <div class="member-name">{{ member.name }}</div>
              <div class="member-meta">
                <span class="meta-item">
                  <el-icon><Calendar /></el-icon>
                  {{ member.generation }}代
                </span>
                <span class="meta-item" :class="member.status === 'ALIVE' ? 'alive' : 'deceased'">
                  <el-icon><CircleCheck v-if="member.status === 'ALIVE'" /><CircleClose v-else /></el-icon>
                  {{ member.status === 'ALIVE' ? '在世' : '已故' }}
                </span>
              </div>
            </div>
            <div class="member-arrow">
              <el-icon><ArrowRight /></el-icon>
            </div>
          </div>
          <el-empty v-if="recentMembers.length === 0" description="暂无成员数据" :image-size="80" />
        </div>
      </div>

      <div class="quick-card">
        <div class="card-header">
          <h3 class="card-title">快捷操作</h3>
        </div>
        <div class="quick-actions">
          <div class="action-item action-primary" @click="$router.push('/members/add')">
            <div class="action-icon">
              <el-icon :size="24"><Plus /></el-icon>
            </div>
            <div class="action-content">
              <div class="action-title">添加成员</div>
              <div class="action-desc">录入新成员信息</div>
            </div>
            <el-icon class="action-arrow"><ArrowRight /></el-icon>
          </div>
          <div class="action-item action-success" @click="$router.push('/genealogy')">
            <div class="action-icon">
              <el-icon :size="24"><DataLine /></el-icon>
            </div>
            <div class="action-content">
              <div class="action-title">查看族谱</div>
              <div class="action-desc">浏览家族树结构</div>
            </div>
            <el-icon class="action-arrow"><ArrowRight /></el-icon>
          </div>
          <div class="action-item action-info" @click="$router.push('/members')">
            <div class="action-icon">
              <el-icon :size="24"><List /></el-icon>
            </div>
            <div class="action-content">
              <div class="action-title">成员列表</div>
              <div class="action-desc">管理所有成员</div>
            </div>
            <el-icon class="action-arrow"><ArrowRight /></el-icon>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { memberApi, type Member } from '@/api/member'
import { User, CircleCheck, CircleClose, Star, Plus, List, ArrowRight, Calendar, DataLine } from '@element-plus/icons-vue'

const stats = ref({
  memberCount: 0,
  aliveCount: 0,
  deceasedCount: 0,
  generationCount: 0
})

const recentMembers = ref<Member[]>([])

const alivePercentage = computed(() => {
  if (stats.value.memberCount === 0) return 0
  return Math.round((stats.value.aliveCount / stats.value.memberCount) * 100)
})

const getAvatarColor = (gender: string) => {
  return gender === 'MALE'
    ? 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'
    : 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)'
}

const loadData = async () => {
  try {
    const res = await memberApi.getList({ page: 1, size: 5 })
    recentMembers.value = res.data.records

    const allRes = await memberApi.getList({ page: 1, size: 1000 })
    const allMembers = allRes.data.records
    stats.value.memberCount = allRes.data.total
    stats.value.aliveCount = allMembers.filter(m => m.status === 'ALIVE').length
    stats.value.deceasedCount = allMembers.filter(m => m.status === 'DECEASED').length

    const generations = new Set(allMembers.map(m => m.generation).filter(g => g !== undefined))
    stats.value.generationCount = generations.size
  } catch (error) {
    console.error('加载数据失败', error)
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.dashboard {
  padding: 0;
  max-width: 1400px;
  margin: 0 auto;
}

.dashboard-header {
  margin-bottom: 32px;
}

.header-content {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.page-title {
  font-family: 'Outfit', 'DM Sans', sans-serif;
  font-size: 32px;
  font-weight: 600;
  color: #18181b;
  margin: 0;
  letter-spacing: -0.5px;
}

.page-subtitle {
  font-size: 14px;
  color: #8e8e93;
  margin: 0;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 32px;
}

.stat-card {
  background: #ffffff;
  border-radius: 20px;
  padding: 24px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1px solid #f2f3f5;
  position: relative;
  overflow: hidden;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 40px rgba(44, 30, 116, 0.12);
}

.stat-icon-wrapper {
  position: relative;
  margin-bottom: 20px;
}

.stat-icon-bg {
  position: absolute;
  width: 56px;
  height: 56px;
  border-radius: 16px;
  opacity: 0.15;
}

.stat-card-primary .stat-icon-bg {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-card-success .stat-icon-bg {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

.stat-card-muted .stat-icon-bg {
  background: linear-gradient(135deg, #6b7280 0%, #4b5563 100%);
}

.stat-card-warning .stat-icon-bg {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
}

.stat-icon {
  position: relative;
  width: 56px;
  height: 56px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ffffff;
}

.stat-card-primary .stat-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
}

.stat-card-success .stat-icon {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  box-shadow: 0 8px 24px rgba(16, 185, 129, 0.3);
}

.stat-card-muted .stat-icon {
  background: linear-gradient(135deg, #6b7280 0%, #4b5563 100%);
  box-shadow: 0 8px 24px rgba(107, 114, 128, 0.3);
}

.stat-card-warning .stat-icon {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  box-shadow: 0 8px 24px rgba(245, 158, 11, 0.3);
}

.stat-value {
  font-family: 'Outfit', 'DM Sans', sans-serif;
  font-size: 36px;
  font-weight: 600;
  color: #18181b;
  line-height: 1;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #8e8e93;
  margin-bottom: 12px;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 8px;
}

.trend-badge {
  font-size: 12px;
  font-weight: 500;
  color: #10b981;
  background: rgba(16, 185, 129, 0.1);
  padding: 2px 8px;
  border-radius: 9999px;
}

.trend-text {
  font-size: 12px;
  color: #8e8e93;
}

.stat-progress {
  display: flex;
  align-items: center;
  gap: 12px;
}

.progress-bar {
  flex: 1;
  height: 6px;
  background: #f0f0f0;
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #10b981 0%, #059669 100%);
  border-radius: 3px;
  transition: width 0.6s ease;
}

.progress-text {
  font-size: 12px;
  font-weight: 500;
  color: #10b981;
  min-width: 40px;
}

.stat-generations {
  display: flex;
  gap: 4px;
}

.generation-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.generation-dot:nth-child(2) { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
.generation-dot:nth-child(3) { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
.generation-dot:nth-child(4) { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); }
.generation-dot:nth-child(5) { background: linear-gradient(135deg, #10b981 0%, #059669 100%); }

.content-grid {
  display: grid;
  grid-template-columns: 1.5fr 1fr;
  gap: 24px;
}

.recent-card,
.quick-card {
  background: #ffffff;
  border-radius: 20px;
  padding: 24px;
  border: 1px solid #f2f3f5;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
}

.header-left {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.card-title {
  font-family: 'Outfit', 'DM Sans', sans-serif;
  font-size: 18px;
  font-weight: 600;
  color: #18181b;
  margin: 0;
}

.card-subtitle {
  font-size: 13px;
  color: #8e8e93;
}

.view-all-link {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  font-weight: 500;
  color: #667eea;
  text-decoration: none;
  transition: color 0.2s;
}

.view-all-link:hover {
  color: #764ba2;
}

.member-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.member-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px;
  border-radius: 12px;
  cursor: pointer;
  transition: background 0.2s;
}

.member-item:hover {
  background: #f8f9fa;
}

.member-avatar {
  position: relative;
}

.member-avatar :deep(.el-avatar) {
  font-family: 'Outfit', sans-serif;
  font-weight: 600;
}

.gender-indicator {
  position: absolute;
  bottom: -2px;
  right: -2px;
  font-size: 10px;
  padding: 1px 4px;
  border-radius: 4px;
  font-weight: 500;
}

.gender-indicator.male {
  background: #667eea;
  color: #ffffff;
}

.gender-indicator.female {
  background: #f5576c;
  color: #ffffff;
}

.member-info {
  flex: 1;
}

.member-name {
  font-size: 15px;
  font-weight: 500;
  color: #18181b;
  margin-bottom: 4px;
}

.member-meta {
  display: flex;
  gap: 12px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #8e8e93;
}

.meta-item.alive {
  color: #10b981;
}

.meta-item.deceased {
  color: #6b7280;
}

.member-arrow {
  color: #d1d5db;
  transition: color 0.2s;
}

.member-item:hover .member-arrow {
  color: #667eea;
}

.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.action-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  border-radius: 14px;
  cursor: pointer;
  transition: all 0.25s ease;
  position: relative;
  overflow: hidden;
}

.action-item::before {
  content: '';
  position: absolute;
  inset: 0;
  opacity: 0;
  transition: opacity 0.25s;
}

.action-item:hover::before {
  opacity: 1;
}

.action-item:hover {
  transform: translateX(4px);
}

.action-primary {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08) 0%, rgba(118, 75, 162, 0.08) 100%);
}

.action-primary::before {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.12) 0%, rgba(118, 75, 162, 0.12) 100%);
}

.action-primary .action-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.action-success {
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.08) 0%, rgba(5, 150, 105, 0.08) 100%);
}

.action-success::before {
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.12) 0%, rgba(5, 150, 105, 0.12) 100%);
}

.action-success .action-icon {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

.action-info {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.08) 0%, rgba(37, 99, 235, 0.08) 100%);
}

.action-info::before {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.12) 0%, rgba(37, 99, 235, 0.12) 100%);
}

.action-info .action-icon {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
}

.action-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ffffff;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.action-content {
  flex: 1;
}

.action-title {
  font-size: 15px;
  font-weight: 500;
  color: #18181b;
  margin-bottom: 2px;
}

.action-desc {
  font-size: 12px;
  color: #8e8e93;
}

.action-arrow {
  color: #d1d5db;
  transition: all 0.2s;
}

.action-item:hover .action-arrow {
  color: #667eea;
  transform: translateX(4px);
}

@media (max-width: 1024px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .content-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }

  .page-title {
    font-size: 24px;
  }
}
</style>
