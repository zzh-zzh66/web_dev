<template>
  <!--
    TimelinePost - 时间轴内容卡片组件
    展示动态内容，包括用户信息、文本、图片/视频、点赞、评论等
  -->
  <article class="content-card" :aria-label="`动态内容 - ${post.userName}`">
    <!-- 卡片头部：用户信息 -->
    <div class="content-card__header">
      <el-avatar :size="40" class="content-card__avatar">
        <el-icon><User /></el-icon>
      </el-avatar>
      <div class="content-card__user-info">
        <div class="content-card__username">
          <span>{{ post.userName }}</span>
          <!-- 关系标签 -->
          <el-tag
            v-if="post.relationshipLabel"
            class="tag--relationship"
            size="small"
          >
            {{ post.relationshipLabel }}
          </el-tag>
        </div>
        <div class="content-card__meta">
          <span>{{ formatTime(post.createdAt) }}</span>
          <!-- 可见范围图标 -->
          <el-tooltip :content="visibilityText" placement="top">
            <el-icon :size="14">
              <View v-if="post.visibility === 'PUBLIC'" />
              <Collection v-else-if="post.visibility === 'FAMILY'" />
              <Lock v-else />
            </el-icon>
          </el-tooltip>
        </div>
      </div>
      <!-- 操作菜单（仅作者可见） -->
      <div v-if="isOwner" class="content-card__actions">
        <el-dropdown trigger="click" @command="handleCommand">
          <el-button text :icon="MoreFilled" />
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="edit">编辑</el-dropdown-item>
              <el-dropdown-item command="delete" divided>删除</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>

    <!-- 内容正文 -->
    <div class="content-card__body">
      <!-- 分类标签 -->
      <el-tag
        v-if="post.categoryName"
        class="tag--category"
        :style="{ backgroundColor: categoryColor }"
        size="small"
      >
        {{ post.categoryName }}
      </el-tag>

      <!-- 标题 -->
      <h3 v-if="post.title" class="content-card__title">{{ post.title }}</h3>

      <!-- 文本内容 -->
      <div
        class="content-card__text"
        :class="{ 'is-expanded': isTextExpanded }"
        v-html="processedContent"
      />
      <!-- 展开/收起按钮 -->
      <button
        v-if="isTextOverflow"
        class="content-card__expand-btn"
        @click="isTextExpanded = !isTextExpanded"
      >
        {{ isTextExpanded ? '收起' : '展开' }}
      </button>
    </div>

    <!-- 媒体区域 -->
    <div class="content-card__media">
      <!-- 图片网格 -->
      <ImageGrid
        v-if="hasImages"
        :images="imageList"
      />
      <!-- 视频播放器 -->
      <div v-if="hasVideo" class="video-player" @click="playVideo">
        <img
          v-if="videoThumbnail"
          :src="videoThumbnail"
          class="video-player__thumbnail"
          alt="视频封面"
        />
        <div class="video-player__play-btn">
          <el-icon :size="24"><VideoPlay /></el-icon>
        </div>
      </div>
    </div>

    <!-- 底部操作栏 -->
    <div class="content-card__footer">
      <!-- 点赞按钮 -->
      <LikeButton
        :is-liked="post.isLiked"
        :like-count="post.likeCount"
        :use-red-color="false"
        @toggle="handleLike"
      />
      <!-- 评论按钮 -->
      <button class="content-card__action" @click="toggleComments">
        <el-icon :size="18"><ChatDotRound /></el-icon>
        <span>{{ post.commentCount }}</span>
      </button>
      <!-- 分享按钮 -->
      <button class="content-card__action" @click="$emit('share', post)">
        <el-icon :size="18"><Share /></el-icon>
        <span>分享</span>
      </button>
    </div>

    <!-- 评论区 -->
    <CommentSection
      v-if="showComments"
      :post-id="post.id"
      :comment-count="post.commentCount"
    />
  </article>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  MoreFilled, View, Collection, Lock,
  ChatDotRound, Share, VideoPlay, User
} from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { useProfileStore } from '@/store/profile'
import ImageGrid from './ImageGrid.vue'
import LikeButton from './LikeButton.vue'
import CommentSection from './CommentSection.vue'
import type { TimelinePost, PostMedia } from '@/types/profile'

