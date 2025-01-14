#!/usr/bin/env bash

# 网络监控模块

# 获取实时网络速度
get_network_speed() {
    local interface="${1:-eth0}"
    local interval="${2:-1}"
    
    local rx1 tx1 rx2 tx2
    
    # 第一次读取
    read rx1 < "/sys/class/net/$interface/statistics/rx_bytes"
    read tx1 < "/sys/class/net/$interface/statistics/tx_bytes"
    
    sleep "$interval"
    
    # 第二次读取
    read rx2 < "/sys/class/net/$interface/statistics/rx_bytes"
    read tx2 < "/sys/class/net/$interface/statistics/tx_bytes"
    
    # 计算速度（KB/s）
    local rx_speed=$(( (rx2 - rx1) / 1024 / interval ))
    local tx_speed=$(( (tx2 - tx1) / 1024 / interval ))
    
    echo "下载速度: ${rx_speed} KB/s"
    echo "上传速度: ${tx_speed} KB/s"
}

# 获取总流量使用情况
get_total_traffic() {
    local interface="${1:-eth0}"
    local rx tx
    
    read rx < "/sys/class/net/$interface/statistics/rx_bytes"
    read tx < "/sys/class/net/$interface/statistics/tx_bytes"
    
    # 转换为GB
    local rx_gb=$(echo "scale=2; $rx / 1024 / 1024 / 1024" | bc)
    local tx_gb=$(echo "scale=2; $tx / 1024 / 1024 / 1024" | bc)
    
    echo "总下载流量: ${rx_gb} GB"
    echo "总上传流量: ${tx_gb} GB"
}

# 检查网络连接状态
check_network_status() {
    local host="${1:-8.8.8.8}"
    local timeout="${2:-5}"
    
    if ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1; then
        echo "网络连接正常"
        return 0
    else
        echo "网络连接异常"
        return 1
    fi
}

# 获取网络接口信息
get_network_interfaces() {
    local interfaces
    interfaces=$(ip -br link show | awk '{print $1}')
    echo "$interfaces"
}

# 检查流量是否超过限制
check_traffic_limit() {
    local interface="${1:-eth0}"
    local limit_gb="$2"
    local current_gb
    
    read rx < "/sys/class/net/$interface/statistics/rx_bytes"
    current_gb=$(echo "scale=2; $rx / 1024 / 1024 / 1024" | bc)
    
    if (( $(echo "$current_gb > $limit_gb" | bc -l) )); then
        return 0  # 超过限制
    else
        return 1  # 未超过限制
    fi
} 