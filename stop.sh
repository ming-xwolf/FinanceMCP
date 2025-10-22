#!/bin/bash

# FinanceMCP Docker Compose 停止脚本

echo "🛑 停止 FinanceMCP 服务..."

# 停止并删除容器
docker-compose down

echo "✅ FinanceMCP 服务已停止"

# 询问是否删除数据
read -p "🗑️  是否删除数据目录？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  删除数据目录..."
    rm -rf ./data
    echo "✅ 数据目录已删除"
fi

echo "🏁 清理完成"
