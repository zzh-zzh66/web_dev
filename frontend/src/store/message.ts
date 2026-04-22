/**
 * MessageStore - 管理私信状态
 */
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { messageApi } from '@/api/profile'
import type { MessageSession, PrivateMessage } from '@/types/profile'

export const useMessageStore = defineStore('message', () => {
  const sessions = ref<MessageSession[]>([])
  const currentSession = ref<MessageSession | null>(null)
  const messages = ref<PrivateMessage[]>([])
  const loading = ref(false)
  const peerUser = ref<{ userId: number; userName: string; userAvatar: string } | null>(null)

  /** 获取私信会话列表 */
  async function fetchSessions() {
    loading.value = true
    try {
      const res = await messageApi.getMessageSessions({ page: 1, size: 50 })
      sessions.value = res.data.records
    } finally {
      loading.value = false
    }
  }

  /** 获取私信会话消息 */
  async function fetchSessionMessages(sessionId: number) {
    loading.value = true
    try {
      const res = await messageApi.getSessionMessages(sessionId, { page: 1, size: 50 })
      messages.value = res.data.records
      // 标记已读
      await messageApi.markSessionRead(sessionId)
      // 更新会话列表中的未读计数
      const session = sessions.value.find(s => s.sessionId === sessionId)
      if (session) {
        session.unreadCount = 0
      }
    } finally {
      loading.value = false
    }
  }

  /** 加载更多消息 */
  async function loadMoreMessages(sessionId: number) {
    loading.value = true
    try {
      const currentPage = Math.ceil(messages.value.length / 50) + 1
      const res = await messageApi.getSessionMessages(sessionId, { page: currentPage, size: 50 })
      messages.value = [...res.data.records, ...messages.value]
    } finally {
      loading.value = false
    }
  }

  /** 发送私信 */
  async function sendMessage(data: { receiverId: number; msgType: 'TEXT' | 'IMAGE'; content: string }) {
    const res = await messageApi.createMessage(data)
    messages.value.push(res.data)

    // 更新会话列表
    const sessionIndex = sessions.value.findIndex(s => s.sessionId === res.data.sessionId)
    if (sessionIndex !== -1) {
      sessions.value[sessionIndex].lastMessage = data.content
      sessions.value[sessionIndex].lastMessageTime = res.data.createdAt
      // 将当前会话移到列表顶部
      const session = sessions.value.splice(sessionIndex, 1)[0]
      sessions.value.unshift(session)
    } else {
      // 新会话
      fetchSessions()
    }

    return res.data
  }

  /** 设置当前会话 */
  function setCurrentSession(session: MessageSession) {
    currentSession.value = session
  }

  /** 标记会话已读 */
  async function markSessionRead(sessionId: number) {
    await messageApi.markSessionRead(sessionId)
    const session = sessions.value.find(s => s.sessionId === sessionId)
    if (session) {
      session.unreadCount = 0
    }
  }

  /** 实时推送新消息 */
  function pushMessage(message: PrivateMessage) {
    messages.value.push(message)
    // 更新会话列表
    const session = sessions.value.find(s => s.sessionId === message.sessionId)
    if (session) {
      session.lastMessage = message.content
      session.lastMessageTime = message.createdAt
      if (currentSession.value?.sessionId !== message.sessionId) {
        session.unreadCount++
      }
    }
  }

  /** 重置状态 */
  function resetState() {
    sessions.value = []
    currentSession.value = null
    messages.value = []
    peerUser.value = null
  }

  return {
    sessions,
    currentSession,
    messages,
    loading,
    peerUser,
    fetchSessions,
    fetchSessionMessages,
    loadMoreMessages,
    sendMessage,
    setCurrentSession,
    markSessionRead,
    pushMessage,
    resetState
  }
})
