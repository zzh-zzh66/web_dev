<template>
  <div
    class="genealogy-node"
    :class="{
      'is-selected': isSelected,
      'is-collapsed': isCollapsed && hasChildren,
      'is-deceased': node.status === 'DECEASED',
      'is-male': node.gender === 'MALE',
      'is-female': node.gender === 'FEMALE',
      'is-highlighted': isHighlighted,
      'is-filtered': isFiltered
    }"
    @click.stop="handleClick"
    @dblclick.stop="handleDoubleClick"
  >
    <!-- 节点内容 -->
    <div class="node-content">
      <!-- 左侧性别条 -->
      <div class="gender-bar"></div>

      <!-- 头像 -->
      <div class="node-avatar">
        <el-avatar
          :size="avatarSize"
          :src="node.portraitUrl"
          :icon="node.gender === 'MALE' ? MaleIcon : FemaleIcon"
        >
          {{ node.name?.charAt(0) }}
        </el-avatar>
        <!-- 状态指示器 -->
        <span class="status-dot" :class="node.status === 'ALIVE' ? 'alive' : 'deceased'"></span>
      </div>

      <!-- 信息区域 -->
      <div class="node-info">
        <div class="node-name" :class="{ 'is-deceased': node.status === 'DECEASED' }">
          {{ node.name }}
        </div>
        <div class="node-meta">
          <span class="generation-badge" :style="{ backgroundColor: generationColor }">
            第{{ node.generation }}代
          </span>
          <span class="gender-tag" :class="node.gender === 'MALE' ? 'male' : 'female'">
            {{ node.gender === 'MALE' ? '男' : '女' }}
          </span>
        </div>
      </div>

      <!-- 折叠指示器 -->
      <div v-if="hasChildren && isCollapsed" class="collapse-indicator">
        <el-badge :value="node.children?.length || 0" type="info" />
      </div>
    </div>

    <!-- 操作按钮（悬停显示） -->
    <div class="node-actions">
      <el-button size="small" text @click.stop="handleView">查看</el-button>
      <el-button size="small" text type="primary">编辑</el-button>
    </div>

    <!-- 关系线：父节点连接 -->
    <div v-if="showConnector" class="node-connector">
      <div class="connector-line"></div>
    </div>

    <!-- 子节点容器 -->
    <div v-if="hasChildren && !isCollapsed" class="node-children">
      <!-- 垂直连接线 -->
      <div class="children-connector">
        <div class="vertical-line"></div>
        <div class="horizontal-line" :style="horizontalLineStyle"></div>
      </div>

      <!-- 子节点列表 -->
      <div class="children-nodes">
        <GenealogyNode
          v-for="(child, index) in visibleChildren"
          :key="child.memberId"
          :node="child"
          :parent-generation="node.generation"
          :show-connector="true"
          :sibling-index="index"
          :sibling-count="visibleChildren.length"
          :selected-id="selectedId"
          :highlighted-ids="highlightedIds"
          :filtered-ids="filteredIds"
          :collapsed-ids="collapsedIds"
          @node-click="handleChildClick"
          @node-dblclick="handleChildDoubleClick"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Male, Female } from '@element-plus/icons-vue'
import { getGenerationColor, type GenealogyTreeNode } from '@/types/genealogy'

interface Props {
  node: GenealogyTreeNode
  parentGeneration?: number
  showConnector?: boolean
  siblingIndex?: number
  siblingCount?: number
  selectedId?: number | null
  highlightedIds?: number[]
  filteredIds?: number[]
  collapsedIds?: number[]
}

const props = withDefaults(defineProps<Props>(), {
  parentGeneration: 0,
  showConnector: false,
  siblingIndex: 0,
  siblingCount: 1,
  selectedId: null,
  highlightedIds: () => [],
  filteredIds: () => [],
  collapsedIds: () => []
})

interface Emits {
  (e: 'node-click', node: GenealogyTreeNode): void
  (e: 'node-dblclick', node: GenealogyTreeNode): void
}

const emit = defineEmits<Emits>()

// 图标组件
const MaleIcon = Male
const FemaleIcon = Female

// 头像尺寸（根据辈分差异）
const avatarSize = computed(() => {
  const diff = (props.node.generation || 1) - (props.parentGeneration || 1)
  if (diff <= 0) return 50
  if (diff === 1) return 46
  if (diff === 2) return 42
  return 38
})

// 辈分颜色
const generationColor = computed(() => {
  return getGenerationColor(props.node.generation || 1)
})

// 是否有子节点
const hasChildren = computed(() => {
  return props.node.children && props.node.children.length > 0
})

// 是否折叠
const isCollapsed = computed(() => {
  return props.collapsedIds?.includes(props.node.memberId) || false
})

// 是否选中
const isSelected = computed(() => {
  return props.selectedId === props.node.memberId
})

// 是否高亮
const isHighlighted = computed(() => {
  return props.highlightedIds?.includes(props.node.memberId) || false
})

// 是否筛选命中
const isFiltered = computed(() => {
  if (!props.filteredIds || props.filteredIds.length === 0) return false
  return !props.filteredIds.includes(props.node.memberId)
})

// 可见的子节点
const visibleChildren = computed(() => {
  if (!props.node.children) return []
  return props.node.children
})

