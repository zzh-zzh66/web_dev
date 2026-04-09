<template>
  <div class="member-detail">
    <div class="page-header">
      <h2 class="page-title">成员详情</h2>
      <div class="page-actions">
        <el-button @click="handleBack">返回</el-button>
        <el-button type="primary" @click="handleEdit">编辑</el-button>
      </div>
    </div>

    <el-card v-loading="loading">
      <div v-if="member" class="detail-content">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="姓名">
            {{ member.name }}
          </el-descriptions-item>
          <el-descriptions-item label="性别">
            {{ member.gender === 'MALE' ? '男' : '女' }}
          </el-descriptions-item>
          <el-descriptions-item label="辈分">
            {{ member.generation || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="member.status === 'ALIVE' ? 'success' : 'info'">
              {{ member.status === 'ALIVE' ? '在世' : '已故' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="出生日期">
            {{ member.birthDate || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="去世日期">
            {{ member.deathDate || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="父亲">
            <router-link v-if="member.fatherId" :to="`/members/${member.fatherId}`">
              {{ member.fatherName || `成员${member.fatherId}` }}
            </router-link>
            <span v-else>-</span>
          </el-descriptions-item>
          <el-descriptions-item label="母亲">
            <router-link v-if="member.motherId" :to="`/members/${member.motherId}`">
              {{ member.motherName || `成员${member.motherId}` }}
            </router-link>
            <span v-else>-</span>
          </el-descriptions-item>
          <el-descriptions-item label="配偶">
            {{ member.spouseName || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="职业">
            {{ member.occupation || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="出生地">
            {{ member.birthplace || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="个人简介" :span="2">
            {{ member.biography || '-' }}
          </el-descriptions-item>
        </el-descriptions>

        <!-- 家庭关系 -->
        <div class="relation-section">
          <h3>家庭关系</h3>
          <div class="relation-list">
            <div v-if="member.fatherId" class="relation-item">
              <span class="relation-label">父亲：</span>
              <router-link :to="`/members/${member.fatherId}`">
                {{ member.fatherName || `成员${member.fatherId}` }}
              </router-link>
            </div>
            <div v-if="member.motherId" class="relation-item">
              <span class="relation-label">母亲：</span>
              <router-link :to="`/members/${member.motherId}`">
                {{ member.motherName || `成员${member.motherId}` }}
              </router-link>
            </div>
            <div v-if="member.spouseName" class="relation-item">
              <span class="relation-label">配偶：</span>
              <span>{{ member.spouseName }}</span>
            </div>
          </div>
        </div>
      </div>

      <el-empty v-else description="未找到成员信息" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { memberApi, type Member } from '@/api/member'
import { ElMessage } from 'element-plus'

const router = useRouter()
const route = useRoute()

const loading = ref(false)
const member = ref<Member | null>(null)

const memberId = () => Number(route.params.id)

const loadMemberDetail = async () => {
  loading.value = true
  try {
    const res = await memberApi.getDetail(memberId())
    member.value = res.data
  } catch (error) {
    console.error('加载成员详情失败', error)
    ElMessage.error('加载成员详情失败')
  } finally {
    loading.value = false
  }
}

const handleBack = () => {
  router.back()
}

const handleEdit = () => {
  router.push(`/members/${memberId()}/edit`)
}

onMounted(() => {
  loadMemberDetail()
})
</script>

<style scoped>
.member-detail {
  padding: 0;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-title {
  margin: 0;
  font-size: 22px;
  color: #333;
}

.page-actions {
  display: flex;
  gap: 10px;
}

.detail-content {
  padding: 10px 0;
}

.relation-section {
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #eee;
}

.relation-section h3 {
  margin-bottom: 15px;
  font-size: 16px;
  color: #333;
}

.relation-list {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}

.relation-item {
  display: flex;
  align-items: center;
}

.relation-label {
  color: #666;
}

.relation-item a {
  color: #409eff;
  text-decoration: none;
}

.relation-item a:hover {
  text-decoration: underline;
}
</style>
