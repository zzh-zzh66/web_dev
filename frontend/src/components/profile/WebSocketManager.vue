<template>
  <!--
    WebSocketManager - WebSocket连接管理组件（隐藏组件）
    负责建立WebSocket连接、心跳检测、接收通知和私信推送
    在App.vue中全局使用
  -->
  <div style="display: none">
    <!-- 这是一个不可见的管理组件，只负责逻辑 -->
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue'
import { useUserStore } from '@/store/user'
import { useNotificationStore } from '@/store/notification'
import { useMessageStore } from '@/store/message'
import type { Notification, PrivateMessage, MessageSession, UnreadCount } from '@/types/profile'

const userStore = useUserStore()
const notificationStore = useNotificationStore()
const messageStore = useMessageStore()

let ws: WebSocket | null = null
let heartbeatTimer: number | null = null
let reconnectTimer: number | null = null
let reconnectAttempts = 0
const maxReconnectAttempts = 5
const heartbeatInterval = 30000 // 30秒
const reconnectBaseDelay = 3000

/** 建立WebSocket连接 */
function connect() {
  if (!userStore.token) return

  const wsUrl = `${import.meta.env.VITE_WS_URL || 'ws://localhost:8080'}/ws?token=${userStore.token}`

  try {
    ws = new WebSocket(wsUrl)

    ws.onopen = () => {
      console.log('WebSocket connected')
      reconnectAttempts = 0
      startHeartbeat()
    }

    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data)
        handleMessage(data)
      } catch (error) {
        console.error('WebSocket消息解析失败', error)
      }
    }

    ws.onclose = (event) => {
      console.log('WebSocket closed', event.code, event.reason)
      stopHeartbeat()
      attemptReconnect()
    }

    ws.onerror = (error) => {
      console.error('WebSocket error', error)
    }
  } catch (error) {
    console.error('WebSocket连接失败', error)
    attemptReconnect()
  }
}

/** 处理WebSocket消息 */
function handleMessage(data: any) {
  switch (data.type) {
    case 'NOTIFICATION':
    case 'notification':
      notificationStore.pushNotification(data.payload as Notification)
      break
    case 'unread_count':
      notificationStore.unreadCount = data.payload as UnreadCount
      break
    case 'message':
      messageStore.pushMessage(data.payload as PrivateMessage)
      break
    case 'new_session':
      // 新会话，刷新会话列表
      messageStore.fetchSessions()
      break
    case 'session_updated':
      updateSessionInList(data.payload as MessageSession)
      break
    case 'pong':
      // 心跳响应，正常情况不需要处理
      break
    default:
      console.log('未知消息类型', data.type)
  }
}

/** 更新会话列表中的会话 */
function updateSessionInList(session: MessageSession) {
  const index = messageStore.sessions.findIndex(s => s.sessionId === session.sessionId)
  if (index !== -1) {
    messageStore.sessions[index] = session
  }
}

/** 开始心跳 */
function startHeartbeat() {
  stopHeartbeat()
  heartbeatTimer = window.setInterval(() => {
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({ type: 'ping' }))
    }
  }, heartbeatInterval)
}

/** 停止心跳 */
function stopHeartbeat() {
  if (heartbeatTimer) {
    clearInterval(heartbeatTimer)
    heartbeatTimer = null
  }
}

/** 尝试重连 */
function attemptReconnect() {
  if (reconnectAttempts >= maxReconnectAttempts) {
    console.log('达到最大重连次数，停止重连')
    return
  }

  if (reconnectTimer) {
    clearTimeout(reconnectTimer)
  }

  reconnectAttempts++
  const delay = reconnectBaseDelay * Math.pow(2, reconnectAttempts - 1)
  console.log(`尝试第${reconnectAttempts}次重连，等待${delay}ms`)

  reconnectTimer = window.setTimeout(() => {
    connect()
  }, delay)
}

/** 断开连接 */
function disconnect() {
  stopHeartbeat()
  if (reconnectTimer) {
    clearTimeout(reconnectTimer)
    reconnectTimer = null
  }
  if (ws) {
    ws.close(1000, '组件卸载')
    ws = null
  }
}

/** 发送私信（通过WebSocket） */
function sendPrivateMessage(data: { receiverId: number; content: string }) {
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify({
      type: 'send_message',
      payload: data
    }))
  } else {
    console.warn('WebSocket未连接，无法发送消息')
  }
}

// 组件挂载时连接
onMounted(() => {
  if (userStore.token) {
    connect()
  }
})

// 组件卸载时断开
onUnmounted(() => {
  disconnect()
})

// 暴露方法供外部调用
defineExpose({ connect, disconnect, sendPrivateMessage })
</script>
