<template>
  <!--
    NotificationPage - 通知中心页面
    包含分类Tab、通知列表、标记已读、全部已读等功能
  -->
  <div class="notification-center">
    <div class="notification-center__header">
      <h1 class="notification-center__title">通知中心</h1>
      <el-button type="primary" text @click="handleMarkAllRead">
        全部已读
      </el-button>
    </div>

    <!-- 分类Tab -->
    <div class="notification-tabs">
      <button
        v-for="tab in tabs"
        :key="tab.value"
        class="notification-tab"
        :class="{ 'is-active': activeTab === tab.value }"
        @click="activeTab = tab.value"
      >
        {{ tab.label }}
        <!-- 未读角标 -->
        <span
          v-if="tab.badgeKey && unreadCount[tab.badgeKey] > 0"
          class="notification-tab__badge"
        >
          {{ unreadCount[tab.badgeKey] > 99 ? '99+' : unreadCount[tab.badgeKey] }}
        </span>
      </button>
    </div>

    <!-- 通知列表 -->
    <div class="notification-list" v-loading="notificationStore.loading">
      <!-- 按天分组 -->
      <template v-if="notificationStore.notifications.length > 0">
        <template v-for="(group, date) in groupedNotifications" :key="date">
          <div class="notification-group__title">{{ date }}</div>
          <div
            v-for="notification in group"
            :key="notification.id"
            class="notification-item"
            :class="{ 'is-unread': !notification.isRead }"
            @click="handleNotificationClick(notification)"
          >
            <!-- 未读标记点 -->
            <div class="notification-item__dot" />

            <el-avatar :size="40" :src="notification.fromUserAvatar" />
            <div class="notification-item__content">
              <div class="notification-item__header">
                <span class="notification-item__username">{{ notification.fromUserName }}</span>
                <span class="notification-item__type">{{ getTypeText(notification.type) }}</span>
              </div>
              <p class="notification-item__text">{{ notification.content }}</p>
              <span class="notification-item__meta">{{ formatTime(notification.createdAt) }}</span>
            </div>
          </div>
        </template>
      </template>

      <!-- 空状态 -->
      <div v-else class="empty-state">
        <el-icon :size="64" color="#C0C4CC"><Bell /></el-icon>
        <h3 class="empty-state__title">暂无通知</h3>
        <p class="empty-state__desc">当有人与你互动时，这里会显示通知</p>
      </div>
    </div>

    <!-- 加载更多 -->
    <div v-if="hasMore" class="load-more">
      <el-button text type="primary" :loading="loadingMore" @click="loadMore">
        加载更多通知
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Bell } from '@element-plus/icons-vue'
import { useNotificationStore } from '@/store/notification'
import type { Notification, UnreadCount } from '@/types/profile'

const router = useRouter()
const notificationStore = useNotificationStore()

/** 当前选中的Tab */
const activeTab = ref('all')

/** 加载更多状态 */
const loadingMore = ref(false)

/** 是否还有更多数据 */
const hasMore = computed(() => {
  return notificationStore.notifications.length < notificationStore.pagination.total
})

/** 未读计数 */
const unreadCount = computed(() => notificationStore.unreadCount)

/** Tab配置 */
const tabs = computed(() => [
  { label: '全部', value: 'all', badgeKey: 'totalCount' },
  { label: '评论', value: 'COMMENT', badgeKey: 'commentCount' },
  { label: '点赞', value: 'LIKE', badgeKey: 'likeCount' },
  { label: '留言', value: 'GUESTBOOK', badgeKey: 'guestbookCount' },
  { label: '@我', value: 'MENTION', badgeKey: 'mentionCount' },
  { label: '回复', value: 'REPLY', badgeKey: 'replyCount' },
  { label: '私信', value: 'MESSAGE', badgeKey: 'messageCount' },
  { label: '系统', value: 'SYSTEM', badgeKey: 'systemCount' }
])

/** 按天分组的通知 */
const groupedNotifications = computed(() => {
  const groups: Record<string, Notification[]> = {}
  const now = new Date()

  notificationStore.notifications.forEach(notif => {
    const date = new Date(notif.createdAt)
    const diffDays = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24))

    let dateLabel: string
    if (diffDays === 0) {
      dateLabel = '今天'
    } else if (diffDays === 1) {
      dateLabel = '昨天'
    } else if (diffDays < 7) {
      dateLabel = `${diffDays}天前`
    } else {
      dateLabel = date.toLocaleDateString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
      })
    }

    if (!groups[dateLabel]) {
      groups[dateLabel] = []
    }
    groups[dateLabel].push(notif)
  })

  return groups
})

/** 获取通知类型文本 */
function getTypeText(type: string): string {
  const map: Record<string, string> = {
    'COMMENT': '评论了你的动态',
    'LIKE': '赞了你的内容',
    'GUESTBOOK': '',
    'MENTION': '提到了你',
    'REPLY': '回复了你的评论',
    'MESSAGE': '给你发了私信',
    'SYSTEM': '系统通知'
  }
  return map[type] || ''
}

