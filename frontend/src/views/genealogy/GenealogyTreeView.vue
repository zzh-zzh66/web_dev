<template>
  <div class="genealogy-tree-view">
    <!-- 左侧边栏 -->
    <aside class="left-sidebar" :class="{ 'is-collapsed': isSidebarCollapsed }">
      <div class="sidebar-header">
        <h2 class="sidebar-title">家族成员</h2>
        <p class="sidebar-subtitle">{{ totalMemberCount }} 位成员</p>
      </div>

      <div class="sidebar-content">
        <!-- 搜索栏 -->
        <div class="sidebar-section search-section">
          <SearchBar
            ref="searchBarRef"
            @search="handleSearch"
            @select="handleSearchSelect"
          />
        </div>

        <!-- 筛选面板 -->
        <div class="sidebar-section filter-section">
          <FilterPanel
            ref="filterPanelRef"
            :show-stats="true"
            :total-count="totalMemberCount"
            :matched-count="filteredMemberCount"
            @filter-change="handleFilterChange"
          />
        </div>

        <!-- 辈分导航 -->
        <div class="sidebar-section generation-nav">
          <div class="section-title">
            <span>辈分导航</span>
            <span class="section-count">{{ generationStats.length }} 代</span>
          </div>
          <div class="generation-list">
            <div
              v-for="gen in generationStats"
              :key="gen.generation"
              class="generation-card"
              :class="{ 'is-active': activeGeneration === gen.generation }"
              @click="handleGenerationClick(gen.generation)"
            >
              <span class="gen-color" :style="{ background: gen.color }"></span>
              <span class="gen-label">第 {{ gen.generation }} 代</span>
              <span class="gen-count">{{ gen.count }} 人</span>
            </div>
          </div>
        </div>
    </div>

    <!-- 侧边栏折叠按钮 -->
      <button class="sidebar-toggle" @click="toggleSidebar">
        <el-icon :size="14">
          <ArrowLeft v-if="!isSidebarCollapsed" />
          <ArrowRight v-else />
        </el-icon>
      </button>
    </aside>

    <!-- 主画布区域 - 固定视口 -->
    <main
      class="main-canvas"
      ref="canvasRef"
      @mousedown="handleCanvasMouseDown"
      @mousemove="handleCanvasMouseMove"
      @mouseup="handleCanvasMouseUp"
      @mouseleave="handleCanvasMouseUp"
      @wheel="handleCanvasWheel"
      @dblclick="handleCanvasDoubleClick"
    >
      <!-- 族谱内容层 - 可缩放拖动 -->
      <div class="canvas-content" :style="canvasContentStyle">
        <!-- 加载状态 -->
        <div v-if="loading" class="canvas-loading">
          <div class="loading-spinner">
            <el-icon class="is-loading"><Loading /></el-icon>
          </div>
          <p>正在加载家族数据...</p>
        </div>

        <!-- 族谱树 -->
        <div v-else-if="treeData" class="tree-wrapper">
          <GenealogyNodeComponent
            :node="treeData"
            :selected-id="selectedMemberId"
            :highlighted-ids="Array.from(highlightedIds)"
            :filtered-ids="Array.from(filteredIds)"
            :collapsed-ids="Array.from(collapsedIds)"
            @node-click="handleNodeClick"
            @node-dblclick="handleNodeDoubleClick"
          />
        </div>

        <!-- 空状态 -->
        <div v-else class="canvas-empty">
          <div class="empty-illustration">
            <el-icon :size="64"><DataLine /></el-icon>
          </div>
          <h3>暂无族谱数据</h3>
          <p>开始添加家族成员，构建您的族谱树</p>
          <el-button type="primary" class="empty-btn">添加成员</el-button>
        </div>
      </div>

      <!-- 缩放控制条 -->
      <div class="canvas-controls">
        <div class="zoom-controls">
          <button class="btn-icon" @click="handleZoomOut" :disabled="zoom <= minZoom">
            <el-icon><Minus /></el-icon>
          </button>
          <div class="zoom-track">
            <el-slider
              v-model="zoom"
              :min="minZoom"
              :max="maxZoom"
              :step="0.1"
              class="zoom-slider"
            />
          </div>
          <button class="btn-icon" @click="handleZoomIn" :disabled="zoom >= maxZoom">
            <el-icon><Plus /></el-icon>
          </button>
          <span class="zoom-value">{{ Math.round(zoom * 100) }}%</span>
        </div>

        <div class="control-divider"></div>

        <div class="view-controls">
          <button class="btn-pill" @click="handleExpandAll">
            <el-icon><Grid /></el-icon>
            {{ allExpanded ? '收起全部' : '展开全部' }}
          </button>
          <button class="btn-pill" @click="handleFullScreen">
            <el-icon><FullScreen /></el-icon>
          </button>
          <button class="btn-pill" @click="handleExport">
            <el-icon><Download /></el-icon>
            导出
          </button>
        </div>
      </div>

      <!-- 状态栏 -->
      <div class="canvas-status">
        <div class="status-left">
          <span class="status-item">
            <span class="status-dot"></span>
            共 {{ totalMemberCount }} 人
          </span>
          <span class="status-item" v-if="selectedMember">
            <span class="status-dot active"></span>
            当前: {{ selectedMember.name }}
          </span>
        </div>
        <div class="status-right">
          <span class="status-item">
            缩放 {{ Math.round(zoom * 100) }}%
          </span>
          <span class="status-item" v-if="filteredMemberCount !== totalMemberCount">
            已筛选 {{ filteredMemberCount }} 人
          </span>
        </div>
      </div>
    </main>

    <!-- 右侧详情面板 -->
    <aside class="right-panel" :class="{ 'is-open': isDetailPanelOpen }">
      <MemberDetailPanel
        :visible="isDetailPanelOpen"
        :member-id="selectedMemberId"
        @update:visible="handleDetailPanelClose"
        @jump="handleJumpToMember"
        @refresh="loadTreeData"
      />
    </aside>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  ArrowLeft,
  ArrowRight,
  Minus,
  Plus,
  FullScreen,
  Download,
  Grid,
  Loading,
  DataLine
} from '@element-plus/icons-vue'
import { genealogyApi } from '@/api/genealogy'
import type { GenealogyNode } from '@/api/genealogy'
import type { FilterConditions, GenerationStats } from '@/types/genealogy'
import { getGenerationColor } from '@/types/genealogy'
import SearchBar from './components/SearchBar.vue'
import FilterPanel from './components/FilterPanel.vue'
import MemberDetailPanel from './components/MemberDetailPanel.vue'
import GenealogyNodeComponent from './components/GenealogyNode.vue'

