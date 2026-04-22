/**
 * 个人主页相关类型定义
 * 对应V2.0架构设计文档中的数据模型
 */

/** 用户主页档案 */
export interface UserProfile {
  id: number
  userId: number
  memberId?: number
  name: string
  gender?: string
  generation?: number
  familyName?: string
  backgroundUrl?: string
  signature?: string
  interests: string[]
  stats: {
    visitCount: number
    contentCount: number
    likeCount: number
    guestbookCount: number
  }
  relationshipLabel?: string
  isOwner: boolean
  createdAt: string
  updatedAt: string
}

/** 动态媒体文件 */
export interface PostMedia {
  id: number
  type: 'IMAGE' | 'VIDEO'
  url: string
  thumbnailUrl?: string
  width?: number
  height?: number
}

/** 时间轴动态 */
export interface TimelinePost {
  id: number
  profileId: number
  userId: number
  userName: string
  userAvatar: string
  postType: 'TEXT' | 'IMAGE' | 'VIDEO' | 'LIFE_EVENT'
  categoryId?: number
  categoryName?: string
  title?: string
  content: string
  visibility: 'PUBLIC' | 'FAMILY' | 'RELATIVE' | 'PRIVATE'
  mediaList: PostMedia[]
  likeCount: number
  commentCount: number
  isLiked: boolean
  createdAt: string
  relationshipLabel?: string
}

/** 评论 */
export interface Comment {
  id: number
  userId: number
  userName: string
  userAvatar: string
  content: string
  parentId: number
  rootId: number
  replyToUserId?: number
  replyToUserName?: string
  depth: number
  likeCount: number
  isLiked: boolean
  createdAt: string
  replies?: Comment[]
  replyCount?: number
}

/** 留言板条目 */
export interface MessageBoard {
  id: number
  userId: number
  userName: string
  userAvatar: string
  content: string
  likeCount: number
  isLiked: boolean
  createdAt: string
}

/** 私信会话 */
export interface MessageSession {
  sessionId: number
  peerUserId: number
  peerUserName: string
  peerUserAvatar: string
  lastMessage: string
  lastMessageTime: string
  unreadCount: number
}

/** 私信消息 */
export interface PrivateMessage {
  id: number
  sessionId: number
  senderId: number
  senderName: string
  msgType: 'TEXT' | 'IMAGE'
  content: string
  isRead: boolean
  createdAt: string
}

/** 通知 */
export interface Notification {
  id: number
  fromUserId: number
  fromUserName: string
  fromUserAvatar: string
  type: 'COMMENT' | 'LIKE' | 'GUESTBOOK' | 'MENTION' | 'REPLY' | 'MESSAGE' | 'SYSTEM'
  content: string
  targetType?: string
  targetId?: number
  isRead: boolean
  createdAt: string
}

/** 未读通知计数 */
export interface UnreadCount {
  totalCount: number
  commentCount: number
  replyCount: number
  likeCount: number
  guestbookCount: number
  mentionCount: number
  messageCount: number
  systemCount: number
}

/** 动态分类 */
export interface Category {
  id: number
  name: string
  icon: string
  color: string
  sortOrder: number
  isSystem: boolean
}

/** 亲属关系 */
export interface Relationship {
  isRelative: boolean
  sameFamily: boolean
  relationshipLabel: string
  generationDiff: number
  pathDescription: string
}

/** 点赞操作结果 */
export interface LikeResult {
  action: 'LIKE' | 'UNLIKE'
  likeCount: number
  isLiked: boolean
}

/** 分页参数 */
export interface PageParams {
  page?: number
  size?: number
}

/** 分页响应 */
export interface PageResult<T> {
  records: T[]
  total: number
  page: number
  size: number
}

/** 发布内容请求 */
export interface CreatePostParams {
  postType: 'TEXT' | 'IMAGE' | 'VIDEO' | 'LIFE_EVENT'
  categoryId?: number
  title?: string
  content: string
  visibility?: 'PUBLIC' | 'FAMILY' | 'RELATIVE' | 'PRIVATE'
  mediaList?: { url: string; type: 'IMAGE' | 'VIDEO' }[]
}

/** 评论请求 */
export interface CreateCommentParams {
  content: string
  parentId?: number
  replyToUserId?: number
}

/** 留言请求 */
export interface CreateGuestbookParams {
  content: string
}

/** 私信发送请求 */
export interface CreateMessageParams {
  receiverId: number
  msgType: 'TEXT' | 'IMAGE'
  content: string
}

/** 点赞请求 */
export interface ToggleLikeParams {
  targetType: 'POST' | 'COMMENT' | 'GUESTBOOK'
  targetId: number
}

/** 更新主页请求 */
export interface UpdateProfileParams {
  backgroundUrl?: string
  signature?: string
  interests?: string[]
}
