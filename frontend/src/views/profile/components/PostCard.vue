<template>
  <div class="post-card" @click="$emit('click')">
    <div class="post-header">
      <el-avatar :size="40" :src="post.authorAvatar">
        {{ post.authorName?.charAt(0) }}
      </el-avatar>
      <div class="post-author">
        <div class="author-name">{{ post.authorName }}</div>
        <div class="post-meta">
          <span class="post-time">{{ formatTime(post.createdAt) }}</span>
          <el-tag v-if="post.postTypeName" size="small" type="info">
            {{ post.postTypeName }}
          </el-tag>
        </div>
      </div>
      <el-dropdown v-if="post.isSelf" @command="handleCommand">
        <el-button text size="small">
          <el-icon><MoreFilled /></el-icon>
        </el-button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="edit">编辑</el-dropdown-item>
            <el-dropdown-item command="delete" divided>删除</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>

    <div class="post-content" v-if="post.title">
      <h4 class="post-title">{{ post.title }}</h4>
    </div>

    <div class="post-content">
      <p class="post-text">{{ post.content }}</p>
    </div>

    <div class="post-images" v-if="post.images && post.images.length > 0">
      <el-image
        v-for="(img, index) in post.images"
        :key="index"
        :src="img"
        :preview-src-list="post.images"
        fit="cover"
        class="post-image"
        :class="{ 'single-image': post.images.length === 1 }"
      />
    </div>

    <div class="post-tags" v-if="post.taggedMembers && post.taggedMembers.length > 0">
      <span v-for="member in post.taggedMembers" :key="member.memberId" class="tagged-member">
        @{{ member.name }}
      </span>
    </div>

    <div class="post-stats">
      <div class="stat-item" :class="{ active: post.isLiked }" @click.stop="toggleLike">
        <el-icon><Star /></el-icon>
        <span>{{ post.likeCount }}</span>
      </div>
      <div class="stat-item" @click.stop="$emit('comment', post)">
        <el-icon><ChatDotRound /></el-icon>
        <span>{{ post.commentCount }}</span>
      </div>
      <div class="stat-item">
        <el-icon><View /></el-icon>
        <span>{{ post.viewCount }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { MoreFilled, Star, ChatDotRound, View } from '@element-plus/icons-vue'
import type { PostDTO } from '@/types/profile'
import { ElMessage } from 'element-plus'

interface Props {
  post: PostDTO
}

const props = defineProps<Props>()
const emit = defineEmits<{
  (e: 'like', post: PostDTO): void
  (e: 'unlike', post: PostDTO): void
  (e: 'comment', post: PostDTO): void
  (e: 'delete', post: PostDTO): void
  (e: 'click'): void
}>()

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

const toggleLike = () => {
  if (props.post.isLiked) {
    emit('unlike', props.post)
  } else {
    emit('like', props.post)
  }
}

const handleCommand = (command: string) => {
  if (command === 'delete') {
    emit('delete', props.post)
  } else if (command === 'edit') {
    ElMessage.info('编辑功能开发中')
  }
}
</script>

<style scoped lang="scss">
.post-card {
  background: #fff;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
  cursor: pointer;
  transition: box-shadow 0.3s;

  &:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  }
}

.post-header {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 12px;

  .post-author {
    flex: 1;

    .author-name {
      font-weight: 600;
      color: #222;
      font-size: 15px;
    }

    .post-meta {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-top: 2px;

      .post-time {
        font-size: 12px;
        color: #8e8e93;
      }
    }
  }
}

.post-content {
  margin-bottom: 12px;

  .post-title {
    font-size: 16px;
    font-weight: 600;
    color: #222;
    margin: 0 0 8px;
  }

  .post-text {
    color: #45515e;
    font-size: 14px;
    line-height: 1.6;
    margin: 0;
    word-break: break-word;
  }
}

.post-images {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 4px;
  margin-bottom: 12px;

  .post-image {
    width: 100%;
    aspect-ratio: 1;
    border-radius: 8px;
    object-fit: cover;

    &.single-image {
      grid-column: span 3;
      aspect-ratio: 16 / 9;
      max-height: 300px;
    }
  }
}

.post-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 12px;

  .tagged-member {
    color: #1456f0;
    font-size: 13px;
    cursor: pointer;

    &:hover {
      text-decoration: underline;
    }
  }
}

.post-stats {
  display: flex;
  gap: 24px;
  padding-top: 12px;
  border-top: 1px solid #f0f0f0;

  .stat-item {
    display: flex;
    align-items: center;
    gap: 4px;
    color: #8e8e93;
    font-size: 13px;
    cursor: pointer;
    transition: color 0.3s;

    &:hover {
      color: #1456f0;
    }

    &.active {
      color: #ef4444;
    }

    .el-icon {
      font-size: 16px;
    }
  }
}
</style>
