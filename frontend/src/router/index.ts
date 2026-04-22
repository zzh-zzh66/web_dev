import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { getToken } from '@/utils/auth'
import { getUserInfo as getStoredUserInfo, type UserInfo } from '@/utils/auth'
import { ElMessage } from 'element-plus'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/auth/LoginView.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/auth/RegisterView.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/',
    component: () => import('@/components/layout/MainLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/DashboardView.vue')
      },
      {
        path: 'family',
        name: 'FamilyHome',
        component: () => import('@/views/family/FamilyHomeView.vue')
      },
      {
        path: 'members',
        name: 'MemberList',
        component: () => import('@/views/member/MemberListView.vue')
      },
      {
        path: 'members/add',
        name: 'MemberAdd',
        component: () => import('@/views/member/MemberFormView.vue')
      },
      {
        path: 'members/:id',
        name: 'MemberDetail',
        component: () => import('@/views/member/MemberDetailView.vue')
      },
      {
        path: 'members/:id/edit',
        name: 'MemberEdit',
        component: () => import('@/views/member/MemberFormView.vue')
      },
      {
        path: 'genealogy',
        name: 'Genealogy',
        component: () => import('@/views/genealogy/GenealogyTreeView.vue')
      },
      {
        path: 'profile/:userId',
        name: 'Profile',
        component: () => import('@/views/ProfilePage.vue')
      },
      {
        path: 'notifications',
        name: 'Notifications',
        component: () => import('@/views/NotificationPage.vue')
      },
      {
        path: 'messages',
        name: 'Messages',
        component: () => import('@/views/MessagePage.vue')
      }
    ]
  },
  {
    path: '/profile/:userId',
    name: 'ProfileStandalone',
    component: () => import('@/views/ProfilePage.vue'),
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, _from, next) => {
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth !== false)
  const token = getToken()
  const userInfo = getStoredUserInfo() as UserInfo | null

  if (requiresAuth && !token) {
    next('/login')
    return
  }

  // 检查成员管理页面权限：只有ADMIN可以访问
  if (to.path === '/members' || to.path.startsWith('/members/')) {
    if (userInfo && userInfo.role !== 'ADMIN') {
      ElMessage.warning('只有族长才能管理家族成员')
      next('/')
      return
    }
  }

  if ((to.path === '/login' || to.path === '/register') && token) {
    next('/')
  } else {
    next()
  }
})

export default router
