// 个人主页相关类型定义

export interface ProfileDTO {
  memberId: number
  userId: number
  name: string
  gender: string
  generation: number
  role: string
  birthDate?: string
  occupation?: string
  birthPlace?: string
  bio?: string
  avatarUrl?: string
  coverUrl?: string
  currentPlace?: string
  hobbies?: string[]
  achievements?: string[]
  motto?: string
  postCount: number
  fanCount: number
  relationTag?: string
  isFollowing: boolean
  isSelf: boolean
}

export interface PostDTO {
  postId: number
  memberId: number
  authorName: string
  authorAvatar?: string
  authorGeneration: number
  authorRole: string
  title?: string
  content: string
  postType: string
  postTypeName: string
  eventDate?: string
  eventPlace?: string
  images?: string[]
  taggedMembers?: TaggedMemberDTO[]
  likeCount: number
  commentCount: number
  viewCount: number
  isLiked: boolean
  createdAt: string
  isSelf: boolean
}

export interface TaggedMemberDTO {
  memberId: number
  name: string
}

export interface CommentDTO {
  commentId: number
  postId: number
  parentId?: number
  userId: number
  memberId: number
  userName: string
  userAvatar?: string
  userGeneration: number
  relationTag?: string
  content: string
  mentionedMembers?: string
  replyCount: number
  likeCount: number
  createdAt: string
  replies: CommentDTO[]
}

export interface GuestbookDTO {
  guestbookId: number
  ownerMemberId: number
  userId: number
  memberId: number
  userName: string
  userAvatar?: string
  userGeneration: number
  relationTag?: string
  parentId?: number
  content: string
  createdAt: string
  replies: GuestbookDTO[]
}

export interface MessageDTO {
  messageId: number
  senderId: number
  senderMemberId: number
  senderName: string
  senderAvatar?: string
  receiverId: number
  receiverMemberId: number
  receiverName: string
  receiverAvatar?: string
  content: string
  isRead: boolean
  createdAt: string
  isSelf: boolean
}

export interface NotificationDTO {
  notificationId: number
  type: string
  typeName: string
  title: string
  content?: string
  triggerUserId: number
  triggerMemberId: number
  triggerUserName: string
  triggerUserAvatar?: string
  resourceType?: string
  resourceId?: number
  isRead: boolean
  createdAt: string
}

export interface PageDTO<T> {
  records: T[]
  total: number
  page: number
  size: number
}

export interface PostCreateRequest {
  memberId: number
  title?: string
  content: string
  postType?: string
  eventDate?: string
  eventPlace?: string
  images?: string[]
  taggedMemberIds?: number[]
  visibility?: string
}

export interface CommentCreateRequest {
  parentId?: number
  content: string
  mentionedMemberIds?: number[]
}

export interface GuestbookRequest {
  parentId?: number
  content: string
}

export interface MessageSendRequest {
  receiverId: number
  content: string
}

export interface ProfileUpdateRequest {
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
}

// 动态类型枚举
export const PostTypeEnum = {
  LIFE_EVENT: { value: 'LIFE_EVENT', label: '人生大事' },
  MILESTONE: { value: 'MILESTONE', label: '里程碑' },
  MEMORY: { value: 'MEMORY', label: '回忆分享' },
  THOUGHT: { value: 'THOUGHT', label: '心得感悟' },
  DAILY: { value: 'DAILY', label: '日常分享' }
} as const

export type PostType = typeof PostTypeEnum[keyof typeof PostTypeEnum]['value']

// 可见范围枚举
export const VisibilityEnum = {
  PUBLIC: { value: 'PUBLIC', label: '公开' },
  FAMILY: { value: 'FAMILY', label: '家族可见' },
  RELATIVES: { value: 'RELATIVES', label: '亲属可见' },
  PRIVATE: { value: 'PRIVATE', label: '仅自己' }
} as const

export type Visibility = typeof VisibilityEnum[keyof typeof VisibilityEnum]['value']

// 通知类型枚举
export const NotificationTypeEnum = {
  COMMENT: { value: 'COMMENT', label: '评论', icon: '💬', color: '#1456f0' },
  REPLY: { value: 'REPLY', label: '回复', icon: '↩️', color: '#3b82f6' },
  LIKE: { value: 'LIKE', label: '点赞', icon: '👍', color: '#ef4444' },
  MESSAGE: { value: 'MESSAGE', label: '私信', icon: '💌', color: '#10b981' },
  MENTION: { value: 'MENTION', label: '@提及', icon: '@', color: '#f59e0b' },
  BIRTHDAY: { value: 'BIRTHDAY', label: '生日', icon: '🎂', color: '#ec4899' },
  ANNIVERSARY: { value: 'ANNIVERSARY', label: '纪念日', icon: '📅', color: '#8b5cf6' }
} as const
