<template>
  <div class="member-list">
    <div class="page-header">
      <h2 class="page-title">成员列表</h2>
      <el-button type="primary" @click="$router.push('/members/add')">
        <el-icon><Plus /></el-icon>
        添加成员
      </el-button>
    </div>

    <!-- 搜索表单 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="姓名">
          <el-input v-model="searchForm.name" placeholder="请输入姓名" clearable />
        </el-form-item>
        <el-form-item label="辈分">
          <el-input v-model.number="searchForm.generation" placeholder="请输入辈分" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 成员列表 -->
    <el-card class="table-card">
      <el-table
        v-loading="loading"
        :data="members"
        style="width: 100%"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column prop="gender" label="性别" width="80">
          <template #default="{ row }">
            {{ row.gender === 'MALE' ? '男' : '女' }}
          </template>
        </el-table-column>
        <el-table-column prop="generation" label="辈分" width="80" />
        <el-table-column prop="birthDate" label="出生日期" width="120" />
        <el-table-column prop="spouseName" label="配偶" width="100" />
        <el-table-column prop="fatherName" label="父亲" width="100" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 'ALIVE' ? 'success' : 'info'">
              {{ row.status === 'ALIVE' ? '在世' : '已故' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="200">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleView(row)">查看</el-button>
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.size"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { memberApi, type Member, type MemberListQuery } from '@/api/member'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'

const router = useRouter()

const loading = ref(false)
const members = ref<Member[]>([])
const selectedRows = ref<Member[]>([])

const searchForm = reactive<MemberListQuery>({
  name: '',
  generation: undefined
})

const pagination = reactive({
  page: 1,
  size: 20,
  total: 0
})

const loadMembers = async () => {
  loading.value = true
  try {
    const res = await memberApi.getList({
      page: pagination.page,
      size: pagination.size,
      name: searchForm.name || undefined,
      generation: searchForm.generation || undefined
    })
    members.value = res.data.records
    pagination.total = res.data.total
  } catch (error) {
    console.error('加载成员列表失败', error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  loadMembers()
}

const handleReset = () => {
  searchForm.name = ''
  searchForm.generation = undefined
  pagination.page = 1
  loadMembers()
}

const handleSelectionChange = (rows: Member[]) => {
  selectedRows.value = rows
}

const handleView = (row: Member) => {
  router.push(`/members/${row.memberId}`)
}

const handleEdit = (row: Member) => {
  router.push(`/members/${row.memberId}/edit`)
}

const handleDelete = async (row: Member) => {
  try {
    await ElMessageBox.confirm(`确定要删除成员"${row.name}"吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await memberApi.delete(row.memberId)
    ElMessage.success('删除成功')
    loadMembers()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除失败', error)
    }
  }
}

const handleSizeChange = () => {
  pagination.page = 1
  loadMembers()
}

const handlePageChange = () => {
  loadMembers()
}

onMounted(() => {
  loadMembers()
})
</script>

<style scoped>
.member-list {
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

.search-card {
  margin-bottom: 20px;
}

.table-card {
  margin-bottom: 20px;
}

.pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
