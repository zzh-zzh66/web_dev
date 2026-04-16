/**
 * 族谱管理类型定义
 */

// 辈分颜色配置 - 根据UI设计文档的7色方案
export const GENERATION_COLORS: Record<number, string> = {
  1: '#667eea',  // HSL(229, 76%, 73%) - 深紫色
  2: '#4f46e5',  // HSL(238, 84%, 67%) - 紫色
  3: '#3b82f6',  // HSL(217, 91%, 53%) - 蓝色
  4: '#06b6d4',  // HSL(189, 94%, 43%) - 青色
  5: '#10b981',  // HSL(160, 84%, 39%) - 绿色
  6: '#f59e0b',  // HSL(38, 92%, 50%) - 橙色
  7: '#ef4444',  // HSL(0, 84%, 61%) - 红色
}

// 默认颜色（用于辈分 > 7的情况）
export const DEFAULT_GENERATION_COLOR = '#909399'

/**
 * 根据辈分获取颜色
 */
export function getGenerationColor(generation: number): string {
  if (generation >= 1 && generation <= 7) {
    return GENERATION_COLORS[generation]
  }
  return DEFAULT_GENERATION_COLOR
}

// 辈分统计信息
export interface GenerationStats {
  generation: number
  count: number
  color: string
}

// 筛选条件
export interface FilterConditions {
  generations: number[]      // 辈分筛选
  gender: 'MALE' | 'FEMALE' | ''  // 性别筛选
  status: 'ALIVE' | 'DECEASED' | ''  // 状态筛选
  birthYearFrom: number | null  // 出生年份范围
  birthYearTo: number | null
}

// 搜索历史记录
export interface SearchHistory {
  keyword: string
  timestamp: number
}

// 族谱节点位置信息（用于小地图）
export interface NodePosition {
  memberId: number
  x: number
  y: number
  width: number
  height: number
}

// 视口信息
export interface ViewportInfo {
  x: number
  y: number
  zoom: number
  width: number
  height: number
}

// 族谱树节点（完整类型，包含关系）
export interface GenealogyTreeNode {
  memberId: number
  name: string
  gender: 'MALE' | 'FEMALE'
  generation: number
  status: 'ALIVE' | 'DECEASED'
  birthDate?: string
  deathDate?: string
  portraitUrl?: string
  occupation?: string
  birthplace?: string
  biography?: string
  spouseName?: string
  fatherId?: number
  fatherName?: string
  motherId?: number
  motherName?: string
  children: GenealogyTreeNode[]
}
