<template>
  <!--
    ProfileTabs - 主页Tab导航
    响应式适配PC/平板/手机
  -->
  <nav class="profile-tabs" role="tablist">
    <button
      v-for="tab in tabs"
      :key="tab.name"
      class="profile-tab"
      :class="{ 'is-active': modelValue === tab.name }"
      role="tab"
      :aria-selected="modelValue === tab.name"
      @click="updateTab(tab.name)"
    >
      <el-icon v-if="tab.icon">
        <component :is="tab.icon" />
      </el-icon>
      {{ tab.label }}
      <!-- 未读角标 -->
      <span
        v-if="tab.badge && tab.badge > 0"
        class="profile-tab__badge"
      >
        {{ tab.badge > 99 ? '99+' : tab.badge }}
      </span>
    </button>
  </nav>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Document, User } from '@element-plus/icons-vue'

interface TabConfig {
  name: string
  label: string
  icon?: string
  badge?: number
}

interface Props {
  modelValue: string
}

interface Emits {
  (e: 'update:modelValue', value: string): void
}

withDefaults(defineProps<Props>(), {
})

const emit = defineEmits<Emits>()

const tabs = computed<TabConfig[]>(() => [
  { name: 'posts', label: '动态', icon: Document },
  { name: 'about', label: '关于', icon: User }
])

function updateTab(name: string) {
  emit('update:modelValue', name)
}
</script>

<style scoped>
.profile-tabs {
  display: flex;
  gap: var(--space-md, 12px);
  border-bottom: 1px solid var(--border-color-light, #E4E7ED);
  overflow-x: auto;
  scrollbar-width: none;
}

.profile-tabs::-webkit-scrollbar {
  display: none;
}

.profile-tab {
  padding: var(--space-md, 12px) var(--space-lg, 16px);
  font-size: var(--font-body, 14px);
  color: var(--text-secondary, #909399);
  background: none;
  border: none;
  border-bottom: 2px solid transparent;
  cursor: pointer;
  white-space: nowrap;
  transition: all var(--duration-fast, 100ms) var(--easing-out);
  position: relative;
  display: flex;
  align-items: center;
  gap: var(--space-xs, 4px);
}

.profile-tab:hover {
  color: var(--text-primary, #303133);
}

.profile-tab.is-active {
  color: var(--primary-color, #409EFF);
  border-bottom-color: var(--primary-color, #409EFF);
  font-weight: 500;
}

.profile-tab__badge {
  min-width: 16px;
  height: 16px;
  padding: 0 4px;
  font-size: 10px;
  line-height: 16px;
  text-align: center;
  color: white;
  background-color: var(--danger-color, #F56C6C);
  border-radius: var(--radius-full);
}

@media (max-width: 767px) {
  .profile-tab {
    padding: var(--space-sm, 8px) var(--space-md, 12px);
    font-size: var(--font-body-sm, 13px);
  }
}
</style>