const loading = ref(false)
const treeData = ref<GenealogyNode | null>(null)
const selectedMemberId = ref<number | null>(null)
const selectedMember = ref<GenealogyNode | null>(null)
const isSidebarCollapsed = ref(false)
const isDetailPanelOpen = ref(false)
const allExpanded = ref(true)

const zoom = ref(1)
const minZoom = 0.3
const maxZoom = 2.0

const canvasRef = ref<HTMLElement | null>(null)
const searchBarRef = ref<InstanceType<typeof SearchBar> | null>(null)
const filterPanelRef = ref<InstanceType<typeof FilterPanel> | null>(null)

const highlightedIds = ref<Set<number>>(new Set())
const filteredIds = ref<Set<number>>(new Set())
const collapsedIds = ref<Set<number>>(new Set())

const isDragging = ref(false)
const dragStart = reactive({ x: 0, y: 0 })
const canvasPosition = reactive({ x: 0, y: 0 })

const activeGeneration = ref<number | null>(null)
const filterConditions = ref<FilterConditions>({
  generations: [],
  gender: '',
  status: '',
  birthYearFrom: null,
  birthYearTo: null
})

const totalMemberCount = computed(() => {
  if (!treeData.value) return 0
  let count = 0
  const traverse = (node: GenealogyNode) => {
    count++
    node.children?.forEach(traverse)
  }
  traverse(treeData.value)
  return count
})

const filteredMemberCount = computed(() => {
  if (filteredIds.value.size === 0) return totalMemberCount.value
  return filteredIds.value.size
})

const generationStats = computed<GenerationStats[]>(() => {
  if (!treeData.value) return []
  const stats = new Map<number, number>()

  const traverse = (node: GenealogyNode) => {
    const gen = node.generation || 1
    stats.set(gen, (stats.get(gen) || 0) + 1)
    node.children?.forEach(traverse)
  }
  traverse(treeData.value)

  return Array.from(stats.entries())
    .map(([generation, count]) => ({
      generation,
      count,
      color: getGenerationColor(generation)
    }))
    .sort((a, b) => a.generation - b.generation)
})

