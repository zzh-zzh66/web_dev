import request from '../utils/request'
import type { ApiResponse, PageResult } from '../utils/request'

/** 家族留言板 */
export interface FamilyGuestbook {
  id: number
  userId: number
  userName: string
  content: string
  createdAt: string
}

export const familyApi = {
  /** 获取家族留言板列表 */
  getFamilyGuestbook(params: { page: number; size: number }): Promise<ApiResponse<PageResult<FamilyGuestbook>>> {
    return request.get('/family/guestbook', { params })
  },

  /** 家族留言 */
  createFamilyGuestbook(data: { content: string }): Promise<ApiResponse<FamilyGuestbook>> {
    return request.post('/family/guestbook', data)
  },

  /** 删除家族留言 */
  deleteFamilyGuestbook(id: number): Promise<ApiResponse<null>> {
    return request.delete(`/family/guestbook/${id}`)
  }
}
