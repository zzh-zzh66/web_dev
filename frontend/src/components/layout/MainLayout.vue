<template>
  <div class="main-layout">
    <header class="header">
      <div class="header-left">
        <div class="logo-container">
          <div class="logo-icon">
            <el-icon :size="24"><DataLine /></el-icon>
          </div>
          <span class="logo-text">FamilyVault</span>
        </div>
      </div>
      <nav class="header-nav">
        <router-link
          v-for="item in navItems"
          :key="item.path"
          :to="item.path"
          class="nav-item"
          :class="{ active: isActive(item.path) }"
        >
          <el-icon :size="18"><component :is="item.icon" /></el-icon>
          <span>{{ item.label }}</span>
        </router-link>
      </nav>
      <div class="header-right">
        <el-dropdown @command="handleCommand" trigger="click">
          <div class="user-trigger">
            <div class="user-avatar">
              {{ userStore.userInfo?.name?.charAt(0) || 'U' }}
            </div>
            <span class="user-name">{{ userStore.userInfo?.name || '用户' }}</span>
            <el-icon :size="14"><ArrowDown /></el-icon>
          </div>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">
                <el-icon><User /></el-icon>
                个人信息
              </el-dropdown-item>
              <el-dropdown-item command="logout" divided>
                <el-icon><SwitchButton /></el-icon>
                退出登录
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </header>

    <div class="main-container">
      <aside class="sidebar">
        <div class="sidebar-header">
          <span class="sidebar-title">导航菜单</span>
        </div>
        <nav class="sidebar-nav">
          <router-link
            v-for="item in navItems"
            :key="item.path"
            :to="item.path"
            class="sidebar-item"
            :class="{ active: isActive(item.path) }"
          >
            <el-icon :size="20"><component :is="item.icon" /></el-icon>
            <span>{{ item.label }}</span>
          </router-link>
        </nav>
        <div class="sidebar-footer">
          <div class="family-info">
            <div class="family-icon">
              <el-icon :size="20"><Sunny /></el-icon>
            </div>
            <div class="family-details">
              <span class="family-name">我的家族</span>
              <span class="family-role">{{ userStore.userInfo?.role || '成员' }}</span>
            </div>
          </div>
        </div>
      </aside>

      <main class="main-content">
        <div class="content-wrapper">
          <router-view />
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import { ElMessageBox } from 'element-plus'
import {
  User,
  DataLine,
  ArrowDown,
  SwitchButton,
  Sunny
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const navItems = [
  { path: '/', label: '首页', icon: 'HomeFilled' },
  { path: '/members', label: '成员管理', icon: 'User' },
  { path: '/genealogy', label: '族谱展示', icon: 'Grid' }
]

const isActive = (path: string) => {
  if (path === '/') {
    return route.path === '/'
  }
  return route.path.startsWith(path)
}

const handleCommand = async (command: string) => {
  if (command === 'logout') {
    await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await userStore.logout()
    router.push('/login')
  } else if (command === 'profile') {
    router.push('/')
  }
}
</script>

<style scoped>
.main-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: #ffffff;
}

.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 64px;
  padding: 0 32px;
  background: #ffffff;
  border-bottom: 1px solid #f2f3f5;
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-left {
  display: flex;
  align-items: center;
}

.logo-container {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 10px;
  color: #ffffff;
}

.logo-text {
  font-family: 'Outfit', sans-serif;
  font-size: 20px;
  font-weight: 600;
  color: #18181b;
  letter-spacing: -0.5px;
}

.header-nav {
  display: flex;
  align-items: center;
  gap: 8px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 500;
  color: #45515e;
  text-decoration: none;
  border-radius: 9999px;
  transition: all 0.2s ease;
}

.nav-item:hover {
  color: #18181b;
  background: rgba(0, 0, 0, 0.05);
}

.nav-item.active {
  color: #18181b;
  background: rgba(0, 0, 0, 0.05);
}

.header-right {
  display: flex;
  align-items: center;
}

.user-trigger {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 6px 12px 6px 6px;
  border-radius: 9999px;
  cursor: pointer;
  transition: background 0.2s;
}

.user-trigger:hover {
  background: rgba(0, 0, 0, 0.05);
}

.user-avatar {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  color: #ffffff;
  font-size: 14px;
  font-weight: 600;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: #18181b;
}

.main-container {
  display: flex;
  flex: 1;
}

.sidebar {
  width: 240px;
  background: #ffffff;
  border-right: 1px solid #f2f3f5;
  display: flex;
  flex-direction: column;
  position: sticky;
  top: 64px;
  height: calc(100vh - 64px);
}

.sidebar-header {
  padding: 24px 20px 16px;
}

.sidebar-title {
  font-size: 12px;
  font-weight: 500;
  color: #8e8e93;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.sidebar-nav {
  flex: 1;
  padding: 0 12px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.sidebar-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  font-size: 14px;
  font-weight: 500;
  color: #45515e;
  text-decoration: none;
  border-radius: 12px;
  transition: all 0.2s ease;
}

.sidebar-item:hover {
  color: #18181b;
  background: #f8f9fa;
}

.sidebar-item.active {
  color: #667eea;
  background: rgba(102, 126, 234, 0.08);
}

.sidebar-item.active::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 24px;
  background: linear-gradient(180deg, #667eea 0%, #764ba2 100%);
  border-radius: 0 2px 2px 0;
}

.sidebar-footer {
  padding: 16px;
  border-top: 1px solid #f2f3f5;
}

.family-info {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08) 0%, rgba(118, 75, 162, 0.08) 100%);
  border-radius: 12px;
}

.family-icon {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 10px;
  color: #ffffff;
}

.family-details {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.family-name {
  font-size: 14px;
  font-weight: 500;
  color: #18181b;
}

.family-role {
  font-size: 12px;
  color: #8e8e93;
}

.main-content {
  flex: 1;
  background: #f8f9fa;
  min-height: calc(100vh - 64px);
}

.content-wrapper {
  padding: 32px;
  max-width: 1400px;
  margin: 0 auto;
}

@media (max-width: 1024px) {
  .sidebar {
    width: 72px;
  }

  .sidebar-title,
  .sidebar-item span,
  .sidebar-footer {
    display: none;
  }

  .sidebar-item {
    justify-content: center;
    padding: 12px;
  }

  .content-wrapper {
    padding: 24px;
  }
}

@media (max-width: 768px) {
  .header-nav {
    display: none;
  }

  .content-wrapper {
    padding: 16px;
  }
}
</style>