const canvasContentStyle = computed(() => ({
  transform: `translate(${canvasPosition.x}px, ${canvasPosition.y}px) scale(${zoom.value})`
}))

const loadTreeData = async () => {
  loading.value = true
  try {
    const res = await genealogyApi.getTree()
    treeData.value = res.data
  } catch (error) {
    console.error('加载族谱数据失败', error)
    ElMessage.error('加载族谱数据失败')
  } finally {
    loading.value = false
  }
}

const handleNodeClick = (node: GenealogyNode) => {
  selectedMemberId.value = node.memberId
  selectedMember.value = node
  isDetailPanelOpen.value = true
}

const handleNodeDoubleClick = (node: GenealogyNode) => {
  if (collapsedIds.value.has(node.memberId)) {
    collapsedIds.value.delete(node.memberId)
  } else {
    collapsedIds.value.add(node.memberId)
  }
}

const handleSearch = (keyword: string) => {
  if (!keyword.trim()) {
    highlightedIds.value.clear()
    return
  }
  const ids = new Set<number>()
  const traverse = (node: GenealogyNode) => {
    if (node.name.includes(keyword)) {
      ids.add(node.memberId)
    }
    node.children?.forEach(traverse)
  }
  if (treeData.value) {
    traverse(treeData.value)
  }
  highlightedIds.value = ids
}

const handleSearchSelect = (member: any) => {
  selectedMemberId.value = member.memberId
  selectedMember.value = member
  isDetailPanelOpen.value = true
}

const handleFilterChange = (filters: FilterConditions) => {
  filterConditions.value = filters
  if (!treeData.value) {
    filteredIds.value.clear()
    return
  }

  const ids = new Set<number>()
  const traverse = (node: GenealogyNode) => {
    let match = true
    if (filters.generations.length > 0 && !filters.generations.includes(node.generation)) {
      match = false
    }
    if (filters.gender && node.gender !== filters.gender) {
      match = false
    }
    if (filters.status && node.status !== filters.status) {
      match = false
    }
    if (match) {
      ids.add(node.memberId)
    }
    node.children?.forEach(traverse)
  }
  traverse(treeData.value)
  filteredIds.value = ids
}

const handleGenerationClick = (generation: number) => {
  activeGeneration.value = activeGeneration.value === generation ? null : generation
  if (activeGeneration.value !== null) {
    const ids = new Set<number>()
    const traverse = (node: GenealogyNode) => {
      if (node.generation === generation) {
        ids.add(node.memberId)
      }
      node.children?.forEach(traverse)
    }
    if (treeData.value) {
      traverse(treeData.value)
    }
    filteredIds.value = ids
  } else {
    filteredIds.value.clear()
  }
}

const handleZoomIn = () => {
  zoom.value = Math.min(zoom.value + 0.1, maxZoom)
}

const handleZoomOut = () => {
  zoom.value = Math.max(zoom.value - 0.1, minZoom)
}

const handleZoomReset = () => {
  zoom.value = 1
  canvasPosition.x = 0
  canvasPosition.y = 0
}

const handleExpandAll = () => {
  allExpanded.value = !allExpanded.value
  if (allExpanded.value) {
    collapsedIds.value.clear()
  } else {
    const collectIds = (node: GenealogyNode) => {
      if (node.children && node.children.length > 0) {
        collapsedIds.value.add(node.memberId)
        node.children.forEach(collectIds)
      }
    }
    if (treeData.value) {
      collectIds(treeData.value)
    }
  }
}

const handleFullScreen = () => {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen()
  } else {
    document.exitFullscreen()
  }
}

const handleExport = () => {
  ElMessage.info('导出功能开发中')
}

const handleCanvasMouseDown = (e: MouseEvent) => {
  if (e.button !== 0) return
  isDragging.value = true
  dragStart.x = e.clientX - canvasPosition.x
  dragStart.y = e.clientY - canvasPosition.y
}

const handleCanvasMouseMove = (e: MouseEvent) => {
  if (!isDragging.value) return
  canvasPosition.x = e.clientX - dragStart.x
  canvasPosition.y = e.clientY - dragStart.y
}

const handleCanvasMouseUp = () => {
  isDragging.value = false
}