interface Props {
  post: TimelinePost
}

interface Emits {
  (e: 'delete', postId: number): void
  (e: 'edit', post: TimelinePost): void
  (e: 'share', post: TimelinePost): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const userStore = useUserStore()
const profileStore = useProfileStore()

/** 判断是否为主页主人 */
const isOwner = computed(() => {
  return props.post.userId === userStore.userInfo?.userId
})

/** 文本展开/收起 */
const isTextExpanded = ref(false)

/** 处理后的内容（解码HTML实体） */
const processedContent = computed(() => {
  if (!props.post.content) return ''
  // 解码HTML实体：&lt; → <, &gt; → >, &amp; → &
  return props.post.content
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&amp;/g, '&')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
})

const isTextOverflow = computed(() => {
  // 使用处理后的纯文本判断是否溢出
  const plainText = processedContent.value.replace(/<[^>]*>/g, '')
  return plainText.length > 200
})

/** 评论显示控制 */
const showComments = ref(false)

/** 切换评论显示 */
function toggleComments() {
  showComments.value = !showComments.value
}

/** 分类颜色映射 */
const categoryColorMap: Record<string, string> = {
  '生平日志': 'var(--color-category-log, #409EFF)',
  '照片墙': 'var(--color-category-photo, #67C23A)',
  '视频集': 'var(--color-category-video, #E6A23C)',
  '心情随笔': 'var(--color-category-mood, #909399)',
  '家族故事': 'var(--color-category-story, #C41E3A)',
  '收藏夹': 'var(--color-category-collection, #D4A017)'
}

const categoryColor = computed(() => {
  if (props.post.categoryName) {
    return categoryColorMap[props.post.categoryName] || 'var(--primary-color, #409EFF)'
  }
  return 'var(--primary-color, #409EFF)'
})

/** 可见范围文本 */
const visibilityText = computed(() => {
  const map: Record<string, string> = {
    'PUBLIC': '全族可见',
    'FAMILY': '家族可见',
    'RELATIVE': '仅亲属',
    'PRIVATE': '仅自己'
  }
  return map[props.post.visibility] || ''
})

/** 图片列表 */
const imageList = computed(() => {
  return props.post.mediaList.filter(m => m.type === 'IMAGE') as PostMedia[]
})

/** 是否有图片 */
const hasImages = computed(() => imageList.value.length > 0)

/** 是否有视频 */
const hasVideo = computed(() => {
  return props.post.mediaList.some(m => m.type === 'VIDEO')
})

/** 视频缩略图 */
const videoThumbnail = computed(() => {
  const video = props.post.mediaList.find(m => m.type === 'VIDEO')
  return video?.thumbnailUrl || ''
})

