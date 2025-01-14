#!/usr/bin/env bash

# 本地安装脚本

# 设置错误处理
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 安装路径
INSTALL_DIR="/usr/local/vps-monitor"
BIN_DIR="/usr/local/bin"
SYSTEMD_DIR="/etc/systemd/system"

# 安装主程序
install_binary() {
    echo -e "${GREEN}正在安装主程序...${NC}"
    
    # 复制主程序
    cp "${INSTALL_DIR}/src/vpsm" "${BIN_DIR}/vpsm"
    chmod +x "${BIN_DIR}/vpsm"
    
    # 创建符号链接
    ln -sf "${BIN_DIR}/vpsm" "${BIN_DIR}/vps-monitor"
}

# 安装系统服务
install_service() {
    echo -e "${GREEN}正在安装系统服务...${NC}"
    
    # 创建服务文件
    cat > "${SYSTEMD_DIR}/vps-monitor.service" << EOF
[Unit]
Description=VPS Monitor Service
After=network.target

[Service]
Type=simple
ExecStart=${BIN_DIR}/vpsm daemon
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    # 重新加载systemd
    systemctl daemon-reload
    
    # 启用服务
    systemctl enable vps-monitor.service
}

# 配置初始化
init_config() {
    echo -e "${GREEN}正在初始化配置...${NC}"
    
    # 运行配置脚本
    source "${INSTALL_DIR}/src/utils/config.sh"
    
    # 提示用户输入Telegram配置
    read -p "请输入Telegram Bot Token: " bot_token
    read -p "请输入Telegram Chat ID: " chat_id
    
    # 更新配置
    update_config "TELEGRAM_BOT_TOKEN" "$bot_token"
    update_config "TELEGRAM_CHAT_ID" "$chat_id"
}

# 检查依赖
check_dependencies() {
    echo -e "${GREEN}正在检查依赖...${NC}"
    
    local dependencies=("bc" "curl" "jq")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo -e "${YELLOW}正在安装依赖: ${dep}${NC}"
            if command -v apt-get &> /dev/null; then
                apt-get update && apt-get install -y "$dep"
            elif command -v yum &> /dev/null; then
                yum install -y "$dep"
            else
                echo -e "${RED}错误: 无法安装依赖${NC}"
                exit 1
            fi
        fi
    done
}

# 主函数
main() {
    echo -e "${GREEN}开始安装VPS监控系统${NC}"
    
    # 检查root权限
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}错误: 此脚本必须以root用户运行${NC}"
        exit 1
    fi
    
    # 检查依赖
    check_dependencies
    
    # 安装主程序
    install_binary
    
    # 安装服务
    install_service
    
    # 初始化配置
    init_config
    
    echo -e "${GREEN}安装完成！${NC}"
    echo -e "使用 ${YELLOW}vpsm${NC} 命令来管理监控系统"
    echo -e "使用 ${YELLOW}systemctl start vps-monitor${NC} 来启动服务"
}

# 执行主函数
main "$@" 