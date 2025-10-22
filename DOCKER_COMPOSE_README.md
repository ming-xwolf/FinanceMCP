# FinanceMCP Docker Compose 部署指南

## 📋 概述

本目录包含了 FinanceMCP 的 Docker Compose 配置文件，可以快速部署和运行 FinanceMCP 服务。

## 🚀 快速开始

### 1. 启动服务

```bash
# 使用启动脚本（推荐）
./start.sh

# 或手动启动
docker-compose up -d
```

### 2. 检查服务状态

```bash
# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs -f finance-mcp

# 测试健康检查
curl http://localhost:20011/health
```

### 3. 停止服务

```bash
# 使用停止脚本（推荐）
./stop.sh

# 或手动停止
docker-compose down
```

## 🔧 配置说明

### 环境变量

创建 `.env` 文件来自定义配置：

```bash
# Tushare API Token (可选)
TUSHARE_TOKEN=your_tushare_token_here

# 服务端口 (默认: 20011)
PORT=20011

# Node.js 环境
NODE_ENV=production
```

### 端口映射

- **20011**: FinanceMCP Streamable HTTP 服务
- **20080**: Nginx 反向代理 (生产环境)

### 数据持久化

- `./data`: 服务数据目录
- 容器重启后数据会保留

## 🌐 服务端点

### 直接访问

- **MCP 端点**: `http://localhost:20011/mcp`
- **健康检查**: `http://localhost:20011/health`

### 通过反向代理

- **MCP 端点**: `http://localhost:20080/mcp`
- **健康检查**: `http://localhost:20080/health`

## 🔄 生产环境

### 启用 Nginx 反向代理

```bash
# 启动包含 Nginx 的完整服务
docker-compose --profile production up -d
```

### 自定义 Nginx 配置

编辑 `nginx.conf` 文件来自定义反向代理配置。

## 🛠️ 管理命令

```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 重新构建并启动
docker-compose up --build -d

# 停止并删除容器
docker-compose down

# 停止并删除容器和数据
docker-compose down -v
```

## 🐛 故障排除

### 检查服务状态

```bash
# 查看容器状态
docker-compose ps

# 查看详细日志
docker-compose logs finance-mcp

# 进入容器调试
docker-compose exec finance-mcp sh
```

### 常见问题

1. **端口冲突**: 确保端口 20011 和 20080 未被占用
2. **权限问题**: 确保脚本有执行权限 `chmod +x *.sh`
3. **网络问题**: 检查防火墙设置

### 重置服务

```bash
# 完全重置（删除容器、网络、数据）
docker-compose down -v
rm -rf ./data
docker-compose up --build -d
```

## 📝 注意事项

- 首次启动会构建 Docker 镜像，可能需要几分钟
- 建议在生产环境中使用反向代理
- 定期备份 `./data` 目录中的数据
- 监控服务健康状态和日志
