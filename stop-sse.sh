#!/bin/bash

# FinanceMCP SSE 服务停止脚本
echo "🛑 停止 FinanceMCP SSE 服务..."

# 检查 PID 文件是否存在
if [ -f ".sse.pid" ]; then
    SSE_PID=$(cat .sse.pid)
    echo "📊 找到服务进程 ID: $SSE_PID"
    
    # 检查进程是否还在运行
    if ps -p $SSE_PID > /dev/null; then
        echo "🔄 正在停止进程 $SSE_PID..."
        kill $SSE_PID
        
        # 等待进程停止
        sleep 2
        
        # 检查进程是否已停止
        if ps -p $SSE_PID > /dev/null; then
            echo "⚠️  进程未正常停止，强制终止..."
            kill -9 $SSE_PID
            sleep 1
        fi
        
        if ps -p $SSE_PID > /dev/null; then
            echo "❌ 无法停止进程 $SSE_PID"
            exit 1
        else
            echo "✅ 进程 $SSE_PID 已停止"
        fi
    else
        echo "ℹ️  进程 $SSE_PID 已不存在"
    fi
    
    # 删除 PID 文件
    rm -f .sse.pid
    echo "🗑️  已删除 PID 文件"
else
    echo "⚠️  未找到 PID 文件，尝试查找并停止相关进程..."
fi

# 查找并停止所有相关的 supergateway 进程
echo "🔍 查找并停止所有 supergateway 进程..."
SUPERGATEWAY_PIDS=$(pgrep -f "supergateway.*build/index.js")

if [ -n "$SUPERGATEWAY_PIDS" ]; then
    echo "找到 supergateway 进程: $SUPERGATEWAY_PIDS"
    for pid in $SUPERGATEWAY_PIDS; do
        echo "停止进程 $pid..."
        kill $pid 2>/dev/null
    done
    sleep 2
    
    # 强制停止仍在运行的进程
    REMAINING_PIDS=$(pgrep -f "supergateway.*build/index.js")
    if [ -n "$REMAINING_PIDS" ]; then
        echo "强制停止剩余进程: $REMAINING_PIDS"
        for pid in $REMAINING_PIDS; do
            kill -9 $pid 2>/dev/null
        done
    fi
else
    echo "ℹ️  未找到运行中的 supergateway 进程"
fi

# 查找并停止所有相关的 Node.js 进程
echo "🔍 查找并停止所有相关的 Node.js 进程..."
NODE_PIDS=$(pgrep -f "node.*build/index.js")

if [ -n "$NODE_PIDS" ]; then
    echo "找到 Node.js 进程: $NODE_PIDS"
    for pid in $NODE_PIDS; do
        echo "停止进程 $pid..."
        kill $pid 2>/dev/null
    done
    sleep 2
    
    # 强制停止仍在运行的进程
    REMAINING_NODE_PIDS=$(pgrep -f "node.*build/index.js")
    if [ -n "$REMAINING_NODE_PIDS" ]; then
        echo "强制停止剩余 Node.js 进程: $REMAINING_NODE_PIDS"
        for pid in $REMAINING_NODE_PIDS; do
            kill -9 $pid 2>/dev/null
        done
    fi
else
    echo "ℹ️  未找到运行中的 Node.js 进程"
fi

# 检查端口使用情况
echo "🔍 检查端口使用情况..."
USED_PORTS=$(lsof -i :3100,3101,3102,3130 2>/dev/null | grep LISTEN | awk '{print $9}' | cut -d: -f2 | sort -u)

if [ -n "$USED_PORTS" ]; then
    echo "⚠️  以下端口仍被占用: $USED_PORTS"
    echo "请手动检查这些端口的使用情况"
else
    echo "✅ 所有相关端口已释放"
fi

# 清理日志文件
if [ -f ".sse.log" ]; then
    echo "服务停止时间: $(date)" >> .sse.log
    echo "---" >> .sse.log
fi

echo "🎉 SSE 服务停止完成！"
