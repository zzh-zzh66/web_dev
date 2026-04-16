<template>
  <div class="member-detail-panel" :class="{ 'is-open': visible }">
    <!-- 关闭按钮 -->
    <div class="panel-header">
      <span class="panel-title">成员详情</span>
      <el-button class="close-btn" text @click="handleClose">
        <el-icon :size="20"><Close /></el-icon>
      </el-button>
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="panel-loading">
      <el-skeleton :rows="10" animated />
    </div>

    <!-- 内容区域 -->
    <div v-else-if="member" class="panel-content">
      <!-- 头像和基本信息 -->
      <div class="member-header">
        <div class="avatar-wrapper">
          <el-avatar
            :size="100"
            :src="member.portraitUrl"
            :icon="member.gender === 'MALE' ? UserFilled : Female"
          />
          <span class="status-indicator" :class="member.status === 'ALIVE' ? 'alive' : 'deceased'">
            {{ member.status === 'ALIVE' ? '在世' : '已故' }}
          </span>
        </div>
        <div class="member-title">
          <h2 class="member-name">{{ member.name }}</h2>
          <div class="member-tags">
            <el-tag size="small" :color="generationColor" effect="dark">
              第{{ member.generation }}代
            </el-tag>
            <el-tag size="small" :type="member.gender === 'MALE' ? 'primary' : 'danger'" effect="plain">
              {{ member.gender === 'MALE' ? '男' : '女' }}
            </el-tag>
          </div>
        </div>
      </div>

      <!-- 基本信息 -->
      <div class="info-section">
        <h3 class="section-title">基本信息</h3>
        <div class="info-list">
          <div class="info-item">
            <span class="info-label">出生日期</span>
            <span class="info-value">{{ member.birthDate || '未知' }}</span>
          </div>
          <div class="info-item" v-if="member.deathDate">
            <span class="info-label">逝世日期</span>
            <span class="info-value">{{ member.deathDate }}</span>
          </div>
          <div class="info-item" v-if="member.birthplace">
            <span class="info-label">出生地</span>
            <span class="info-value">{{ member.birthplace }}</span>
          </div>
          <div class="info-item" v-if="member.occupation">
            <span class="info-label">职业</span>
            <span class="info-value">{{ member.occupation }}</span>
          </div>
        </div>
      </div>

      <!-- 家族关系 -->
      <div class="info-section">
        <h3 class="section-title">家族关系</h3>
        <div class="relation-list">
          <!-- 父亲 -->
          <div class="relation-item" v-if="member.fatherId">
            <div class="relation-icon father">
              <el-icon><User /></el-icon>
            </div>
            <div class="relation-info">
              <span class="relation-label">父亲</span>
              <span class="relation-name">{{ member.fatherName || '未知' }}</span>
            </div>
            <el-button text size="small" @click="handleJump(member.fatherId!)">
              跳转
            </el-button>
          </div>

          <!-- 母亲 -->
          <div class="relation-item" v-if="member.motherId">
            <div class="relation-icon mother">
              <el-icon><User /></el-icon>
            </div>
            <div class="relation-info">
              <span class="relation-label">母亲</span>
              <span class="relation-name">{{ member.motherName || '未知' }}</span>
            </div>
            <el-button text size="small" @click="handleJump(member.motherId!)">
              跳转
            </el-button>
          </div>

          <!-- 配偶 -->
          <div class="relation-item" v-if="member.spouseName">
            <div class="relation-icon spouse">
              <el-icon><Connection /></el-icon>
            </div>
            <div class="relation-info">
              <span class="relation-label">配偶</span>
              <span class="relation-name">{{ member.spouseName }}</span>
            </div>
          </div>

          <!-- 子女 -->
          <div class="relation-item" v-if="children.length > 0">
            <div class="relation-icon children">
              <el-icon><UserFilled /></el-icon>
            </div>
            <div class="relation-info">
              <span class="relation-label">子女</span>
              <span class="relation-name">{{ children.length }}人</span>
            </div>
            <el-button text size="small" @click="handleShowChildren">
              查看全部
            </el-button>
          </div>
        </div>
      </div>

      <!-- 个人简介 -->
      <div class="info-section" v-if="member.biography">
        <h3 class="section-title">个人简介</h3>
        <p class="biography">{{ member.biography }}</p>
      </div>

      <!-- 操作按钮 -->
      <div class="panel-actions">
        <el-button type="primary" @click="handleEdit">编辑</el-button>
        <el-button type="danger" @click="handleDelete">删除</el-button>
      </div>
    </div>

    <!-- 空状态 -->
    <div v-else class="panel-empty">
      <el-empty description="请选择一位成员查看详情" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox, ElMessage } from 'element-plus'
