<template>
  <div class="genealogy-node">
    <div class="node-content" :class="{ 'has-children': hasChildren }" @click="handleClick">
      <div class="node-avatar">
        <el-icon v-if="node.gender === 'MALE'" :size="24"><Male /></el-icon>
        <el-icon v-else :size="24"><Female /></el-icon>
      </div>
      <div class="node-info">
        <div class="node-name">{{ node.name }}</div>
        <div class="node-generation">{{ node.generation }}辈</div>
      </div>
    </div>

    <!-- 连接线 -->
    <div v-if="hasChildren" class="node-connector">
      <div class="connector-line" />
    </div>

    <!-- 子节点 -->
    <div v-if="hasChildren && isExpanded" class="node-children">
      <div class="children-connector">
        <div class="vertical-line" />
        <div class="horizontal-line" />
      </div>
      <div class="children-nodes">
        <GenealogyNode
          v-for="child in node.children"
          :key="child.memberId"
          :node="child"
          :default-expanded="defaultExpanded"
          @node-click="$emit('node-click', $event)"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import type { GenealogyNode } from '@/api/genealogy'
import { Male, Female } from '@element-plus/icons-vue'

interface Props {
  node: GenealogyNode
  defaultExpanded?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  defaultExpanded: true
})

const emit = defineEmits<{
  (e: 'node-click', node: GenealogyNode): void
}>()

const isExpanded = ref(props.defaultExpanded)

const hasChildren = computed(() => {
  return props.node.children && props.node.children.length > 0
})

const handleClick = () => {
  emit('node-click', props.node)
}
</script>

<style scoped>
.genealogy-node {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.node-content {
  display: flex;
  align-items: center;
  padding: 12px 20px;
  background: #fff;
  border: 2px solid #409eff;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
  min-width: 120px;
}

.node-content:hover {
  background: #ecf5ff;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
}

.node-content.has-children {
  border-color: #409eff;
}

.node-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #409eff;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
}

.node-info {
  text-align: left;
}

.node-name {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.node-generation {
  font-size: 12px;
  color: #999;
  margin-top: 2px;
}

.node-connector {
  height: 20px;
  display: flex;
  justify-content: center;
}

.connector-line {
  width: 2px;
  height: 100%;
  background: #409eff;
}

.node-children {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.children-connector {
  position: relative;
  height: 20px;
}

.vertical-line {
  position: absolute;
  left: 50%;
  top: 0;
  width: 2px;
  height: 100%;
  background: #409eff;
  transform: translateX(-50%);
}

.horizontal-line {
  position: absolute;
  left: calc(50% - calc(50% * v-bind(childCount)));
  right: calc(50% - calc(50% * v-bind(childCount)));
  top: 50%;
  height: 2px;
  background: #409eff;
}

.children-nodes {
  display: flex;
  gap: 20px;
  position: relative;
}

.children-nodes::before {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  top: 0;
  height: 2px;
  background: #409eff;
}

.children-nodes > .genealogy-node {
  position: relative;
  padding-top: 20px;
}

.children-nodes > .genealogy-node::before {
  content: '';
  position: absolute;
  top: 0;
  left: 50%;
  width: 2px;
  height: 20px;
  background: #409eff;
  transform: translateX(-50%);
}
</style>
