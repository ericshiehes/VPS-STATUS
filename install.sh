#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 检查root权限
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}请使用root权限运行此脚本${NC}"
   exit 1
fi

# 检测系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
fi

# 安装依赖
install_dependencies() {
    echo "正在检查并安装依赖..."
    
    case $OS in
        "Ubuntu"|"Debian")
            apt-get update
            apt-get install -y curl jq bc wget net-tools
            ;;
        "CentOS Linux"|"CentOS")
            yum -y update
            yum -y install curl jq bc wget net-tools
            ;;
        *)
            echo -e "${RED}不支持的操作系统${NC}"
            exit 1
            ;;
    esac
}

# 创建程序目录
create_directories() {
    mkdir -p /usr/local/vps-monitor
    mkdir -p /usr/local/vps-monitor/config
}

# 下载程序文件
download_files() {
    echo "正在下载程序文件..."
    # 这里替换为实际的GitHub仓库地址
    REPO="your_username/vps-monitor"
    wget -O /usr/local/vps-monitor/monitor.sh https://raw.githubusercontent.com/$REPO/main/src/monitor.sh
    wget -O /usr/local/vps-monitor/config.sh https://raw.githubusercontent.com/$REPO/main/src/config.sh
    # ... 下载其他文件
}

# 设置权限
set_permissions() {
    chmod +x /usr/local/vps-monitor/*.sh
    chmod 644 /usr/local/vps-monitor/config/*
}

# 创建快捷命令
create_command() {
    echo "创建命令 'vpsm'..."
    cp /usr/local/vps-monitor/bin/vpsm /usr/local/bin/vpsm
    chmod +x /usr/local/bin/vpsm
}

# 设置开机自启
setup_autostart() {
    echo "设置开机自启..."
    cat > /etc/systemd/system/vps-monitor.service << EOF
[Unit]
Description=VPS Monitor Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/vps-monitor/monitor.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable vps-monitor
    systemctl start vps-monitor
}

# 主安装流程
main() {
    echo "开始安装 VPS Monitor..."
    install_dependencies
    create_directories
    download_files
    set_permissions
    create_command
    setup_autostart
    
    echo -e "${GREEN}安装完成！请运行 'status' 命令进行配置。${NC}"
}

main 