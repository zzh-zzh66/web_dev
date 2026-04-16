import request from '@/utils/request'

// 个人主页相关API

/**
 * 获取个人主页信息
 */
export function getProfile(memberId: number) {
  return request({
    url: `/api/v1/profile/${memberId}`,
    method: 'get'
  })
}

/**
 * 获取用户动态列表
 */
export function getUserPosts(memberId: number, page = 1, size = 10) {
  return request({
    url: `/api/v1/profile/${memberId}/posts`,
    method: 'get',
    params: { page, size }
  })
}

/**
 * 发布动态
 */
export function createPost(data: {
  memberId: number
  title?: string
  content: string
  postType?: string
  eventDate?: string
  eventPlace?: string
  images?: string[]
  taggedMemberIds?: number[]
  visibility?: string
}) {
  return request({
    url: '/api/v1/profile/posts',
    method: 'post',
    data
  })
}

/**
 * 获取动态详情
 */
export function getPostDetail(postId: number) {
  return request({
    url: `/api/v1/profile/posts/${postId}`,
    method: 'get'
  })
}

/**
 * 删除动态
 */
export function deletePost(postId: number) {
  return request({
    url: `/api/v1/profile/posts/${postId}`,
    method: 'delete'
  })
}

/**
 * 点赞动态
 */
export function likePost(postId: number) {
  return request({
    url: `/api/v1/profile/posts/${postId}/like`,
    method: 'post'
  })
}

/**
 * 取消点赞
 */
export function unlikePost(postId: number) {
  return request({
    url: `/api/v1/profile/posts/${postId}/like`,
    method: 'delete'
  })
}

/**
 * 评论动态
 */
export function createComment(postId: number, data: {
  parentId?: number
  content: string
  mentionedMemberIds?: number[]
}) {
  return request({
    url: `/api/v1/profile/posts/${postId}/comments`,
    method: 'post',
    data
  })
}

/**
 * 获取动态评论列表
 */
export function getPostComments(postId: number) {
  return request({
    url: `/api/v1/profile/posts/${postId}/comments`,
    method: 'get'
  })
}

/**
 * 获取留言板
 */
export function getGuestbook(memberId: number) {
  return request({
    url: `/api/v1/profile/members/${memberId}/guestbook`,
    method: 'get'
  })
}

/**
 * 添加留言
 */
export function createGuestbook(memberId: number, data: {
  parentId?: number
  content: string
}) {
  return request({
    url: `/api/v1/profile/members/${memberId}/guestbook`,
    method: 'post',
    data
  })
}

/**
 * 删除留言
 */
export function deleteGuestbook(guestbookId: number) {
  return request({
    url: `/api/v1/profile/guestbook/${guestbookId}`,
    method: 'delete'
  })
}

/**
 * 获取私信列表
 */
export function getMessages(page = 1, size = 20) {
  return request({
    url: '/api/v1/profile/messages',
    method: 'get',
    params: { page, size }
  })
}

/**
 * 发送私信
 */
export function sendMessage(data: {
  receiverId: number
  content: string
}) {
  return request({
    url: '/api/v1/profile/messages',
    method: 'post',
    data
  })
}

/**
 * 获取通知列表
 */
export function getNotifications(page = 1, size = 20) {
  return request({
    url: '/api/v1/profile/notifications',
    method: 'get',
    params: { page, size }
  })
}

/**
 * 标记通知已读
 */
export function markNotificationRead(notificationId: number) {
  return request({
    url: `/api/v1/profile/notifications/${notificationId}/read`,
    method: 'put'
  })
}

/**
 * 标记所有通知已读
 */
export function markAllNotificationsRead() {
  return request({
    url: '/api/v1/profile/notifications/read-all',
    method: 'put'
  })
}

/**
 * 更新个人资料
 */
export function updateProfile(data: {
  avatarUrl?: string
  coverUrl?: string
  bio?: string
  occupation?: string
  birthPlace?: string
  currentPlace?: string
  hobbies?: string[]
  achievements?: string[]
  motto?: string
  email?: string
  phone?: string
  privacySetting?: string
}) {
  return request({
    url: '/api/v1/profile',
    method: 'put',
    data
  })
}
