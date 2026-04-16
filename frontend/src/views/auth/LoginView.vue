<template>
  <div class="login-container">
    <div class="login-background">
      <div class="bg-gradient bg-gradient-1"></div>
      <div class="bg-gradient bg-gradient-2"></div>
      <div class="bg-gradient bg-gradient-3"></div>
    </div>
    <div class="login-card">
      <div class="login-header">
        <div class="logo-container">
          <div class="logo-icon">
            <el-icon :size="32"><UserFilled /></el-icon>
          </div>
          <h1 class="brand-name">FamilyVault</h1>
        </div>
        <p class="brand-tagline">数字化族谱管理平台</p>
      </div>
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        class="login-form"
        @submit.prevent="handleLogin"
      >
        <div class="form-group">
          <label class="form-label">手机号</label>
          <el-input
            v-model="form.phone"
            placeholder="请输入手机号"
            size="large"
            class="custom-input"
          >
            <template #prefix>
              <el-icon class="input-icon"><Iphone /></el-icon>
            </template>
          </el-input>
        </div>
        <div class="form-group">
          <label class="form-label">密码</label>
          <el-input
            v-model="form.password"
            type="password"
            placeholder="请输入密码"
            size="large"
            class="custom-input"
            show-password
          >
            <template #prefix>
              <el-icon class="input-icon"><Lock /></el-icon>
            </template>
          </el-input>
        </div>
        <el-button
          type="primary"
          size="large"
          :loading="loading"
          class="login-btn"
          native-type="submit"
        >
          登录
        </el-button>
      </el-form>
      <div class="login-footer">
        <span class="footer-text">还没有账号？</span>
        <router-link to="/register" class="footer-link">立即注册</router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import { authApi } from '@/api/auth'
import { ElMessage } from 'element-plus'
import { UserFilled, Iphone, Lock } from '@element-plus/icons-vue'
import type { FormInstance, FormRules } from 'element-plus'

const router = useRouter()
const userStore = useUserStore()

const formRef = ref<FormInstance>()
const loading = ref(false)

const form = reactive({
  phone: '',
  password: ''
})

const rules: FormRules = {
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        const res = await authApi.login(form)
        userStore.setUserToken(res.data.token, res.data.user)
        ElMessage.success('登录成功')
        router.push('/')
      } catch (error) {
        console.error('登录失败', error)
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #ffffff;
  position: relative;
  overflow: hidden;
}

.login-background {
  position: absolute;
  inset: 0;
  z-index: 0;
}

.bg-gradient {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.6;
  animation: float 20s ease-in-out infinite;
}

.bg-gradient-1 {
  width: 600px;
  height: 600px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  top: -200px;
  right: -100px;
  animation-delay: 0s;
}

.bg-gradient-2 {
  width: 400px;
  height: 400px;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  bottom: -100px;
  left: -50px;
  animation-delay: -5s;
}

.bg-gradient-3 {
  width: 300px;
  height: 300px;
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  top: 50%;
  left: 30%;
  animation-delay: -10s;
}

@keyframes float {
  0%, 100% { transform: translate(0, 0) scale(1); }
  25% { transform: translate(20px, -20px) scale(1.05); }
  50% { transform: translate(0, 20px) scale(0.95); }
  75% { transform: translate(-20px, -10px) scale(1.02); }
}

.login-card {
  position: relative;
  z-index: 1;
  width: 420px;
  padding: 48px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-radius: 24px;
  box-shadow:
    0 4px 6px rgba(0, 0, 0, 0.05),
    0 10px 40px rgba(44, 30, 116, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.8);
  animation: slideUp 0.6s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.login-header {
  text-align: center;
  margin-bottom: 40px;
}

.logo-container {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin-bottom: 12px;
}

.logo-icon {
  width: 56px;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  color: #ffffff;
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
}

.brand-name {
  font-family: 'Outfit', 'DM Sans', sans-serif;
  font-size: 28px;
  font-weight: 600;
  color: #18181b;
  letter-spacing: -0.5px;
}

.brand-tagline {
  font-size: 14px;
  color: #8e8e93;
  letter-spacing: 2px;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  font-size: 13px;
  font-weight: 500;
  color: #45515e;
  letter-spacing: 0.5px;
}

.custom-input {
  --el-input-border-radius: 12px;
  --el-input-bg-color: #f8f9fa;
  --el-input-border-color: #e5e7eb;
  --el-input-hover-border-color: #667eea;
  --el-input-focus-border-color: #667eea;
}

.custom-input :deep(.el-input__wrapper) {
  padding: 4px 16px;
  border-radius: 12px;
  background: #f8f9fa;
  box-shadow: none;
  border: 1px solid #e5e7eb;
  transition: all 0.25s ease;
}

.custom-input :deep(.el-input__wrapper:hover) {
  border-color: #667eea;
}

.custom-input :deep(.el-input__wrapper.is-focus) {
  border-color: #667eea;
  background: #ffffff;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.custom-input :deep(.el-input__inner) {
  font-size: 15px;
  height: 40px;
}

.input-icon {
  color: #8e8e93;
  font-size: 16px;
}

.login-btn {
  width: 100%;
  height: 52px;
  margin-top: 8px;
  font-size: 16px;
  font-weight: 500;
  letter-spacing: 1px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 12px;
  color: #ffffff;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
}

.login-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4);
}

.login-btn:active {
  transform: translateY(0);
}

.login-footer {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 6px;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #f2f3f5;
}

.footer-text {
  font-size: 14px;
  color: #8e8e93;
}

.footer-link {
  font-size: 14px;
  font-weight: 500;
  color: #667eea;
  text-decoration: none;
  transition: color 0.2s ease;
}

.footer-link:hover {
  color: #764ba2;
}
</style>