/** 格式化时间 */
function formatTime(timeStr: string): string {
  const date = new Date(timeStr)
  const hours = date.getHours().toString().padStart(2, '0')
  const minutes = date.getMinutes().toString().padStart(2, '0')
  return `${hours}:${minutes}`
}

/** 点击通知 */
async function handleNotificationClick(notification: Notification) {
  if (!notification.isRead) {
    await notificationStore.markRead(notification.id)
  }

  // 根据目标类型跳转
  if (notification.targetType === 'POST' && notification.targetId) {
    // 可以跳转到动态详情
    ElMessage.info('跳转到动态详情功能开发中')
  }
}

/** 全部标记已读 */
async function handleMarkAllRead() {
  await notificationStore.markAllRead()
  ElMessage.success('已全部标记为已读')
}

/** 加载更多 */
async function loadMore() {
  loadingMore.value = true
  try {
    await notificationStore.loadMoreNotifications(
      activeTab.value === 'all' ? undefined : activeTab.value
    )
  } finally {
    loadingMore.value = false
  }
}

/** 切换Tab时重新加载 */
watch(activeTab, async (newTab) => {
  notificationStore.pagination.page = 1
  await notificationStore.fetchNotifications(newTab === 'all' ? undefined : newTab)
})

onMounted(async () => {
  await notificationStore.fetchUnreadCount()
  await notificationStore.fetchNotifications()
})
</script>

<style scoped>
.notification-center {
  padding: var(--space-xl, 24px);
  max-width: 900px;
  margin: 0 auto;
}

.notification-center__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--space-lg, 16px);
}

.notification-center__title {
  font-size: var(--font-h2, 22px);
  font-weight: 700;
  color: var(--text-primary, #303133);
}

.notification-tabs {
  display: flex;
  gap: var(--space-sm, 8px);
  margin-bottom: var(--space-xl, 24px);
  border-bottom: 1px solid var(--border-color-light, #E4E7ED);
  overflow-x: auto;
  scrollbar-width: none;
}

.notification-tabs::-webkit-scrollbar {
  display: none;
}

.notification-tab {
  padding: var(--space-md, 12px) var(--space-lg, 16px);
  font-size: var(--font-body, 14px);
  color: var(--text-secondary, #909399);
  background: none;
  border: none;
  border-bottom: 2px solid transparent;
  cursor: pointer;
  white-space: nowrap;
  transition: all var(--duration-fast, 100ms) var(--easing-out);
  position: relative;
}

.notification-tab.is-active {
  color: var(--primary-color, #409EFF);
  border-bottom-color: var(--primary-color, #409EFF);
  font-weight: 500;
}

.notification-tab__badge {
  position: absolute;
  top: var(--space-xs, 4px);
  right: 0;
  min-width: 16px;
  height: 16px;
  padding: 0 4px;
  font-size: 10px;
  line-height: 16px;
  text-align: center;
  color: white;
  background-color: var(--danger-color, #F56C6C);
  border-radius: var(--radius-full);
}

.notification-group__title {
  font-size: var(--font-body-sm, 13px);
  font-weight: 600;
  color: var(--text-secondary, #909399);
  padding: var(--space-md, 12px) 0 var(--space-sm, 8px);
  border-bottom: 1px solid var(--border-color-light, #E4E7ED);
  margin-bottom: var(--space-sm, 8px);
}

.notification-item {
  display: flex;
  gap: var(--space-md, 12px);
  padding: var(--space-md, 12px);
  border-radius: var(--radius-base, 4px);
  cursor: pointer;
  transition: background-color var(--duration-fast, 100ms) var(--easing-out);
  position: relative;
}

.notification-item:hover {
  background-color: var(--bg-color, #F4F4F5);
}

.notification-item.is-unread {
  background-color: var(--primary-color-light-1, #ECF5FF);
}

.notification-item__dot {
  position: absolute;
  left: var(--space-sm, 8px);
  top: var(--space-md, 12px);
  width: 8px;
  height: 8px;
  border-radius: var(--radius-full);
  background-color: var(--primary-color, #409EFF);
  flex-shrink: 0;
}

.notification-item.is-unread .notification-item__dot {
  display: block;
}

.notification-item:not(.is-unread) .notification-item__dot {
  display: none;
}

.notification-item__content {
  flex: 1;
  min-width: 0;
}

.notification-item__header {
  display: flex;
  align-items: center;
  gap: var(--space-sm, 8px);
  margin-bottom: var(--space-xs, 4px);
}

.notification-item__username {
  font-size: var(--font-body, 14px);
  font-weight: 600;
  color: var(--text-primary, #303133);
}

.notification-item__type {
  font-size: var(--font-caption, 12px);
  color: var(--text-secondary, #909399);
}

.notification-item__text {
  font-size: var(--font-body-sm, 13px);
  color: var(--text-regular, #606266);
  margin-bottom: var(--space-xs, 4px);
}

.notification-item__meta {
  font-size: var(--font-caption, 12px);
  color: var(--text-secondary, #909399);
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--space-xxxl, 48px) var(--space-xl, 24px);
  text-align: center;
  color: var(--text-secondary, #909399);
}

.load-more {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-xl, 24px) 0;
}
</style>
