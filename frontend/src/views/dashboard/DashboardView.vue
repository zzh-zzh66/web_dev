<template>
  <div class="dashboard">
    <h2 class="page-title">首页</h2>
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #409eff;">
              <el-icon :size="30"><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.memberCount }}</div>
              <div class="stat-label">成员总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #67c23a;">
              <el-icon :size="30"><CircleCheck /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.aliveCount }}</div>
              <div class="stat-label">在世成员</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #909399;">
              <el-icon :size="30"><CircleClose /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.deceasedCount }}</div>
              <div class="stat-label">已故成员</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #e6a23c;">
              <el-icon :size="30"><Star /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.generationCount }}</div>
              <div class="stat-label">辈分数量</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="16">
        <el-card class="recent-card">
          <template #header>
            <div class="card-header">
              <span>最近添加的成员</span>
              <router-link to="/members">查看更多</router-link>
            </div>
          </template>
          <el-table :data="recentMembers" style="width: 100%">
            <el-table-column prop="name" label="姓名" />
            <el-table-column prop="gender" label="性别">
              <template #default="{ row }">
                {{ row.gender === 'MALE' ? '男' : '女' }}
              </template>
            </el-table-column>
            <el-table-column prop="generation" label="辈分" />
            <el-table-column prop="status" label="状态">
              <template #default="{ row }">
                <el-tag :type="row.status === 'ALIVE' ? 'success' : 'info'">
                  {{ row.status === 'ALIVE' ? '在世' : '已故' }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card class="quick-card">
          <template #header>
            <span>快捷操作</span>
          </template>
          <div class="quick-actions">
            <el-button type="primary" @click="$router.push('/members/add')">
              <el-icon><Plus /></el-icon>
              添加成员
            </el-button>
            <el-button type="success" @click="$router.push('/genealogy')">
              <el-icon><Tree /></el-icon>
              查看族谱
            </el-button>
            <el-button type="info" @click="$router.push('/members')">
              <el-icon><List /></el-icon>
              成员列表
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { memberApi, type Member } from '@/api/member'
import { User, CircleCheck, CircleClose, Star, Plus, Grid, List } from '@element-plus/icons-vue'

const stats = ref({
  memberCount: 0,
  aliveCount: 0,
  deceasedCount: 0,
  generationCount: 0
})

const recentMembers = ref<Member[]>([])

const loadData = async () => {
  try {
    const res = await memberApi.getList({ page: 1, size: 5 })
    recentMembers.value = res.data.records

    // 计算统计数据
    const allRes = await memberApi.getList({ page: 1, size: 1000 })
    const allMembers = allRes.data.records
    stats.value.memberCount = allRes.data.total
    stats.value.aliveCount = allMembers.filter(m => m.status === 'ALIVE').length
    stats.value.deceasedCount = allMembers.filter(m => m.status === 'DECEASED').length

    // 辈分数
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
}

.page-title {
  margin-bottom: 20px;
  font-size: 22px;
  color: #333;
}

.stat-card {
  cursor: pointer;
  transition: transform 0.2s;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-content {
  display: flex;
  align-items: center;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  margin-right: 15px;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #333;
}

.stat-label {
  font-size: 14px;
  color: #999;
  margin-top: 5px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header a {
  color: #409eff;
  text-decoration: none;
  font-size: 14px;
}

.card-header a:hover {
  text-decoration: underline;
}

.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.quick-actions .el-button {
  width: 100%;
  justify-content: flex-start;
}
</style>
