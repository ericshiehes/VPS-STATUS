#!/bin/bash

source /usr/local/vps-monitor/src/utils.sh
source /usr/local/vps-monitor/src/telegram.sh

# 获取系统信息
get_system_info() {
    OS_VERSION=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d'"' -f2)
    KERNEL=$(uname -r)
    ARCH=$(uname -m)
    HOSTNAME=$(hostname)
}

# 获取CPU信息
get_cpu_info() {
    CPU_MODEL=$(cat /proc/cpuinfo | grep "model name" | head -n1 | cut -d':' -f2 | xargs)
    CPU_CORES=$(nproc)
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%
}

# 获取内存信息
get_memory_info() {
    TOTAL_MEM=$(free -m | awk '/Mem:/ {print $2}')
    USED_MEM=$(free -m | awk '/Mem:/ {print $3}')
    FREE_MEM=$(free -m | awk '/Mem:/ {print $4}')
    MEM_USAGE=$(echo "scale=2; $USED_MEM*100/$TOTAL_MEM" | bc)%
    
    SWAP_TOTAL=$(free -m | awk '/Swap:/ {print $2}')
    SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')
    SWAP_FREE=$(free -m | awk '/Swap:/ {print $4}')
}

# 获取磁盘信息
get_disk_info() {
    DISK_INFO=$(df -h | grep '^/dev/' | awk '{print $1 " " $2 " " $3 " " $4 " " $5}')
}

# 获取网络流量信息
get_network_info() {
    # 获取所有网络接口的流量
    INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -v "lo")
    NETWORK_INFO=""
    
    for interface in $INTERFACES; do
        RX_BYTES=$(cat /sys/class/net/$interface/statistics/rx_bytes)
        TX_BYTES=$(cat /sys/class/net/$interface/statistics/tx_bytes)
        
        # 转换为可读格式
        RX_HUMAN=$(numfmt --to=iec-i --suffix=B $RX_BYTES)
        TX_HUMAN=$(numfmt --to=iec-i --suffix=B $TX_BYTES)
        
        NETWORK_INFO+="$interface: ↓$RX_HUMAN ↑$TX_HUMAN\n"
    done
}

# 监控SSH登录
monitor_ssh() {
    LAST_SSH_LOG=$(tail -n1 /var/log/auth.log 2>/dev/null || tail -n1 /var/log/secure)
    if echo "$LAST_SSH_LOG" | grep -q "Accepted"; then
        USER=$(echo "$LAST_SSH_LOG" | grep -oP '(?<=for )\w+')
        IP=$(echo "$LAST_SSH_LOG" | grep -oP '(?<=from )[0-9.]+')
        send_telegram_alert "SSH登录提醒\n用户: $USER\nIP: $IP\n时间: $(date '+%Y-%m-%d %H:%M:%S')"
    fi
}

# 生成状态报告
generate_report() {
    get_system_info
    get_cpu_info
    get_memory_info
    get_disk_info
    get_network_info
    
    REPORT="VPS状态报告\n"
    REPORT+="------------------------\n"
    REPORT+="系统信息:\n"
    REPORT+="系统版本: $OS_VERSION\n"
    REPORT+="内核版本: $KERNEL\n"
    REPORT+="主机名: $HOSTNAME\n\n"
    
    REPORT+="CPU信息:\n"
    REPORT+="型号: $CPU_MODEL\n"
    REPORT+="核心数: $CPU_CORES\n"
    REPORT+="使用率: $CPU_USAGE\n\n"
    
    REPORT+="内存信息:\n"
    REPORT+="总内存: ${TOTAL_MEM}MB\n"
    REPORT+="已用: ${USED_MEM}MB\n"
    REPORT+="剩余: ${FREE_MEM}MB\n"
    REPORT+="使用率: $MEM_USAGE\n\n"
    
    REPORT+="磁盘信息:\n$DISK_INFO\n\n"
    REPORT+="网络信息:\n$NETWORK_INFO"
    
    echo -e "$REPORT"
}

# 主循环
main() {
    while true; do
        # 检查是否需要发送定时报告
        current_time=$(date +%H:%M)
        if [ "$current_time" = "$(get_config NOTIFICATION_TIME)" ]; then
            report=$(generate_report)
            send_telegram_message "$report"
        fi
        
        # 监控SSH登录
        monitor_ssh
        
        # 每分钟检查一次
        sleep 60
    done
}

main 