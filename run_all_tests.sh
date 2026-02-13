#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 错误处理
error_exit() {
    print_message "$RED" "错误: $1"
    exit 1
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        error_exit "$1 未安装"
    fi
}

# 主函数
main() {
    print_message "$BLUE" "======================================"
    print_message "$BLUE" "重生到火影忍者世界 - 运行所有测试"
    print_message "$BLUE" "======================================"
    echo ""

    # 检查依赖
    print_message "$YELLOW" "检查依赖..."
    check_command "flutter"
    check_command "npm"
    check_command "node"
    print_message "$GREEN" "依赖检查完成 ✓"
    echo ""

    # 进入项目目录
    PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$PROJECT_ROOT" || error_exit "无法进入项目目录"

    FRONTEND_DIR="$PROJECT_ROOT/src/frontend"
    BACKEND_DIR="$PROJECT_ROOT/src/backend"

    # 运行前端测试
    print_message "$BLUE" "======================================"
    print_message "$BLUE" "运行前端测试 (Flutter)"
    print_message "$BLUE" "======================================"
    cd "$FRONTEND_DIR" || error_exit "无法进入前端目录"

    # 安装Flutter依赖
    print_message "$YELLOW" "安装Flutter依赖..."
    flutter pub get || error_exit "Flutter依赖安装失败"

    # 运行测试
    print_message "$YELLOW" "运行Flutter测试..."
    flutter test --coverage || {
        print_message "$RED" "前端测试失败"
        FRONTEND_STATUS=1
    }

    if [ "${FRONTEND_STATUS:-0}" -eq 0 ]; then
        print_message "$GREEN" "前端测试完成 ✓"
        print_message "$GREEN" "覆盖率报告: $FRONTEND_DIR/coverage/"
    fi
    echo ""

    # 运行后端测试
    print_message "$BLUE" "======================================"
    print_message "$BLUE" "运行后端测试 (Node.js)"
    print_message "$BLUE" "======================================"
    cd "$BACKEND_DIR" || error_exit "无法进入后端目录"

    # 检查MongoDB连接
    print_message "$YELLOW" "检查MongoDB连接..."
    # 这里可以添加MongoDB连接检查逻辑

    # 安装Node依赖
    print_message "$YELLOW" "安装Node.js依赖..."
    npm install || error_exit "Node.js依赖安装失败"

    # 运行测试
    print_message "$YELLOW" "运行Node.js测试..."
    npm run test:coverage || {
        print_message "$RED" "后端测试失败"
        BACKEND_STATUS=1
    }

    if [ "${BACKEND_STATUS:-0}" -eq 0 ]; then
        print_message "$GREEN" "后端测试完成 ✓"
        print_message "$GREEN" "覆盖率报告: $BACKEND_DIR/coverage/"
    fi
    echo ""

    # 总结
    print_message "$BLUE" "======================================"
    print_message "$BLUE" "测试总结"
    print_message "$BLUE" "======================================"

    if [ "${FRONTEND_STATUS:-0}" -eq 0 ] && [ "${BACKEND_STATUS:-0}" -eq 0 ]; then
        print_message "$GREEN" "所有测试通过 ✓"
        print_message "$GREEN" "前端状态: 通过"
        print_message "$GREEN" "后端状态: 通过"
        return 0
    else
        print_message "$RED" "部分测试失败 ✗"
        [ "${FRONTEND_STATUS:-0}" -eq 0 ] && print_message "$GREEN" "前端状态: 通过" || print_message "$RED" "前端状态: 失败"
        [ "${BACKEND_STATUS:-0}" -eq 0 ] && print_message "$GREEN" "后端状态: 通过" || print_message "$RED" "后端状态: 失败"
        return 1
    fi
}

# 运行主函数
main
