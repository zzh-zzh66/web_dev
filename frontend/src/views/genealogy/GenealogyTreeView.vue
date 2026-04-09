<template>
  <div class="genealogy-tree">
    <div class="page-header">
      <h2 class="page-title">族谱展示</h2>
      <div class="page-actions">
        <el-button @click="handleExpandAll">{{ expandAll ? '收起全部' : '展开全部' }}</el-button>
        <el-button @click="handleRefresh">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
      </div>
    </div>

    <el-card v-loading="loading">
      <div v-if="treeData" class="tree-container">
        <div class="tree-wrapper">
          <GenealogyNode
            :node="treeData"
            :default-expanded="defaultExpanded"
            @node-click="handleNodeClick"
          />
        </div>
      </div>
      <el-empty v-else description="暂无族谱数据" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { genealogyApi, type GenealogyNode } from '@/api/genealogy'
import { ElMessage } from 'element-plus'
import { Refresh } from '@element-plus/icons-vue'
import GenealogyNode from './components/GenealogyNode.vue'

const router = useRouter()

const loading = ref(false)
const treeData = ref<GenealogyNode | null>(null)
const expandAll = ref(false)
const defaultExpanded = ref(true)

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

const handleExpandAll = () => {
  expandAll.value = !expandAll.value
}

const handleRefresh = () => {
  loadTreeData()
}

const handleNodeClick = (node: GenealogyNode) => {
  router.push(`/members/${node.memberId}`)
}

onMounted(() => {
  loadTreeData()
})
</script>

<style scoped>
.genealogy-tree {
  padding: 0;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-title {
  margin: 0;
  font-size: 22px;
  color: #333;
}

.page-actions {
  display: flex;
  gap: 10px;
}

.tree-container {
  min-height: 400px;
  overflow: auto;
  padding: 20px;
}

.tree-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
}
</style>
