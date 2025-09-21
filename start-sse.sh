#!/bin/bash

# FinanceMCP SSE 服务启动脚本
echo "🚀 启动 FinanceMCP SSE 服务..."

# 检查是否已有服务在运行
if pgrep -f "supergateway.*build/index.js" > /dev/null; then
    echo "⚠️  检测到已有 SSE 服务在运行"
    echo "正在停止现有服务..."
    pkill -f "supergateway.*build/index.js"
    sleep 2
fi

# 检查端口是否被占用
PORT=${1:-3101}
if lsof -i :$PORT > /dev/null 2>&1; then
    echo "❌ 端口 $PORT 已被占用，请选择其他端口"
    echo "使用方法: $0 [端口号]"
    echo "示例: $0 3102"
    exit 1
fi

# 检查构建文件是否存在
if [ ! -f "build/index.js" ]; then
    echo "📦 构建文件不存在，正在构建项目..."
    npm run build
    if [ $? -ne 0 ]; then
        echo "❌ 构建失败"
        exit 1
    fi
fi

# 设置环境变量
export NODE_ENV=production
export PORT=$PORT

# 启动 SSE 服务
echo "🌟 启动 SSE 服务在端口 $PORT..."
npx supergateway --stdio "node build/index.js" --port $PORT &

# 获取进程 ID
SSE_PID=$!
echo $SSE_PID > .sse.pid

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 3

# 检查服务是否成功启动
if ps -p $SSE_PID > /dev/null; then
    echo "✅ SSE 服务启动成功！"
    echo "📊 进程 ID: $SSE_PID"
    echo "🌐 SSE 端点: http://localhost:$PORT/sse"
    echo "📨 消息端点: http://localhost:$PORT/message"
    echo "📝 日志文件: .sse.log"
    
    # 将输出重定向到日志文件
    echo "服务启动时间: $(date)" > .sse.log
    echo "进程 ID: $SSE_PID" >> .sse.log
    echo "端口: $PORT" >> .sse.log
    echo "---" >> .sse.log
    
    echo ""
    echo "💡 使用以下命令停止服务:"
    echo "   ./stop-sse.sh"
    echo "   或"
    echo "   kill $SSE_PID"
else
    echo "❌ SSE 服务启动失败"
    rm -f .sse.pid
    exit 1
fi
