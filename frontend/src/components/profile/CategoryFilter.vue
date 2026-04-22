<template>
  <!--
    CategoryFilter - 分类筛选组件
    支持分类标签筛选和按年月筛选
  -->
  <div class="category-filter">
    <!-- 分类标签 -->
    <el-tag
      v-for="cat in categories"
      :key="cat.id"
      class="category-tag"
      :class="{ 'is-active': modelValue === cat.id }"
      :effect="modelValue === cat.id ? 'dark' : 'plain'"
      @click="handleSelect(cat.id)"
    >
      {{ cat.name }}
    </el-tag>

    <!-- 年月筛选 -->
    <el-date-picker
      v-model="selectedDate"
      type="month"
      placeholder="按年月筛选"
      format="YYYY年MM月"
      size="small"
      clearable
      @change="handleDateChange"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import type { Category } from '@/types/profile'

interface Props {
  categories: Category[]
  modelValue?: number | null
}

interface Emits {
  (e: 'update:modelValue', value: number | null): void
  (e: 'change', params: { categoryId?: number; year?: number; month?: number }): void
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: null
})

const emit = defineEmits<Emits>()

const selectedDate = ref<Date | null>(null)

function handleSelect(categoryId: number) {
  const newId = props.modelValue === categoryId ? null : categoryId
  emit('update:modelValue', newId)
  emitChange(newId)
}

function handleDateChange(date: Date | null) {
  if (date) {
    const year = date.getFullYear()
    const month = date.getMonth() + 1
    emit('change', { categoryId: props.modelValue ?? undefined, year, month })
  } else {
    emitChange(props.modelValue)
  }
}

function emitChange(categoryId: number | null) {
  emit('change', { categoryId: categoryId ?? undefined })
}
</script>

<style scoped>
.category-filter {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-sm, 8px);
  margin-bottom: var(--space-lg, 16px);
  align-items: center;
}

.category-tag {
  cursor: pointer;
  transition: all var(--duration-fast, 100ms) var(--easing-out);
}
</style>
