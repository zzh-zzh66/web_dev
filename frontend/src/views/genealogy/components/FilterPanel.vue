<template>
  <div class="filter-panel">
    <div class="panel-header">
      <span class="panel-title">筛选条件</span>
      <el-button
        v-if="hasActiveFilters"
        text
        size="small"
        type="danger"
        @click="clearAllFilters"
      >
        清除全部
      </el-button>
    </div>

    <div class="filter-content">
      <!-- 辈分筛选 -->
      <div class="filter-section">
        <div class="filter-label">辈分</div>
        <div class="filter-buttons">
          <el-check-tag
            v-for="gen in generations"
            :key="gen.value"
            :checked="filters.generations.includes(gen.value)"
            :style="gen.checked ? { backgroundColor: gen.color, borderColor: gen.color } : {}"
            @change="toggleGeneration(gen.value)"
          >
            {{ gen.label }}
          </el-check-tag>
        </div>
      </div>

      <!-- 性别筛选 -->
      <div class="filter-section">
        <div class="filter-label">性别</div>
        <div class="filter-buttons">
          <el-radio-group v-model="filters.gender" size="small">
            <el-radio-button :label="''">全部</el-radio-button>
            <el-radio-button label="MALE">男</el-radio-button>
            <el-radio-button label="FEMALE">女</el-radio-button>
          </el-radio-group>
        </div>
      </div>

      <!-- 状态筛选 -->
      <div class="filter-section">
        <div class="filter-label">状态</div>
        <div class="filter-buttons">
          <el-radio-group v-model="filters.status" size="small">
            <el-radio-button :label="''">全部</el-radio-button>
            <el-radio-button label="ALIVE">在世</el-radio-button>
            <el-radio-button label="DECEASED">已故</el-radio-button>
          </el-radio-group>
        </div>
      </div>

      <!-- 出生年代筛选 -->
      <div class="filter-section">
        <div class="filter-label">出生年代</div>
        <div class="filter-range">
          <el-input-number
            v-model="filters.birthYearFrom"
            :min="1900"
            :max="2030"
            size="small"
            placeholder="从"
            @change="handleRangeChange"
          />
          <span class="range-separator">至</span>
          <el-input-number
            v-model="filters.birthYearTo"
            :min="1900"
            :max="2030"
            size="small"
            placeholder="至"
            @change="handleRangeChange"
          />
        </div>
      </div>
    </div>

    <!-- 已选筛选标签 -->
    <div v-if="hasActiveFilters" class="active-filters">
      <div class="active-filters-header">已选筛选:</div>
      <div class="filter-tags">
        <el-tag
          v-for="tag in activeFilterTags"
          :key="tag.key"
          closable
          size="small"
          @close="removeFilter(tag.key)"
        >
          {{ tag.label }}
        </el-tag>
      </div>
    </div>

    <!-- 筛选结果统计 -->
    <div v-if="showStats" class="filter-stats">
      <span class="stats-text">
        共 <strong>{{ totalCount }}</strong> 人，
        匹配 <strong>{{ matchedCount }}</strong> 人
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch } from 'vue'
import { getGenerationColor, type FilterConditions } from '@/types/genealogy'

interface Props {
  showStats?: boolean
  totalCount?: number
  matchedCount?: number
}

interface Emits {
  (e: 'filter-change', filters: FilterConditions): void
}

withDefaults(defineProps<Props>(), {
  showStats: true,
  totalCount: 0,
  matchedCount: 0
})

const emit = defineEmits<Emits>()

// 辈分选项
const generations = ref<Array<{
  value: number
  label: string
  checked: boolean
  color: string
}>>([])

// 初始化辈分选项
const initGenerations = () => {
  generations.value = [1, 2, 3, 4, 5, 6, 7].map(gen => ({
    value: gen,
    label: `第${gen}代`,
    checked: false,
    color: getGenerationColor(gen)
  }))
}

// 筛选条件
const filters = reactive<FilterConditions>({
  generations: [],
  gender: '',
  status: '',
  birthYearFrom: null,
  birthYearTo: null
})

// 是否有激活的筛选
const hasActiveFilters = computed(() => {
  return (
    filters.generations.length > 0 ||
    filters.gender !== '' ||
    filters.status !== '' ||
    filters.birthYearFrom !== null ||
    filters.birthYearTo !== null
  )
})

