<template>
  <!--
    ProfileHeader - 个人主页头部组件
    展示背景图、用户头像、姓名、签名、统计数据等信息
  -->
  <div class="profile-header">
    <!-- 封面区域 -->
    <div
      class="profile-cover"
      :style="profile?.backgroundUrl ? { backgroundImage: `url(${profile.backgroundUrl})` } : { background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' }"
      @click="isOwner && triggerCoverUpload()"
    >
      <div class="profile-cover__overlay" />
      <!-- 更换封面按钮（仅主页主人可见） -->
      <el-button
        v-if="isOwner"
        class="profile-cover__change-btn"
        type="primary"
        size="small"
        :icon="Picture"
        @click.stop="triggerCoverUpload"
      >
        更换封面
      </el-button>
      <!-- 隐藏的封面上传input -->
      <input
        ref="coverInputRef"
        type="file"
        accept="image/*"
        hidden
        @change="handleCoverUpload"
      />
    </div>

    <!-- 用户信息区域 -->
    <div class="profile-info">
      <!-- 头像 -->
      <div class="profile-info__avatar-wrapper">
        <img
          v-if="getAvatarUrl()"
          :src="getAvatarUrl()"
          :alt="profile?.name || '头像'"
          class="profile-info__avatar"
          @click="isOwner && triggerAvatarUpload()"
        />
        <div
          v-else
          class="profile-info__avatar profile-info__avatar--placeholder"
          @click="isOwner && triggerAvatarUpload()"
        >
          <el-icon :size="40"><User /></el-icon>
        </div>
        <input
          ref="avatarInputRef"
          type="file"
          accept="image/*"
          hidden
          @change="handleAvatarUpload"
        />
      </div>

      <!-- 用户信息 -->
      <div class="profile-info__content">
        <div class="profile-info__name">
          <span>{{ profile?.name }}</span>
          <!-- 族长标识 -->
          <el-tag v-if="profile?.generation === 1" class="tag--clan-leader" size="small" effect="dark">
            族长
          </el-tag>
          <!-- 关系标签 -->
          <el-tag v-if="profile?.relationshipLabel" class="tag--relationship" size="small">
            {{ profile.relationshipLabel }}
          </el-tag>
        </div>

        <div class="profile-info__meta">
          <span v-if="profile?.generation" class="profile-info__meta-item">
            <el-icon><User /></el-icon>
            第{{ profile.generation }}代
          </span>
          <span v-if="profile?.familyName" class="profile-info__meta-item">
            <el-icon><School /></el-icon>
            {{ profile.familyName }}
          </span>
        </div>

        <!-- 签名 -->
        <p v-if="profile?.signature" class="profile-info__bio">
          {{ profile.signature }}
        </p>

        <!-- 统计数据 -->
        <div class="profile-stats">
          <div class="profile-stats__item">
            <span class="profile-stats__count">{{ profile?.stats.visitCount || 0 }}</span>
            <span class="profile-stats__label">访问</span>
          </div>
          <div class="profile-stats__item">
            <span class="profile-stats__count">{{ profile?.stats.contentCount || 0 }}</span>
            <span class="profile-stats__label">动态</span>
          </div>
          <div class="profile-stats__item">
            <span class="profile-stats__count">{{ profile?.stats.likeCount || 0 }}</span>
            <span class="profile-stats__label">获赞</span>
          </div>
          <div class="profile-stats__item">
            <span class="profile-stats__count">{{ profile?.stats.guestbookCount || 0 }}</span>
            <span class="profile-stats__label">留言</span>
          </div>
        </div>
      </div>

      <!-- 操作按钮 -->
      <div class="profile-info__actions">
        <el-button
          v-if="isOwner"
          type="primary"
          :icon="Edit"
          @click="$emit('edit')"
        >
          编辑主页
        </el-button>
        <el-button
          v-if="!isOwner"
          type="primary"
          plain
          :icon="Message"
          @click="$emit('message')"
        >
          发消息
        </el-button>
        <el-dropdown v-if="!isOwner" trigger="click">
          <el-button :icon="MoreFilled" />
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="$emit('view-relation')">查看关系</el-dropdown-item>
              <el-dropdown-item divided>屏蔽</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { Edit, MoreFilled, Message, User, School, Picture } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import type { UserProfile } from '@/types/profile'
import { fileApi } from '@/api/profile'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()

interface Props {
  profile: UserProfile | null
}

