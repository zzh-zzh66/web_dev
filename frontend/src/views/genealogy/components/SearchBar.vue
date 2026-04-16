<template>
  <div class="search-bar">
    <el-input
      v-model="searchKeyword"
      :placeholder="placeholder"
      clearable
      @input="handleInput"
      @focus="handleFocus"
      @blur="handleBlur"
      @keyup.enter="handleSearch"
      @keyup.up.prevent="handleArrowUp"
      @keyup.down.prevent="handleArrowDown"
    >
      <template #prefix>
        <el-icon class="search-icon"><Search /></el-icon>
      </template>
      <template #suffix>
        <div class="search-actions">
          <el-icon
            v-if="searchKeyword"
            class="clear-icon"
            @click="handleClear"
          >
            <Close />
          </el-icon>
          <el-button
            v-if="showHistory"
            text
            size="small"
            class="history-btn"
            @click.stop="toggleHistory"
          >
            <el-icon><Clock /></el-icon>
          </el-button>
        </div>
      </template>
    </el-input>

    <!-- 搜索建议下拉 -->
    <div
      v-if="showSuggestions && suggestions.length > 0"
      class="suggestions-dropdown"
    >
      <div
        v-for="(suggestion, index) in suggestions"
        :key="suggestion.memberId"
        class="suggestion-item"
        :class="{ 'is-active': index === activeIndex }"
        @click="handleSelectSuggestion(suggestion)"
        @mouseenter="activeIndex = index"
      >
        <el-icon class="suggestion-avatar">
          <UserFilled v-if="suggestion.gender === 'MALE'" />
          <Female v-else />
        </el-icon>
        <div class="suggestion-info">
          <span class="suggestion-name" v-html="suggestion.name"></span>
          <span class="suggestion-meta">
            第{{ suggestion.generation }}代 ·
            {{ suggestion.status === 'ALIVE' ? '在世' : '已故' }}
          </span>
        </div>
      </div>
    </div>

    <!-- 搜索历史下拉 -->
    <div
      v-if="showSuggestions && showHistoryDropdown && historyList.length > 0"
      class="suggestions-dropdown"
    >
      <div class="dropdown-header">
        <span>搜索历史</span>
        <el-button text size="small" @click.stop="clearHistory">清除</el-button>
      </div>
      <div
        v-for="(item, index) in historyList"
        :key="index"
        class="suggestion-item history-item"
        @click="handleSelectHistory(item)"
      >
        <el-icon class="history-icon"><Clock /></el-icon>
        <span class="history-text">{{ item.keyword }}</span>
      </div>
    </div>

    <!-- 无结果提示 -->
    <div
      v-if="showSuggestions && showNoResult"
      class="suggestions-dropdown no-result"
    >
      <el-empty description="未找到匹配成员" :image-size="60" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { Search, Close, Clock, UserFilled, Female } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import type { Member } from '@/api/member'
import { memberApi } from '@/api/member'
import type { SearchHistory } from '@/types/genealogy'

interface Props {
  placeholder?: string
  showHistory?: boolean
}

interface Emits {
  (e: 'search', keyword: string): void
  (e: 'select', member: Member): void
}

const props = withDefaults(defineProps<Props>(), {
  placeholder: '请输入姓名、手机号搜索...',
  showHistory: true
})

const emit = defineEmits<Emits>()

const searchKeyword = ref('')
const suggestions = ref<Member[]>([])
const showSuggestions = ref(false)
const showHistoryDropdown = ref(false)
const activeIndex = ref(-1)
const loading = ref(false)

const HISTORY_KEY = 'genealogy_search_history'
const MAX_HISTORY = 10
const MIN_SEARCH_LENGTH = 2

// 历史记录列表
const historyList = computed<SearchHistory[]>(() => {
  const history = localStorage.getItem(HISTORY_KEY)
  return history ? JSON.parse(history) : []
})

// 是否显示无结果
const showNoResult = computed(() => {
  return (
    searchKeyword.value.length >= MIN_SEARCH_LENGTH &&
    suggestions.value.length === 0 &&
    !loading.value &&
    !showHistoryDropdown.value
  )
})

// 防抖定时器
let debounceTimer: ReturnType<typeof setTimeout> | null = null

// 搜索建议
const fetchSuggestions = async (keyword: string) => {
  if (keyword.length < MIN_SEARCH_LENGTH) {
    suggestions.value = []
    return
  }

  loading.value = true
  try {
    const res = await memberApi.getList({
      name: keyword,
      size: 10
    })
    suggestions.value = res.data.records
  } catch (error) {
    console.error('搜索失败', error)
    suggestions.value = []
  } finally {
    loading.value = false
  }
}