// 激活的筛选标签
const activeFilterTags = computed(() => {
  const tags: Array<{ key: string; label: string }> = []

  filters.generations.forEach(gen => {
    tags.push({
      key: `generation_${gen}`,
      label: `第${gen}代`
    })
  })

  if (filters.gender) {
    tags.push({
      key: 'gender',
      label: filters.gender === 'MALE' ? '男' : '女'
    })
  }

  if (filters.status) {
    tags.push({
      key: 'status',
      label: filters.status === 'ALIVE' ? '在世' : '已故'
    })
  }

  if (filters.birthYearFrom && filters.birthYearTo) {
    tags.push({
      key: 'birthYear',
      label: `${filters.birthYearFrom}-${filters.birthYearTo}年`
    })
  } else if (filters.birthYearFrom) {
    tags.push({
      key: 'birthYearFrom',
      label: `${filters.birthYearFrom}年以后`
    })
  } else if (filters.birthYearTo) {
    tags.push({
      key: 'birthYearTo',
      label: `${filters.birthYearTo}年以前`
    })
  }

  return tags
})

// 切换辈分筛选
const toggleGeneration = (generation: number) => {
  const index = filters.generations.indexOf(generation)
  if (index === -1) {
    filters.generations.push(generation)
  } else {
    filters.generations.splice(index, 1)
  }

  // 更新辈分选项的选中状态
  generations.value.forEach(gen => {
    gen.checked = filters.generations.includes(gen.value)
  })

  emit('filter-change', { ...filters })
}

// 年代范围变化
const handleRangeChange = () => {
  emit('filter-change', { ...filters })
}

// 移除单个筛选
const removeFilter = (key: string) => {
  if (key.startsWith('generation_')) {
    const gen = parseInt(key.replace('generation_', ''))
    const index = filters.generations.indexOf(gen)
    if (index !== -1) {
      filters.generations.splice(index, 1)
      generations.value.forEach(g => {
        g.checked = filters.generations.includes(g.value)
      })
    }
  } else if (key === 'gender') {
    filters.gender = ''
  } else if (key === 'status') {
    filters.status = ''
  } else if (key === 'birthYear') {
    filters.birthYearFrom = null
    filters.birthYearTo = null
  } else if (key === 'birthYearFrom') {
    filters.birthYearFrom = null
  } else if (key === 'birthYearTo') {
    filters.birthYearTo = null
  }

  emit('filter-change', { ...filters })
}

// 清除所有筛选
const clearAllFilters = () => {
  filters.generations = []
  filters.gender = ''
  filters.status = ''
  filters.birthYearFrom = null
  filters.birthYearTo = null

  generations.value.forEach(gen => {
    gen.checked = false
  })

  emit('filter-change', { ...filters })
}

// 监听辈分筛选的radio变化，更新checked状态
watch(() => filters.generations, (newGenerations) => {
  generations.value.forEach(gen => {
    gen.checked = newGenerations.includes(gen.value)
  })
}, { deep: true })

// 初始化
initGenerations()

// 暴露方法
defineExpose({
  clearAll: clearAllFilters
})
</script>

<style scoped>
.filter-panel {
  background: #fff;
  border-radius: 4px;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #E4E7ED;
}

.panel-title {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.filter-content {
  padding: 16px;
}

.filter-section {
  margin-bottom: 16px;
}

.filter-section:last-child {
  margin-bottom: 0;
}

.filter-label {
  font-size: 13px;
  color: #606266;
  margin-bottom: 8px;
}

.filter-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.filter-range {
  display: flex;
  align-items: center;
  gap: 8px;
}

.range-separator {
  color: #909399;
  font-size: 13px;
}

/* 辈分标签样式 */
.filter-buttons :deep(.el-check-tag) {
  padding: 4px 12px;
  font-size: 12px;
  border-radius: 4px;
  border: 1px solid #DCDFE6;
  color: #606266;
  background: #fff;
  transition: all 0.2s;
}

.filter-buttons :deep(.el-check-tag:hover) {
  color: #409EFF;
  border-color: #409EFF;
}

.filter-buttons :deep(.el-check-tag.is-checked) {
  color: #fff;
  border-color: transparent;
}

/* 激活的筛选标签 */
.active-filters {
  padding: 12px 16px;
  background: #F5F7FA;
  border-top: 1px solid #E4E7ED;
}

.active-filters-header {
  font-size: 12px;
  color: #909399;
  margin-bottom: 8px;
}

.filter-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

/* 统计信息 */
.filter-stats {
  padding: 12px 16px;
  border-top: 1px solid #E4E7ED;
}

.stats-text {
  font-size: 12px;
  color: #606266;
}

.stats-text strong {
  color: #409EFF;
}
</style>
