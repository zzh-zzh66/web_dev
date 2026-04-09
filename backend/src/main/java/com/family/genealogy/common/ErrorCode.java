package com.family.genealogy.common;

public class ErrorCode {

    // 认证错误码 (AUTH_xxx)
    public static final String AUTH_USER_EXISTS = "AUTH_001";
    public static final String AUTH_PHONE_EXISTS = "AUTH_002";
    public static final String AUTH_CREDENTIALS_ERROR = "AUTH_003";
    public static final String AUTH_TOKEN_EXPIRED = "AUTH_004";

    // 成员错误码 (MEMBER_xxx)
    public static final String MEMBER_NOT_EXISTS = "MEMBER_001";
    public static final String MEMBER_NAME_DUPLICATE = "MEMBER_002";

    // 关系错误码 (REL_xxx)
    public static final String REL_EXISTS = "REL_001";
    public static final String REL_CIRCULAR_NOT_ALLOWED = "REL_002";
}
