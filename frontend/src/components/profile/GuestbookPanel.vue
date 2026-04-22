<template>
  <!--
    GuestbookPanel - 留言板组件
    支持留言发布、列表展示、点赞、删除等功能
  -->
  <div class="guestbook-panel">
    <div class="guestbook-panel__header">
      <h3 class="guestbook-panel__title">留言板</h3>
    </div>

    <!-- 留言输入区 -->
    <div class="guestbook-input">
      <el-avatar :size="36">
        <el-icon><User /></el-icon>
      </el-avatar>
      <div class="guestbook-input__box">
        <textarea
          v-model="guestbookText"
          class="guestbook-input__textarea"
          placeholder="留下你想说的话..."
          maxlength="500"
          rows="3"
        />
        <div class="guestbook-input__actions">
          <el-button
            type="primary"
            size="small"
            :loading="submitting"
            :disabled="!guestbookText.trim()"
            @click="handleSubmit"
          >
            发布留言
          </el-button>
        </div>
      </div>
    </div>

    <!-- 留言列表 -->
    <div class="guestbook-list" v-loading="loading">
      <template v-if="guestbookList.length === 0 && !loading">
        <div class="empty-state">
          <el-icon :size="48" color="#C0C4CC"><ChatDotRound /></el-icon>
          <p class="empty-state__desc">暂无留言，快来抢沙发吧</p>
        </div>
      </template>

      <div
        v-for="item in guestbookList"
        :key="item.id"
        class="guestbook-item"
      >
        <el-avatar :size="36" class="guestbook-item__avatar">
          <el-icon><User /></el-icon>
        </el-avatar>
        <div class="guestbook-item__content">
          <div class="guestbook-item__header">
            <span class="guestbook-item__username">{{ item.userName }}</span>
            <span class="guestbook-item__time">{{ formatTime(item.createdAt) }}</span>
          </div>
          <p class="guestbook-item__text">{{ item.content }}</p>
          <div class="guestbook-item__actions">
            <LikeButton
              :is-liked="item.isLiked"
              :like-count="item.likeCount"
              @toggle="handleLike(item.id)"
            />
            <button
              v-if="canDelete(item)"
              class="comment-item__action"
              @click="handleDelete(item.id)"
            >
              <el-icon :size="14"><Delete /></el-icon>
              删除
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 加载更多 -->
    <div v-if="hasMore" class="comment-load-more">
      <el-button text type="primary" :loading="loadingMore" @click="loadMore">
        加载更多留言
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ChatDotRound, Delete, User } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { useProfileStore } from '@/store/profile'
import { guestbookApi } from '@/api/profile'
import LikeButton from '@/components/profile/LikeButton.vue'
import type { MessageBoard } from '@/types/profile'

interface Props {
  userId: number
}

const props = defineProps<Props>()

const userStore = useUserStore()
const profileStore = useProfileStore()

const guestbookList = ref<MessageBoard[]>([])
const guestbookText = ref('')
const loading = ref(false)
const loadingMore = ref(false)
const submitting = ref(false)
const hasMore = ref(false)
const page = ref(1)

const isOwner = computed(() => props.userId === userStore.userInfo?.userId)

/** 是否可以删除 */
function canDelete(item: MessageBoard): boolean {
  return isOwner.value || item.userId === userStore.userInfo?.userId
}

/** 获取留言列表 */
async function fetchGuestbook(reset = false) {
  if (reset) {
    page.value = 1
    guestbookList.value = []
  }

  loading.value = true
  try {
    const res = await guestbookApi.getGuestbookList(props.userId, {
      page: page.value,
      size: 10
    })
    if (reset) {
      guestbookList.value = res.data.records
    } else {
      guestbookList.value = [...guestbookList.value, ...res.data.records]
    }
    hasMore.value = guestbookList.value.length < res.data.total
  } catch (error) {
    console.error('获取留言失败', error)
  } finally {
    loading.value = false
  }
}

/** 加载更多 */
async function loadMore() {
  page.value++
  await fetchGuestbook()
}

/** 提交留言 */
async function handleSubmit() {
  if (!guestbookText.value.trim()) return

  submitting.value = true
  try {
    await guestbookApi.createGuestbook(props.userId, {
      content: guestbookText.value
    })

    ElMessage.success('留言成功')
    guestbookText.value = ''
    await fetchGuestbook(true)
  } catch (error) {
    ElMessage.error('留言失败')
  } finally {
    submitting.value = false
  }
}

/** 处理点赞 */
function handleLike(guestbookId: number) {
  profileStore.toggleLike('GUESTBOOK', guestbookId)
}