interface Emits {
  (e: 'edit'): void
  (e: 'message'): void
  (e: 'view-relation'): void
  (e: 'cover-change', url: string): void
  (e: 'avatar-change', url: string): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

/** 判断是否为主页主人 */
const isOwner = computed(() => props.profile?.isOwner ?? false)

const coverInputRef = ref<HTMLInputElement | null>(null)
const avatarInputRef = ref<HTMLInputElement | null>(null)

/** 触发封面上传 */
function triggerCoverUpload() {
  coverInputRef.value?.click()
}

/** 触发头像上传 */
function triggerAvatarUpload() {
  avatarInputRef.value?.click()
}

/** 获取头像URL */
function getAvatarUrl(): string {
  // 优先使用userStore中的头像，兼容可能的字段名
  const avatar = userStore.userInfo?.avatarUrl || userStore.userInfo?.avatar || ''
  console.log('头像URL:', avatar, 'userInfo:', userStore.userInfo)
  return avatar
}

/** 触发封面上传 */
async function handleCoverUpload(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return

  try {
    const res = await fileApi.uploadImage(file)
    emit('cover-change', res.data.url)
    ElMessage.success('封面更换成功')
  } catch (error) {
    ElMessage.error('封面上传失败')
  }
  // 重置input以支持重复选择同一文件
  input.value = ''
}

/** 处理头像上传 */
async function handleAvatarUpload(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return

  try {
    const res = await fileApi.uploadImage(file)
    emit('avatar-change', res.data.url)
    ElMessage.success('头像更换成功')
  } catch (error) {
    ElMessage.error('头像上传失败')
  }
  input.value = ''
}
</script>

<style scoped>
.profile-header {
  margin-bottom: 0;
}

.profile-cover {
  position: relative;
  height: var(--cover-height, 280px);
  background-size: cover;
  background-position: center;
  background-color: var(--border-color, #DCDFE6);
  border-radius: 0 0 var(--radius-lg, 12px) var(--radius-lg, 12px);
  overflow: hidden;
  cursor: pointer;
}

.profile-cover__overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to bottom, transparent 50%, rgba(0, 0, 0, 0.5) 100%);
}

.profile-cover:hover :deep(.profile-cover__change-btn) {
  opacity: 1;
}

.profile-info {
  display: flex;
  align-items: flex-end;
  gap: var(--space-lg, 16px);
  margin-top: calc(var(--avatar-size, 120px) / -2 - var(--space-lg, 16px));
  padding: 0 var(--space-xl, 24px);
  position: relative;
  z-index: 1;
}

.profile-info__avatar-wrapper {
  flex-shrink: 0;
}

.profile-info__avatar {
  width: var(--avatar-size, 120px);
  height: var(--avatar-size, 120px);
  border: 4px solid #fff;
  border-radius: var(--radius-full);
  box-shadow: var(--shadow-base, 0 4px 12px rgba(0, 0, 0, 0.15));
  object-fit: cover;
  background-color: #f0f0f0;
  cursor: pointer;
  transition: transform var(--duration-base, 200ms) var(--easing-out);
}

.profile-info__avatar--placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
}

.profile-info__avatar:hover {
  transform: scale(1.05);
}

.profile-info__content {
  flex: 1;
  padding-bottom: var(--space-sm, 8px);
  min-width: 0;
}

.profile-info__name {
  display: flex;
  align-items: center;
  gap: var(--space-sm, 8px);
  font-size: var(--font-h3, 18px);
  font-weight: 700;
  color: var(--text-primary, #303133);
}

.profile-info__meta {
  display: flex;
  align-items: center;
  gap: var(--space-md, 12px);
  font-size: var(--font-body-sm, 13px);
  color: var(--text-secondary, #909399);
  margin-top: var(--space-xs, 4px);
}

.profile-info__meta-item {
  display: inline-flex;
  align-items: center;
  gap: 2px;
}

.profile-info__bio {
  font-size: var(--font-body, 14px);
  color: var(--text-regular, #606266);
  margin-top: var(--space-sm, 8px);
  max-width: 600px;
  line-height: 1.6;
}

.profile-info__interests {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-sm, 8px);
  margin-top: var(--space-sm, 8px);
}

.profile-stats {
  display: flex;
  gap: var(--space-xl, 24px);
  margin-top: var(--space-sm, 8px);
}

.profile-stats__item {
  display: flex;
  align-items: baseline;
  gap: 2px;
}

.profile-stats__count {
  font-size: var(--font-h4, 16px);
  font-weight: 600;
  color: var(--text-primary, #303133);
}

.profile-stats__label {
  font-size: var(--font-caption, 12px);
  color: var(--text-secondary, #909399);
}

.profile-info__actions {
  display: flex;
  gap: var(--space-sm, 8px);
  padding-bottom: var(--space-sm, 8px);
}

/* 平板端适配 */
@media (max-width: 1199px) {
  .profile-cover {
    height: var(--cover-height-md, 220px);
  }

  .profile-info__avatar {
    width: var(--avatar-size-md, 100px);
    height: var(--avatar-size-md, 100px);
  }

  .profile-info {
    margin-top: calc(var(--avatar-size-md, 100px) / -2 - var(--space-lg, 16px));
  }
}

/* 移动端适配 */
@media (max-width: 767px) {
  .profile-cover {
    height: var(--cover-height-sm, 180px);
    border-radius: 0;
  }

  .profile-info {
    flex-direction: column;
    align-items: flex-start;
    gap: var(--space-sm, 8px);
    margin-top: calc(var(--avatar-size-sm, 80px) / -2 - var(--space-sm, 8px));
    padding: 0 var(--space-md, 12px);
  }

  .profile-info__avatar {
    width: var(--avatar-size-sm, 80px);
    height: var(--avatar-size-sm, 80px);
  }

  .profile-info__content {
    padding-bottom: 0;
  }

  .profile-info__name {
    font-size: var(--font-h4, 16px);
  }

  .profile-stats {
    flex-wrap: wrap;
    gap: var(--space-md, 12px);
  }

  .profile-info__actions {
    width: 100%;
  }

  .profile-info__actions :deep(.el-button) {
    flex: 1;
  }
}
</style>