// 输入处理
const handleInput = () => {
  activeIndex.value = -1
  showHistoryDropdown.value = false

  if (debounceTimer) {
    clearTimeout(debounceTimer)
  }

  debounceTimer = setTimeout(() => {
    fetchSuggestions(searchKeyword.value)
  }, 300)
}

// 聚焦处理
const handleFocus = () => {
  showSuggestions.value = true
  if (searchKeyword.value.length === 0 && props.showHistory) {
    showHistoryDropdown.value = true
    suggestions.value = []
  }
}

// 失焦处理
const handleBlur = () => {
  setTimeout(() => {
    showSuggestions.value = false
    showHistoryDropdown.value = false
  }, 200)
}

// 切换历史记录显示
const toggleHistory = () => {
  showHistoryDropdown.value = !showHistoryDropdown.value
  if (showHistoryDropdown.value) {
    suggestions.value = []
  }
}

// 清除搜索关键词
const handleClear = () => {
  searchKeyword.value = ''
  suggestions.value = []
  showHistoryDropdown.value = false
  emit('search', '')
}

// 搜索
const handleSearch = () => {
  if (!searchKeyword.value.trim()) {
    ElMessage.warning('请输入搜索关键词')
    return
  }

  addToHistory(searchKeyword.value.trim())
  showSuggestions.value = false
  emit('search', searchKeyword.value.trim())
}

// 选择搜索建议
const handleSelectSuggestion = (member: Member) => {
  addToHistory(member.name)
  showSuggestions.value = false
  emit('select', member)
}

// 选择历史记录
const handleSelectHistory = (item: SearchHistory) => {
  searchKeyword.value = item.keyword
  showHistoryDropdown.value = false
  emit('search', item.keyword)
  fetchSuggestions(item.keyword)
}

// 键盘向上
const handleArrowUp = () => {
  if (suggestions.value.length > 0) {
    activeIndex.value = activeIndex.value <= 0
      ? suggestions.value.length - 1
      : activeIndex.value - 1
  }
}

// 键盘向下
const handleArrowDown = () => {
  if (suggestions.value.length > 0) {
    activeIndex.value = activeIndex.value >= suggestions.value.length - 1
      ? 0
      : activeIndex.value + 1
  }
}

// 添加到历史记录
const addToHistory = (keyword: string) => {
  let history: SearchHistory[] = JSON.parse(localStorage.getItem(HISTORY_KEY) || '[]')

  // 移除已存在的相同关键词
  history = history.filter(item => item.keyword !== keyword)

  // 添加到开头
  history.unshift({
    keyword,
    timestamp: Date.now()
  })

  // 限制数量
  if (history.length > MAX_HISTORY) {
    history = history.slice(0, MAX_HISTORY)
  }

  localStorage.setItem(HISTORY_KEY, JSON.stringify(history))
}

// 清除历史记录
const clearHistory = () => {
  localStorage.removeItem(HISTORY_KEY)
  showHistoryDropdown.value = false
}

// 暴露方法
defineExpose({
  clear: () => {
    searchKeyword.value = ''
    suggestions.value = []
  }
})
</script>

<style scoped>
.search-bar {
  position: relative;
}

.search-icon {
  color: #909399;
}

.search-actions {
  display: flex;
  align-items: center;
  gap: 4px;
}

.clear-icon {
  cursor: pointer;
  color: #909399;
  font-size: 14px;
}

.clear-icon:hover {
  color: #409EFF;
}

.history-btn {
  padding: 4px;
  color: #909399;
}

.history-btn:hover {
  color: #409EFF;
}

/* 下拉建议 */
.suggestions-dropdown {
  position: absolute;
  top: calc(100% + 4px);
  left: 0;
  right: 0;
  background: #fff;
  border: 1px solid #E4E7ED;
  border-radius: 4px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  z-index: 1000;
  max-height: 320px;
  overflow-y: auto;
}

.dropdown-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  font-size: 12px;
  color: #909399;
  border-bottom: 1px solid #F4F4F5;
}

.suggestion-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  cursor: pointer;
  transition: background 0.15s;
}

.suggestion-item:hover,
.suggestion-item.is-active {
  background: #F5F7FA;
}

.suggestion-avatar {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #409EFF;
  color: #fff;
  border-radius: 50%;
  font-size: 16px;
}

.suggestion-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.suggestion-name {
  font-size: 14px;
  color: #303133;
  font-weight: 500;
}

.suggestion-name :deep(mark) {
  color: #E6A23C;
  background: none;
  font-weight: 600;
}

.suggestion-meta {
  font-size: 12px;
  color: #909399;
}

/* 历史记录 */
.history-item {
  padding: 8px 12px;
}

.history-icon {
  color: #909399;
  font-size: 14px;
}

.history-text {
  font-size: 13px;
  color: #606266;
}

/* 无结果 */
.no-result {
  padding: 20px;
  text-align: center;
}
</style>
