<template>
  <!--
    PostDialog - 内容发布对话框
    支持文本、图片上传、视频上传、可见性选择、分类选择
  -->
  <el-dialog
    v-model="dialogVisible"
    title="发布动态"
    width="600px"
    class="post-dialog"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <!-- 用户信息 -->
    <div class="post-dialog__header">
      <el-avatar :size="40">
        <el-icon><User /></el-icon>
      </el-avatar>
      <div class="post-dialog__user-info">
        <span class="post-dialog__username">{{ userName }}</span>
      </div>
      <!-- 可见性选择 -->
      <el-dropdown trigger="click">
        <el-button text>
          {{ visibilityText }}
          <el-icon><ArrowDown /></el-icon>
        </el-button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item v-for="opt in visibilityOptions" :key="opt.value" @click="visibility = opt.value">
              {{ opt.label }}
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>

    <!-- 内容输入区 -->
    <div class="post-dialog__content">
      <!-- 分类选择 -->
      <el-select
        v-model="categoryId"
        placeholder="选择分类"
        size="small"
        clearable
        class="post-dialog__category-select"
      >
        <el-option
          v-for="cat in categories"
          :key="cat.id"
          :label="cat.name"
          :value="cat.id"
        />
      </el-select>

      <textarea
        v-model="contentText"
        class="post-dialog__textarea"
        placeholder="分享你的生活点滴..."
        maxlength="5000"
        rows="5"
        @input="onContentInput"
      />
      <div class="post-dialog__char-count">{{ contentLength }}/5000</div>
    </div>

    <!-- 工具栏 -->
    <div class="post-dialog__tools">
      <button class="post-dialog__tool-btn" @click="triggerImageUpload">
        <el-icon><Picture /></el-icon>
        图片
      </button>
      <button class="post-dialog__tool-btn" @click="triggerVideoUpload">
        <el-icon><VideoCamera /></el-icon>
        视频
      </button>
      <button class="post-dialog__tool-btn" @click="insertMention">
        <el-icon><User /></el-icon>
        @提到
      </button>
      <button class="post-dialog__tool-btn" @click="insertHashtag">
        <el-icon><ChatDotRound /></el-icon>
        #话题
      </button>
      <!-- 隐藏的上传input -->
      <input ref="imageInputRef" type="file" accept="image/*" multiple hidden @change="handleImageUpload" />
      <input ref="videoInputRef" type="file" accept="video/*" hidden @change="handleVideoUpload" />
    </div>

    <!-- 图片预览列表 -->
    <div v-if="uploadedImages.length > 0" class="post-dialog__images">
      <div class="post-dialog__image-list">
        <div v-for="(img, index) in uploadedImages" :key="index" class="post-dialog__image-item">
          <img :src="img.previewUrl" :alt="`图片 ${index + 1}`" />
          <button class="post-dialog__image-remove" @click="removeImage(index)">
            <el-icon><Close /></el-icon>
          </button>
          <!-- 上传进度 -->
          <div v-if="img.uploading" class="post-dialog__upload-progress">
            <el-progress type="circle" :percentage="img.progress" :width="30" />
          </div>
        </div>
        <!-- 添加图片按钮 -->
        <button v-if="uploadedImages.length < 9" class="post-dialog__upload-btn" @click="triggerImageUpload">
          <el-icon :size="24"><Plus /></el-icon>
          <span>添加图片</span>
        </button>
      </div>
    </div>

    <!-- 底部操作 -->
    <div class="post-dialog__footer">
      <div class="post-dialog__settings">
        <!-- 分类选择 -->
        <span class="post-dialog__setting-text">
          发布到: 
          <el-select v-model="postType" size="small" style="width: 100px">
            <el-option label="日常动态" value="TEXT" />
            <el-option label="图文动态" value="IMAGE" />
            <el-option label="视频动态" value="VIDEO" />
            <el-option label="生平事件" value="LIFE_EVENT" />
          </el-select>
        </span>
      </div>
      <div class="post-dialog__actions">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="submitting"
          :disabled="!canSubmit"
          @click="handlePost"
        >
          发布
        </el-button>
      </div>
    </div>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  ArrowDown, Picture, VideoCamera, User,
  ChatDotRound, Plus, Close
} from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { useProfileStore } from '@/store/profile'
import { fileApi } from '@/api/profile'

interface Props {
  visible: boolean
}

