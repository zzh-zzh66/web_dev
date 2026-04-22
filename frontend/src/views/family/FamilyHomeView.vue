<template>
  <div class="family-home">
    <div class="family-home__header">
      <h1 class="family-home__title">{{ familyName }} - 家族动态</h1>
      <p class="family-home__subtitle">记录家族故事，传承家族文化</p>
    </div>

    <div class="family-home__content">
      <div class="family-home__main">
        <!-- 动态列表 -->
        <div v-loading="loading" class="post-list">
          <TimelinePost
            v-for="post in posts"
            :key="post.id"
            :post="post"
          />
          <div v-if="!loading && posts.length === 0" class="empty-state">
            <el-icon :size="64" color="#C0C4CC"><Document /></el-icon>
            <h3>暂无动态</h3>
            <p>家族还没有发布动态</p>
          </div>
        </div>

        <div v-if="hasMore" class="load-more">
          <el-button text type="primary" :loading="loadingMore" @click="loadMore">加载更多</el-button>
        </div>
      </div>

      <div class="family-home__sidebar">
        <FamilyGuestbook />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Document } from '@element-plus/icons-vue'
import { contentApi } from '@/api/profile'
import TimelinePost from '@/components/profile/TimelinePost.vue'
import FamilyGuestbook from '@/components/family/FamilyGuestbook.vue'
import type { TimelinePost as TimelinePostType } from '@/types/profile'

const familyName = ref('张氏家族')
const posts = ref<TimelinePostType[]>([])
const loading = ref(false)
const loadingMore = ref(false)
const page = ref(1)
const pageSize = 20
const total = ref(0)

const hasMore = computed(() => posts.value.length < total.value)

async function fetchPosts() {
  loading.value = true
  try {
    const res = await contentApi.getFamilyPosts({
      page: page.value,
      size: pageSize
    })
    posts.value = res.data.records
    total.value = res.data.total
  } catch (error) {
    console.error('获取动态失败', error)
  } finally {
    loading.value = false
  }
}

async function loadMore() {
  loadingMore.value = true
  page.value++
  try {
    const res = await contentApi.getFamilyPosts({
      page: page.value,
      size: pageSize
    })
    posts.value = [...posts.value, ...res.data.records]
    total.value = res.data.total
  } catch (error) {
    console.error('加载更多失败', error)
    page.value--
  } finally {
    loadingMore.value = false
  }
}

onMounted(() => {
  fetchPosts()
})
</script>

<style scoped>
.family-home {
  max-width: 1200px;
  margin: 0 auto;
  padding: var(--space-lg, 16px);
}

.family-home__header {
  text-align: center;
  padding: var(--space-xl, 24px) 0;
  margin-bottom: var(--space-lg, 16px);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: var(--radius-lg, 12px);
  color: #fff;
}

.family-home__title {
  font-size: 24px;
  font-weight: 600;
  margin-bottom: 8px;
}

.family-home__subtitle {
  font-size: 14px;
  opacity: 0.9;
}

.family-home__content {
  display: grid;
  grid-template-columns: 1fr 320px;
  gap: var(--space-lg, 16px);
}

@media (max-width: 992px) {
  .family-home__content {
    grid-template-columns: 1fr;
  }
}

.post-list {
  min-height: 200px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--space-xxxl, 48px);
  text-align: center;
  color: var(--text-secondary, #909399);
}

.empty-state h3 {
  margin-top: var(--space-md, 12px);
  font-size: 16px;
}

.empty-state p {
  margin-top: var(--space-sm, 8px);
  font-size: 14px;
}

.load-more {
  display: flex;
  justify-content: center;
  padding: var(--space-lg, 16px);
}

.family-home__sidebar {
  position: sticky;
  top: 80px;
  height: fit-content;
}

@media (max-width: 992px) {
  .family-home__sidebar {
    position: static;
  }
}
</style>
