<template>
  <div class="profile-page">
    <ProfileHeader
      :profile="profileStore.currentProfile"
      @edit="handleEditProfile"
      @message="handleMessage"
      @view-relation="handleViewRelation"
      @cover-change="handleCoverChange"
      @avatar-change="handleAvatarChange"
    />

    <div class="profile-container">
      <ProfileTabs v-model="activeTab" />

      <div class="profile-content">
        <template v-if="activeTab === 'posts'">
          <!-- 发布动态入口（仅主人可见） -->
          <div v-if="isOwner" class="post-entry">
            <el-avatar :size="40">
              <el-icon :size="24"><User /></el-icon>
            </el-avatar>
            <div class="post-entry__input" @click="showPostDialog = true">
              <span>分享你的生活点滴...</span>
            </div>
          </div>

          <div v-loading="profileStore.loading">
            <CategoryFilter
              v-if="isOwner"
              :categories="profileStore.categories"
              v-model="selectedCategory"
              @change="handleCategoryChange"
            />

            <TimelinePost
              v-for="post in profileStore.posts"
              :key="post.id"
              :post="post"
            />

            <div v-if="!profileStore.posts.length && !profileStore.loading" class="empty-state">
              <el-icon :size="64" color="#C0C4CC"><Document /></el-icon>
              <h3 class="empty-state__title">暂无动态</h3>
              <p class="empty-state__desc">{{ isOwner ? '点击上方发布按钮开始分享吧' : '该用户还没有发布动态' }}</p>
            </div>

            <div v-if="hasMorePosts" class="load-more">
              <el-button text type="primary" :loading="loadingMore" @click="loadMorePosts">
                加载更多
              </el-button>
            </div>
          </div>
        </template>

        <template v-if="activeTab === 'about'">
          <AboutMe :profile="profileStore.currentProfile" />
        </template>
      </div>
    </div>

    <!-- 发布动态对话框 -->
    <PostDialog
      v-model="showPostDialog"
      :categories="profileStore.categories"
      @success="handlePostSuccess"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, onUnmounted, defineAsyncComponent } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Document, User } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { useProfileStore } from '@/store/profile'
import ProfileHeader from '@/components/profile/ProfileHeader.vue'
import ProfileTabs from '@/components/profile/ProfileTabs.vue'
import CategoryFilter from '@/components/profile/CategoryFilter.vue'
import TimelinePost from '@/components/profile/TimelinePost.vue'
import PostDialog from '@/components/profile/PostDialog.vue'

const AboutMe = defineAsyncComponent(() => import('@/components/profile/AboutMe.vue'))

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const profileStore = useProfileStore()

const userId = computed(() => Number(route.params.userId))
const isOwner = computed(() => userId.value === userStore.userInfo?.userId)

const activeTab = ref('posts')
const selectedCategory = ref<number | null>(null)
const loadingMore = ref(false)
const showPostDialog = ref(false)

const hasMorePosts = computed(() => {
  return profileStore.posts.length < profileStore.pagination.total
})

async function fetchProfileData() {
  if (userId.value) {
    await profileStore.fetchProfile(userId.value)
    await fetchPosts()
    await profileStore.fetchCategories()
  }
}

async function fetchPosts() {
  await profileStore.fetchPosts(userId.value, { categoryId: selectedCategory.value })
}

async function loadMorePosts() {
  loadingMore.value = true
  try {
    await profileStore.loadMorePosts(userId.value, { categoryId: selectedCategory.value })
  } finally {
    loadingMore.value = false
  }
}

function handleCategoryChange(params: { categoryId?: number }) {
  selectedCategory.value = params.categoryId ?? null
  profileStore.pagination.page = 1
  fetchPosts()
}

async function handlePostSuccess() {
  showPostDialog.value = false
  await fetchPosts()
}

function handleEditProfile() {
  ElMessage.info('编辑主页功能开发中')
}

function handleMessage() {
  router.push('/messages')
}

function handleViewRelation() {
  ElMessage.info('查看关系功能开发中')
}

async function handleCoverChange(url: string) {
  try {
    await profileStore.updateProfile({ backgroundUrl: url })
    if (profileStore.currentProfile) {
      profileStore.currentProfile.backgroundUrl = url
    }
    ElMessage.success('封面更换成功')
  } catch (error) {
    ElMessage.error('封面更换失败')
  }
}

async function handleAvatarChange(url: string) {
  try {
    await profileStore.updateProfile({ avatarUrl: url } as any)
    if (profileStore.currentProfile) {
      (profileStore.currentProfile as any).avatarUrl = url
    }
    ElMessage.success('头像更换成功')
  } catch (error) {
    ElMessage.error('头像更换失败')
  }
}

watch(() => route.params.userId, async () => {
  profileStore.resetState()
  await fetchProfileData()
}, { immediate: false })

onMounted(async () => {
  await fetchProfileData()
})

onUnmounted(() => {
  profileStore.resetState()
})
</script>

<style scoped>
.profile-page {
  max-width: 1000px;
  margin: 0 auto;
  padding: var(--space-lg, 16px);
}

.profile-container {
  margin-top: var(--space-lg, 16px);
}

.profile-content {
  margin-top: var(--space-lg, 16px);
}

.post-entry {
  display: flex;
  align-items: center;
  gap: var(--space-md, 12px);
  padding: var(--space-md, 12px);
  background: #fff;
  border-radius: var(--radius-lg, 12px);
  margin-bottom: var(--space-lg, 16px);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.post-entry__input {
  flex: 1;
  padding: var(--space-sm, 8px) var(--space-md, 12px);
  background: var(--bg-color-light, #f5f7fa);
  border-radius: var(--radius-full, 20px);
  color: var(--text-secondary, #909399);
  cursor: pointer;
  transition: background var(--duration-base, 200ms);
}

.post-entry__input:hover {
  background: var(--bg-color, #f0f2f5);
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
}

.empty-state p {
  margin-top: var(--space-sm, 8px);
}

.load-more {
  display: flex;
  justify-content: center;
  padding: var(--space-lg, 16px);
}
</style>
