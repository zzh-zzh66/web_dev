<template>
  <!--
    LikeButton - 点赞按钮组件
    支持点赞/取消点赞切换，带弹跳动画
  -->
  <button
    class="like-button"
    :class="{ 'is-liked': isLiked, 'like-chinese-red': useRedColor }"
    @click="handleLike"
  >
    <el-icon class="like-button__icon" :size="20">
      <StarFilled v-if="isLiked" />
      <Star v-else />
    </el-icon>
    <span class="like-button__count">{{ displayCount }}</span>
  </button>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { Star, StarFilled } from '@element-plus/icons-vue'

interface Props {
  /** 当前是否已点赞 */
  isLiked: boolean
  /** 点赞数 */
  likeCount: number
  /** 使用中国红作为点赞激活色 */
  useRedColor?: boolean
}

interface Emits {
  (e: 'toggle'): void
}

const props = withDefaults(defineProps<Props>(), {
  useRedColor: false
})

const emit = defineEmits<Emits>()

const isLiked = ref(props.isLiked)
const displayCount = ref(props.likeCount)

/** 监听外部状态变化 */
watch(() => props.isLiked, (val) => {
  isLiked.value = val
})

watch(() => props.likeCount, (val) => {
  displayCount.value = val
})

/** 处理点赞切换 */
function handleLike() {
  // 先更新本地状态（乐观更新）
  isLiked.value = !isLiked.value
  displayCount.value += isLiked.value ? 1 : -1

  // 触发父组件更新
  emit('toggle')
}
</script>

<style scoped>
.like-button {
  display: inline-flex;
  align-items: center;
  gap: var(--space-xs, 4px);
  padding: var(--space-xs, 4px) var(--space-sm, 8px);
  font-size: var(--font-body, 14px);
  color: var(--text-secondary, #909399);
  background: none;
  border: none;
  border-radius: var(--radius-base, 4px);
  cursor: pointer;
  transition: all var(--duration-base, 200ms) var(--easing-out);
  position: relative;
}

.like-button:hover {
  color: var(--primary-color, #409EFF);
}

.like-button.is-liked {
  color: var(--primary-color, #409EFF);
}

.like-button.is-liked.like-chinese-red {
  color: var(--chinese-red, #C41E3A);
}

.like-button__icon {
  font-size: 20px;
  transition: transform var(--duration-base, 200ms) var(--easing-out);
}

.like-button.is-liked .like-button__icon {
  animation: likeAnimation 200ms ease-out;
}

.like-button__count {
  font-size: var(--font-body, 14px);
  font-weight: 400;
  transition: opacity var(--duration-fast, 100ms);
}

@keyframes likeAnimation {
  0% { transform: scale(1); }
  30% { transform: scale(1.3); }
  60% { transform: scale(1.1); }
  100% { transform: scale(1); }
}
</style>
