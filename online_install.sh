#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 版本信息
VERSION="1.0.0"
REPO="your_username/vps-monitor"
BRANCH="main"
GITHUB_RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
GITHUB_API="https://api.github.com/repos/${REPO}"

# 检测包管理器
detect_package_manager() {
    if command -v apt-get >/dev/null; then
        PM="apt-get"
        PM_INSTALL="apt-get install -y"
        PM_UPDATE="apt-get update"
    elif command -v yum >/dev/null; then
        PM="yum"
        PM_INSTALL="yum install -y"
        PM_UPDATE="yum update -y"
    elif command -v dnf >/dev/null; then
        PM="dnf"
        PM_INSTALL="dnf install -y"
        PM_UPDATE="dnf update -y"
    else
        echo -e "${RED}错误: 未找到支持的包管理器${NC}"
        exit 1
    fi
}

# 检查并安装依赖
install_dependencies() {
    echo -e "${YELLOW}检查并安装必要的依赖...${NC}"
    
    # 更新包列表
    $PM_UPDATE >/dev/null 2>&1
    
    # 安装基本依赖
    local deps=(curl wget jq bc net-tools)
    for dep in "${deps[@]}"; do
        if ! command -v $dep >/dev/null 2>&1; then
            echo "安装 $dep..."
            $PM_INSTALL $dep >/dev/null 2>&1
        fi
    done
}

# 检查系统要求
check_system() {
    echo -e "${YELLOW}检查系统要求...${NC}"
    
    # 检查操作系统
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "检测到操作系统: $PRETTY_NAME"
    else
        echo -e "${RED}错误: 无法确定操作系统类型${NC}"
        exit 1
    fi
    
    # 检查systemd
    if ! command -v systemctl >/dev/null 2>&1; then
        echo -e "${RED}错误: 系统需要支持systemd${NC}"
        exit 1
    fi
    
    # 检查root权限
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}错误: 请使用root权限运行此脚本${NC}"
        echo "请运行: sudo bash $0"
        exit 1
    fi
}

# 下载文件
download_file() {
    local url="$1"
    local dest="$2"
    
    if ! wget -q --show-progress "$url" -O "$dest"; then
        echo -e "${RED}错误: 下载失败 - $url${NC}"
        return 1
    fi
    return 0
}

# 下载安装文件
download_files() {
    echo -e "${YELLOW}下载程序文件...${NC}"
    
    # 创建临时目录
    local tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    
    # 下载主要文件
    local files=(
        "install.sh"
        "src/monitor.sh"
        "src/config.sh"
        "src/menu.sh"
        "src/utils.sh"
        "src/telegram.sh"
        "bin/vpsm"
    )
    
    for file in "${files[@]}"; do
        echo "下载 $file..."
        if ! download_file "${GITHUB_RAW}/${file}" "$file"; then
            echo -e "${RED}下载失败，安装终止${NC}"
            cd - >/dev/null
            rm -rf "$tmp_dir"
            exit 1
        fi
    done
    
    # 设置执行权限
    chmod +x install.sh
    
    echo -e "${GREEN}文件下载完成${NC}"
    return 0
}

# 开始安装
start_install() {
    echo -e "${YELLOW}开始安装...${NC}"
    ./install.sh
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}安装完成！${NC}"
        echo -e "请运行 ${YELLOW}vpsm${NC} 命令来使用程序"
    else
        echo -e "${RED}安装失败！${NC}"
        exit 1
    fi
}

# 清理
cleanup() {
    cd - >/dev/null
    rm -rf "$tmp_dir"
}

# 主函数
main() {
    echo "VPS监控系统安装程序 v${VERSION}"
    echo "------------------------"
    
    check_system
    detect_package_manager
    install_dependencies
    download_files
    start_install
    cleanup
}

# 捕获Ctrl+C
trap 'echo -e "\n${RED}安装已取消${NC}"; cleanup; exit 1' INT

# 运行主函数
main 