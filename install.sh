#!/usr/bin/env bash

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

# 检查root权限
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}请使用root权限运行此脚本${NC}"
    exit 1
fi

# 安装依赖
install_dependencies() {
    echo -e "${GREEN}正在安装依赖...${NC}"
    
    if command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y curl jq bc wget net-tools
    elif command -v yum &> /dev/null; then
        yum -y update
        yum -y install curl jq bc wget net-tools
    else
        echo -e "${RED}不支持的操作系统${NC}"
        exit 1
    fi
}

# 创建目录结构
create_directories() {
    echo -e "${GREEN}创建目录结构...${NC}"
    
    mkdir -p "${INSTALL_DIR}/src/"{monitor,notify,utils}
    mkdir -p "/etc/vps-monitor"
    mkdir -p "/var/log/vps-monitor"
    
    # 设置权限
    chmod 755 "${INSTALL_DIR}"
    chmod 755 "${INSTALL_DIR}/src"
    chmod 755 "${INSTALL_DIR}/src/"{monitor,notify,utils}
}

# 复制文件
copy_files() {
    echo -e "${GREEN}复制程序文件...${NC}"
    
    # 复制主程序
    cp -f "${PWD}/src/vpsm" "${INSTALL_DIR}/src/"
    cp -f "${PWD}/src/monitor/"*.sh "${INSTALL_DIR}/src/monitor/"
    cp -f "${PWD}/src/notify/"*.sh "${INSTALL_DIR}/src/notify/"
    cp -f "${PWD}/src/utils/"*.sh "${INSTALL_DIR}/src/utils/"
    
    # 设置权限
    chmod +x "${INSTALL_DIR}/src/vpsm"
    chmod +x "${INSTALL_DIR}/src/monitor/"*.sh
    chmod +x "${INSTALL_DIR}/src/notify/"*.sh
    chmod +x "${INSTALL_DIR}/src/utils/"*.sh
}

# 创建命令链接
create_command() {
    echo -e "${GREEN}创建命令链接...${NC}"
    ln -sf "${INSTALL_DIR}/src/vpsm" "${BIN_DIR}/vpsm"
}

# 创建服务
create_service() {
    echo -e "${GREEN}创建系统服务...${NC}"
    
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
    
    systemctl daemon-reload
    systemctl enable vps-monitor.service
}

# 初始化配置
init_config() {
    echo -e "${GREEN}初始化配置...${NC}"
    
    if [[ ! -f "/etc/vps-monitor/config.conf" ]]; then
        cat > "/etc/vps-monitor/config.conf" << EOF
# Telegram配置
TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""

# 监控配置
CHECK_INTERVAL=300
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80
TRAFFIC_LIMIT=1000

# 日志配置
LOG_LEVEL=info
EOF
    fi
    
    chmod 600 "/etc/vps-monitor/config.conf"
}

# 主函数
main() {
    echo -e "${GREEN}开始安装VPS监控系统...${NC}"
    
    install_dependencies
    create_directories
    copy_files
    create_command
    create_service
    init_config
    
    echo -e "${GREEN}安装完成！${NC}"
    echo -e "使用 ${YELLOW}vpsm${NC} 命令来管理监控系统"
    echo -e "使用 ${YELLOW}vpsm help${NC} 查看帮助信息"
}

# 执行主函数
main "$@" 