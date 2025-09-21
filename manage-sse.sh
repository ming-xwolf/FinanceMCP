#!/bin/bash

# FinanceMCP SSE 服务管理脚本
# 使用方法: ./manage-sse.sh [start|stop|restart|status|logs]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION=${1:-status}

case $ACTION in
    start)
        echo "🚀 启动 SSE 服务..."
        $SCRIPT_DIR/start-sse.sh ${@:2}
        ;;
    stop)
        echo "🛑 停止 SSE 服务..."
        $SCRIPT_DIR/stop-sse.sh
        ;;
    restart)
        echo "🔄 重启 SSE 服务..."
        $SCRIPT_DIR/stop-sse.sh
        sleep 2
        $SCRIPT_DIR/start-sse.sh ${@:2}
        ;;
    status)
        $SCRIPT_DIR/status-sse.sh
        ;;
    logs)
        echo "📝 显示 SSE 服务日志..."
        if [ -f ".sse.log" ]; then
            if [ "$2" = "-f" ] || [ "$2" = "--follow" ]; then
                echo "实时监控日志 (按 Ctrl+C 退出)..."
                tail -f .sse.log
            else
                echo "最近 20 行日志:"
                tail -20 .sse.log
            fi
        else
            echo "❌ 日志文件不存在"
        fi
        ;;
    test)
        echo "🧪 测试 SSE 服务..."
        PORT=${2:-3101}
        echo "测试端口: $PORT"
        
        # 检查服务是否运行
        if ! lsof -i :$PORT > /dev/null 2>&1; then
            echo "❌ 端口 $PORT 上没有运行的服务"
            exit 1
        fi
        
        echo "测试 SSE 连接..."
        curl -H "Accept: text/event-stream" "http://localhost:$PORT/sse" --max-time 10 --no-buffer
        
        echo ""
        echo "测试消息端点..."
        curl -X POST "http://localhost:$PORT/message" \
             -H "Content-Type: application/json" \
             -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}' \
             --max-time 5
        ;;
    help|--help|-h)
        echo "FinanceMCP SSE 服务管理脚本"
        echo ""
        echo "使用方法:"
        echo "  $0 [命令] [选项]"
        echo ""
        echo "命令:"
        echo "  start [端口]     启动 SSE 服务 (默认端口: 3101)"
        echo "  stop             停止 SSE 服务"
        echo "  restart [端口]   重启 SSE 服务"
        echo "  status           查看服务状态"
        echo "  logs [-f]        查看日志 (添加 -f 实时监控)"
        echo "  test [端口]      测试服务连接"
        echo "  help             显示此帮助信息"
        echo ""
        echo "示例:"
        echo "  $0 start         在端口 3101 启动服务"
        echo "  $0 start 3102    在端口 3102 启动服务"
        echo "  $0 stop          停止服务"
        echo "  $0 restart       重启服务"
        echo "  $0 status        查看状态"
        echo "  $0 logs -f       实时查看日志"
        echo "  $0 test 3101     测试端口 3101 的服务"
        ;;
    *)
        echo "❌ 未知命令: $ACTION"
        echo "使用 '$0 help' 查看可用命令"
        exit 1
        ;;
esac
