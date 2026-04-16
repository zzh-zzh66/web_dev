import request from '../utils/request'
import type { ApiResponse } from '../utils/request'

export interface GenealogyNode {
  memberId: number
  name: string
  gender: 'MALE' | 'FEMALE'
  generation: number
  status: 'ALIVE' | 'DECEASED'
  birthDate?: string
  deathDate?: string
  portraitUrl?: string
  spouseName?: string
  fatherId?: number
  fatherName?: string
  motherId?: number
  motherName?: string
  children: GenealogyNode[]
}

export interface MemberBasic {
  memberId: number
  name: string
  generation: number
}

export const genealogyApi = {
  getTree(rootMemberId?: number): Promise<ApiResponse<GenealogyNode>> {
    return request.get('/genealogy/tree', {
      params: rootMemberId ? { rootMemberId } : {}
    })
  },

  getDescendants(memberId: number): Promise<ApiResponse<MemberBasic[]>> {
    return request.get(`/genealogy/${memberId}/descendants`)
  },

  getAncestors(memberId: number): Promise<ApiResponse<MemberBasic[]>> {
    return request.get(`/genealogy/${memberId}/ancestors`)
  }
}
