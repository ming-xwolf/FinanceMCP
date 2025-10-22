#!/bin/bash

# FinanceMCP Docker Compose 启动脚本

echo "🚀 启动 FinanceMCP 服务..."

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker"
    exit 1
fi

# 创建数据目录
mkdir -p ./data

# 检查环境变量文件
if [ ! -f .env ]; then
    echo "⚠️  未找到 .env 文件，使用默认配置"
    echo "💡 提示：可以创建 .env 文件来自定义配置"
fi

# 启动服务
echo "📦 构建并启动 FinanceMCP 容器..."
docker-compose up --build -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose ps

# 测试健康检查
echo "🏥 测试健康检查..."
if curl -s http://localhost:20011/health > /dev/null; then
    echo "✅ FinanceMCP 服务启动成功！"
    echo ""
    echo "📍 服务地址："
    echo "   - MCP 端点: http://localhost:20011/mcp"
    echo "   - 健康检查: http://localhost:20011/health"
    echo "   - 反向代理: http://localhost:20080 (如果启用了 nginx-proxy)"
    echo ""
    echo "🔧 管理命令："
    echo "   - 查看日志: docker-compose logs -f"
    echo "   - 停止服务: docker-compose down"
    echo "   - 重启服务: docker-compose restart"
else
    echo "❌ 服务启动失败，请检查日志："
    echo "   docker-compose logs finance-mcp"
fi
