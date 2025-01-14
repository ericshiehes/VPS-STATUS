#!/bin/bash

source /usr/local/vps-monitor/src/utils.sh
source /usr/local/vps-monitor/src/config.sh

VERSION="1.0.0"

show_menu() {
    clear
    echo "VPS监控系统 - 当前版本: $VERSION"
    echo "------------------------"
    echo "1. 测试Telegram通知"
    echo "2. 修改Telegram配置"
    echo "3. 修改VPS信息"
    echo "4. 设置通知时间"
    echo "5. 设置月流量限制"
    echo "6. 查看当前状态"
    echo "7. 一键更新"
    echo "8. 一键卸载"
    echo "0. 退出"
    echo "------------------------"
}

test_telegram() {
    send_telegram_message "这是一条测试消息"
    echo "测试消息已发送，请检查您的Telegram"
    read -p "按回车键继续..."
}

modify_notification_time() {
    echo "当前通知时间: $(get_config NOTIFICATION_TIME)"
    echo "请输入新的通知时间 (格式: HH:MM):"
    read -p "> " new_time
    if [ ! -z "$new_time" ]; then
        set_config NOTIFICATION_TIME "$new_time"
        echo "通知时间已更新"
    fi
    read -p "按回车键继续..."
}

set_traffic_limit() {
    echo "当前月流量限制: $(get_config MONTHLY_TRAFFIC_LIMIT)"
    echo "请输入新的月流量限制 (单位: GB):"
    read -p "> " new_limit
    if [ ! -z "$new_limit" ]; then
        set_config MONTHLY_TRAFFIC_LIMIT "$new_limit"
        echo "月流量限制已更新"
    fi
    read -p "按回车键继续..."
}

uninstall() {
    echo "确定要卸载VPS监控系统吗？(y/n)"
    read -p "> " confirm
    if [ "$confirm" = "y" ]; then
        systemctl stop vps-monitor
        systemctl disable vps-monitor
        rm -rf /usr/local/vps-monitor
        rm -f /usr/local/bin/status
        rm -f /etc/systemd/system/vps-monitor.service
        systemctl daemon-reload
        echo "卸载完成"
        exit 0
    fi
}

# 主循环
while true; do
    show_menu
    read -p "请选择操作 [0-8]: " choice
    
    case $choice in
        1) test_telegram ;;
        2) configure_telegram ;;
        3) configure_vps ;;
        4) modify_notification_time ;;
        5) set_traffic_limit ;;
        6) generate_report ;;
        7) update_program ;;
        8) uninstall ;;
        0) exit 0 ;;
        *) echo "无效选项" ;;
    esac
done 