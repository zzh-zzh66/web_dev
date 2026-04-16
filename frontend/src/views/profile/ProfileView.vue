<template>
  <div class="profile-page">
    <!-- 顶部导航栏 -->
    <div class="profile-header">
      <div class="header-left">
        <el-button text @click="goBack">
          <el-icon><ArrowLeft /></el-icon>
          返回
        </el-button>
      </div>
      <div class="header-title">个人主页</div>
      <div class="header-right">
        <el-button text @click="goToSettings" v-if="profile?.isSelf">
          <el-icon><Setting /></el-icon>
        </el-button>
        <el-badge :value="unreadCount" :hidden="unreadCount === 0" :max="99">
          <el-button text @click="goToMessages">
            <el-icon><Message /></el-icon>
          </el-button>
        </el-badge>
      </div>
    </div>

    <!-- 封面区域 -->
    <div class="cover-section" :style="coverStyle">
      <div class="cover-overlay" v-if="profile?.isSelf">
        <el-button plain @click="changeCover">
          <el-icon><Camera /></el-icon>
          更换封面
        </el-button>
      </div>
    </div>

    <!-- 用户信息区域 -->
    <div class="user-info-section">
      <div class="avatar-wrapper">
        <el-avatar :size="80" :src="profile?.avatarUrl" @error="() => true">
          {{ profile?.name?.charAt(0) }}
        </el-avatar>
        <el-button circle v-if="profile?.isSelf" class="avatar-edit-btn" @click="changeAvatar">
          <el-icon><Camera /></el-icon>
        </el-button>
      </div>
      <div class="user-details">
        <h1 class="user-name">{{ profile?.name }}</h1>
        <div class="user-tags">
          <el-tag v-if="profile?.generation" type="info" size="small">
            第{{ profile.generation }}辈
          </el-tag>
          <el-tag v-if="profile?.role === 'ADMIN'" type="warning" size="small">
            家族管理员
          </el-tag>
          <span v-if="profile?.relationTag" class="relation-tag">
            {{ profile.relationTag }}
          </span>
        </div>
        <p class="user-bio" v-if="profile?.bio">{{ profile.bio }}</p>
      </div>
      <div class="user-actions">
        <el-button v-if="profile?.isSelf" type="primary" @click="editProfile">
          编辑资料
        </el-button>
        <el-button v-if="!profile?.isSelf" @click="sendMessage">
          发消息
        </el-button>
        <el-button v-if="!profile?.isSelf" @click="toggleFollow">
          {{ profile?.isFollowing ? '已关注' : '关注' }}
        </el-button>
      </div>
    </div>

    <!-- 用户统计 -->
    <div class="user-stats">
      <div class="stat-item">
        <span class="stat-value">{{ profile?.postCount || 0 }}</span>
        <span class="stat-label">动态</span>
      </div>
      <div class="stat-item">
        <span class="stat-value">{{ profile?.fanCount || 0 }}</span>
        <span class="stat-label">粉丝</span>
      </div>
    </div>

    <!-- 标签页 -->
    <el-tabs v-model="activeTab" class="profile-tabs" @tab-change="handleTabChange">
      <el-tab-pane label="动态" name="posts">
        <template #label>
          动态<span class="tab-count">({{ profile?.postCount || 0 }})</span>
        </template>
      </el-tab-pane>
      <el-tab-pane label="相册" name="albums">
        <template #label>
          相册<span class="tab-count">({{ photoCount }})</span>
        </template>
      </el-tab-pane>
      <el-tab-pane label="关于TA" name="about">
        <template #label>
          关于TA<span class="tab-count">({{ aboutCount }})</span>
        </template>
      </el-tab-pane>
      <el-tab-pane label="亲属" name="relatives">
        <template #label>
          亲属<span class="tab-count">({{ relativeCount }})</span>
        </template>
      </el-tab-pane>
    </el-tabs>

    <!-- 动态列表 -->
    <div class="posts-section" v-if="activeTab === 'posts'">
      <div class="post-create" v-if="profile?.isSelf">
        <el-input
          v-model="newPostContent"
          type="textarea"
          placeholder="分享你的近况..."
          :rows="3"
        />
        <div class="post-create-actions">
          <el-select v-model="newPostType" placeholder="选择类型" size="small">
            <el-option
              v-for="item in postTypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
          <el-button type="primary" size="small" @click="showPostDialog = true">
            发布
          </el-button>
        </div>
      </div>

      <div class="post-filters" v-if="postList.length > 0">
        <el-radio-group v-model="postFilter" size="small">
          <el-radio-button label="">全部</el-radio-button>
          <el-radio-button label="LIFE_EVENT">人生大事</el-radio-button>
          <el-radio-button label="MILESTONE">里程碑</el-radio-button>
          <el-radio-button label="MEMORY">回忆</el-radio-button>
          <el-radio-button label="THOUGHT">感悟</el-radio-button>
          <el-radio-button label="DAILY">日常</el-radio-button>
        </el-radio-group>
      </div>

      <div class="post-list">
        <PostCard
          v-for="post in filteredPosts"
          :key="post.postId"
          :post="post"
          @like="handleLike"
          @unlike="handleUnlike"
          @comment="handleShowComment"
          @delete="handleDeletePost"
          @click="goToPostDetail(post.postId)"
        />
        <el-empty v-if="postList.length === 0" description="暂无动态" />
      </div>
    </div>

    <!-- 相册 -->
    <div class="albums-section" v-if="activeTab === 'albums'">
      <el-empty description="暂无相册" />
    </div>

    <!-- 关于TA -->
    <div class="about-section" v-if="activeTab === 'about'">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="职业">
          {{ profile?.occupation || '未填写' }}
        </el-descriptions-item>
        <el-descriptions-item label="出生地">
          {{ profile?.birthPlace || '未填写' }}
        </el-descriptions-item>
        <el-descriptions-item label="现居地">
          {{ profile?.currentPlace || '未填写' }}
        </el-descriptions-item>
        <el-descriptions-item label="兴趣爱好">
          <el-tag v-for="hobby in profile?.hobbies" :key="hobby" size="small" class="hobby-tag">
            {{ hobby }}
          </el-tag>
          <span v-if="!profile?.hobbies?.length">未填写</span>
        </el-descriptions-item>
        <el-descriptions-item label="个人成就">
          <div v-for="achievement in profile?.achievements" :key="achievement" class="achievement-item">
            {{ achievement }}
          </div>
          <span v-if="!profile?.achievements?.length">未填写</span>
        </el-descriptions-item>
        <el-descriptions-item label="座右铭">
          {{ profile?.motto || '未填写' }}
        </el-descriptions-item>
      </el-descriptions>
    </div>

    <!-- 亲属 -->
    <div class="relatives-section" v-if="activeTab === 'relatives'">
      <el-empty description="暂无亲属信息" />
    </div>

    <!-- 留言板 -->
    <div class="guestbook-section">
      <h3 class="section-title">留言板 ({{ guestbookList.length }})</h3>
      <div class="guestbook-input">
        <el-input
          v-model="guestbookContent"
          placeholder="写下你的留言..."
          :rows="2"
          type="textarea"
        />
        <el-button type="primary" size="small" @click="submitGuestbook" :disabled="!guestbookContent">
          留言
        </el-button>
      </div>
      <div class="guestbook-list">
        <div v-for="item in guestbookList" :key="item.guestbookId" class="guestbook-item">
          <el-avatar :size="40" :src="item.userAvatar">
            {{ item.userName?.charAt(0) }}
          </el-avatar>
          <div class="guestbook-content">
            <div class="guestbook-header">
              <span class="guestbook-name">{{ item.userName }}</span>
              <span class="guestbook-tag" v-if="item.relationTag">{{ item.relationTag }}</span>
              <span class="guestbook-time">{{ formatTime(item.createdAt) }}</span>
            </div>
            <div class="guestbook-text">{{ item.content }}</div>
          </div>
          <el-button
            v-if="profile?.isSelf || item.userId === currentUserId"
            text
            size="small"
            @click="deleteGuestbook(item.guestbookId)"
          >
            删除
          </el-button>
        </div>
        <el-empty v-if="guestbookList.length === 0" description="暂无留言" />
      </div>
    </div>

    <!-- 发布动态弹窗 -->
    <el-dialog v-model="showPostDialog" title="发布动态" width="600px">
      <el-form :model="postForm" label-width="80px">
        <el-form-item label="类型">
          <el-select v-model="postForm.postType" placeholder="选择动态类型">
            <el-option
              v-for="item in postTypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="标题" v-if="postForm.postType === 'LIFE_EVENT' || postForm.postType === 'MILESTONE'">
          <el-input v-model="postForm.title" placeholder="输入标题" />
        </el-form-item>
        <el-form-item label="内容">
          <el-input
            v-model="postForm.content"
            type="textarea"
            :rows="4"
            placeholder="分享你的故事..."
          />
        </el-form-item>
        <el-form-item label="时间" v-if="postForm.postType === 'LIFE_EVENT'">
          <el-date-picker
            v-model="postForm.eventDate"
            type="date"
            placeholder="选择日期"
          />
        </el-form-item>
        <el-form-item label="地点" v-if="postForm.postType === 'LIFE_EVENT'">
          <el-input v-model="postForm.eventPlace" placeholder="输入地点" />
        </el-form-item>
        <el-form-item label="可见范围">
          <el-select v-model="postForm.visibility">
            <el-option
              v-for="item in visibilityOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showPostDialog = false">取消</el-button>
        <el-button type="primary" @click="submitPost">发布</el-button>
      </template>
    </el-dialog>

    <!-- 评论弹窗 -->
    <el-dialog v-model="showCommentDialog" title="评论" width="500px">
      <div class="comment-post-content" v-if="currentPost">
        <strong>{{ currentPost.authorName }}:</strong>
        {{ currentPost.content }}
      </div>
      <el-input
        v-model="commentContent"
        type="textarea"
        :rows="3"
        placeholder="写下你的评论..."
        class="comment-input"
      />
      <template #footer>
        <el-button @click="showCommentDialog = false">取消</el-button>
        <el-button type="primary" @click="submitComment">发表评论</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  ArrowLeft, Setting, Message, Camera
} from '@element-plus/icons-vue'
import {
  getProfile, getUserPosts, createPost, deletePost,
  likePost, unlikePost, getGuestbook, createGuestbook,
  deleteGuestbook as deleteGuestbookApi, getNotifications
} from '@/api/profile'
import type {
  ProfileDTO, PostDTO, GuestbookDTO,
  PostCreateRequest, NotificationDTO
} from '@/types/profile'
import PostCard from './components/PostCard.vue'

