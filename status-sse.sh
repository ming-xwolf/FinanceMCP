#!/bin/bash

# FinanceMCP SSE 服务状态检查脚本
echo "📊 FinanceMCP SSE 服务状态检查"
echo "=================================="

# 检查 PID 文件
if [ -f ".sse.pid" ]; then
    SSE_PID=$(cat .sse.pid)
    echo "📁 PID 文件: .sse.pid (PID: $SSE_PID)"
    
    if ps -p $SSE_PID > /dev/null; then
        echo "✅ 服务状态: 运行中"
        echo "🆔 进程 ID: $SSE_PID"
        
        # 获取进程详细信息
        PROCESS_INFO=$(ps -p $SSE_PID -o pid,ppid,etime,pcpu,pmem,command)
        echo "📋 进程信息:"
        echo "$PROCESS_INFO"
    else
        echo "❌ 服务状态: 已停止 (PID 文件存在但进程不存在)"
        echo "💡 建议: 运行 ./stop-sse.sh 清理 PID 文件"
    fi
else
    echo "📁 PID 文件: 不存在"
fi

echo ""

# 检查所有相关的 supergateway 进程
echo "🔍 检查 supergateway 进程..."
SUPERGATEWAY_PIDS=$(pgrep -f "supergateway.*build/index.js")

if [ -n "$SUPERGATEWAY_PIDS" ]; then
    echo "✅ 找到 supergateway 进程:"
    for pid in $SUPERGATEWAY_PIDS; do
        PROCESS_INFO=$(ps -p $pid -o pid,ppid,etime,pcpu,pmem,command 2>/dev/null)
        if [ $? -eq 0 ]; then
            echo "  $PROCESS_INFO"
        fi
    done
else
    echo "ℹ️  未找到 supergateway 进程"
fi

echo ""

# 检查所有相关的 Node.js 进程
echo "🔍 检查 Node.js 进程..."
NODE_PIDS=$(pgrep -f "node.*build/index.js")

if [ -n "$NODE_PIDS" ]; then
    echo "✅ 找到 Node.js 进程:"
    for pid in $NODE_PIDS; do
        PROCESS_INFO=$(ps -p $pid -o pid,ppid,etime,pcpu,pmem,command 2>/dev/null)
        if [ $? -eq 0 ]; then
            echo "  $PROCESS_INFO"
        fi
    done
else
    echo "ℹ️  未找到 Node.js 进程"
fi

echo ""

# 检查端口使用情况
echo "🔍 检查端口使用情况..."
PORTS=(3100 3101 3102 3130)
USED_PORTS=()

for port in "${PORTS[@]}"; do
    if lsof -i :$port > /dev/null 2>&1; then
        USED_PORTS+=($port)
        PROCESS_INFO=$(lsof -i :$port | grep LISTEN | head -1)
        echo "⚠️  端口 $port 被占用: $PROCESS_INFO"
    else
        echo "✅ 端口 $port 空闲"
    fi
done

echo ""

# 检查构建文件
echo "🔍 检查构建文件..."
if [ -f "build/index.js" ]; then
    echo "✅ 构建文件存在: build/index.js"
    BUILD_TIME=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" build/index.js 2>/dev/null || stat -c "%y" build/index.js 2>/dev/null)
    echo "📅 构建时间: $BUILD_TIME"
else
    echo "❌ 构建文件不存在: build/index.js"
    echo "💡 建议: 运行 npm run build"
fi

echo ""

# 检查日志文件
if [ -f ".sse.log" ]; then
    echo "📝 日志文件: .sse.log"
    LOG_SIZE=$(wc -l < .sse.log 2>/dev/null || echo "0")
    echo "📊 日志行数: $LOG_SIZE"
    
    if [ $LOG_SIZE -gt 0 ]; then
        echo "📋 最近 5 行日志:"
        tail -5 .sse.log | sed 's/^/  /'
    fi
else
    echo "📝 日志文件: 不存在"
fi

echo ""
echo "=================================="
echo "🎯 总结:"

# 总体状态判断
if [ -f ".sse.pid" ] && ps -p $(cat .sse.pid) > /dev/null 2>&1; then
    echo "✅ 服务状态: 正常运行"
    echo "🌐 访问地址: http://localhost:$(cat .sse.pid | xargs ps -p | grep -o 'port [0-9]*' | grep -o '[0-9]*' | head -1 || echo '未知')/sse"
elif [ ${#USED_PORTS[@]} -gt 0 ]; then
    echo "⚠️  服务状态: 可能有其他实例在运行"
    echo "🔧 建议: 运行 ./stop-sse.sh 清理所有进程"
else
    echo "❌ 服务状态: 未运行"
    echo "🚀 建议: 运行 ./start-sse.sh 启动服务"
fi