import { Close, User, UserFilled, Female, Connection } from '@element-plus/icons-vue'
import { memberApi, type Member } from '@/api/member'
import { getGenerationColor } from '@/types/genealogy'

interface Props {
  visible: boolean
  memberId: number | null
}

interface Emits {
  (e: 'update:visible', value: boolean): void
  (e: 'jump', memberId: number): void
  (e: 'refresh'): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const router = useRouter()

const loading = ref(false)
const member = ref<Member | null>(null)
const children = ref<{ memberId: number; name: string }[]>([])

const generationColor = computed(() => {
  if (member.value?.generation) {
    return getGenerationColor(member.value.generation)
  }
  return '#409EFF'
})

// 加载成员详情
const loadMemberDetail = async (memberId: number) => {
  loading.value = true
  try {
    const res = await memberApi.getDetail(memberId)
    member.value = res.data
  } catch (error) {
    console.error('加载成员详情失败', error)
    ElMessage.error('加载成员详情失败')
  } finally {
    loading.value = false
  }
}

// 监听 memberId 变化
watch(() => props.memberId, (newId) => {
  if (newId) {
    loadMemberDetail(newId)
  } else {
    member.value = null
  }
}, { immediate: true })

const handleClose = () => {
  emit('update:visible', false)
}

const handleEdit = () => {
  if (member.value) {
    router.push(`/members/${member.value.memberId}/edit`)
  }
}

const handleDelete = async () => {
  if (!member.value) return

  try {
    await ElMessageBox.confirm(
      `确定要删除成员"${member.value.name}"吗？删除后无法恢复。`,
      '删除确认',
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    await memberApi.delete(member.value.memberId)
    ElMessage.success('删除成功')
    emit('refresh')
    handleClose()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleJump = (memberId: number) => {
  emit('jump', memberId)
}

const handleShowChildren = () => {
  // 暂时通过搜索实现，后续可扩展
  ElMessage.info('子女列表功能开发中')
}
</script>

<style scoped>
.member-detail-panel {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: #fff;
  border-left: 1px solid #E4E7ED;
  transition: transform 0.3s ease-out;
}

/* 头部 */
.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #E4E7ED;
}

.panel-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.close-btn {
  padding: 4px;
  color: #909399;
}

.close-btn:hover {
  color: #409EFF;
}

/* 加载状态 */
.panel-loading {
  padding: 20px;
}

/* 内容区域 */
.panel-content {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
}

/* 成员头部 */
.member-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 24px;
  text-align: center;
}

.avatar-wrapper {
  position: relative;
  margin-bottom: 12px;
}

.status-indicator {
  position: absolute;
  bottom: 0;
  right: 0;
  padding: 2px 8px;
  font-size: 10px;
  color: #fff;
  border-radius: 10px;
  transform: translate(30%, 30%);
}

.status-indicator.alive {
  background: #67C23A;
}

.status-indicator.deceased {
  background: #909399;
}

.member-title {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.member-name {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}

.member-tags {
  display: flex;
  gap: 8px;
}

/* 信息区块 */
.info-section {
  margin-bottom: 24px;
}

.section-title {
  margin: 0 0 12px 0;
  padding-bottom: 8px;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  border-bottom: 1px solid #E4E7ED;
}

.info-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.info-label {
  font-size: 13px;
  color: #909399;
}

.info-value {
  font-size: 13px;
  color: #303133;
}

/* 关系列表 */
.relation-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.relation-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 12px;
  background: #F5F7FA;
  border-radius: 6px;
}

.relation-icon {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  color: #fff;
  font-size: 14px;
}

.relation-icon.father {
  background: #409EFF;
}

.relation-icon.mother {
  background: #F56C6C;
}

.relation-icon.spouse {
  background: #67C23A;
}

.relation-icon.children {
  background: #E6A23C;
}

.relation-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.relation-label {
  font-size: 12px;
  color: #909399;
}

.relation-name {
  font-size: 14px;
  color: #303133;
  font-weight: 500;
}

/* 个人简介 */
.biography {
  margin: 0;
  font-size: 13px;
  color: #606266;
  line-height: 1.6;
}

/* 操作按钮 */
.panel-actions {
  display: flex;
  gap: 12px;
  padding: 16px 20px;
  border-top: 1px solid #E4E7ED;
}

.panel-actions .el-button {
  flex: 1;
}

/* 空状态 */
.panel-empty {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
