<template>
  <div class="genealogy-tree-view">
    <!-- 左侧边栏 -->
    <aside class="left-sidebar" :class="{ 'is-collapsed': isSidebarCollapsed }">
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
          <div class="section-title">辈分导航</div>
          <div class="generation-list">
            <div
              v-for="gen in generationStats"
              :key="gen.generation"
              class="generation-item"
              :class="{ 'is-active': activeGeneration === gen.generation }"
              @click="handleGenerationClick(gen.generation)"
            >
              <span class="gen-color" :style="{ backgroundColor: gen.color }"></span>
              <span class="gen-label">第{{ gen.generation }}代</span>
              <span class="gen-count">{{ gen.count }}人</span>
            </div>
          </div>
        </div>

        <!-- 小地图 -->
        <div class="sidebar-section mini-map-section">
          <MiniMap
            :tree-data="treeData"
            :current-member-id="selectedMemberId ?? undefined"
            :current-member-name="selectedMember?.name"
            :current-generation="selectedMember?.generation"
            @jump="handleMapJump"
          />
        </div>
      </div>

      <!-- 侧边栏折叠按钮 -->
      <button class="sidebar-toggle" @click="toggleSidebar">
        <el-icon :size="16">
          <ArrowLeft v-if="!isSidebarCollapsed" />
          <ArrowRight v-else />
        </el-icon>
      </button>
    </aside>

    <!-- 主画布区域 -->
    <main class="main-canvas" ref="canvasRef">
      <!-- 画布容器 -->
      <div
        class="canvas-container"
        :style="canvasStyle"
        @mousedown="handleCanvasMouseDown"
        @mousemove="handleCanvasMouseMove"
        @mouseup="handleCanvasMouseUp"
        @mouseleave="handleCanvasMouseUp"
        @wheel="handleCanvasWheel"
        @dblclick="handleCanvasDoubleClick"
      >
        <!-- 加载状态 -->
        <div v-if="loading" class="canvas-loading">
          <el-skeleton :rows="8" animated />
        </div>

        <!-- 族谱树 -->
        <div v-else-if="treeData" class="tree-wrapper">
          <GenealogyNodeComponent
          :node="treeData"
          :selected-id="selectedMemberId"
          :highlighted-ids="highlightedIds"
          :filtered-ids="filteredIds"
          :collapsed-ids="collapsedIds"
          @node-click="handleNodeClick"
          @node-dblclick="handleNodeDoubleClick"
        />
        </div>

        <!-- 空状态 -->
        <div v-else class="canvas-empty">
          <el-empty description="暂无族谱数据">
            <el-button type="primary">添加成员</el-button>
          </el-empty>
        </div>
      </div>

      <!-- 缩放控制条 -->
      <div class="canvas-controls">
        <div class="zoom-controls">
          <el-button-group>
            <el-button @click="handleZoomOut" :disabled="zoom <= minZoom">
              <el-icon><Minus /></el-icon>
            </el-button>
            <el-button class="zoom-value" disabled>{{ Math.round(zoom * 100) }}%</el-button>
            <el-button @click="handleZoomIn" :disabled="zoom >= maxZoom">
              <el-icon><Plus /></el-icon>
            </el-button>
          </el-button-group>
          <el-slider
            v-model="zoom"
            :min="minZoom"
            :max="maxZoom"
            :step="0.1"
            class="zoom-slider"
          />
          <el-button @click="handleZoomReset">重置</el-button>
        </div>

        <div class="view-controls">
          <el-button @click="handleExpandAll">
            {{ allExpanded ? '收起全部' : '展开全部' }}
          </el-button>
          <el-button @click="handleFullScreen">
            <el-icon><FullScreen /></el-icon>
          </el-button>
          <el-button @click="handleExport">
            <el-icon><Download /></el-icon>
            导出
          </el-button>
        </div>
      </div>

      <!-- 状态栏 -->
      <div class="canvas-status">
        <span class="status-item">
          共 {{ totalMemberCount }} 人
        </span>
        <span class="status-item" v-if="selectedMember">
          当前: {{ selectedMember.name }}
        </span>
        <span class="status-item">
          缩放: {{ Math.round(zoom * 100) }}%
        </span>
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
  Download
} from '@element-plus/icons-vue'
import { genealogyApi } from '@/api/genealogy'
import type { GenealogyNode } from '@/api/genealogy'
import type { FilterConditions, GenerationStats } from '@/types/genealogy'
import { getGenerationColor } from '@/types/genealogy'
import SearchBar from './components/SearchBar.vue'
import FilterPanel from './components/FilterPanel.vue'
import MiniMap from './components/MiniMap.vue'
import MemberDetailPanel from './components/MemberDetailPanel.vue'
import GenealogyNodeComponent from './components/GenealogyNode.vue'

