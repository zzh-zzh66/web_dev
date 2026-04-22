<template>
  <!--
    MessagePage - 私信页面
    左侧：会话列表，右侧：聊天区域，支持消息发送、已读状态、实时推送
  -->
  <div class="message-page">
    <!-- 左侧：会话列表 -->
    <aside class="message-sidebar">
      <div class="message-sidebar__header">
        <h2 class="message-sidebar__title">私信</h2>
        <el-input
          v-model="searchText"
          placeholder="搜索联系人"
          size="small"
          clearable
          class="message-sidebar__search"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
      </div>

      <!-- 会话列表 -->
      <div class="message-session-list" v-loading="messageStore.loading">
        <div
          v-for="session in filteredSessions"
          :key="session.sessionId"
          class="message-session-item"
          :class="{ 'is-active': messageStore.currentSession?.sessionId === session.sessionId }"
          @click="handleSelectSession(session)"
        >
          <el-avatar :size="44" :src="session.peerUserAvatar" />
          <div class="message-session-item__content">
            <div class="message-session-item__header">
              <span class="message-session-item__name">{{ session.peerUserName }}</span>
              <span class="message-session-item__time">{{ formatShortTime(session.lastMessageTime) }}</span>
            </div>
            <p class="message-session-item__last">{{ session.lastMessage }}</p>
          </div>
          <!-- 未读角标 -->
          <el-badge
            v-if="session.unreadCount > 0"
            :value="session.unreadCount"
            :max="99"
            class="message-session-item__badge"
          />
        </div>

        <!-- 空状态 -->
        <div v-if="filteredSessions.length === 0 && !messageStore.loading" class="empty-state">
          <el-icon :size="48" color="#C0C4CC"><ChatDotRound /></el-icon>
          <p class="empty-state__desc">暂无私信</p>
        </div>
      </div>
    </aside>

    <!-- 右侧：聊天区域 -->
    <main class="message-chat">
      <template v-if="messageStore.currentSession">
        <!-- 聊天头部 -->
        <div class="message-chat__header">
          <el-avatar :size="36" :src="messageStore.currentSession.peerUserAvatar" />
          <div class="message-chat__info">
            <h3 class="message-chat__name">{{ messageStore.currentSession.peerUserName }}</h3>
            <span class="message-chat__status" :class="{ 'is-online': isOnline }">
              {{ isOnline ? '在线' : '离线' }}
            </span>
          </div>
        </div>

        <!-- 消息列表 -->
        <div class="message-chat__messages" ref="messagesContainerRef">
          <div
            v-for="msg in messageStore.messages"
            :key="msg.id"
            class="message-item"
            :class="{ 'is-self': msg.senderId === currentUserId }"
          >
            <el-avatar :size="32" :src="msg.senderId === currentUserId ? currentUserAvatar : messageStore.currentSession.peerUserAvatar" class="message-item__avatar" />
            <div class="message-item__wrapper">
              <div class="message-item__bubble">
                <img
                  v-if="msg.msgType === 'IMAGE'"
                  :src="msg.content"
                  alt="图片消息"
                  class="message-bubble__image"
                />
                <template v-else>
                  {{ msg.content }}
                </template>
              </div>
              <div class="message-item__time">
                {{ formatMessageTime(msg.createdAt) }}
                <span v-if="msg.isRead && msg.senderId === currentUserId" class="message-item__read">已读</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 消息输入区 -->
        <div class="message-chat__input">
          <el-button text :icon="Picture" @click="triggerImageUpload" />
          <textarea
            v-model="messageText"
            class="message-chat__textarea"
            placeholder="输入消息..."
            rows="1"
            maxlength="1000"
            @keydown.enter.prevent="handleSendMessage"
          />
          <el-button
            type="primary"
            :disabled="!messageText.trim()"
            @click="handleSendMessage"
          >
            发送
          </el-button>
          <!-- 隐藏的文件input -->
          <input ref="imageInputRef" type="file" accept="image/*" hidden @change="handleImageUpload" />
        </div>
      </template>

      <!-- 未选择会话时的空状态 -->
      <template v-else>
        <div class="empty-state">
          <el-icon :size="64" color="#C0C4CC"><Message /></el-icon>
          <h3 class="empty-state__title">选择一个会话</h3>
          <p class="empty-state__desc">从左侧列表选择一个联系人开始聊天</p>
        </div>
      </template>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, nextTick, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, ChatDotRound, Message, Picture } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { useMessageStore } from '@/store/message'