const handleCanvasWheel = (e: WheelEvent) => {
  e.preventDefault()
  const delta = e.deltaY > 0 ? -0.1 : 0.1
  zoom.value = Math.max(minZoom, Math.min(maxZoom, zoom.value + delta))
}

const handleCanvasDoubleClick = () => {
  handleZoomReset()
}

const handleDetailPanelClose = () => {
  isDetailPanelOpen.value = false
}

const handleJumpToMember = (memberId: number) => {
  selectedMemberId.value = memberId
}

const toggleSidebar = () => {
  isSidebarCollapsed.value = !isSidebarCollapsed.value
}

const handleResize = () => {
  if (canvasRef.value) {
    // Handle resize if needed
  }
}

onMounted(() => {
  loadTreeData()
  window.addEventListener('resize', handleResize)
})
</script>

<style scoped>
.genealogy-tree-view {
  display: flex;
  height: calc(100vh - 64px);
  overflow: hidden;
  background: #ffffff;
}

/* 左侧边栏 */
.left-sidebar {
  position: relative;
  width: 300px;
  background: rgba(255, 255, 255, 0.98);
  border-right: 1px solid rgba(102, 126, 234, 0.1);
  display: flex;
  flex-direction: column;
  transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
  box-shadow: 4px 0 24px rgba(44, 30, 116, 0.06);
}

.left-sidebar.is-collapsed {
  width: 0;
  border-right: none;
}

.sidebar-header {
  padding: 24px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 0 0 24px 24px;
  margin: -16px -16px 16px -16px;
}

.sidebar-title {
  font-family: 'Outfit', sans-serif;
  font-size: 20px;
  font-weight: 600;
  color: #ffffff;
  margin: 0 0 4px 0;
}

.sidebar-subtitle {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.85);
  margin: 0;
}

.sidebar-content {
  flex: 1;
  overflow-y: auto;
  padding: 0 16px 16px;
}

.sidebar-section {
  margin-bottom: 20px;
}

.sidebar-toggle {
  position: absolute;
  right: -14px;
  top: 50%;
  transform: translateY(-50%);
  width: 28px;
  height: 56px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(102, 126, 234, 0.2);
  border-radius: 0 14px 14px 0;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #667eea;
  box-shadow: rgba(44, 30, 116, 0.08) 4px 0 12px;
  transition: all 0.2s ease;
  z-index: 10;
}

.sidebar-toggle:hover {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #ffffff;
  border-color: transparent;
}

/* 搜索区域 */
.search-section {
  margin-bottom: 16px;
}

/* 筛选区域 */
.filter-section {
  margin-bottom: 20px;
}

/* 辈分导航 */
.generation-nav {
  margin-bottom: 20px;
}

.section-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 13px;
  font-weight: 600;
  color: #45515e;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
}

.section-count {
  font-size: 11px;
  font-weight: 500;
  color: #8e8e93;
  background: rgba(102, 126, 234, 0.08);
  padding: 2px 8px;
  border-radius: 9999px;
}

.generation-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.generation-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 14px;
  background: #ffffff;
  border-radius: 12px;
  border: 1px solid #f2f3f5;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.generation-card:hover {
  transform: translateY(-2px);
  box-shadow: rgba(44, 30, 116, 0.12) 0 8px 24px;
  border-color: rgba(102, 126, 234, 0.3);
}

.generation-card.is-active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-color: transparent;
  box-shadow: rgba(44, 30, 116, 0.2) 0 8px 24px;
}

.generation-card.is-active .gen-label,
.generation-card.is-active .gen-count {
  color: #ffffff;
}

.gen-color {
  width: 14px;
  height: 14px;
  border-radius: 6px;
  flex-shrink: 0;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
}

.gen-label {
  flex: 1;
  font-family: 'DM Sans', sans-serif;
  font-size: 13px;
  font-weight: 500;
  color: #18181b;
}

.gen-count {
  font-size: 11px;
  color: #8e8e93;
  background: #f5f5f5;
  padding: 4px 10px;
  border-radius: 9999px;
  font-weight: 500;
}

.generation-card.is-active .gen-count {
  background: rgba(255, 255, 255, 0.2);
  color: #ffffff;
}

/* 小地图 */
.mini-map-section {
  margin-top: auto;
  padding-top: 16px;
  border-top: 1px solid rgba(102, 126, 234, 0.1);
}

/* 主画布 */
.main-canvas {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  position: relative;
  background: #ffffff;
}

