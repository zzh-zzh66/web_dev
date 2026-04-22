<template>
  <!--
    ImageGrid - 图片网格组件
    支持1-9张图片的不同布局，点击图片打开预览
  -->
  <div class="image-grid" :data-count="displayCount" @click="handleImageClick">
    <div
      v-for="(media, index) in displayImages"
      :key="media.id || index"
      class="image-grid__item"
    >
      <img
        :src="media.thumbnailUrl || media.url"
        :alt="`图片 ${index + 1}`"
        loading="lazy"
        @click.stop="openPreview(index)"
      />
    </div>
    <!-- 超过9张时显示"更多"覆盖层 -->
    <div
      v-if="images.length > 9"
      class="image-grid__item"
      style="position: relative"
    >
      <img
        :src="images[8].thumbnailUrl || images[8].url"
        alt="更多图片"
        loading="lazy"
      />
      <div class="image-grid__more" @click="openPreview(8)">
        +{{ images.length - 9 }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { ElImageViewer } from 'element-plus'
import type { PostMedia } from '@/types/profile'

interface Props {
  /** 图片列表 */
  images: PostMedia[]
}

const props = defineProps<Props>()

/** 最多显示9张图片 */
const displayImages = computed(() => {
  return props.images.slice(0, 9)
})

/** 实际显示的图片数量 */
const displayCount = computed(() => {
  return Math.min(props.images.length, 9)
})

/** 打开图片预览 */
function openPreview(index: number) {
  // 使用Element Plus的图片预览功能
  const urls = props.images.map(img => img.url)
  ElImageViewer({
    urlList: urls,
    initialIndex: index,
    hideOnClickModal: true,
    teleported: true
  })
}

/** 兼容旧版事件 */
function handleImageClick() {
  // 通过子元素的 @click.stop 阻止冒泡
  // 此方法不再被调用
}
</script>

<style scoped>
.image-grid {
  display: grid;
  gap: 4px;
  border-radius: var(--radius-base, 4px);
  overflow: hidden;
}

.image-grid[data-count="1"] {
  grid-template-columns: 1fr;
}

.image-grid[data-count="1"] .image-grid__item {
  max-height: 400px;
}

.image-grid[data-count="1"] .image-grid__item img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.image-grid[data-count="2"] {
  grid-template-columns: 1fr 1fr;
}

.image-grid[data-count="3"] {
  grid-template-columns: 1fr 1fr 1fr;
}

.image-grid[data-count="4"] {
  grid-template-columns: 1fr 1fr;
}

.image-grid[data-count="5"],
.image-grid[data-count="6"],
.image-grid[data-count="7"],
.image-grid[data-count="8"],
.image-grid[data-count="9"] {
  grid-template-columns: 1fr 1fr 1fr;
}

.image-grid__item {
  position: relative;
  aspect-ratio: 1;
  overflow: hidden;
  cursor: pointer;
  border-radius: var(--radius-base, 4px);
}

.image-grid__item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform var(--duration-fast, 200ms) var(--easing-out);
}

.image-grid__item:hover img {
  transform: scale(1.02);
}

.image-grid__more {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.5);
  color: white;
  font-size: var(--font-h3, 18px);
  font-weight: 600;
  border-radius: var(--radius-base, 4px);
}
</style>