/** 格式化时间 */
function formatTime(timeStr: string): string {
  const date = new Date(timeStr)
  const now = new Date()
  const diffMs = now.getTime() - date.getTime()
  const diffSec = Math.floor(diffMs / 1000)
  const diffMin = Math.floor(diffSec / 60)
  const diffHour = Math.floor(diffMin / 60)
  const diffDay = Math.floor(diffHour / 24)

  if (diffSec < 60) return '刚刚'
  if (diffMin < 60) return `${diffMin}分钟前`
  if (diffHour < 24) return `${diffHour}小时前`
  if (diffDay < 7) return `${diffDay}天前`

  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

/** 处理操作命令 */
async function handleCommand(command: string) {
  if (command === 'edit') {
    emit('edit', props.post)
  } else if (command === 'delete') {
    try {
      await ElMessageBox.confirm('确定要删除这条动态吗？', '确认删除', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      emit('delete', props.post.id)
      ElMessage.success('动态已删除')
    } catch {
      // 用户取消
    }
  }
}

/** 处理点赞 */
function handleLike() {
  profileStore.toggleLike('POST', props.post.id)
}

/** 播放视频（预留） */
function playVideo() {
  ElMessage.info('视频播放功能开发中')
}
</script>

<style scoped>
.content-card {
  background: var(--bg-color-overlay, #FFFFFF);
  border-radius: var(--radius-md, 8px);
  box-shadow: var(--shadow-light, 0 2px 4px rgba(0, 0, 0, 0.08));
  padding: var(--space-lg, 16px);
  margin-bottom: var(--space-lg, 16px);
  transition: box-shadow var(--duration-base, 200ms) var(--easing-out);
}

.content-card:hover {
  box-shadow: var(--shadow-base, 0 4px 12px rgba(0, 0, 0, 0.12));
}

.content-card__header {
  display: flex;
  align-items: center;
  gap: var(--space-md, 12px);
  margin-bottom: var(--space-md, 12px);
}

.content-card__avatar {
  flex-shrink: 0;
}

.content-card__user-info {
  flex: 1;
  min-width: 0;
}

.content-card__username {
  display: flex;
  align-items: center;
  gap: var(--space-xs, 4px);
  font-size: var(--font-h4, 16px);
  font-weight: 600;
  color: var(--text-primary, #303133);
}

.content-card__meta {
  display: flex;
  align-items: center;
  gap: var(--space-sm, 8px);
  font-size: var(--font-caption, 12px);
  color: var(--text-secondary, #909399);
  margin-top: 2px;
}

.content-card__actions {
  flex-shrink: 0;
}

.content-card__body {
  margin-bottom: var(--space-md, 12px);
}

.tag--category {
  margin-bottom: var(--space-sm, 8px);
}

.content-card__title {
  font-size: var(--font-h4, 16px);
  font-weight: 600;
  color: var(--text-primary, #303133);
  margin-bottom: var(--space-sm, 8px);
}

.content-card__text {
  font-size: var(--font-body-lg, 15px);
  line-height: var(--line-height-body-lg, 1.8);
  color: var(--ink-color, #4A4A4A);
  display: -webkit-box;
  -webkit-line-clamp: 6;
  -webkit-box-orient: vertical;
  overflow: hidden;
  white-space: pre-wrap;
  word-break: break-word;
}

.content-card__text.is-expanded {
  -webkit-line-clamp: unset;
}

.content-card__expand-btn {
  margin-top: var(--space-xs, 4px);
  color: var(--primary-color, #409EFF);
  font-size: var(--font-body-sm, 13px);
  cursor: pointer;
  border: none;
  background: none;
  padding: 0;
  transition: color var(--duration-fast, 100ms);
}

.content-card__expand-btn:hover {
  color: var(--primary-color-hover, #66B1FF);
}

.content-card__media {
  margin-bottom: var(--space-md, 12px);
}

.video-player {
  position: relative;
  width: 100%;
  aspect-ratio: 16 / 9;
  border-radius: var(--radius-base, 4px);
  overflow: hidden;
  background-color: var(--bg-color, #F4F4F5);
  cursor: pointer;
}

.video-player__thumbnail {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.video-player__play-btn {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 64px;
  height: 64px;
  background-color: rgba(0, 0, 0, 0.6);
  border-radius: var(--radius-full);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 24px;
  transition: background-color var(--duration-fast, 100ms) var(--easing-out);
}

.video-player:hover .video-player__play-btn {
  background-color: rgba(0, 0, 0, 0.8);
}

.content-card__footer {
  display: flex;
  align-items: center;
  gap: var(--space-xl, 24px);
  padding-top: var(--space-md, 12px);
  border-top: 1px solid var(--border-color-light, #E4E7ED);
}

.content-card__action {
  display: inline-flex;
  align-items: center;
  gap: var(--space-xs, 4px);
  padding: var(--space-xs, 4px) var(--space-sm, 8px);
  font-size: var(--font-body-sm, 13px);
  color: var(--text-secondary, #909399);
  background: none;
  border: none;
  border-radius: var(--radius-base, 4px);
  cursor: pointer;
  transition: color var(--duration-fast, 100ms) var(--easing-out),
              background-color var(--duration-fast, 100ms) var(--easing-out);
}

.content-card__action:hover {
  color: var(--primary-color, #409EFF);
  background-color: var(--primary-color-light-1, #ECF5FF);
}

@media (max-width: 767px) {
  .content-card {
    padding: var(--space-md, 12px);
  }

  .content-card__footer {
    gap: var(--space-md, 12px);
  }
}
</style>
