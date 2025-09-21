#!/bin/bash

# Docker SSE 测试脚本
echo "🐳 开始测试 Docker SSE 模式..."

# 构建 Docker 镜像
echo "📦 构建 Docker 镜像..."
docker build -t finance-mcp-sse .

if [ $? -eq 0 ]; then
    echo "✅ Docker 镜像构建成功"
else
    echo "❌ Docker 镜像构建失败"
    exit 1
fi

# 停止可能存在的容器
echo "🛑 停止现有容器..."
docker stop finance-mcp-sse-container 2>/dev/null || true
docker rm finance-mcp-sse-container 2>/dev/null || true

# 启动容器
echo "🚀 启动 SSE 容器..."
docker run -d \
  --name finance-mcp-sse-container \
  -p 3130:3100 \
  -e TUSHARE_TOKEN="${TUSHARE_TOKEN:f11798770f32be905122f11c537f7e622f187a233d47c815b58d37b7}" \
  finance-mcp-sse

if [ $? -eq 0 ]; then
    echo "✅ 容器启动成功"
else
    echo "❌ 容器启动失败"
    exit 1
fi

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 5

# 测试 SSE 端点
echo "🧪 测试 SSE 端点..."
curl -H "Accept: text/event-stream" http://localhost:3130/sse --max-time 10

echo ""
echo "📊 容器状态:"
docker ps | grep finance-mcp-sse-container

echo ""
echo "📝 容器日志:"
docker logs finance-mcp-sse-container --tail 20

echo ""
echo "🎉 测试完成！"
echo "SSE 端点: http://localhost:3130/sse"
echo "消息端点: http://localhost:3130/message"
