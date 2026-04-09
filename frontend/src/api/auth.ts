import request from '../utils/request'
import type { ApiResponse } from '../utils/request'

export interface LoginRequest {
  phone: string
  password: string
}

export interface RegisterRequest {
  phone: string
  password: string
  name: string
}

export interface LoginResponse {
  token: string
  user: {
    userId: number
    phone: string
    name: string
    role: string
  }
}

export interface UserProfile {
  userId: number
  phone: string
  name: string
  role: string
  familyId?: number
}

export const authApi = {
  login(data: LoginRequest): Promise<ApiResponse<LoginResponse>> {
    return request.post('/auth/login', data)
  },

  register(data: RegisterRequest): Promise<ApiResponse<{ userId: number }>> {
    return request.post('/auth/register', data)
  },

  logout(): Promise<ApiResponse<null>> {
    return request.post('/auth/logout')
  },

  getProfile(): Promise<ApiResponse<UserProfile>> {
    return request.get('/auth/profile')
  },

  updateProfile(data: { name: string }): Promise<ApiResponse<null>> {
    return request.put('/auth/profile', data)
  }
}