// 水平连接线样式
const horizontalLineStyle = computed(() => {
  if (!props.siblingCount || props.siblingCount <= 1) {
    return { left: '50%', right: '50%' }
  }

  const halfCount = props.siblingCount / 2
  const leftPercent = ((halfCount - 0.5) / props.siblingCount) * 100
  const rightPercent = ((halfCount - 0.5) / props.siblingCount) * 100

  return {
    left: `${leftPercent}%`,
    right: `${rightPercent}%`
  }
})

// 点击处理
const handleClick = () => {
  emit('node-click', props.node)
}

// 双击处理
const handleDoubleClick = () => {
  emit('node-dblclick', props.node)
}

// 子节点点击
const handleChildClick = (node: GenealogyTreeNode) => {
  emit('node-click', node)
}

// 子节点双击
const handleChildDoubleClick = (node: GenealogyTreeNode) => {
  emit('node-dblclick', node)
}

// 查看处理
const handleView = () => {
  emit('node-click', props.node)
}
</script>

<style scoped>
.genealogy-node {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
}

/* 节点内容 */
.node-content {
  position: relative;
  display: flex;
  align-items: center;
  padding: 10px 16px;
  background: #fff;
  border: 2px solid #E4E7ED;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease-out;
  min-width: 120px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* 性别条 */
.gender-bar {
  position: absolute;
  left: 0;
  top: 8px;
  bottom: 8px;
  width: 4px;
  border-radius: 0 2px 2px 0;
}

.is-male .gender-bar {
  background: #409EFF;
}

.is-female .gender-bar {
  background: #F56C6C;
}

/* 头像 */
.node-avatar {
  position: relative;
  margin-right: 12px;
  flex-shrink: 0;
}

.status-dot {
  position: absolute;
  bottom: 2px;
  right: 2px;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  border: 2px solid #fff;
}

.status-dot.alive {
  background: #67C23A;
}

.status-dot.deceased {
  background: #909399;
}

/* 信息区域 */
.node-info {
  flex: 1;
  min-width: 0;
}

.node-name {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.node-name.is-deceased {
  text-decoration: line-through;
  color: #909399;
}

.node-meta {
  display: flex;
  align-items: center;
  gap: 6px;
}

.generation-badge {
  padding: 1px 6px;
  font-size: 10px;
  color: #fff;
  border-radius: 3px;
}

.gender-tag {
  font-size: 10px;
  padding: 1px 4px;
  border-radius: 2px;
}

.gender-tag.male {
  color: #409EFF;
  background: rgba(64, 158, 255, 0.1);
}

.gender-tag.female {
  color: #F56C6C;
  background: rgba(245, 108, 108, 0.1);
}

/* 折叠指示器 */
.collapse-indicator {
  position: absolute;
  bottom: -8px;
  right: -8px;
}

/* 操作按钮 */
.node-actions {
  position: absolute;
  top: -36px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 4px;
  background: #fff;
  padding: 4px 8px;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  opacity: 0;
  visibility: hidden;
  transition: all 0.2s;
  z-index: 10;
}

.node-content:hover .node-actions {
  opacity: 1;
  visibility: visible;
}

/* 悬停状态 */
.node-content:hover {
  background: #ECF5FF;
  border-color: #409EFF;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
}

.is-male .node-content:hover {
  border-color: #409EFF;
}

.is-female .node-content:hover {
  border-color: #F56C6C;
}

/* 选中状态 */
.is-selected .node-content {
  background: #FDF6EC;
  border-color: #E6A23C;
  border-width: 2px;
  box-shadow: 0 4px 12px rgba(230, 162, 60, 0.3);
}

/* 折叠状态 */
.is-collapsed .node-content {
  border-style: dashed;
}

/* 已故状态 */
.is-deceased .node-content {
  opacity: 0.6;
}

.is-deceased .node-avatar :deep(.el-avatar) {
  filter: grayscale(100%);
}

/* 高亮状态 */
.is-highlighted .node-content {
  background: #FFF7E6;
  border-color: #E6A23C;
  animation: pulse 0.6s ease-in-out 3;
}

@keyframes pulse {
  0%, 100% {
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }
  50% {
    box-shadow: 0 4px 16px rgba(230, 162, 60, 0.4);
  }
}

/* 筛选未命中状态 */
.is-filtered {
  opacity: 0.3;
  pointer-events: none;
}

/* 连接线 */
.node-connector {
  height: 20px;
  display: flex;
  justify-content: center;
}

.connector-line {
  width: 2px;
  height: 100%;
  background: #909399;
}

/* 子节点容器 */
.node-children {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.children-connector {
  position: relative;
  height: 20px;
  width: 100%;
}

.vertical-line {
  position: absolute;
  left: 50%;
  top: 0;
  width: 2px;
  height: 100%;
  background: #909399;
  transform: translateX(-50%);
}

.horizontal-line {
  position: absolute;
  top: 0;
  height: 2px;
  background: #909399;
}

/* 子节点列表 */
.children-nodes {
  display: flex;
  gap: 20px;
  position: relative;
  padding-top: 20px;
}

.children-nodes::before {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  top: 0;
  height: 2px;
  background: #909399;
}

.children-nodes > .genealogy-node {
  position: relative;
}

.children-nodes > .genealogy-node::before {
  content: '';
  position: absolute;
  top: 0;
  left: 50%;
  width: 2px;
  height: 20px;
  background: #909399;
  transform: translateX(-50%);
}
</style>
