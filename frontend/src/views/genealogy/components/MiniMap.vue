<template>
  <div class="mini-map" :class="{ 'is-expanded': isExpanded }">
    <div class="map-header" @click="toggleExpand">
      <span class="map-title">小地图</span>
      <el-icon class="expand-icon" :class="{ 'is-expanded': isExpanded }">
        <ArrowRight />
      </el-icon>
    </div>

    <div v-if="isExpanded" class="map-content">
      <div
        ref="mapCanvasRef"
        class="map-canvas"
        @click="handleMapClick"
      >
        <!-- 缩略图绘制区域 -->
        <svg class="map-svg" :viewBox="`0 0 ${viewBoxWidth} ${viewBoxHeight}`">
          <!-- 绘制所有节点 -->
          <g v-for="node in allNodes" :key="node.memberId">
            <rect
              :x="node.x * scale"
              :y="node.y * scale"
              :width="nodeWidth * scale"
              :height="nodeHeight * scale"
              :fill="getNodeColor(node.generation)"
              :stroke="node.memberId === currentMemberId ? '#E6A23C' : 'none'"
              :stroke-width="2 * scale"
              rx="2"
              class="map-node"
              :class="{ 'is-current': node.memberId === currentMemberId }"
            />
          </g>

          <!-- 绘制连接线 -->
          <g v-for="line in connectionLines" :key="`${line.from}-${line.to}`">
            <line
              :x1="line.x1 * scale"
              :y1="line.y1 * scale"
              :x2="line.x2 * scale"
              :y2="line.y2 * scale"
              stroke="#909399"
              :stroke-width="1 * scale"
            />
          </g>

          <!-- 当前视口指示器 -->
          <rect
            v-if="currentViewport"
            :x="currentViewport.x * scale"
            :y="currentViewport.y * scale"
            :width="currentViewport.width * scale"
            :height="currentViewport.height * scale"
            fill="rgba(64, 158, 255, 0.2)"
            stroke="#409EFF"
            :stroke-width="2 * scale"
            class="viewport-rect"
          />
        </svg>
      </div>

      <div class="map-footer">
        <span class="current-position" v-if="currentMemberName">
          {{ currentMemberName }}
        </span>
        <span class="current-position" v-else>
          第{{ currentGeneration || 1 }}代
        </span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { ArrowRight } from '@element-plus/icons-vue'
import { getGenerationColor, type GenealogyTreeNode } from '@/types/genealogy'

interface Props {
  treeData: GenealogyTreeNode | null
  currentMemberId?: number
  currentMemberName?: string
  currentGeneration?: number
}

interface Emits {
  (e: 'jump', position: { x: number; y: number }): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const isExpanded = ref(true)
const mapCanvasRef = ref<HTMLElement | null>(null)

// 地图缩放比例
const scale = 0.05

// 节点尺寸
const nodeWidth = 120
const nodeHeight = 80

// 视图尺寸
const viewBoxWidth = 800
const viewBoxHeight = 600

// 计算所有节点位置
interface MapNode {
  memberId: number
  x: number
  y: number
  generation: number
}

interface ConnectionLine {
  from: number
  to: number
  x1: number
  y1: number
  x2: number
  y2: number
}

// 节点映射
const nodeMap = new Map<number, MapNode>()

// 连接线列表
const connectionLines = ref<ConnectionLine[]>([])

// 所有节点列表
const allNodes = computed<MapNode[]>(() => {
  nodeMap.clear()
  connectionLines.value = []

  if (!props.treeData) return []

  const result: MapNode[] = []
  const horizontalSpacing = 150
  const verticalSpacing = 120

  // 遍历树计算位置
  const traverse = (node: GenealogyTreeNode, x: number, y: number, level: number) => {
    const nodeObj: MapNode = {
      memberId: node.memberId,
      x,
      y,
      generation: node.generation
    }
    nodeMap.set(node.memberId, nodeObj)
    result.push(nodeObj)

    if (node.children && node.children.length > 0) {
      const childCount = node.children.length
      const startX = x - ((childCount - 1) * horizontalSpacing) / 2

      node.children.forEach((child, index) => {
        const childX = startX + index * horizontalSpacing
        const childY = y + verticalSpacing

        // 添加连接线
        connectionLines.value.push({
          from: node.memberId,
          to: child.memberId,
          x1: x + nodeWidth / 2,
          y1: y + nodeHeight,
          x2: childX + nodeWidth / 2,
          y2: childY
        })

        traverse(child, childX, childY, level + 1)
      })
    }
  }

  traverse(props.treeData, viewBoxWidth / 2 - nodeWidth / 2, 30, 0)

  return result
})

// 当前视口信息（模拟）
const currentViewport = computed(() => {
  if (!props.currentMemberId || !nodeMap.has(props.currentMemberId)) {
    return null
  }

  const node = nodeMap.get(props.currentMemberId)!
  return {
    x: node.x - 100,
    y: node.y - 50,
    width: 400,
    height: 300
  }
})

// 获取节点颜色
const getNodeColor = (generation: number) => {
  const color = getGenerationColor(generation)
  return color
}

// 切换展开状态
const toggleExpand = () => {
  isExpanded.value = !isExpanded.value
}

// 处理地图点击
const handleMapClick = (event: MouseEvent) => {
  if (!mapCanvasRef.value) return

  const rect = mapCanvasRef.value.getBoundingClientRect()
  const x = (event.clientX - rect.left) / scale
  const y = (event.clientY - rect.top) / scale

  // 找到最近的节点
  let closestNode: MapNode | undefined = undefined
  let minDistance = Infinity

  for (const node of Array.from(nodeMap.values())) {
    const distance = Math.sqrt(
      Math.pow(x - (node.x + nodeWidth / 2), 2) +
      Math.pow(y - (node.y + nodeHeight / 2), 2)
    )
    if (distance < minDistance && distance < 100) {
      minDistance = distance
      closestNode = node
    }
  }

  if (closestNode !== undefined) {
    emit('jump', { x: closestNode.x, y: closestNode.y })
  }
}
</script>

<style scoped>
.mini-map {
  background: #fff;
  border-radius: 4px;
  overflow: hidden;
}

.map-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  cursor: pointer;
  transition: background 0.2s;
}

.map-header:hover {
  background: #F5F7FA;
}

.map-title {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.expand-icon {
  font-size: 14px;
  color: #909399;
  transition: transform 0.3s;
}

.expand-icon.is-expanded {
  transform: rotate(90deg);
}

.map-content {
  border-top: 1px solid #E4E7ED;
}

.map-canvas {
  height: 200px;
  padding: 8px;
  cursor: pointer;
  background: #FAFAFA;
}

.map-svg {
  width: 100%;
  height: 100%;
}

.map-node {
  opacity: 0.8;
  transition: opacity 0.2s;
}

.map-node:hover {
  opacity: 1;
}

.map-node.is-current {
  opacity: 1;
}

.viewport-rect {
  pointer-events: none;
}

.map-footer {
  padding: 8px 16px;
  border-top: 1px solid #E4E7ED;
  text-align: center;
}

.current-position {
  font-size: 12px;
  color: #909399;
}
</style>