/* 主画布 - 固定视口 */
.main-canvas {
  flex: 1;
  position: relative;
  overflow: hidden;
  background: #ffffff;
  cursor: grab;
}

.main-canvas:active {
  cursor: grabbing;
}

/* 族谱内容层 - 可缩放拖动 */
.canvas-content {
  position: absolute;
  top: 50%;
  left: 50%;
  transform-origin: center center;
  transition: transform 0.05s linear;
  will-change: transform;
}

.canvas-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  color: #ffffff;
  font-size: 24px;
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.1); opacity: 0.8; }
}

.canvas-loading p {
  font-size: 14px;
  color: #8e8e93;
  margin: 0;
}

.canvas-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 60px;
}

.empty-illustration {
  width: 120px;
  height: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  border-radius: 32px;
  color: #667eea;
  margin-bottom: 24px;
}

.canvas-empty h3 {
  font-family: 'Outfit', sans-serif;
  font-size: 20px;
  font-weight: 600;
  color: #18181b;
  margin: 0 0 8px 0;
}

.canvas-empty p {
  font-size: 14px;
  color: #8e8e93;
  margin: 0 0 24px 0;
}

.empty-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  padding: 12px 24px;
  border-radius: 12px;
  font-weight: 500;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
}

.empty-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4);
}

.tree-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: max-content;
}

/* 画布控制条 */
.canvas-controls {
  position: absolute;
  bottom: 50px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 10px 20px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(16px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.8);
  box-shadow:
    rgba(44, 30, 116, 0.12) 0 8px 32px,
    inset 0 1px 0 rgba(255, 255, 255, 1);
}

.zoom-controls {
  display: flex;
  align-items: center;
  gap: 12px;
}

.btn-icon {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-icon:hover:not(:disabled) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #ffffff;
}

.btn-icon:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.zoom-track {
  width: 100px;
}

.zoom-slider {
  width: 100%;
}

.zoom-slider :deep(.el-slider__runway) {
  background: #e5e7eb;
  height: 4px;
  border-radius: 2px;
}

.zoom-slider :deep(.el-slider__bar) {
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  height: 4px;
  border-radius: 2px;
}

.zoom-slider :deep(.el-slider__button) {
  width: 14px;
  height: 14px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.zoom-value {
  font-family: 'DM Sans', sans-serif;
  font-size: 13px;
  font-weight: 500;
  color: #45515e;
  min-width: 48px;
  text-align: center;
}

.control-divider {
  width: 1px;
  height: 24px;
  background: rgba(102, 126, 234, 0.15);
}

.view-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-pill {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 14px;
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
  border: none;
  border-radius: 9999px;
  font-family: 'DM Sans', sans-serif;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-pill:hover {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #ffffff;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

/* 状态栏 */
.canvas-status {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(12px);
  border-top: 1px solid rgba(102, 126, 234, 0.1);
  font-family: 'DM Sans', sans-serif;
  font-size: 12px;
  color: #45515e;
}

.status-left,
.status-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 6px;
}

.status-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #d1d5db;
}

.status-dot.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* 右侧面板 */
.right-panel {
  width: 0;
  background: #ffffff;
  border-left: 1px solid rgba(102, 126, 234, 0.1);
  overflow: hidden;
  transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: -4px 0 24px rgba(44, 30, 116, 0.06);
}

.right-panel.is-open {
  width: 360px;
}

/* 响应式适配 */
@media (max-width: 1199px) {
  .left-sidebar {
    width: 260px;
  }

  .generation-nav {
    display: none;
  }
}

@media (max-width: 768px) {
  .left-sidebar {
    position: fixed;
    left: 0;
    top: 64px;
    bottom: 0;
    z-index: 100;
    width: 300px;
    transform: translateX(-100%);
  }

  .left-sidebar.is-collapsed {
    transform: translateX(-100%);
    width: 300px;
  }

  .right-panel {
    position: fixed;
    right: 0;
    top: 64px;
    bottom: 0;
    z-index: 100;
    width: 100%;
  }

  .right-panel.is-open {
    width: 100%;
  }

  .canvas-controls {
    bottom: 60px;
    flex-wrap: wrap;
    justify-content: center;
    padding: 8px 16px;
    gap: 12px;
  }

  .zoom-track {
    display: none;
  }

  .control-divider {
    display: none;
  }
}
</style>