const route = useRoute()
const router = useRouter()

const memberId = computed(() => Number(route.params.memberId))
const currentUserId = ref<number | null>(null)

// 数据
const profile = ref<ProfileDTO | null>(null)
const postList = ref<PostDTO[]>([])
const guestbookList = ref<GuestbookDTO[]>([])
const notifications = ref<NotificationDTO[]>([])
const unreadCount = ref(0)

// UI状态
const activeTab = ref('posts')
const postFilter = ref('')
const showPostDialog = ref(false)
const showCommentDialog = ref(false)

// 表单数据
const newPostContent = ref('')
const newPostType = ref('DAILY')
const guestbookContent = ref('')
const commentContent = ref('')
const currentPost = ref<PostDTO | null>(null)

// 常量
const postTypeOptions = [
  { value: 'LIFE_EVENT', label: '人生大事' },
  { value: 'MILESTONE', label: '里程碑' },
  { value: 'MEMORY', label: '回忆分享' },
  { value: 'THOUGHT', label: '心得感悟' },
  { value: 'DAILY', label: '日常分享' }
]

const visibilityOptions = [
  { value: 'PUBLIC', label: '公开' },
  { value: 'FAMILY', label: '家族可见' },
  { value: 'RELATIVES', label: '亲属可见' },
  { value: 'PRIVATE', label: '仅自己' }
]

