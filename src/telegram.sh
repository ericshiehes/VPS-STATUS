#!/bin/bash

source /usr/local/vps-monitor/src/utils.sh

# 发送Telegram消息
send_telegram_message() {
    local message="$1"
    local bot_token=$(get_config TELEGRAM_BOT_TOKEN)
    local chat_id=$(get_config TELEGRAM_CHAT_ID)
    
    if [ -z "$bot_token" ] || [ -z "$chat_id" ]; then
        echo "错误: Telegram配置不完整"
        return 1
    fi
    
    curl -s -X POST \
        "https://api.telegram.org/bot${bot_token}/sendMessage" \
        -d "chat_id=${chat_id}" \
        -d "text=${message}" \
        -d "parse_mode=HTML" \
        > /dev/null
}

# 发送告警消息
send_telegram_alert() {
    local message="$1"
    local alert_message="🚨 警告\n\n${message}"
    send_telegram_message "$alert_message"
}

# 测试Telegram配置
test_telegram_config() {
    local test_message="✅ VPS监控系统测试消息\n\n如果您收到这条消息，说明Telegram配置正确！"
    if send_telegram_message "$test_message"; then
        echo "测试消息发送成功！"
        return 0
    else
        echo "测试消息发送失败！"
        return 1
    fi
}

# 发送流量警告
send_traffic_alert() {
    local used_traffic=$1
    local limit_traffic=$2
    local alert_message="⚠️ 流量警告\n\n"
    alert_message+="当前已使用流量: $(format_traffic $used_traffic)\n"
    alert_message+="月度流量限制: $(format_traffic $limit_traffic)\n"
    alert_message+="请注意控制使用！"
    
    send_telegram_alert "$alert_message"
}

# 发送SSH登录通知
send_ssh_alert() {
    local user=$1
    local ip=$2
    local time=$3
    local alert_message="🔐 SSH登录提醒\n\n"
    alert_message+="用户: $user\n"
    alert_message+="IP地址: $ip\n"
    alert_message+="时间: $time\n"
    
    send_telegram_alert "$alert_message"
} 