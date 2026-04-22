/**
 * ProfileStore - 管理个人主页状态
 */
import { defineStore } from 'pinia'
import { ref, reactive } from 'vue'
import { profileApi, contentApi, likeApi, categoryApi } from '@/api/profile'
import type { UserProfile, TimelinePost, Category } from '@/types/profile'

interface ProfileState {
  currentProfile: UserProfile | null
  posts: TimelinePost[]
  currentPost: TimelinePost | null
  categories: Category[]
  loading: boolean
  pagination: { page: number; size: number; total: number }
}

export const useProfileStore = defineStore('profile', () => {
  const currentProfile = ref<UserProfile | null>(null)
  const posts = ref<TimelinePost[]>([])
  const currentPost = ref<TimelinePost | null>(null)
  const categories = ref<Category[]>([])
  const loading = ref(false)
  const pagination = reactive({ page: 1, size: 20, total: 0 })

  /** 获取个人主页信息 */
  async function fetchProfile(userId: number) {
    loading.value = true
    try {
      const res = await profileApi.getProfile(userId)
      currentProfile.value = res.data
    } finally {
      loading.value = false
    }
  }

  /** 更新个人主页 */
  async function updateProfile(data: { backgroundUrl?: string; signature?: string; avatarUrl?: string }) {
    const res = await profileApi.updateProfile(data)
    if (currentProfile.value) {
      Object.assign(currentProfile.value, res.data)
    }
    return res.data
  }

  /** 获取动态列表 */
  async function fetchPosts(userId: number, params?: { categoryId?: number; year?: number; month?: number }) {
    loading.value = true
    try {
      const res = await contentApi.getPostList({
        userId,
        page: pagination.page,
        size: pagination.size,
        ...params
      })
      posts.value = res.data.records
      pagination.total = res.data.total
    } finally {
      loading.value = false
    }
  }

  /** 加载更多动态 */
  async function loadMorePosts(userId: number, params?: { categoryId?: number; year?: number; month?: number }) {
    if (pagination.page * pagination.size >= pagination.total) return
    pagination.page++
    loading.value = true
    try {
      const res = await contentApi.getPostList({
        userId,
        page: pagination.page,
        size: pagination.size,
        ...params
      })
      posts.value = [...posts.value, ...res.data.records]
    } finally {
      loading.value = false
    }
  }

  /** 发布动态 */
  async function createPost(data: {
    postType: 'TEXT' | 'IMAGE' | 'VIDEO' | 'LIFE_EVENT'
    categoryId?: number
    title?: string
    content: string
    visibility?: 'PUBLIC' | 'FAMILY' | 'RELATIVE' | 'PRIVATE'
    mediaList?: { url: string; type: 'IMAGE' | 'VIDEO' }[]
  }) {
    const res = await contentApi.createPost(data)
    posts.value.unshift(res.data)
    pagination.total++
    return res.data
  }

  /** 删除动态 */
  async function deletePost(postId: number) {
    await contentApi.deletePost(postId)
    const index = posts.value.findIndex(p => p.id === postId)
    if (index !== -1) {
      posts.value.splice(index, 1)
      pagination.total--
    }
  }

  /** 切换点赞状态 */
  async function toggleLike(targetType: 'POST' | 'COMMENT' | 'GUESTBOOK', targetId: number) {
    const res = await likeApi.toggleLike({ targetType, targetId })

    // 如果是动态点赞，更新本地状态
    if (targetType === 'POST') {
      const post = posts.value.find(p => p.id === targetId)
      if (post) {
        post.isLiked = res.data.isLiked
        post.likeCount = res.data.likeCount
      }
      if (currentPost.value && currentPost.value.id === targetId) {
        currentPost.value.isLiked = res.data.isLiked
        currentPost.value.likeCount = res.data.likeCount
      }
    }

    return res.data
  }

  /** 获取分类列表 */
  async function fetchCategories() {
    const res = await categoryApi.getCategories()
    categories.value = res.data
    return res.data
  }

  /** 重置状态 */
  function resetState() {
    currentProfile.value = null
    posts.value = []
    currentPost.value = null
    pagination.page = 1
    pagination.total = 0
  }

  return {
    currentProfile,
    posts,
    currentPost,
    categories,
    loading,
    pagination,
    fetchProfile,
    updateProfile,
    fetchPosts,
    loadMorePosts,
    createPost,
    deletePost,
    toggleLike,
    fetchCategories,
    resetState
  }
})
