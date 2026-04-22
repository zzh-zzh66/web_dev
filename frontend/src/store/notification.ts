/**
 * NotificationStore - 管理通知状态
 */
import { defineStore } from 'pinia'
import { ref, reactive } from 'vue'
import { notificationApi } from '@/api/profile'
import type { Notification, UnreadCount } from '@/types/profile'

export const useNotificationStore = defineStore('notification', () => {
  const notifications = ref<Notification[]>([])
  const unreadCount = ref<UnreadCount>({
    totalCount: 0,
    commentCount: 0,
    replyCount: 0,
    likeCount: 0,
    guestbookCount: 0,
    mentionCount: 0,
    messageCount: 0,
    systemCount: 0
  })
  const loading = ref(false)
  const pagination = reactive({ page: 1, size: 20, total: 0 })

  /** 获取通知列表 */
  async function fetchNotifications(type?: string) {
    loading.value = true
    try {
      const res = await notificationApi.getNotifications({
        type,
        page: pagination.page,
        size: pagination.size
      })
      notifications.value = res.data.records
      pagination.total = res.data.total
    } finally {
      loading.value = false
    }
  }

  /** 加载更多通知 */
  async function loadMoreNotifications(type?: string) {
    if (pagination.page * pagination.size >= pagination.total) return
    pagination.page++
    loading.value = true
    try {
      const res = await notificationApi.getNotifications({
        type,
        page: pagination.page,
        size: pagination.size
      })
      notifications.value = [...notifications.value, ...res.data.records]
    } finally {
      loading.value = false
    }
  }

  /** 获取未读通知数量 */
  async function fetchUnreadCount() {
    try {
      const res = await notificationApi.getUnreadCount()
      unreadCount.value = res.data
    } catch (error) {
      console.error('获取未读通知数量失败', error)
    }
  }

  /** 标记通知已读 */
  async function markRead(notificationId: number) {
    await notificationApi.markNotificationRead(notificationId)
    const notification = notifications.value.find(n => n.id === notificationId)
    if (notification) {
      notification.isRead = true
    }
    // 更新未读计数
    if (unreadCount.value.totalCount > 0) {
      unreadCount.value.totalCount--
    }
  }

  /** 全部标记已读 */
  async function markAllRead() {
    await notificationApi.markAllNotificationsRead()
    notifications.value.forEach(n => (n.isRead = true))
    unreadCount.value.totalCount = 0
    unreadCount.value.commentCount = 0
    unreadCount.value.replyCount = 0
    unreadCount.value.likeCount = 0
    unreadCount.value.guestbookCount = 0
    unreadCount.value.mentionCount = 0
    unreadCount.value.messageCount = 0
    unreadCount.value.systemCount = 0
  }

  /** 实时推送新通知 */
  function pushNotification(notification: Notification) {
    notifications.value.unshift(notification)
    pagination.total++
    unreadCount.value.totalCount++
    // 根据类型更新对应的未读计数
    switch (notification.type) {
      case 'COMMENT':
        unreadCount.value.commentCount++
        break
      case 'REPLY':
        unreadCount.value.replyCount++
        break
      case 'LIKE':
        unreadCount.value.likeCount++
        break
      case 'GUESTBOOK':
        unreadCount.value.guestbookCount++
        break
      case 'MENTION':
        unreadCount.value.mentionCount++
        break
      case 'MESSAGE':
        unreadCount.value.messageCount++
        break
      case 'SYSTEM':
        unreadCount.value.systemCount++
        break
    }
  }

  /** 重置状态 */
  function resetState() {
    notifications.value = []
    pagination.page = 1
    pagination.total = 0
  }

  return {
    notifications,
    unreadCount,
    loading,
    pagination,
    fetchNotifications,
    loadMoreNotifications,
    fetchUnreadCount,
    markRead,
    markAllRead,
    pushNotification,
    resetState
  }
})
