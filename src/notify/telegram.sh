#!/usr/bin/env bash

# Telegram通知模块

# 加载配置
source "$(dirname "${BASH_SOURCE[0]}")/../utils/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils/logger.sh"

# 发送Telegram消息
send_telegram_message() {
    local message="$1"
    local parse_mode="${2:-HTML}"
    local disable_notification="${3:-false}"
    
    if [[ -z "$TELEGRAM_BOT_TOKEN" || -z "$TELEGRAM_CHAT_ID" ]]; then
        log_error "Telegram配置未设置"
        return 1
    }
    
    local response
    response=$(curl -s -X POST \
        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${message}" \
        -d "parse_mode=${parse_mode}" \
        -d "disable_notification=${disable_notification}")
    
    if echo "$response" | grep -q '"ok":true'; then
        log_info "Telegram消息发送成功"
        return 0
    else
        log_error "Telegram消息发送失败: $response"
        return 1
    fi
}

# 发送系统状态报告
send_status_report() {
    local cpu_usage memory_usage disk_usage
    cpu_usage=$(get_cpu_usage)
    memory_usage=$(get_memory_usage)
    disk_usage=$(get_disk_usage)
    
    local message
    message="<b>VPS状态报告</b>
    
📊 系统资源使用情况：
CPU: ${cpu_usage}%
内存: ${memory_usage}%
磁盘: ${disk_usage}%

🌐 网络状态：
$(get_network_speed)
$(get_total_traffic)

🔒 SSH连接：
当前连接数: $(get_ssh_connections)
"
    
    send_telegram_message "$message" "HTML"
}

# 发送警告消息
send_alert() {
    local alert_type="$1"
    local message="$2"
    
    local formatted_message="⚠️ <b>警告</b> ⚠️
类型: ${alert_type}
时间: $(date '+%Y-%m-%d %H:%M:%S')
    
${message}"
    
    send_telegram_message "$formatted_message" "HTML" "false"
}

# 测试Telegram配置
test_telegram_config() {
    local test_message="🔔 VPS监控系统测试消息
时间: $(date '+%Y-%m-%d %H:%M:%S')
配置测试成功！"
    
    if send_telegram_message "$test_message" "HTML"; then
        echo "Telegram配置测试成功"
        return 0
    else
        echo "Telegram配置测试失败"
        return 1
    fi
} 