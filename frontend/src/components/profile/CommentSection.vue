<template>
  <!--
    CommentSection - 评论区组件
    支持一级评论、二级回复、@用户、点赞等功能
  -->
  <div class="comment-section">
    <!-- 评论输入区 -->
    <div class="comment-input">
      <el-avatar :size="32" class="comment-input__avatar">
        <el-icon><User /></el-icon>
      </el-avatar>
      <div class="comment-input__box">
        <textarea
          v-model="commentText"
          class="comment-input__textarea"
          :placeholder="placeholderText"
          rows="3"
          maxlength="500"
        />
        <div class="comment-input__actions">
          <el-button
            type="primary"
            size="small"
            :loading="submitting"
            :disabled="!commentText.trim()"
            @click="handleSubmit"
          >
            {{ replyTo ? '回复' : '评论' }}
          </el-button>
          <el-button v-if="replyTo" size="small" @click="cancelReply">
            取消
          </el-button>
        </div>
      </div>
    </div>

    <!-- 评论列表 -->
    <div class="comment-list" v-loading="loading">
      <template v-if="comments.length === 0 && !loading">
        <div class="empty-state">
          <el-icon :size="48" color="#C0C4CC"><ChatDotRound /></el-icon>
          <p class="empty-state__desc">暂无评论，快来抢沙发吧</p>
        </div>
      </template>

      <div
        v-for="comment in comments"
        :key="comment.id"
        class="comment-item"
      >
        <!-- 评论者头像 -->
        <el-avatar :size="36" class="comment-item__avatar">
          <el-icon><User /></el-icon>
        </el-avatar>

        <!-- 评论内容 -->
        <div class="comment-item__content">
          <div class="comment-item__header">
            <span class="comment-item__username">{{ comment.userName }}</span>
            <span class="comment-item__time">{{ formatTime(comment.createdAt) }}</span>
          </div>

          <p class="comment-item__text">{{ comment.content }}</p>

          <!-- 评论操作 -->
          <div class="comment-item__actions">
            <LikeButton
              :is-liked="comment.isLiked"
              :like-count="comment.likeCount"
              @toggle="handleCommentLike(comment.id)"
            />
            <button class="comment-item__action" @click="startReply(comment)">
              <el-icon :size="14"><ChatLineSquare /></el-icon>
              回复
            </button>
            <button
              v-if="canDeleteComment(comment)"
              class="comment-item__action"
              @click="handleDeleteComment(comment.id)"
            >
              <el-icon :size="14"><Delete /></el-icon>
              删除
            </button>
          </div>

          <!-- 收起回复 -->
          <button
            v-if="comment.replyCount && comment.replyCount > 0 && !comment.replies?.length"
            class="comment-replies-toggle"
            @click="loadReplies(comment)"
          >
            查看 {{ comment.replyCount }} 条回复
          </button>

          <!-- 回复列表 -->
          <div v-if="comment.replies && comment.replies.length > 0" class="reply-list">
            <div v-for="reply in comment.replies" :key="reply.id" class="reply-item">
              <div class="reply-item__avatar">
                <el-avatar :size="28">
                  <el-icon><User /></el-icon>
                </el-avatar>
              </div>
              <div class="reply-item__content">
                <div class="reply-item__header">
                  <span class="reply-item__username">{{ reply.userName }}</span>
                  <span v-if="reply.replyToUserName" class="reply-item__mention">
                    回复 {{ reply.replyToUserName }}
                  </span>
                  <span class="reply-item__time">{{ formatTime(reply.createdAt) }}</span>
                </div>
                <p class="reply-item__text">{{ reply.content }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 加载更多 -->
    <div v-if="hasMore" class="comment-load-more">
      <el-button text type="primary" :loading="loadingMore" @click="loadMore">
        加载更多评论
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ChatDotRound, ChatLineSquare, Delete, User } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { useProfileStore } from '@/store/profile'
import { commentApi } from '@/api/profile'
import LikeButton from './LikeButton.vue'
import type { Comment } from '@/types/profile'

interface Props {
  postId: number
  commentCount: number
}

const props = defineProps<Props>()

const userStore = useUserStore()
const profileStore = useProfileStore()

const comments = ref<Comment[]>([])
const loading = ref(false)
const loadingMore = ref(false)
const submitting = ref(false)
const commentText = ref('')
const replyTo = ref<Comment | null>(null)
const hasMore = ref(false)

const currentUserAvatar = computed(() => userStore.userInfo?.avatarUrl || '')

/** 输入框提示文本 */
const placeholderText = computed(() => {
  return replyTo.value ? `回复 ${replyTo.value.userName}:` : '写下你的评论...'
})

/** 是否可以删除评论 */
function canDeleteComment(comment: Comment): boolean {
  return comment.userId === userStore.userInfo?.userId
}

/** 获取评论列表 */
async function fetchComments() {
  loading.value = true
  try {
    const res = await commentApi.getComments(props.postId, { page: 1, size: 10 })
    comments.value = res.data.records
    hasMore.value = comments.value.length < res.data.total
  } catch (error) {
    console.error('获取评论失败', error)
  } finally {
    loading.value = false
  }
}

/** 加载更多评论 */
async function loadMore() {
  loadingMore.value = true
  try {
    const res = await commentApi.getComments(props.postId, { page: 2, size: 10 })
    comments.value = [...comments.value, ...res.data.records]
    hasMore.value = comments.value.length < res.data.total
  } catch (error) {
    console.error('加载更多评论失败', error)
  } finally {
    loadingMore.value = false
  }
}