import { fileApi } from '@/api/profile'
import type { MessageSession } from '@/types/profile'

const userStore = useUserStore()
const messageStore = useMessageStore()

const messageText = ref('')
const searchText = ref('')
const isOnline = ref(false)
const imageInputRef = ref<HTMLInputElement | null>(null)
const messagesContainerRef = ref<HTMLDivElement | null>(null)

const currentUserId = computed(() => userStore.userInfo?.userId)
const currentUserAvatar = computed(() => userStore.userInfo?.avatarUrl || '')

/** 过滤后的会话列表 */
const filteredSessions = computed(() => {
  if (!searchText.value) return messageStore.sessions
  return messageStore.sessions.filter(s =>
    s.peerUserName.toLowerCase().includes(searchText.value.toLowerCase())
  )
})

/** 选择会话 */
async function handleSelectSession(session: MessageSession) {
  messageStore.setCurrentSession(session)
  await messageStore.fetchSessionMessages(session.sessionId)
  scrollToBottom()
}

/** 发送消息 */
async function handleSendMessage() {
  if (!messageText.value.trim() || !messageStore.currentSession) return

  const text = messageText.value
  messageText.value = ''

  try {
    await messageStore.sendMessage({
      receiverId: messageStore.currentSession.peerUserId,
      msgType: 'TEXT',
      content: text
    })
    scrollToBottom()
  } catch (error) {
    ElMessage.error('发送失败')
    messageText.value = text
  }
}

/** 触发图片上传 */
function triggerImageUpload() {
  imageInputRef.value?.click()
}

/** 处理图片上传 */
async function handleImageUpload(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file || !messageStore.currentSession) return

  try {
    ElMessage.info('图片上传中...')
    const res = await fileApi.uploadImage(file)
    await messageStore.sendMessage({
      receiverId: messageStore.currentSession.peerUserId,
      msgType: 'IMAGE',
      content: res.data.url
    })
    ElMessage.success('图片发送成功')
    scrollToBottom()
  } catch (error) {
    ElMessage.error('图片发送失败')
  }
  input.value = ''
}

/** 滚动到底部 */
async function scrollToBottom() {
  await nextTick()
  if (messagesContainerRef.value) {
    messagesContainerRef.value.scrollTop = messagesContainerRef.value.scrollHeight
  }
}

/** 格式化短时间 */
function formatShortTime(timeStr: string): string {
  const date = new Date(timeStr)
  const now = new Date()
  const diffDays = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24))

  if (diffDays === 0) {
    return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
  }
  if (diffDays === 1) return '昨天'
  if (diffDays < 7) return `${diffDays}天前`
  return date.toLocaleDateString('zh-CN', { month: '2-digit', day: '2-digit' })
}

