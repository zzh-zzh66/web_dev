<template>
  <div class="family-guestbook">
    <div class="family-guestbook__header">
      <h3 class="family-guestbook__title">
        <el-icon><ChatDotRound /></el-icon>
        家族留言板
      </h3>
    </div>

    <div class="family-guestbook__input">
      <el-avatar :size="32">
        <el-icon :size="18"><User /></el-icon>
      </el-avatar>
      <el-input
        v-model="newMessage"
        placeholder="写下对家族的祝福..."
        size="small"
        class="family-guestbook__input-field"
      >
        <template #append>
          <el-button :disabled="!newMessage.trim()" @click="handleSubmit">
            留言
          </el-button>
        </template>
      </el-input>
    </div>

    <div v-loading="loading" class="family-guestbook__list">
      <div
        v-for="item in messages"
        :key="item.id"
        class="guestbook-item"
      >
        <el-avatar :size="36" class="guestbook-item__avatar">
          <el-icon><User /></el-icon>
        </el-avatar>
        <div class="guestbook-item__content">
          <div class="guestbook-item__header">
            <span class="guestbook-item__name">{{ item.userName }}</span>
            <span class="guestbook-item__time">{{ formatTime(item.createdAt) }}</span>
          </div>
          <p class="guestbook-item__text">{{ item.content }}</p>
        </div>
        <el-dropdown v-if="item.userId === userStore.userInfo?.userId" trigger="click">
          <el-button text size="small" :icon="MoreFilled" />
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="handleDelete(item.id)">删除</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>

      <div v-if="!loading && messages.length === 0" class="family-guestbook__empty">
        <p>暂无留言</p>
        <p>成为第一个留言的人吧</p>
      </div>

      <div v-if="hasMore" class="family-guestbook__more">
        <el-button text size="small" @click="loadMore">加载更多</el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { ChatDotRound, User, MoreFilled } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { familyApi } from '@/api/family'
import type { MessageBoard } from '@/types/profile'

const userStore = useUserStore()

const messages = ref<MessageBoard[]>([])
const loading = ref(false)
const newMessage = ref('')
const page = ref(1)
const pageSize = 20
const total = ref(0)

const hasMore = computed(() => messages.value.length < total.value)

async function fetchMessages() {
  loading.value = true
  try {
    const res = await familyApi.getFamilyGuestbook({ page: page.value, size: pageSize })
    messages.value = res.data.records
    total.value = res.data.total
  } catch (error) {
    console.error('获取留言失败', error)
  } finally {
    loading.value = false
  }
}

async function loadMore() {
  page.value++
  try {
    const res = await familyApi.getFamilyGuestbook({ page: page.value, size: pageSize })
    messages.value = [...messages.value, ...res.data.records]
    total.value = res.data.total
  } catch (error) {
    console.error('加载更多失败', error)
    page.value--
  }
}

async function handleSubmit() {
  if (!newMessage.value.trim()) return

  try {
    await familyApi.createFamilyGuestbook({ content: newMessage.value })
    ElMessage.success('留言成功')
    newMessage.value = ''
    page.value = 1
    await fetchMessages()
  } catch (error) {
    ElMessage.error('留言失败')
  }
}

async function handleDelete(id: number) {
  try {
    await familyApi.deleteFamilyGuestbook(id)
    const index = messages.value.findIndex(m => m.id === id)
    if (index !== -1) {
      messages.value.splice(index, 1)
      total.value--
    }
    ElMessage.success('删除成功')
  } catch (error) {
    ElMessage.error('删除失败')
  }
}

function formatTime(time: string): string {
  const date = new Date(time)
  const now = new Date()
  const diff = now.getTime() - date.getTime()

  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  if (diff < 604800000) return `${Math.floor(diff / 86400000)}天前`
  return date.toLocaleDateString()
}

import { computed } from 'vue'

onMounted(() => {
  fetchMessages()
})
</script>

<style scoped>
.family-guestbook {
  background: #fff;
  border-radius: var(--radius-lg, 12px);
  padding: var(--space-lg, 16px);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.family-guestbook__header {
  margin-bottom: var(--space-md, 12px);
}

.family-guestbook__title {
  display: flex;
  align-items: center;
  gap: var(--space-sm, 8px);
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary, #303133);
  margin: 0;
}

.family-guestbook__input {
  display: flex;
  gap: var(--space-sm, 8px);
  margin-bottom: var(--space-lg, 16px);
}

.family-guestbook__input-field {
  flex: 1;
}

.family-guestbook__list {
  max-height: 500px;
  overflow-y: auto;
}

.guestbook-item {
  display: flex;
  gap: var(--space-sm, 8px);
  padding: var(--space-md, 12px) 0;
  border-bottom: 1px solid var(--border-color-light, #E4E7ED);
}

.guestbook-item:last-child {
  border-bottom: none;
}

.guestbook-item__content {
  flex: 1;
  min-width: 0;
}

.guestbook-item__header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}

.guestbook-item__name {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-primary, #303133);
}

.guestbook-item__time {
  font-size: 12px;
  color: var(--text-secondary, #909399);
}

.guestbook-item__text {
  font-size: 14px;
  color: var(--text-regular, #606266);
  line-height: 1.5;
  margin: 0;
  word-break: break-word;
}

.family-guestbook__empty {
  text-align: center;
  padding: var(--space-xl, 24px);
  color: var(--text-secondary, #909399);
}

.family-guestbook__empty p {
  margin: 4px 0;
  font-size: 13px;
}

.family-guestbook__more {
  text-align: center;
  padding: var(--space-md, 12px);
}
</style>
