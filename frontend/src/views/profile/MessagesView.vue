<template>
  <div class="messages-page">
    <!-- 顶部导航栏 -->
    <div class="messages-header">
      <div class="header-left">
        <el-button text @click="goBack">
          <el-icon><ArrowLeft /></el-icon>
        </el-button>
      </div>
      <div class="header-title">消息中心</div>
      <div class="header-right">
        <el-button text @click="markAllRead" v-if="unreadCount > 0">
          全部已读
        </el-button>
      </div>
    </div>

    <!-- 标签页 -->
    <el-tabs v-model="activeTab" class="messages-tabs">
      <el-tab-pane label="通知" name="notifications">
        <template #label>
          通知<span class="tab-badge" v-if="notificationCount > 0">{{ notificationCount }}</span>
        </template>
      </el-tab-pane>
      <el-tab-pane label="私信" name="messages">
        <template #label>
          私信<span class="tab-badge" v-if="unreadMessageCount > 0">{{ unreadMessageCount }}</span>
        </template>
      </el-tab-pane>
    </el-tabs>

    <!-- 通知列表 -->
    <div class="notification-list" v-if="activeTab === 'notifications'">
      <div
        v-for="item in notifications"
        :key="item.notificationId"
        class="notification-item"
        :class="{ unread: !item.isRead }"
        @click="handleNotificationClick(item)"
      >
        <div class="notification-icon" :style="{ backgroundColor: getNotificationColor(item.type) }">
          {{ getNotificationIcon(item.type) }}
        </div>
        <div class="notification-content">
          <div class="notification-header">
            <el-avatar :size="32" :src="item.triggerUserAvatar">
              {{ item.triggerUserName?.charAt(0) }}
            </el-avatar>
            <div class="notification-info">
              <div class="notification-title">{{ item.triggerUserName }} {{ item.title }}</div>
              <div class="notification-time">{{ formatTime(item.createdAt) }}</div>
            </div>
          </div>
          <div class="notification-text" v-if="item.content">{{ item.content }}</div>
        </div>
        <div class="notification-badge" v-if="!item.isRead"></div>
      </div>
      <el-empty v-if="notifications.length === 0" description="暂无通知" />
    </div>

    <!-- 私信列表 -->
    <div class="message-list" v-if="activeTab === 'messages'">
      <div
        v-for="item in conversations"
        :key="item.conversationKey"
        class="conversation-item"
        :class="{ unread: !item.isRead }"
        @click="goToChat(item)"
      >
        <el-avatar :size="48" :src="item.avatar">
          {{ item.name?.charAt(0) }}
        </el-avatar>
        <div class="conversation-content">
          <div class="conversation-header">
            <span class="conversation-name">{{ item.name }}</span>
            <span class="conversation-time">{{ formatTime(item.lastMessageTime) }}</span>
          </div>
          <div class="conversation-preview">{{ item.lastMessage }}</div>
        </div>
        <div class="unread-badge" v-if="item.unreadCount > 0">
          {{ item.unreadCount > 99 ? '99+' : item.unreadCount }}
        </div>
      </div>
      <el-empty v-if="conversations.length === 0" description="暂无私信" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'
import {
  getNotifications, markNotificationRead, markAllNotificationsRead,
  getMessages
} from '@/api/profile'
import type { NotificationDTO, MessageDTO } from '@/types/profile'
import { NotificationTypeEnum } from '@/types/profile'

const router = useRouter()

const activeTab = ref('notifications')
const notifications = ref<NotificationDTO[]>([])
const messages = ref<MessageDTO[]>([])

// 计算未读数量
const notificationCount = computed(() => {
  return notifications.value.filter(n => !n.isRead).length
})

const unreadMessageCount = computed(() => {
  return messages.value.filter(m => !m.isRead && !m.isSelf).length
})

const unreadCount = computed(() => {
  return notificationCount.value + unreadMessageCount.value
})

// 转换为会话列表
const conversations = computed(() => {
  const map = new Map<string, {
    conversationKey: string
    userId: number
    name: string
    avatar?: string
    lastMessage: string
    lastMessageTime: string
    isRead: boolean
    unreadCount: number
  }>()

  messages.value.forEach(msg => {
    const otherUserId = msg.isSelf ? msg.receiverId : msg.senderId
    const otherName = msg.isSelf ? msg.receiverName : msg.senderName
    const otherAvatar = msg.isSelf ? msg.receiverAvatar : msg.senderAvatar
    const key = `user_${otherUserId}`

    if (!map.has(key)) {
      map.set(key, {
        conversationKey: key,
        userId: otherUserId,
        name: otherName || '未知用户',
        avatar: otherAvatar,
        lastMessage: msg.content,
        lastMessageTime: msg.createdAt,
        isRead: msg.isRead || msg.isSelf,
        unreadCount: (!msg.isRead && !msg.isSelf) ? 1 : 0
      })
    } else {
      const existing = map.get(key)!
      if (new Date(msg.createdAt) > new Date(existing.lastMessageTime)) {
        existing.lastMessage = msg.content
        existing.lastMessageTime = msg.createdAt
      }
      if (!msg.isRead && !msg.isSelf) {
        existing.unreadCount++
        existing.isRead = false
      }
    }
  })

  return Array.from(map.values()).sort((a, b) =>
    new Date(b.lastMessageTime).getTime() - new Date(a.lastMessageTime).getTime()
  )
})

