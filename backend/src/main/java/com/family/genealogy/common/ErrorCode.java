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

    // 通用错误码
    public static final String PARAM_ERROR = "40001";
    public static final String RESOURCE_NOT_FOUND = "40002";
    public static final String PERMISSION_DENIED = "40003";

    // 个人主页错误码
    public static final String PROFILE_NOT_FOUND = "40101";
    public static final String PROFILE_EDIT_DENIED = "40102";
    public static final String PROFILE_ACCESS_DENIED = "40103";

    // 动态管理错误码
    public static final String POST_NOT_FOUND = "40201";
    public static final String POST_EDIT_DENIED = "40202";
    public static final String POST_VISIBILITY_DENIED = "40203";
    public static final String CATEGORY_NOT_FOUND = "40204";

    // 评论系统错误码
    public static final String COMMENT_NOT_FOUND = "40301";
    public static final String COMMENT_DEPTH_LIMIT = "40302";
    public static final String COMMENT_TARGET_INVALID = "40303";

    // 点赞系统错误码
    public static final String LIKE_DUPLICATE = "40401";

    // 留言板错误码
    public static final String GUESTBOOK_NOT_FOUND = "40501";

    // 私信系统错误码
    public static final String MESSAGE_SEND_DENIED = "40601";
    public static final String SESSION_NOT_FOUND = "40602";
    public static final String MESSAGE_NOT_FOUND = "40603";

    // 通知系统错误码
    public static final String NOTIFICATION_NOT_FOUND = "40701";

    // 关系判定错误码
    public static final String NOT_RELATIVE = "40801";
    public static final String CROSS_FAMILY_DENIED = "40802";

    // 文件上传错误码
    public static final String FILE_TYPE_UNSUPPORTED = "40901";
    public static final String FILE_SIZE_EXCEEDED = "40902";

    // 话题管理错误码
    public static final String TOPIC_NOT_FOUND = "41001";
    public static final String TOPIC_NAME_DUPLICATE = "41002";
    public static final String TOPIC_MANAGE_DENIED = "41003";

    // 隐私设置错误码
    public static final String PRIVACY_NOT_FOUND = "41101";
    public static final String PRIVACY_RESTRICTED = "41102";
}
