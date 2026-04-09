# 部署流程文档

## 1. 部署概述

### 1.1 部署环境

| 环境 | 用途 | 访问方式 |
|------|------|----------|
| 开发环境 | 本地开发调试 | localhost |
| 测试环境 | 功能测试 | dev.family-genealogy.com |
| 预生产环境 | 上线前验证 | pre.family-genealogy.com |
| 生产环境 | 正式运行 | www.family-genealogy.com |

### 1.2 部署方式

| 环境 | 部署方式 | 说明 |
|------|----------|------|
| 开发环境 | Docker Compose | 本地快速启动 |
| 测试环境 | Docker Compose | CI/CD自动部署 |
| 预生产环境 | Docker Swarm | 模拟生产环境 |
| 生产环境 | Docker Swarm/K8s | 高可用集群 |

## 2. 部署架构

### 2.1 生产环境拓扑

```
                          ┌─────────────────┐
                          │   CDN/WAF       │
                          │ (Cloudflare)    │
                          └────────┬────────┘
                                   │
                          ┌────────▼────────┐
                          │  负载均衡器      │
                          │  (Nginx)        │
                          └────────┬────────┘
                                   │
          ┌────────────────────────┼────────────────────────┐
          │                        │                        │
          ▼                        ▼                        ▼
    ┌───────────┐            ┌───────────┐            ┌───────────┐
    │ App-01    │            │ App-02    │            │ App-03    │
    │ (Docker)  │            │ (Docker)  │            │ (Docker)  │
    └─────┬─────┘            └─────┬─────┘            └─────┬─────┘
          │                        │                        │
          └────────────────────────┼────────────────────────┘
                                   │
          ┌────────────────────────┼────────────────────────┐
          │                        │                        │
          ▼                        ▼                        ▼
    ┌───────────┐            ┌───────────┐            ┌───────────┐
    │   MySQL   │◀───────────│   Redis   │            │  MinIO    │
    │  主从集群  │            │   集群    │            │   集群    │
    └───────────┘            └───────────┘            └───────────┘
```

### 2.2 服务器规划

| 服务器 | 配置 | 数量 | 用途 |
|--------|------|------|------|
| 应用服务器 | 4核8G | 3台 | 运行Spring Boot应用 |
| 数据库服务器 | 8核16G | 2台 | MySQL主从 |
| 缓存服务器 | 4核8G | 2台 | Redis集群 |
| 存储服务器 | 4核8G | 2台 | MinIO集群 |
| Nginx服务器 | 2核4G | 2台 | 负载均衡+静态资源 |

## 3. 部署前准备

### 3.1 服务器环境

```bash
# 1. 安装Docker (Ubuntu)
curl -fsSL https://get.docker.com | bash

# 2. 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 3. 配置Docker镜像加速
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  }
}
EOF

# 4. 重启Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 3.2 目录规划

```bash
/app
├── family-genealogy/          # 应用目录
│   ├── app/                  # 应用代码
│   ├── config/               # 配置文件
│   ├── logs/                 # 日志目录
│   └── data/                 # 数据目录
├── docker/                    # Docker数据目录
│   ├── mysql/                # MySQL数据
│   ├── redis/                # Redis数据
│   └── minio/                # MinIO数据
├── nginx/                     # Nginx配置
│   ├── conf.d/
│   └── logs/
└── backup/                    # 备份目录
    ├── db/
    └── files/
```

### 3.3 环境变量配置

```bash
# /app/family-genealogy/.env
# 应用配置
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080

# 数据库配置
MYSQL_HOST=mysql-master
MYSQL_PORT=3306
MYSQL_DATABASE=family_genealogy
MYSQL_USER=family_user
MYSQL_PASSWORD=your_secure_password

# Redis配置
REDIS_HOST=redis-master
REDIS_PORT=6379
REDIS_PASSWORD=your_secure_password

# MinIO配置
MINIO_ENDPOINT=minio:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=your_secure_password
MINIO_BUCKET=family-files