/** 删除留言 */
async function handleDelete(guestbookId: number) {
  try {
    await ElMessageBox.confirm('确定要删除这条留言吗？', '确认删除', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await guestbookApi.deleteGuestbook(guestbookId)
    ElMessage.success('留言已删除')
    await fetchGuestbook(true)
  } catch {
    // 用户取消
  }
}

/** 格式化时间 */
function formatTime(timeStr: string): string {
  const date = new Date(timeStr)
  const now = new Date()
  const diffMs = now.getTime() - date.getTime()
  const diffMin = Math.floor(diffMs / 60000)
  const diffHour = Math.floor(diffMin / 60)
  const diffDay = Math.floor(diffHour / 24)

  if (diffMin < 60) return `${diffMin}分钟前`
  if (diffHour < 24) return `${diffHour}小时前`
  if (diffDay < 7) return `${diffDay}天前`
  return date.toLocaleDateString('zh-CN', { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })
}

/** 监听userId变化，重新获取 */
watch(() => props.userId, () => {
  fetchGuestbook(true)
}, { immediate: true })

defineExpose({ fetchGuestbook })
</script>

<style scoped>
.guestbook-panel {
  background: var(--bg-color-overlay, #FFFFFF);
  border-radius: var(--radius-md, 8px);
  box-shadow: var(--shadow-light, 0 2px 4px rgba(0, 0, 0, 0.08));
  padding: var(--space-lg, 16px);
}

.guestbook-panel__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--space-lg, 16px);
}

.guestbook-panel__title {
  font-size: var(--font-h4, 16px);
  font-weight: 600;
  color: var(--text-primary, #303133);
}

.guestbook-input {
  display: flex;
  gap: var(--space-md, 12px);
  margin-bottom: var(--space-xl, 24px);
  align-items: flex-start;
}

.guestbook-input__box {
  flex: 1;
}

.guestbook-input__textarea {
  width: 100%;
  padding: var(--space-md, 12px);
  font-size: var(--font-body, 14px);
  line-height: var(--line-height-body, 1.6);
  color: var(--text-primary, #303133);
  background-color: var(--bg-color-page, #F9F6F0);
  border: 1px solid var(--border-color, #DCDFE6);
  border-radius: var(--radius-base, 4px);
  resize: none;
  min-height: 60px;
  transition: border-color var(--duration-fast, 100ms) var(--easing-out);
}

.guestbook-input__textarea:focus {
  outline: none;
  border-color: var(--primary-color, #409EFF);
  box-shadow: 0 0 0 2px var(--primary-color-light-1, #ECF5FF);
}

.guestbook-input__textarea::placeholder {
  color: var(--text-placeholder, #C0C4CC);
}

.guestbook-input__actions {
  display: flex;
  justify-content: flex-end;
  margin-top: var(--space-sm, 8px);
}

.guestbook-list {
  display: flex;
  flex-direction: column;
}

.guestbook-item {
  display: flex;
  gap: var(--space-md, 12px);
  padding: var(--space-lg, 16px) 0;
  border-bottom: 1px solid var(--border-color-light, #E4E7ED);
}

.guestbook-item:last-child {
  border-bottom: none;
}

.guestbook-item__avatar {
  flex-shrink: 0;
}

.guestbook-item__content {
  flex: 1;
  min-width: 0;
}

.guestbook-item__header {
  display: flex;
  align-items: center;
  gap: var(--space-sm, 8px);
  margin-bottom: var(--space-xs, 4px);
}

.guestbook-item__username {
  font-size: var(--font-body, 14px);
  font-weight: 600;
  color: var(--text-primary, #303133);
}

.guestbook-item__time {
  font-size: var(--font-caption, 12px);
  color: var(--text-secondary, #909399);
}

.guestbook-item__text {
  font-size: var(--font-body, 14px);
  line-height: var(--line-height-body, 1.6);
  color: var(--text-primary, #303133);
  margin-bottom: var(--space-sm, 8px);
}

.guestbook-item__actions {
  display: flex;
  align-items: center;
  gap: var(--space-lg, 16px);
}

.comment-item__action {
  display: inline-flex;
  align-items: center;
  gap: var(--space-xs, 4px);
  font-size: var(--font-caption, 12px);
  color: var(--text-secondary, #909399);
  background: none;
  border: none;
  cursor: pointer;
  padding: var(--space-xs, 4px) 0;
  transition: color var(--duration-fast, 100ms) var(--easing-out);
}

.comment-item__action:hover {
  color: var(--primary-color, #409EFF);
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--space-xl, 24px) 0;
  text-align: center;
}

.comment-load-more {
  display: flex;
  justify-content: center;
  padding: var(--space-lg, 16px) 0;
}
</style>