/** 加载回复列表 */
async function loadReplies(comment: Comment) {
  try {
    const res = await commentApi.getReplies(comment.rootId || comment.id, { page: 1, size: 10 })
    // 在本地更新评论的replies
    const target = comments.value.find(c => c.id === comment.id)
    if (target) {
      target.replies = res.data.records
    }
  } catch (error) {
    console.error('获取回复失败', error)
  }
}

/** 开始回复 */
function startReply(comment: Comment) {
  replyTo.value = comment
}

/** 取消回复 */
function cancelReply() {
  replyTo.value = null
  commentText.value = ''
}

/** 提交评论 */
async function handleSubmit() {
  if (!commentText.value.trim()) return

  submitting.value = true
  try {
    await commentApi.createComment(props.postId, {
      content: commentText.value,
      parentId: replyTo.value?.id,
      replyToUserId: replyTo.value?.userId
    })

    ElMessage.success('评论成功')
    commentText.value = ''
    replyTo.value = null

    // 刷新评论列表
    await fetchComments()
  } catch (error) {
    ElMessage.error('评论失败')
  } finally {
    submitting.value = false
  }
}

/** 处理评论点赞 */
function handleCommentLike(commentId: number) {
  profileStore.toggleLike('COMMENT', commentId)
}

/** 删除评论 */
async function handleDeleteComment(commentId: number) {
  try {
    await ElMessageBox.confirm('确定要删除这条评论吗？', '确认删除', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await commentApi.deleteComment(commentId)
    ElMessage.success('评论已删除')
    await fetchComments()
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

/** 监听postId变化，重新获取评论 */
watch(() => props.postId, fetchComments, { immediate: true })

defineExpose({ fetchComments })
</script>

<style scoped>
.comment-section {
  margin-top: var(--space-lg, 16px);
}

.comment-input {
  display: flex;
  gap: var(--space-md, 12px);
  margin-bottom: var(--space-lg, 16px);
}

.comment-input__avatar {
  flex-shrink: 0;
}

.comment-input__box {
  flex: 1;
}

.comment-input__textarea {
  width: 100%;
  padding: var(--space-md, 12px);
  font-size: var(--font-body, 14px);
  line-height: var(--line-height-body, 1.6);
  color: var(--text-primary, #303133);
  background-color: var(--bg-color-page, #F9F6F0);
  border: 1px solid var(--border-color, #DCDFE6);
  border-radius: var(--radius-base, 4px);
  resize: none;
  min-height: 80px;
  transition: border-color var(--duration-fast, 100ms) var(--easing-out);
}

.comment-input__textarea:focus {
  outline: none;
  border-color: var(--primary-color, #409EFF);
  box-shadow: 0 0 0 2px var(--primary-color-light-1, #ECF5FF);
}

.comment-input__actions {
  display: flex;
  justify-content: flex-end;
  gap: var(--space-sm, 8px);
  margin-top: var(--space-sm, 8px);
}

.comment-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-md, 12px);
}

.comment-item {
  display: flex;
  gap: var(--space-md, 12px);
}

.comment-item__avatar {
  flex-shrink: 0;
}

.comment-item__content {
  flex: 1;
  min-width: 0;
}

.comment-item__header {
  display: flex;
  align-items: center;
  gap: var(--space-sm, 8px);
  margin-bottom: var(--space-xs, 4px);
}

.comment-item__username {
  font-size: var(--font-body, 14px);
  font-weight: 600;
  color: var(--text-primary, #303133);
}

.comment-item__time {
  font-size: var(--font-caption, 12px);
  color: var(--text-secondary, #909399);
}

.comment-item__text {
  font-size: var(--font-body, 14px);
  line-height: var(--line-height-body, 1.6);
  color: var(--text-primary, #303133);
  margin-bottom: var(--space-sm, 8px);
}

.comment-item__actions {
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

.reply-list {
  margin-top: var(--space-md, 12px);
  padding-left: var(--space-md, 12px);
  border-left: 2px solid var(--border-color-light, #E4E7ED);
  display: flex;
  flex-direction: column;
  gap: var(--space-md, 12px);
}

.reply-item {
  display: flex;
  gap: var(--space-sm, 8px);
}

.reply-item__avatar {
  flex-shrink: 0;
}

.reply-item__content {
  flex: 1;
  min-width: 0;
}

.reply-item__header {
  display: flex;
  align-items: center;
  gap: var(--space-sm, 8px);
  margin-bottom: 2px;
}

.reply-item__username {
  font-size: var(--font-body-sm, 13px);
  font-weight: 600;
  color: var(--text-primary, #303133);
}

.reply-item__time {
  font-size: var(--font-caption, 12px);
  color: var(--text-secondary, #909399);
}

.reply-item__text {
  font-size: var(--font-body-sm, 13px);
  line-height: var(--line-height-body, 1.6);
  color: var(--text-primary, #303133);
}

.reply-item__mention {
  color: var(--primary-color, #409EFF);
  cursor: pointer;
}

.reply-item__mention:hover {
  text-decoration: underline;
}

.comment-replies-toggle {
  margin-top: var(--space-xs, 4px);
  color: var(--primary-color, #409EFF);
  font-size: var(--font-caption, 12px);
  cursor: pointer;
  border: none;
  background: none;
  padding: 0;
  transition: color var(--duration-fast, 100ms);
}

.comment-replies-toggle:hover {
  color: var(--primary-color-hover, #66B1FF);
}

.comment-load-more {
  display: flex;
  justify-content: center;
  padding: var(--space-lg, 16px) 0;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--space-xl, 24px) 0;
  text-align: center;
}
</style>