const postForm = ref<PostCreateRequest>({
  memberId: memberId.value,
  content: '',
  postType: 'DAILY',
  visibility: 'FAMILY'
})

// 计算属性
const coverStyle = computed(() => {
  if (profile.value?.coverUrl) {
    return { backgroundImage: `url(${profile.value.coverUrl})` }
  }
  return { background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' }
})

const filteredPosts = computed(() => {
  if (!postFilter.value) return postList.value
  return postList.value.filter(post => post.postType === postFilter.value)
})

const photoCount = computed(() => {
  return postList.value.reduce((count, post) => count + (post.images?.length || 0), 0)
})

const aboutCount = computed(() => {
  let count = 0
  if (profile.value?.occupation) count++
  if (profile.value?.birthPlace) count++
  if (profile.value?.currentPlace) count++
  if (profile.value?.hobbies?.length) count++
  if (profile.value?.achievements?.length) count++
  if (profile.value?.motto) count++
  return count
})

const relativeCount = computed(() => 0)

// 方法
const loadProfile = async () => {
  try {
    const res = await getProfile(memberId.value)
    profile.value = res.data
  } catch (error) {
    console.error('加载个人主页失败', error)
  }
}

const loadPosts = async () => {
  try {
    const res = await getUserPosts(memberId.value)
    postList.value = res.data.records
  } catch (error) {
    console.error('加载动态失败', error)
  }
}

const loadGuestbook = async () => {
  try {
    const res = await getGuestbook(memberId.value)
    guestbookList.value = res.data
  } catch (error) {
    console.error('加载留言板失败', error)
  }
}

const loadNotifications = async () => {
  try {
    const res = await getNotifications()
    notifications.value = res.data.records
    unreadCount.value = notifications.value.filter(n => !n.isRead).length
  } catch (error) {
    console.error('加载通知失败', error)
  }
}

const handleTabChange = (tab: string) => {
  console.log('切换标签', tab)
}

const formatTime = (time: string) => {
  const date = new Date(time)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)

  if (minutes < 1) return '刚刚'
  if (minutes < 60) return `${minutes}分钟前`
  if (hours < 24) return `${hours}小时前`
  if (days < 7) return `${days}天前`
  return date.toLocaleDateString()
}

