<template>
  <div class="member-form">
    <div class="page-header">
      <h2 class="page-title">{{ isEdit ? '编辑成员' : '添加成员' }}</h2>
      <el-button @click="handleBack">返回</el-button>
    </div>

    <el-card>
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
        class="member-form-body"
      >
        <el-form-item label="姓名" prop="name">
          <el-input v-model="form.name" placeholder="请输入姓名" />
        </el-form-item>

        <el-form-item label="性别" prop="gender">
          <el-radio-group v-model="form.gender">
            <el-radio label="MALE">男</el-radio>
            <el-radio label="FEMALE">女</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="出生日期" prop="birthDate">
          <el-date-picker
            v-model="form.birthDate"
            type="date"
            placeholder="请选择出生日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="辈分" prop="generation">
          <el-input-number v-model="form.generation" :min="1" :max="100" />
        </el-form-item>

        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio label="ALIVE">在世</el-radio>
            <el-radio label="DECEASED">已故</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="父亲" prop="fatherId">
          <el-select
            v-model="form.fatherId"
            placeholder="请选择父亲"
            clearable
            filterable
            style="width: 100%"
          >
            <el-option
              v-for="member in maleMembers"
              :key="member.memberId"
              :label="`${member.name} (${member.generation}辈)`"
              :value="member.memberId"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="母亲" prop="motherId">
          <el-select
            v-model="form.motherId"
            placeholder="请选择母亲"
            clearable
            filterable
            style="width: 100%"
          >
            <el-option
              v-for="member in femaleMembers"
              :key="member.memberId"
              :label="`${member.name} (${member.generation}辈)`"
              :value="member.memberId"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="配偶姓名" prop="spouseName">
          <el-input v-model="form.spouseName" placeholder="请输入配偶姓名" />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" :loading="loading" @click="handleSubmit">
            {{ isEdit ? '保存' : '添加' }}
          </el-button>
          <el-button @click="handleBack">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { memberApi, type MemberFormData, type Member } from '@/api/member'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

const router = useRouter()
const route = useRoute()

const formRef = ref<FormInstance>()
const loading = ref(false)
const memberId = computed(() => Number(route.params.id))
const isEdit = computed(() => !!memberId.value)

const form = reactive<MemberFormData>({
  name: '',
  gender: 'MALE',
  birthDate: '',
  generation: 1,
  status: 'ALIVE',
  fatherId: undefined,
  motherId: undefined,
  spouseName: ''
})

const rules: FormRules = {
  name: [
    { required: true, message: '请输入姓名', trigger: 'blur' },
    { min: 2, max: 20, message: '姓名长度为2-20个字符', trigger: 'blur' }
  ],
  gender: [
    { required: true, message: '请选择性别', trigger: 'change' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ]
}

const maleMembers = ref<Member[]>([])
const femaleMembers = ref<Member[]>([])

const loadMemberOptions = async () => {
  try {
    const res = await memberApi.getList({ page: 1, size: 1000 })
    maleMembers.value = res.data.records.filter(m => m.gender === 'MALE')
    femaleMembers.value = res.data.records.filter(m => m.gender === 'FEMALE')
  } catch (error) {
    console.error('加载成员选项失败', error)
  }
}

const loadMemberDetail = async () => {
  if (!memberId.value) return

  try {
    const res = await memberApi.getDetail(memberId.value)
    const member = res.data
    form.name = member.name
    form.gender = member.gender
    form.birthDate = member.birthDate || ''
    form.generation = member.generation || 1
    form.status = member.status
    form.fatherId = member.fatherId
    form.motherId = member.motherId
    form.spouseName = member.spouseName || ''
  } catch (error) {
    console.error('加载成员详情失败', error)
    ElMessage.error('加载成员详情失败')
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        if (isEdit.value) {
          await memberApi.update(memberId.value, form)
          ElMessage.success('保存成功')
        } else {
          await memberApi.create(form)
          ElMessage.success('添加成功')
        }
        router.push('/members')
      } catch (error) {
        console.error('保存失败', error)
      } finally {
        loading.value = false
      }
    }
  })
}

const handleBack = () => {
  router.back()
}

onMounted(() => {
  loadMemberOptions()
  if (isEdit.value) {
    loadMemberDetail()
  }
})
</script>

<style scoped>
.member-form {
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

.member-form-body {
  max-width: 600px;
}
</style>
