import { defineStore } from 'pinia'
import { ref } from 'vue'
import { authApi } from '@/api/auth'
import { getToken, setToken, removeToken, getUserInfo, setUserInfo, removeUserInfo, type UserInfo } from '@/utils/auth'

export const useUserStore = defineStore('user', () => {
  const token = ref<string | null>(getToken())
  const userInfo = ref<UserInfo | null>(getUserInfo())

  const setUserToken = (newToken: string, user: UserInfo) => {
    token.value = newToken
    setToken(newToken)
    userInfo.value = user
    setUserInfo(user)
  }

  const logout = async () => {
    try {
      await authApi.logout()
    } catch (error) {
      // 忽略退出登录的错误
    } finally {
      token.value = null
      userInfo.value = null
      removeToken()
      removeUserInfo()
    }
  }

  const fetchUserInfo = async () => {
    try {
      const res = await authApi.getProfile()
      if (res.data) {
        userInfo.value = res.data
        setUserInfo(res.data)
      }
    } catch (error) {
      console.error('获取用户信息失败', error)
    }
  }

  return {
    token,
    userInfo,
    setUserToken,
    logout,
    fetchUserInfo
  }
})