const goBack = () => {
  router.back()
}

const goToSettings = () => {
  router.push('/settings')
}

const goToMessages = () => {
  router.push('/messages')
}

const goToPostDetail = (postId: number) => {
  router.push(`/profile/post/${postId}`)
}

const editProfile = () => {
  router.push('/profile/edit')
}

const sendMessage = () => {
  if (profile.value) {
    router.push(`/messages?to=${profile.value.userId}`)
  }
}

const toggleFollow = () => {
  ElMessage.info('关注功能开发中')
}

const changeCover = () => {
  ElMessage.info('更换封面功能开发中')
}

const changeAvatar = () => {
  ElMessage.info('更换头像功能开发中')
}

const handleLike = async (post: PostDTO) => {
  try {
    await likePost(post.postId)
    post.isLiked = true
    post.likeCount++
    ElMessage.success('点赞成功')
  } catch (error: any) {
    ElMessage.error(error.message || '点赞失败')
  }
}

const handleUnlike = async (post: PostDTO) => {
  try {
    await unlikePost(post.postId)
    post.isLiked = false
    post.likeCount--
    ElMessage.success('已取消点赞')
  } catch (error: any) {
    ElMessage.error(error.message || '取消点赞失败')
  }
}

const handleShowComment = (post: PostDTO) => {
  currentPost.value = post
  showCommentDialog.value = true
}