interface Emits {
  (e: 'update:visible', val: boolean): void
  (e: 'success'): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const userStore = useUserStore()
const profileStore = useProfileStore()

const dialogVisible = computed({
  get: () => props.visible,
  set: (val) => emit('update:visible', val)
})

/** 表单数据 */
const contentText = ref('')
const postType = ref<'TEXT' | 'IMAGE' | 'VIDEO' | 'LIFE_EVENT'>('TEXT')
const categoryId = ref<number | undefined>(undefined)
const visibility = ref<'PUBLIC' | 'FAMILY' | 'RELATIVE' | 'PRIVATE'>('FAMILY')
const uploadedImages = ref<Array<{ file: File; previewUrl: string; url: string; uploading: boolean; progress: number }>>([])

const submitting = ref(false)
const imageInputRef = ref<HTMLInputElement | null>(null)
const videoInputRef = ref<HTMLInputElement | null>(null)

const categories = computed(() => profileStore.categories)
const userName = computed(() => userStore.userInfo?.name || '我')
const userAvatar = computed(() => userStore.userInfo?.avatar || userStore.userInfo?.avatarUrl || '/default-avatar.png')

/** 内容长度 */
const contentLength = computed(() => contentText.value.length)

/** 是否可以提交 */
const canSubmit = computed(() => {
  return contentText.value.trim().length > 0 && !submitting.value
})

/** 可见性选项 */
const visibilityOptions = [
  { label: '全族可见', value: 'PUBLIC' as const },
  { label: '家族可见', value: 'FAMILY' as const },
  { label: '仅亲属', value: 'RELATIVE' as const },
  { label: '仅自己', value: 'PRIVATE' as const }
]

/** 可见性文本 */
const visibilityText = computed(() => {
  const opt = visibilityOptions.find(o => o.value === visibility.value)
  return opt?.label || '全族可见'
})

/** 触发图片上传 */
function triggerImageUpload() {
  imageInputRef.value?.click()
}

/** 触发视频上传 */
function triggerVideoUpload() {
  videoInputRef.value?.click()
}

/** 处理图片上传 */
async function handleImageUpload(event: Event) {
  const input = event.target as HTMLInputElement
  const files = input.files
  if (!files) return

  const remainingSlots = 9 - uploadedImages.value.length
  const filesToUpload = Array.from(files).slice(0, remainingSlots)

  for (const file of filesToUpload) {
    const previewUrl = URL.createObjectURL(file)
    const item = {
      file,
      previewUrl,
      url: '',
      uploading: true,
      progress: 0
    }
    uploadedImages.value.push(item)

    try {
      // 模拟上传进度
      item.progress = 0
      const interval = setInterval(() => {
        item.progress = Math.min(item.progress + 20, 90)
      }, 200)

      const res = await fileApi.uploadImage(file)
      clearInterval(interval)
      item.url = res.data.url
      item.progress = 100
      item.uploading = false

      // 更新动态类型
      if (postType.value === 'TEXT') {
        postType.value = 'IMAGE'
      }
    } catch (error) {
      ElMessage.error(`图片 "${file.name}" 上传失败`)
      // 移除失败项
      const idx = uploadedImages.value.indexOf(item)
      if (idx !== -1) {
        uploadedImages.value.splice(idx, 1)
        URL.revokeObjectURL(previewUrl)
      }
    }
  }

  input.value = ''
}

/** 处理视频上传 */
async function handleVideoUpload(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return

  try {
    ElMessage.info('视频上传中...')
    const res = await fileApi.uploadVideo(file)
    // 视频上传成功后可以保存视频信息
    postType.value = 'VIDEO'
    ElMessage.success('视频上传成功')
  } catch (error) {
    ElMessage.error('视频上传失败')
  }

  input.value = ''
}

/** 移除图片 */
function removeImage(index: number) {
  const item = uploadedImages.value[index]
  URL.revokeObjectURL(item.previewUrl)
  uploadedImages.value.splice(index, 1)
}

/** 插入@提及 */
function insertMention() {
  contentText.value += '@'
}

/** 插入话题标签 */
function insertHashtag() {
  contentText.value += '#'
}

/** 内容输入处理 */
function onContentInput() {
  // 可以在此处做内容解析（@用户、话题标签高亮等）
}

/** 发布动态 */
async function handlePost() {
  if (!canSubmit.value) return

  submitting.value = true
  try {
    // 等待所有图片上传完成
    const pendingImages = uploadedImages.value.filter(img => img.uploading)
    if (pendingImages.length > 0) {
      ElMessage.warning('图片正在上传中，请稍候...')
      return
    }

    await profileStore.createPost({
      postType: postType.value,
      categoryId: categoryId.value,
      content: contentText.value,
      visibility: visibility.value,
      mediaList: uploadedImages.value.map(img => ({
        url: img.url,
        type: 'IMAGE' as const
      }))
    })

    ElMessage.success('发布成功')
    dialogVisible.value = false
    emit('success')
  } catch (error) {
    ElMessage.error('发布失败')
  } finally {
    submitting.value = false
  }
}

/** 对话框关闭后重置 */
function handleClosed() {
  contentText.value = ''
  postType.value = 'TEXT'
  categoryId.value = undefined
  visibility.value = 'FAMILY'
  uploadedImages.value = []
}

/** 获取分类列表 */
onMounted(async () => {
  if (categories.value.length === 0) {
    await profileStore.fetchCategories()
  }
})
</script>

<style scoped>
.post-dialog__header {
  display: flex;
  align-items: center;
  gap: var(--space-md, 12px);
  padding: var(--space-lg, 16px);
  border-bottom: 1px solid var(--border-color-light, #E4E7ED);
}

.post-dialog__user-info {
  display: flex;
  align-items: center;
  gap: var(--space-sm, 8px);
  flex: 1;
}

.post-dialog__username {
  font-size: var(--font-body, 14px);
  font-weight: 600;
  color: var(--text-primary, #303133);
}

.post-dialog__content {
  padding: var(--space-lg, 16px);
}

.post-dialog__category-select {
  margin-bottom: var(--space-md, 12px);
}

.post-dialog__textarea {
  width: 100%;
  padding: var(--space-md, 12px);
  font-size: var(--font-body-lg, 15px);
  line-height: var(--line-height-body-lg, 1.8);
  color: var(--text-primary, #303133);
  background: transparent;
  border: none;
  resize: none;
  min-height: 120px;
}

.post-dialog__textarea:focus {
  outline: none;
}

.post-dialog__textarea::placeholder {
  color: var(--text-placeholder, #C0C4CC);
}

.post-dialog__char-count {
  text-align: right;
  font-size: var(--font-caption, 12px);
  color: var(--text-secondary, #909399);
  margin-top: var(--space-xs, 4px);
}

.post-dialog__tools {
  display: flex;
  gap: var(--space-sm, 8px);
  padding: var(--space-sm, 8px) var(--space-lg, 16px);
  border-bottom: 1px solid var(--border-color-light, #E4E7ED);
}

.post-dialog__tool-btn {
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
  transition: all var(--duration-fast, 100ms) var(--easing-out);
}

.post-dialog__tool-btn:hover {
  color: var(--primary-color, #409EFF);
  background: var(--primary-color-light-1, #ECF5FF);
}

.post-dialog__images {
  padding: var(--space-sm, 8px) var(--space-lg, 16px);
}

.post-dialog__image-list {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-sm, 8px);
}

.post-dialog__image-item {
  position: relative;
  width: 100px;
  height: 100px;
  border-radius: var(--radius-base, 4px);
  overflow: hidden;
}

.post-dialog__image-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.post-dialog__image-remove {
  position: absolute;
  top: 2px;
  right: 2px;
  width: 20px;
  height: 20px;
  background: rgba(0, 0, 0, 0.6);
  color: white;
  border: none;
  border-radius: var(--radius-full);
  font-size: 12px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.post-dialog__upload-progress {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.8);
}

.post-dialog__upload-btn {
  width: 100px;
  height: 100px;
  border: 1px dashed var(--border-color, #DCDFE6);
  border-radius: var(--radius-base, 4px);
  background: var(--bg-color-page, #F9F6F0);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--space-xs, 4px);
  cursor: pointer;
  transition: all var(--duration-fast, 100ms) var(--easing-out);
  color: var(--text-secondary, #909399);
  font-size: var(--font-caption, 12px);
}

.post-dialog__upload-btn:hover {
  border-color: var(--primary-color, #409EFF);
  color: var(--primary-color, #409EFF);
}

.post-dialog__footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-lg, 16px);
  border-top: 1px solid var(--border-color-light, #E4E7ED);
}

.post-dialog__settings {
  display: flex;
  gap: var(--space-lg, 16px);
}

.post-dialog__setting-text {
  font-size: var(--font-body-sm, 13px);
  color: var(--text-secondary, #909399);
  display: flex;
  align-items: center;
  gap: var(--space-xs, 4px);
}

.post-dialog__actions {
  display: flex;
  gap: var(--space-sm, 8px);
}
</style>