# JWT配置
JWT_SECRET=your_jwt_secret_key_min_32_chars
JWT_EXPIRATION=7200000

# 文件上传配置
FILE_MAX_SIZE=10485760
ALLOWED_FILE_TYPES=jpg,jpeg,png,pdf

# 日志配置
LOG_LEVEL=INFO
LOG_PATH=/app/family-genealogy/logs
```

## 4. Docker Compose部署

### 4.1 docker-compose.yml

```yaml
version: '3.8'

services:
  # Spring Boot应用
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: family-app
    restart: always
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - TZ=Asia/Shanghai
    env_file:
      - .env
    volumes:
      - ./app/logs:/app/family-genealogy/logs
      - ./app/data:/app/family-genealogy/data
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - family-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # MySQL数据库
  mysql:
    image: mysql:8.0
    container_name: family-mysql
    restart: always
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
      - TZ=Asia/Shanghai
    volumes:
      - ./docker/mysql/data:/var/lib/mysql
      - ./docker/mysql/conf:/etc/mysql/conf.d
      - ./backup/db:/backup
    command: --default-authentication-plugin=mysql_native_password
    networks:
      - family-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis缓存
  redis:
    image: redis:7-alpine
    container_name: family-redis
    restart: always
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    environment:
      - TZ=Asia/Shanghai
    volumes:
      - ./docker/redis/data:/data
    networks:
      - family-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # MinIO对象存储
  minio:
    image: minio/minio:latest
    container_name: family-minio
    restart: always
    ports:
      - "9000:9000"
      - "9090:9090"
    environment:
      - MINIO_ROOT_USER=${MINIO_ACCESS_KEY}
      - MINIO_ROOT_PASSWORD=${MINIO_SECRET_KEY}
      - TZ=Asia/Shanghai
    volumes:
      - ./docker/minio/data:/data
    command: server /data --console-address ":9090"
    networks:
      - family-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3

  # Nginx反向代理
  nginx:
    image: nginx:alpine
    container_name: family-nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/logs:/var/log/nginx
      - ./docker/minio/data:/static:ro
    depends_on:
      - app
    networks:
      - family-network
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  family-network:
    driver: bridge
```

### 4.2 Nginx配置

```nginx
# /app/family-genealogy/nginx/conf.d/family-genealogy.conf

upstream app_backend {
    server app:8080;
    keepalive 32;
}

server {
    listen 80;
    server_name www.family-genealogy.com;

    # 重定向到HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name www.family-genealogy.com;

    # SSL配置
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # 日志配置
    access_log /var/log/nginx/family-access.log main;
    error_log /var/log/nginx/family-error.log warn;

    # Gzip压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    gzip_min_length 1000;

    # API代理
    location /api/ {
        proxy_pass http://app_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # WebSocket支持
    location /ws/ {
        proxy_pass http://app_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # 静态资源
    location / {
        root /var/www/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # 静态文件缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        root /var/www/html;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # 健康检查
    location /health {
        access_log off;
        return 200 "OK";
    }
}
```

## 5. 应用部署步骤

### 5.1 构建应用

```bash
# 1. 进入项目目录
cd /app/family-genealogy

# 2. 拉取最新代码
git pull origin main

# 3. 构建Docker镜像
docker build -t family-genealogy:latest .

# 4. 推送镜像（可选，用于私有仓库）
docker tag family-genealogy:latest registry.example.com/family-genealogy:latest
docker push registry.example.com/family-genealogy:latest
```

### 5.2 部署应用

```bash
# 1. 停止旧容器
docker-compose down

# 2. 启动新容器
docker-compose up -d

# 3. 查看容器状态
docker-compose ps

# 4. 查看日志
docker-compose logs -f app

# 5. 健康检查
curl http://localhost:8080/actuator/health
```

### 5.3 数据库初始化

```bash
# 1. 执行SQL脚本
docker exec -i family-mysql mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} < db/migration/V1.0__init.sql

# 2. 验证数据
docker exec -i family-mysql mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} -e "SHOW TABLES;"
```

## 6. 回滚机制

### 6.1 回滚策略

```bash
# 1. 查看历史版本
docker images family-genealogy

# 2. 回滚到指定版本
docker tag family-genealogy:V1.0.1 family-genealogy:latest
docker-compose down
docker-compose up -d

# 3. 回滚数据库（如需要）
docker exec -i family-mysql mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} < backup/db/V1.0__rollback.sql
```

### 6.2 自动回滚

```yaml
# GitHub Actions 自动回滚
name: Rollback