const handleDeletePost = async (post: PostDTO) => {
  try {
    await ElMessageBox.confirm('确定要删除这条动态吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await deletePost(post.postId)
    postList.value = postList.value.filter(p => p.postId !== post.postId)
    ElMessage.success('删除成功')
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const submitPost = async () => {
  if (!postForm.value.content) {
    ElMessage.warning('请输入内容')
    return
  }
  try {
    postForm.value.memberId = memberId.value
    await createPost(postForm.value)
    ElMessage.success('发布成功')
    showPostDialog.value = false
    postForm.value = {
      memberId: memberId.value,
      content: '',
      postType: 'DAILY',
      visibility: 'FAMILY'
    }
    loadPosts()
  } catch (error: any) {
    ElMessage.error(error.message || '发布失败')
  }
}

const submitComment = async () => {
  if (!commentContent.value || !currentPost.value) {
    ElMessage.warning('请输入评论内容')
    return
  }
  ElMessage.info('评论功能开发中')
  showCommentDialog.value = false
  commentContent.value = ''
}

const submitGuestbook = async () => {
  if (!guestbookContent.value) {
    ElMessage.warning('请输入留言内容')
    return
  }
  try {
    await createGuestbook(memberId.value, {
      content: guestbookContent.value
    })
    ElMessage.success('留言成功')
    guestbookContent.value = ''
    loadGuestbook()
  } catch (error: any) {
    ElMessage.error(error.message || '留言失败')
  }
}

const deleteGuestbook = async (guestbookId: number) => {
  try {
    await ElMessageBox.confirm('确定要删除这条留言吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await deleteGuestbookApi(guestbookId)
    guestbookList.value = guestbookList.value.filter(g => g.guestbookId !== guestbookId)
    ElMessage.success('删除成功')
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

// 监听路由变化
watch(() => route.params.memberId, () => {
  loadProfile()
  loadPosts()
  loadGuestbook()
})

// 初始化
onMounted(() => {
  loadProfile()
  loadPosts()
  loadGuestbook()
  loadNotifications()
})
</script>

<style scoped lang="scss">
.profile-page {
  min-height: 100vh;
  background: #f5f5f5;
}

.profile-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  background: #fff;
  border-bottom: 1px solid #e5e7eb;

  .header-title {
    font-size: 16px;
    font-weight: 500;
  }
}

.cover-section {
  height: 200px;
  background-size: cover;
  background-position: center;
  position: relative;

  .cover-overlay {
    position: absolute;
    bottom: 12px;
    right: 12px;
    opacity: 0;
    transition: opacity 0.3s;
  }

  &:hover .cover-overlay {
    opacity: 1;
  }
}

.user-info-section {
  padding: 16px;
  background: #fff;
  margin-bottom: 12px;

  .avatar-wrapper {
    position: relative;
    display: inline-block;

    .avatar-edit-btn {
      position: absolute;
      bottom: 0;
      right: 0;
      width: 28px;
      height: 28px;
    }
  }

  .user-details {
    margin-top: -40px;
    margin-left: 100px;

    .user-name {
      font-size: 24px;
      font-weight: 600;
      margin: 8px 0;
    }

    .user-tags {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      margin-bottom: 8px;

      .relation-tag {
        font-size: 12px;
        color: #8e8e93;
      }
    }

    .user-bio {
      color: #45515e;
      font-size: 14px;
      margin: 8px 0 0;
    }
  }

  .user-actions {
    margin-top: 16px;
    display: flex;
    gap: 8px;
  }
}

.user-stats {
  display: flex;
  padding: 16px;
  background: #fff;
  margin-bottom: 12px;

  .stat-item {
    flex: 1;
    text-align: center;

    .stat-value {
      font-size: 18px;
      font-weight: 600;
      color: #222;
    }

    .stat-label {
      font-size: 12px;
      color: #8e8e93;
      margin-left: 4px;
    }
  }
}

.profile-tabs {
  background: #fff;
  padding: 0 16px;

  .tab-count {
    font-size: 12px;
    margin-left: 4px;
  }
}

.posts-section {
  padding: 16px;

  .post-create {
    background: #fff;
    padding: 16px;
    border-radius: 12px;
    margin-bottom: 16px;

    .post-create-actions {
      display: flex;
      justify-content: space-between;
      margin-top: 12px;
    }
  }

  .post-filters {
    margin-bottom: 16px;
  }
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  margin: 16px 0;
}

.guestbook-section {
  padding: 16px;

  .guestbook-input {
    display: flex;
    gap: 12px;
    margin-bottom: 16px;

    .el-textarea {
      flex: 1;
    }
  }

  .guestbook-list {
    background: #fff;
    border-radius: 12px;
    padding: 16px;
  }

  .guestbook-item {
    display: flex;
    gap: 12px;
    padding: 12px 0;
    border-bottom: 1px solid #f0f0f0;

    &:last-child {
      border-bottom: none;
    }

    .guestbook-content {
      flex: 1;

      .guestbook-header {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 4px;

        .guestbook-name {
          font-weight: 500;
          color: #222;
        }

        .guestbook-tag {
          font-size: 12px;
          color: #8e8e93;
        }

        .guestbook-time {
          font-size: 12px;
          color: #8e8e93;
          margin-left: auto;
        }
      }

      .guestbook-text {
        color: #45515e;
        font-size: 14px;
      }
    }
  }
}

.comment-post-content {
  padding: 12px;
  background: #f5f5f5;
  border-radius: 8px;
  margin-bottom: 12px;
}

.comment-input {
  margin-top: 12px;
}

.hobby-tag {
  margin-right: 8px;
  margin-bottom: 4px;
}

.achievement-item {
  padding: 4px 0;
}
</style>
