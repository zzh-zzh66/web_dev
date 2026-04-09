import request from '../utils/request'
import type { ApiResponse } from '../utils/request'

export type Gender = 'MALE' | 'FEMALE'
export type MemberStatus = 'ALIVE' | 'DECEASED'

export interface Member {
  memberId: number
  name: string
  gender: Gender
  birthDate?: string
  deathDate?: string
  fatherId?: number
  fatherName?: string
  motherId?: number
  motherName?: string
  spouseName?: string
  generation?: number
  status: MemberStatus
  portraitUrl?: string
  biography?: string
  birthplace?: string
  occupation?: string
}

export interface MemberFormData {
  name: string
  gender: Gender
  birthDate?: string
  deathDate?: string
  fatherId?: number
  motherId?: number
  spouseName?: string
  generation?: number
  status: MemberStatus
}

export interface MemberListQuery {
  page?: number
  size?: number
  name?: string
  generation?: number
}

export interface MemberListResponse {
  records: Member[]
  total: number
  page: number
  size: number
}

export const memberApi = {
  getList(params: MemberListQuery): Promise<ApiResponse<MemberListResponse>> {
    return request.get('/members', { params })
  },

  getDetail(id: number): Promise<ApiResponse<Member>> {
    return request.get(`/members/${id}`)
  },

  create(data: MemberFormData): Promise<ApiResponse<{ memberId: number }>> {
    return request.post('/members', data)
  },

  update(id: number, data: Partial<MemberFormData>): Promise<ApiResponse<null>> {
    return request.put(`/members/${id}`, data)
  },

  delete(id: number): Promise<ApiResponse<null>> {
    return request.delete(`/members/${id}`)
  }
}
