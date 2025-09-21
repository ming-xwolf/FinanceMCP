# FinanceMCP SSE 服务管理脚本

本目录包含用于管理 FinanceMCP SSE 服务的脚本集合。

## 📁 脚本文件

| 脚本文件 | 功能描述 |
|---------|---------|
| `manage-sse.sh` | 主管理脚本，提供统一的命令接口 |
| `start-sse.sh` | 启动 SSE 服务 |
| `stop-sse.sh` | 停止 SSE 服务 |
| `status-sse.sh` | 查看服务状态 |
| `test-docker-sse.sh` | Docker SSE 测试脚本 |

## 🚀 快速开始

### 使用主管理脚本（推荐）

```bash
# 查看帮助
./manage-sse.sh help

# 启动服务（默认端口 3101）
./manage-sse.sh start

# 在指定端口启动服务
./manage-sse.sh start 3102

# 查看服务状态
./manage-sse.sh status

# 停止服务
./manage-sse.sh stop

# 重启服务
./manage-sse.sh restart

# 查看日志
./manage-sse.sh logs

# 实时监控日志
./manage-sse.sh logs -f

# 测试服务连接
./manage-sse.sh test
```

### 使用独立脚本

```bash
# 启动服务
./start-sse.sh [端口号]

# 停止服务
./stop-sse.sh

# 查看状态
./status-sse.sh
```

## 🔧 功能特性

### 启动脚本 (`start-sse.sh`)
- ✅ 自动检查端口占用
- ✅ 自动构建项目（如果构建文件不存在）
- ✅ 进程 ID 管理
- ✅ 日志记录
- ✅ 服务状态验证

### 停止脚本 (`stop-sse.sh`)
- ✅ 优雅停止服务
- ✅ 强制清理残留进程
- ✅ 端口释放检查
- ✅ PID 文件清理

### 状态脚本 (`status-sse.sh`)
- ✅ 进程状态检查
- ✅ 端口使用情况
- ✅ 构建文件检查
- ✅ 日志文件信息
- ✅ 综合状态报告

### 管理脚本 (`manage-sse.sh`)
- ✅ 统一命令接口
- ✅ 参数传递
- ✅ 错误处理
- ✅ 帮助信息

## 📊 服务端点

启动服务后，可通过以下端点访问：

- **SSE 端点**: `http://localhost:[端口]/sse`
- **消息端点**: `http://localhost:[端口]/message`

## 📝 日志文件

- **日志文件**: `.sse.log`
- **PID 文件**: `.sse.pid`

## 🐳 Docker 支持

使用 Docker 运行 SSE 服务：

```bash
# 构建 Docker 镜像
docker build -t finance-mcp-sse .

# 运行 Docker 容器
./test-docker-sse.sh

# 或手动运行
docker run -d \
  --name finance-mcp-sse-container \
  -p 3130:3100 \
  -e TUSHARE_TOKEN="your_token_here" \
  finance-mcp-sse
```

## 🔍 故障排除

### 服务无法启动
1. 检查端口是否被占用：`lsof -i :3101`
2. 检查构建文件是否存在：`ls -la build/index.js`
3. 查看错误日志：`./manage-sse.sh logs`

### 服务无法停止
1. 查看进程状态：`./manage-sse.sh status`
2. 手动停止进程：`./stop-sse.sh`
3. 强制清理：`pkill -f supergateway`

### 端口冲突
1. 使用不同端口：`./manage-sse.sh start 3102`
2. 停止占用端口的服务
3. 检查端口使用：`lsof -i :端口号`

## 📋 常用命令

```bash
# 快速启动
./manage-sse.sh start

# 查看状态
./manage-sse.sh status

# 重启服务
./manage-sse.sh restart

# 测试连接
./manage-sse.sh test

# 实时监控
./manage-sse.sh logs -f
```

## ⚠️ 注意事项

1. 确保已安装 Node.js 和 npm
2. 确保已安装 supergateway：`npm install -g supergateway`
3. 确保项目已构建：`npm run build`
4. 确保有足够的端口权限
5. 建议使用主管理脚本 `manage-sse.sh` 进行所有操作
