<template>
  <!--
    AboutMe - 关于我组件
    展示用户详细信息、族谱信息、加入时间等
  -->
  <div class="about-me" v-if="profile">
    <el-card class="about-me__card">
      <template #header>
        <h3 class="about-me__title">关于 {{ profile.name }}</h3>
      </template>

      <el-descriptions :column="1" border>
        <el-descriptions-item label="姓名">{{ profile.name }}</el-descriptions-item>
        <el-descriptions-item v-if="profile.gender" label="性别">
          {{ profile.gender === 'MALE' ? '男' : profile.gender === 'FEMALE' ? '女' : profile.gender }}
        </el-descriptions-item>
        <el-descriptions-item v-if="profile.generation" label="世代">
          第{{ profile.generation }}代
        </el-descriptions-item>
        <el-descriptions-item v-if="profile.familyName" label="家族">
          {{ profile.familyName }}
        </el-descriptions-item>
        <el-descriptions-item label="签名">
          {{ profile.signature || '暂无' }}
        </el-descriptions-item>
        <el-descriptions-item label="兴趣">
          <el-tag
            v-for="interest in profile.interests"
            :key="interest"
            size="small"
            class="about-me__interest-tag"
          >
            {{ interest }}
          </el-tag>
          <span v-if="!profile.interests?.length" class="about-me__empty">暂无</span>
        </el-descriptions-item>
        <el-descriptions-item label="加入时间">
          {{ formatDate(profile.createdAt) }}
        </el-descriptions-item>
        <el-descriptions-item label="最后更新">
          {{ formatDate(profile.updatedAt) }}
        </el-descriptions-item>
      </el-descriptions>

      <!-- 统计数据 -->
      <div class="about-me__stats">
        <el-statistic title="访问量" :value="profile.stats.visitCount" />
        <el-statistic title="动态数" :value="profile.stats.contentCount" />
        <el-statistic title="获赞数" :value="profile.stats.likeCount" />
        <el-statistic title="留言数" :value="profile.stats.guestbookCount" />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import type { UserProfile } from '@/types/profile'

interface Props {
  profile: UserProfile | null
}

defineProps<Props>()

function formatDate(dateStr: string): string {
  const date = new Date(dateStr)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}
</script>

<style scoped>
.about-me {
  max-width: 700px;
}

.about-me__title {
  font-size: var(--font-h4, 16px);
  font-weight: 600;
  color: var(--text-primary, #303133);
}

.about-me__stats {
  display: flex;
  gap: var(--space-xl, 24px);
  margin-top: var(--space-xl, 24px);
  padding-top: var(--space-lg, 16px);
  border-top: 1px solid var(--border-color-light, #E4E7ED);
}

.about-me__interest-tag {
  margin-right: var(--space-xs, 4px);
}

.about-me__empty {
  color: var(--text-secondary, #909399);
  font-size: var(--font-body-sm, 13px);
}
</style>