const loadNotifications = async () => {
  try {
    const res = await getNotifications()
    notifications.value = res.data.records
  } catch (error) {
    console.error('加载通知失败', error)
  }
}

const loadMessages = async () => {
  try {
    const res = await getMessages()
    messages.value = res.data.records
  } catch (error) {
    console.error('加载私信失败', error)
  }
}

const formatTime = (time: string) => {
  const date = new Date(time)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)

  if (minutes < 1) return '刚刚'
  if (minutes < 60) return `${minutes}分钟前`
  if (hours < 24) return `${hours}小时前`
  if (days < 7) return `${days}天前`
  return date.toLocaleDateString()
}

const getNotificationIcon = (type: string) => {
  const config = NotificationTypeEnum[type as keyof typeof NotificationTypeEnum]
  return config?.icon || '🔔'
}

const getNotificationColor = (type: string) => {
  const config = NotificationTypeEnum[type as keyof typeof NotificationTypeEnum]
  return config?.color || '#1456f0'
}

const handleNotificationClick = async (item: NotificationDTO) => {
  if (!item.isRead) {
    try {
      await markNotificationRead(item.notificationId)
      item.isRead = true
    } catch (error) {
      console.error('标记已读失败', error)
    }
  }

  // 根据资源类型跳转到对应页面
  if (item.resourceType === 'post' && item.resourceId) {
    router.push(`/profile/post/${item.resourceId}`)
  } else if (item.resourceType === 'message') {
    activeTab.value = 'messages'
  }
}

const markAllRead = async () => {
  try {
    await markAllNotificationsRead()
    notifications.value.forEach(n => n.isRead = true)
    ElMessage.success('已全部标记为已读')
  } catch (error) {
    console.error('标记全部已读失败', error)
  }
}

const goToChat = (conversation: any) => {
  router.push(`/messages?to=${conversation.userId}`)
}

const goBack = () => {
  router.back()
}

onMounted(() => {
  loadNotifications()
  loadMessages()
})
</script>

<style scoped lang="scss">
.messages-page {
  min-height: 100vh;
  background: #f5f5f5;
}

.messages-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  background: #fff;
  border-bottom: 1px solid #e5e7eb;

  .header-title {
    font-size: 16px;
    font-weight: 500;
  }
}

.messages-tabs {
  background: #fff;

  .tab-badge {
    display: inline-block;
    padding: 0 6px;
    margin-left: 4px;
    font-size: 10px;
    background: #ef4444;
    color: #fff;
    border-radius: 10px;
    min-width: 16px;
    text-align: center;
  }
}

.notification-list {
  padding: 12px 16px;
}

.notification-item {
  display: flex;
  gap: 12px;
  padding: 12px;
  background: #fff;
  border-radius: 12px;
  margin-bottom: 8px;
  cursor: pointer;
  position: relative;
  transition: background 0.3s;

  &:hover {
    background: #fafafa;
  }

  &.unread {
    background: #f0f7ff;
  }

  .notification-icon {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    flex-shrink: 0;
  }

  .notification-content {
    flex: 1;
    min-width: 0;

    .notification-header {
      display: flex;
      gap: 8px;

      .notification-info {
        flex: 1;

        .notification-title {
          font-size: 14px;
          color: #222;
          font-weight: 500;
        }

        .notification-time {
          font-size: 12px;
          color: #8e8e93;
          margin-top: 2px;
        }
      }
    }

    .notification-text {
      font-size: 13px;
      color: #45515e;
      margin-top: 4px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }

  .notification-badge {
    width: 8px;
    height: 8px;
    background: #ef4444;
    border-radius: 50%;
    position: absolute;
    top: 12px;
    right: 12px;
  }
}

.message-list {
  padding: 12px 16px;
}

.conversation-item {
  display: flex;
  gap: 12px;
  padding: 12px;
  background: #fff;
  border-radius: 12px;
  margin-bottom: 8px;
  cursor: pointer;
  position: relative;
  transition: background 0.3s;

  &:hover {
    background: #fafafa;
  }

  &.unread {
    background: #f0f7ff;
  }

  .conversation-content {
    flex: 1;
    min-width: 0;

    .conversation-header {
      display: flex;
      justify-content: space-between;
      align-items: center;

      .conversation-name {
        font-size: 15px;
        font-weight: 500;
        color: #222;
      }

      .conversation-time {
        font-size: 12px;
        color: #8e8e93;
      }
    }

    .conversation-preview {
      font-size: 13px;
      color: #45515e;
      margin-top: 4px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }

  .unread-badge {
    position: absolute;
    top: 8px;
    right: 8px;
    padding: 0 6px;
    font-size: 10px;
    background: #ef4444;
    color: #fff;
    border-radius: 10px;
    min-width: 16px;
    text-align: center;
  }
}
</style>
