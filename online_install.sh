#!/usr/bin/env bash

# 在线安装脚本

# 设置错误处理
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 版本信息
VERSION="1.0.0"
GITHUB_REPO="ericshiehes/VPS-STATUS"
INSTALL_DIR="/usr/local/vps-monitor"

# 检查系统要求
check_system() {
    # 检查是否为root用户
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}错误: 此脚本必须以root用户运行${NC}"
        exit 1
    fi
    
    # 检查系统类型
    if ! command -v systemctl &> /dev/null; then
        echo -e "${RED}错误: 此系统不支持systemd${NC}"
        exit 1
    fi
    
    # 检查必要命令
    local required_commands=("curl" "wget" "grep" "awk" "sed")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "${YELLOW}正在安装必要的命令: ${cmd}${NC}"
            if command -v apt-get &> /dev/null; then
                apt-get update && apt-get install -y "$cmd"
            elif command -v yum &> /dev/null; then
                yum install -y "$cmd"
            else
                echo -e "${RED}错误: 无法安装必要的命令${NC}"
                exit 1
            fi
        fi
    done
}

# 下载安装包
download_package() {
    echo -e "${GREEN}正在下载安装包...${NC}"
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # 尝试使用curl下载
    if ! curl -L "https://github.com/${GITHUB_REPO}/archive/main.tar.gz" -o "${temp_dir}/vps-monitor.tar.gz"; then
        echo -e "${YELLOW}curl下载失败，尝试使用wget...${NC}"
        if ! wget -O "${temp_dir}/vps-monitor.tar.gz" "https://github.com/${GITHUB_REPO}/archive/main.tar.gz"; then
            echo -e "${YELLOW}wget下载失败，尝试使用git克隆...${NC}"
            if ! command -v git &> /dev/null; then
                if command -v apt-get &> /dev/null; then
                    apt-get update && apt-get install -y git
                elif command -v yum &> /dev/null; then
                    yum install -y git
                fi
            fi
            git clone "https://github.com/${GITHUB_REPO}.git" "${temp_dir}/VPS-STATUS"
            mv "${temp_dir}/VPS-STATUS" "$INSTALL_DIR"
        else
            tar -xzf "${temp_dir}/vps-monitor.tar.gz" -C "$temp_dir"
            mkdir -p "$INSTALL_DIR"
            cp -r "${temp_dir}"/VPS-STATUS-main/* "$INSTALL_DIR/"
        fi
    else
        tar -xzf "${temp_dir}/vps-monitor.tar.gz" -C "$temp_dir"
        mkdir -p "$INSTALL_DIR"
        cp -r "${temp_dir}"/VPS-STATUS-main/* "$INSTALL_DIR/"
    fi
    
    # 清理临时文件
    rm -rf "$temp_dir"
}

# 安装程序
install_monitor() {
    echo -e "${GREEN}正在安装VPS监控系统...${NC}"
    
    # 创建必要的目录
    mkdir -p "/etc/vps-monitor"
    mkdir -p "/var/log/vps-monitor"
    
    # 设置权限
    chmod +x "${INSTALL_DIR}/install.sh"
    
    # 运行安装脚本
    bash "${INSTALL_DIR}/install.sh"
}

# 主函数
main() {
    echo -e "${GREEN}开始安装VPS监控系统 v${VERSION}${NC}"
    
    # 检查系统
    check_system
    
    # 下载安装包
    download_package
    
    # 安装程序
    install_monitor
    
    echo -e "${GREEN}安装完成！${NC}"
    echo -e "使用 ${YELLOW}vpsm${NC} 命令来管理监控系统"
}

# 执行主函数
main "$@" 