/** 格式化消息时间 */
function formatMessageTime(timeStr: string): string {
  const date = new Date(timeStr)
  return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

/** 初始化 */
import { onMounted } from 'vue'
onMounted(async () => {
  await messageStore.fetchSessions()
})
</script>

<style scoped>
.message-page {
  display: flex;
  height: calc(100vh - var(--header-height, 64px));
  background: var(--rice-paper, #F9F6F0);
}

.message-sidebar {
  width: var(--sidebar-left-width, 280px);
  border-right: 1px solid var(--border-color-light, #E4E7ED);
  background: var(--bg-color-overlay, #FFFFFF);
  display: flex;
  flex-direction: column;
}

.message-sidebar__header {
  padding: var(--space-lg, 16px);
  border-bottom: 1px solid var(--border-color-light, #E4E7ED);
}

.message-sidebar__title {
  font-size: var(--font-h4, 16px);
  font-weight: 600;
  color: var(--text-primary, #303133);
  margin-bottom: var(--space-sm, 8px);
}

.message-sidebar__search {
  width: 100%;
}

.message-session-list {
  flex: 1;
  overflow-y: auto;
}

.message-session-item {
  display: flex;
  align-items: center;
  gap: var(--space-md, 12px);
  padding: var(--space-md, 12px) var(--space-lg, 16px);
  cursor: pointer;
  transition: background-color var(--duration-fast, 100ms) var(--easing-out);
  border-bottom: 1px solid var(--border-color-light, #E4E7ED);
  position: relative;
}

.message-session-item:hover {
  background-color: var(--bg-color, #F4F4F5);
}

.message-session-item.is-active {
  background-color: var(--primary-color-light-1, #ECF5FF);
}

.message-session-item__content {
  flex: 1;
  min-width: 0;
}

.message-session-item__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--space-xs, 4px);
}

.message-session-item__name {
  font-size: var(--font-body, 14px);
  font-weight: 500;
  color: var(--text-primary, #303133);
}

.message-session-item__time {
  font-size: var(--font-caption, 12px);
  color: var(--text-secondary, #909399);
}

.message-session-item__last {
  font-size: var(--font-body-sm, 13px);
  color: var(--text-secondary, #909399);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.message-session-item__badge {
  position: absolute;
  right: var(--space-lg, 16px);
  top: var(--space-md, 12px);
}

.message-chat {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: var(--bg-color-overlay, #FFFFFF);
}

.message-chat__header {
  display: flex;
  align-items: center;
  gap: var(--space-md, 12px);
  padding: var(--space-lg, 16px);
  border-bottom: 1px solid var(--border-color-light, #E4E7ED);
}

.message-chat__info {
  flex: 1;
}

.message-chat__name {
  font-size: var(--font-h4, 16px);
  font-weight: 600;
  color: var(--text-primary, #303133);
  margin: 0;
}

.message-chat__status {
  font-size: var(--font-caption, 12px);
  color: var(--text-secondary, #909399);
}

.message-chat__status.is-online {
  color: var(--success-color, #67C23A);
}

.message-chat__messages {
  flex: 1;
  overflow-y: auto;
  padding: var(--space-lg, 16px);
  display: flex;
  flex-direction: column;
  gap: var(--space-md, 12px);
}

.message-item {
  display: flex;
  gap: var(--space-sm, 8px);
  max-width: 70%;
}

.message-item.is-self {
  align-self: flex-end;
  flex-direction: row-reverse;
}

.message-item__avatar {
  flex-shrink: 0;
}

.message-item__wrapper {
  display: flex;
  flex-direction: column;
  gap: var(--space-xs, 4px);
}

.message-item__bubble {
  padding: var(--space-sm, 8px) var(--space-md, 12px);
  border-radius: var(--radius-lg, 12px);
  font-size: var(--font-body, 14px);
  line-height: var(--line-height-body, 1.6);
  word-break: break-word;
}

.message-item:not(.is-self) .message-item__bubble {
  background: var(--bg-color, #F4F4F5);
  color: var(--text-primary, #303133);
  border-top-left-radius: var(--radius-sm, 2px);
}

.message-item.is-self .message-item__bubble {
  background: var(--primary-color, #409EFF);
  color: white;
  border-top-right-radius: var(--radius-sm, 2px);
}

.message-bubble__image {
  max-width: 240px;
  max-height: 240px;
  border-radius: var(--radius-base, 4px);
  cursor: pointer;
}

.message-item__time {
  font-size: var(--font-caption, 12px);
  color: var(--text-secondary, #909399);
}

.message-item.is-self .message-item__time {
  text-align: right;
}

.message-item__read {
  margin-left: var(--space-xs, 4px);
  font-size: var(--font-caption, 12px);
  color: var(--success-color, #67C23A);
}

.message-chat__input {
  display: flex;
  gap: var(--space-sm, 8px);
  padding: var(--space-lg, 16px);
  border-top: 1px solid var(--border-color-light, #E4E7ED);
  align-items: flex-end;
}

.message-chat__textarea {
  flex: 1;
  padding: var(--space-sm, 8px) var(--space-md, 12px);
  font-size: var(--font-body, 14px);
  line-height: var(--line-height-body, 1.6);
  color: var(--text-primary, #303133);
  border: 1px solid var(--border-color, #DCDFE6);
  border-radius: var(--radius-md, 8px);
  resize: none;
  min-height: 40px;
  max-height: 120px;
}

.message-chat__textarea:focus {
  outline: none;
  border-color: var(--primary-color, #409EFF);
}

.message-chat__textarea::placeholder {
  color: var(--text-placeholder, #C0C4CC);
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

/* 移动端适配 */
@media (max-width: 767px) {
  .message-page {
    flex-direction: column;
  }

  .message-sidebar {
    width: 100%;
    height: 40vh;
    border-right: none;
    border-bottom: 1px solid var(--border-color-light, #E4E7ED);
  }

  .message-chat {
    flex: 1;
    height: 60vh;
  }
}
</style>