// 状态
const loading = ref(false)
const treeData = ref<GenealogyNode | null>(null)
const selectedMemberId = ref<number | null>(null)
const selectedMember = ref<GenealogyNode | null>(null)
const isSidebarCollapsed = ref(false)
const isDetailPanelOpen = ref(false)
const allExpanded = ref(true)

// 缩放相关
const zoom = ref(1)
const minZoom = 0.3
const maxZoom = 2.0

// 画布拖拽相关
const isDragging = ref(false)
const dragStart = reactive({ x: 0, y: 0 })
const panOffset = reactive({ x: 0, y: 0 })
const canvasRef = ref<HTMLElement | null>(null)

// 筛选相关
const filterConditions = ref<FilterConditions>({
  generations: [],
  gender: '',
  status: '',
  birthYearFrom: null,
  birthYearTo: null
})
const highlightedIds = ref<number[]>([])
const filteredIds = ref<number[]>([])
const collapsedIds = ref<number[]>([])
const activeGeneration = ref<number | null>(null)

// 搜索相关
const searchBarRef = ref<InstanceType<typeof SearchBar> | null>(null)

// Refs
const filterPanelRef = ref<InstanceType<typeof FilterPanel> | null>(null)

// 计算属性
const canvasStyle = computed(() => ({
  transform: `scale(${zoom.value}) translate(${panOffset.x}px, ${panOffset.y}px)`,
  transformOrigin: 'center center'
}))

