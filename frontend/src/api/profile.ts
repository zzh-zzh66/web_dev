import request from '../utils/request'
import type { ApiResponse } from '../utils/request'
import type {
  UserProfile,
  TimelinePost,
  Comment,
  MessageBoard,
  MessageSession,
  PrivateMessage,
  Notification,
  UnreadCount,
  Category,
  Relationship,
  LikeResult,
  PageResult,
  CreatePostParams,
  CreateCommentParams,
  CreateGuestbookParams,
  CreateMessageParams,
  ToggleLikeParams,
  UpdateProfileParams,
  PageParams
} from '../types/profile'

/** 个人主页 API */
export const profileApi = {
  /** 获取个人主页信息 */
  getProfile(userId: number): Promise<ApiResponse<UserProfile>> {
    return request.get(`/profiles/${userId}`)
  },

  /** 编辑个人主页 */
  updateProfile(data: UpdateProfileParams): Promise<ApiResponse<UserProfile>> {
    return request.put('/profiles/me', data)
  }
}

/** 内容管理 API */
export const contentApi = {
  /** 发布内容 */
  createPost(data: CreatePostParams): Promise<ApiResponse<TimelinePost>> {
    return request.post('/contents', data)
  },

  /** 获取家族动态列表 */
  getFamilyPosts(params: PageParams): Promise<ApiResponse<PageResult<TimelinePost>>> {
    return request.get('/contents/family', { params })
  },

  /** 获取内容列表（时间轴） */
  getPostList(params: {
    userId?: number
    categoryId?: number
    year?: number
    month?: number
    sort?: string
  } & PageParams): Promise<ApiResponse<PageResult<TimelinePost>>> {
    return request.get('/contents', { params })
  },

  /** 获取内容详情 */
  getPostDetail(postId: number): Promise<ApiResponse<TimelinePost>> {
    return request.get(`/contents/${postId}`)
  },

  /** 编辑动态 */
  updatePost(postId: number, data: CreatePostParams): Promise<ApiResponse<TimelinePost>> {
    return request.put(`/contents/${postId}`, data)
  },

  /** 删除动态 */
  deletePost(postId: number): Promise<ApiResponse<null>> {
    return request.delete(`/contents/${postId}`)
  }
}

/** 评论系统 API */
export const commentApi = {
  /** 发布评论 */
  createComment(postId: number, data: CreateCommentParams): Promise<ApiResponse<Comment>> {
    return request.post(`/contents/${postId}/comments`, data)
  },

  /** 获取评论列表 */
  getComments(postId: number, params?: { page?: number; size?: number; sort?: string }): Promise<ApiResponse<PageResult<Comment>>> {
    return request.get(`/contents/${postId}/comments`, { params })
  },

  /** 获取评论的回复列表 */
  getReplies(rootId: number, params?: { page?: number; size?: number }): Promise<ApiResponse<PageResult<Comment>>> {
    return request.get(`/comments/${rootId}/replies`, { params })
  },

  /** 删除评论 */
  deleteComment(commentId: number): Promise<ApiResponse<null>> {
    return request.delete(`/comments/${commentId}`)
  }
}

/** 点赞系统 API */
export const likeApi = {
  /** 切换点赞状态 */
  toggleLike(data: ToggleLikeParams): Promise<ApiResponse<LikeResult>> {
    return request.post('/likes', data)
  }
}

/** 留言板 API */
export const guestbookApi = {
  /** 发布留言 */
  createGuestbook(userId: number, data: CreateGuestbookParams): Promise<ApiResponse<MessageBoard>> {
    return request.post(`/profiles/${userId}/guestbook`, data)
  },

  /** 获取留言列表 */
  getGuestbookList(userId: number, params?: PageParams): Promise<ApiResponse<PageResult<MessageBoard>>> {
    return request.get(`/profiles/${userId}/guestbook`, { params })
  },

  /** 删除留言 */
  deleteGuestbook(guestbookId: number): Promise<ApiResponse<null>> {
    return request.delete(`/guestbook/${guestbookId}`)
  }
}

/** 私信系统 API */
export const messageApi = {
  /** 获取私信会话列表 */
  getMessageSessions(params?: PageParams): Promise<ApiResponse<PageResult<MessageSession>>> {
    return request.get('/messages/sessions', { params })
  },

  /** 获取私信会话消息 */
  getSessionMessages(sessionId: number, params?: PageParams): Promise<ApiResponse<PageResult<PrivateMessage>>> {
    return request.get(`/messages/sessions/${sessionId}`, { params })
  },

  /** 发送私信 */
  createMessage(data: CreateMessageParams): Promise<ApiResponse<PrivateMessage>> {
    return request.post('/messages', data)
  },

  /** 标记消息已读 */
  markSessionRead(sessionId: number): Promise<ApiResponse<null>> {
    return request.put(`/messages/sessions/${sessionId}/read`)
  }
}

/** 通知系统 API */
export const notificationApi = {
  /** 获取通知列表 */
  getNotifications(params?: { type?: string } & PageParams): Promise<ApiResponse<PageResult<Notification>>> {
    return request.get('/notifications', { params })
  },

  /** 获取未读通知数量 */
  getUnreadCount(): Promise<ApiResponse<UnreadCount>> {
    return request.get('/notifications/unread-count')
  },

  /** 标记通知已读 */
  markNotificationRead(notificationId: number): Promise<ApiResponse<null>> {
    return request.put(`/notifications/${notificationId}/read`)
  },

  /** 全部标记已读 */
  markAllNotificationsRead(): Promise<ApiResponse<null>> {
    return request.put('/notifications/read-all')
  }
}

/** 亲属关系 API */
export const relationshipApi = {
  /** 获取两个用户的关系 */
  getRelationship(userId: number, targetUserId: number): Promise<ApiResponse<Relationship>> {
    return request.get(`/relationships/${userId}/to/${targetUserId}`)
  }
}

/** 分类 API */
export const categoryApi = {
  /** 获取分类列表 */
  getCategories(): Promise<ApiResponse<Category[]>> {
    return request.get('/categories')
  }
}

/** 文件上传 API */
export const fileApi = {
  /** 上传图片 */
  uploadImage(file: File): Promise<ApiResponse<{ url: string; width: number; height: number; fileSize: number }>> {
    const formData = new FormData()
    formData.append('file', file)
    return request.post('/files/images', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  },

  /** 上传视频 */
  uploadVideo(file: File): Promise<ApiResponse<{ url: string; thumbnailUrl: string; duration: number; fileSize: number }>> {
    const formData = new FormData()
    formData.append('file', file)
    return request.post('/files/videos', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  }
}