on:
  workflow_dispatch:
    inputs:
      version:
        description: '版本号'
        required: true

jobs:
  rollback:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy rollback version
        run: |
          docker tag registry.example.com/family-genealogy:${{ github.event.inputs.version }} family-genealogy:latest
          docker-compose up -d
```

## 7. 监控告警

### 7.1 监控指标

| 指标类型 | 监控项 | 告警阈值 |
|----------|--------|----------|
| 基础设施 | CPU使用率 | > 80% |
| 基础设施 | 内存使用率 | > 85% |
| 基础设施 | 磁盘使用率 | > 90% |
| 应用 | 接口响应时间 | > 500ms |
| 应用 | 接口错误率 | > 1% |
| 应用 | JVM堆内存 | > 80% |
| 数据库 | 连接池使用率 | > 80% |
| 数据库 | 慢查询 | > 10/分钟 |

### 7.2 告警配置

```yaml
# Prometheus告警规则
groups:
  - name: family-genealogy
    rules:
      - alert: HighErrorRate
        expr: rate(http_server_requests_seconds_count{status=~"5.."}[5m]) > 0.01
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "接口错误率超过1%"

      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m])) > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "接口响应时间超过500ms"
```

## 8. 备份策略

### 8.1 备份计划

| 备份类型 | 频率 | 时间 | 保留时间 |
|----------|------|------|----------|
| 数据库全量 | 每周 | 周日 02:00 | 4周 |
| 数据库增量 | 每日 | 每日 02:00 | 7天 |
| 文件备份 | 每周 | 周日 03:00 | 4周 |
| 配置文件 | 每月 | 每月1日 04:00 | 12个月 |

### 8.2 备份脚本

```bash
#!/bin/bash
# /app/scripts/backup.sh

BACKUP_DIR=/backup
DATE=$(date +%Y%m%d)
TIME=$(date +%H%M%S)

# 数据库备份
docker exec family-mysql mysqldump -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} > ${BACKUP_DIR}/db/${DATE}_${TIME}.sql

# 文件备份
tar -czf ${BACKUP_DIR}/files/${DATE}_${TIME}.tar.gz /app/family-genealogy/data

# 清理7天前的备份
find ${BACKUP_DIR}/db -name "*.sql" -mtime +7 -delete
find ${BACKUP_DIR}/files -name "*.tar.gz" -mtime +7 -delete

# 上传到对象存储
# aws s3 cp ${BACKUP_DIR}/ s3://family-backup/ --recursive
```

## 9. 部署检查清单

### 9.1 部署前检查

```
[ ] 服务器环境已准备
[ ] Docker和Docker Compose已安装
[ ] 配置文件已更新
[ ] 数据库迁移脚本已准备
[ ] 备份已执行
[ ] 团队成员已通知
[ ] 回滚方案已确认
```

### 9.2 部署后检查

```
[ ] 所有容器运行正常
[ ] 健康检查通过
[ ] 接口可正常访问
[ ] 日志无异常
[ ] 监控指标正常
[ ] 功能测试通过
```

## 10. 文档更新记录

| 版本 | 日期 | 更新内容 | 作者 |
|------|------|----------|------|
| v1.0 | 2026-04-09 | 初始版本 | AI Assistant |