// 辈分统计
const generationStats = computed<GenerationStats[]>(() => {
  if (!treeData.value) return []

  const stats: Map<number, number> = new Map()

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

// 总成员数
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

// 筛选后的成员数
const filteredMemberCount = computed(() => {
  if (filteredIds.value.length === 0) return totalMemberCount.value
  return filteredIds.value.length
})

// 加载族谱数据
const loadTreeData = async () => {
  loading.value = true
  try {
    const res = await genealogyApi.getTree()
    treeData.value = res.data
    // 默认展开全部
    collapsedIds.value = []
  } catch (error) {
    console.error('加载族谱数据失败', error)
    ElMessage.error('加载族谱数据失败')
  } finally {
    loading.value = false
  }
}

// 节点点击
const handleNodeClick = (node: GenealogyNode) => {
  selectedMemberId.value = node.memberId
  selectedMember.value = node
  isDetailPanelOpen.value = true

  // 如果节点被折叠，展开它
  if (collapsedIds.value.includes(node.memberId)) {
    toggleCollapse(node.memberId)
  }
}

// 节点双击
const handleNodeDoubleClick = (node: GenealogyNode) => {
  if (node.children && node.children.length > 0) {
    toggleCollapse(node.memberId)
  } else {
    // 居中到该节点
    centerToNode(node)
  }
}

// 切换折叠状态
const toggleCollapse = (memberId: number) => {
  const index = collapsedIds.value.indexOf(memberId)
  if (index === -1) {
    collapsedIds.value.push(memberId)
  } else {
    collapsedIds.value.splice(index, 1)
  }
}

// 居中到节点
const centerToNode = (node: GenealogyNode) => {
  // 简单实现，实际需要计算节点位置
  ElMessage.info(`定位到: ${node.name}`)
}

// 搜索处理
const handleSearch = (keyword: string) => {
  if (!keyword) {
    highlightedIds.value = []
    return
  }

  // 搜索并高亮匹配节点
  const matchedIds: number[] = []
  const searchInTree = (node: GenealogyNode) => {
    if (node.name.includes(keyword)) {
      matchedIds.push(node.memberId)
    }
    node.children?.forEach(searchInTree)
  }

  if (treeData.value) {
    searchInTree(treeData.value)
  }

  highlightedIds.value = matchedIds

  if (matchedIds.length === 0) {
    ElMessage.warning('未找到匹配成员')
  } else {
    ElMessage.success(`找到 ${matchedIds.length} 个匹配成员`)
  }
}

// 搜索选择
const handleSearchSelect = (member: any) => {
  selectedMemberId.value = member.memberId
  isDetailPanelOpen.value = true

  // 高亮搜索结果
  highlightedIds.value = [member.memberId]

  // 折叠路径上的节点需要展开
  expandPathToNode(member.memberId)
}

// 展开到节点的路径
const expandPathToNode = (memberId: number) => {
  const path: number[] = []

  const findPath = (node: GenealogyNode, targetId: number): boolean => {
    if (node.memberId === targetId) {
      return true
    }

    if (node.children) {
      for (const child of node.children) {
        if (findPath(child, targetId)) {
          path.push(node.memberId)
          return true
        }
      }
    }

    return false
  }

  if (treeData.value) {
    findPath(treeData.value, memberId)
    // 移除当前节点，只展开祖先节点
    collapsedIds.value = collapsedIds.value.filter(id => !path.includes(id))
  }
}

// 筛选变化
const handleFilterChange = (filters: FilterConditions) => {
  filterConditions.value = filters

  if (!treeData.value) {
    filteredIds.value = []
    return
  }

  // 应用筛选
  const matchedIds: number[] = []

  const filterNode = (node: GenealogyNode): boolean => {
    // 辈分筛选
    if (filters.generations.length > 0) {
      const gen = node.generation || 1
      if (!filters.generations.includes(gen)) {
        return false
      }
    }

    // 性别筛选
    if (filters.gender && node.gender !== filters.gender) {
      return false
    }

    // 状态筛选
    if (filters.status && node.status !== filters.status) {
      return false
    }

    // 年代筛选（简化处理）
    if (filters.birthYearFrom || filters.birthYearTo) {
      if (node.birthDate) {
        const year = parseInt(node.birthDate.split('-')[0])
        if (filters.birthYearFrom && year < filters.birthYearFrom) {
          return false
        }
        if (filters.birthYearTo && year > filters.birthYearTo) {
          return false
        }
      }
    }

    return true
  }

  const traverse = (node: GenealogyNode) => {
    if (filterNode(node)) {
      matchedIds.push(node.memberId)
    }
    node.children?.forEach(traverse)
  }

  traverse(treeData.value)
  filteredIds.value = matchedIds

  if (matchedIds.length === 0 && hasActiveFilters()) {
    ElMessage.warning('没有符合条件的成员')
  }
}

// 是否有激活的筛选
const hasActiveFilters = () => {
  const f = filterConditions.value
  return (
    f.generations.length > 0 ||
    f.gender !== null ||
    f.status !== null ||
    f.birthYearFrom !== null ||
    f.birthYearTo !== null
  )
}

// 辈分导航点击
const handleGenerationClick = (generation: number) => {
  activeGeneration.value = generation
  filterConditions.value = {
    ...filterConditions.value,
    generations: [generation]
  }
  handleFilterChange(filterConditions.value)
}

// 小地图跳转
const handleMapJump = (position: { x: number; y: number }) => {
  // 移动画布到位置
  panOffset.x = -position.x / 100
  panOffset.y = -position.y / 100
  ElMessage.success('已跳转到指定位置')
}

// 展开/折叠全部
const handleExpandAll = () => {
  allExpanded.value = !allExpanded.value

  if (allExpanded.value) {
    collapsedIds.value = []
  } else {
    // 折叠所有有子节点的节点
    collapsedIds.value = []
    const collectCollapsed = (node: GenealogyNode) => {
      if (node.children && node.children.length > 0) {
        collapsedIds.value.push(node.memberId)
        node.children.forEach(collectCollapsed)
      }
    }
    if (treeData.value) {
      collectCollapsed(treeData.value)
    }
  }
}

// 缩放控制
const handleZoomIn = () => {
  zoom.value = Math.min(zoom.value + 0.1, maxZoom)
}

const handleZoomOut = () => {
  zoom.value = Math.max(zoom.value - 0.1, minZoom)
}

const handleZoomReset = () => {
  zoom.value = 1
  panOffset.x = 0
  panOffset.y = 0
}

// 全屏
const handleFullScreen = () => {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen()
  } else {
    document.exitFullscreen()
  }
}

// 导出
const handleExport = () => {
  ElMessage.info('导出功能开发中')
}

// 画布拖拽
const handleCanvasMouseDown = (e: MouseEvent) => {
  if (e.button === 0) {
    isDragging.value = true
    dragStart.x = e.clientX - panOffset.x
    dragStart.y = e.clientY - panOffset.y
  }
}

const handleCanvasMouseMove = (e: MouseEvent) => {
  if (isDragging.value) {
    panOffset.x = e.clientX - dragStart.x
    panOffset.y = e.clientY - dragStart.y
  }
}

const handleCanvasMouseUp = () => {
  isDragging.value = false
}

const handleCanvasWheel = (e: WheelEvent) => {
  e.preventDefault()
  if (e.deltaY < 0) {
    handleZoomIn()
  } else {
    handleZoomOut()
  }
}

const handleCanvasDoubleClick = () => {
  handleZoomReset()
}

// 详情面板关闭
const handleDetailPanelClose = (visible: boolean) => {
  isDetailPanelOpen.value = visible
  if (!visible) {
    selectedMemberId.value = null
    selectedMember.value = null
  }
}

// 跳转到成员
const handleJumpToMember = (memberId: number) => {
  selectedMemberId.value = memberId
  isDetailPanelOpen.value = true

  // 找到节点并选中
  const findNode = (node: GenealogyNode): GenealogyNode | null => {
    if (node.memberId === memberId) {
      return node
    }
    for (const child of node.children || []) {
      const found = findNode(child)
      if (found) return found
    }
    return null
  }

  if (treeData.value) {
    const node = findNode(treeData.value)
    if (node) {
      selectedMember.value = node
      expandPathToNode(memberId)
    }
  }
}

// 切换侧边栏
const toggleSidebar = () => {
  isSidebarCollapsed.value = !isSidebarCollapsed.value
}

// 监听窗口大小变化
const handleResize = () => {
  // 响应式处理
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
  background: #F5F7FA;
}

/* 左侧边栏 */
.left-sidebar {
  position: relative;
  width: 280px;
  background: #fff;
  border-right: 1px solid #E4E7ED;
  display: flex;
  flex-direction: column;
  transition: width 0.3s ease;
  overflow: hidden;
}

.left-sidebar.is-collapsed {
  width: 0;
  border-right: none;
}

.sidebar-content {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

.sidebar-section {
  margin-bottom: 20px;
}

.sidebar-section:last-child {
  margin-bottom: 0;
}

.sidebar-toggle {
  position: absolute;
  right: -12px;
  top: 50%;
  transform: translateY(-50%);
  width: 24px;
  height: 48px;
  background: #fff;
  border: 1px solid #E4E7ED;
  border-radius: 0 4px 4px 0;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #909399;
  z-index: 10;
}

.sidebar-toggle:hover {
  color: #409EFF;
  border-color: #409EFF;
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
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #E4E7ED;
}

.generation-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.generation-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border-radius: 4px;
  cursor: pointer;
  transition: background 0.2s;
}

.generation-item:hover {
  background: #F5F7FA;
}

.generation-item.is-active {
  background: #ECF5FF;
}

.gen-color {
  width: 12px;
  height: 12px;
  border-radius: 3px;
  flex-shrink: 0;
}

.gen-label {
  flex: 1;
  font-size: 13px;
  color: #303133;
}

.gen-count {
  font-size: 12px;
  color: #909399;
}

/* 小地图 */
.mini-map-section {
  margin-top: auto;
}

/* 主画布 */
.main-canvas {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  position: relative;
}

.canvas-container {
  flex: 1;
  overflow: auto;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding: 40px;
  transition: transform 0.1s ease-out;
  cursor: grab;
}

.canvas-container:active {
  cursor: grabbing;
}

.canvas-loading,
.canvas-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
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
  gap: 24px;
  padding: 8px 16px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.zoom-controls {
  display: flex;
  align-items: center;
  gap: 12px;
}

.zoom-value {
  min-width: 60px;
  text-align: center;
}

.zoom-slider {
  width: 120px;
}

.view-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

/* 状态栏 */
.canvas-status {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 40px;
  display: flex;
  align-items: center;
  gap: 24px;
  padding: 0 20px;
  background: #fff;
  border-top: 1px solid #E4E7ED;
  font-size: 12px;
  color: #909399;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 4px;
}

/* 右侧面板 */
.right-panel {
  width: 0;
  background: #fff;
  border-left: 1px solid #E4E7ED;
  overflow: hidden;
  transition: width 0.3s ease-out;
}

.right-panel.is-open {
  width: 320px;
}

/* 响应式适配 */
@media (max-width: 1199px) {
  .left-sidebar {
    width: 240px;
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
    width: 280px;
    transform: translateX(-100%);
  }

  .left-sidebar.is-collapsed {
    transform: translateX(-100%);
    width: 280px;
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
  }

  .zoom-slider {
    display: none;
  }
}
</style>
