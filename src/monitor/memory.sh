#!/usr/bin/env bash

# 内存监控模块

# 获取内存使用率
get_memory_usage() {
    local mem_info
    local total
    local used
    local usage
    
    mem_info=$(free)
    total=$(echo "$mem_info" | awk '/Mem:/ {print $2}')
    used=$(echo "$mem_info" | awk '/Mem:/ {print $3}')
    
    usage=$(echo "scale=2; $used * 100 / $total" | bc)
    printf "%.2f" "$usage"
}

# 获取详细内存信息
get_memory_info() {
    local mem_info
    mem_info=$(free -h)
    echo "$mem_info"
}

# 获取交换分区使用情况
get_swap_usage() {
    local swap_info
    local total
    local used
    local usage
    
    swap_info=$(free)
    total=$(echo "$swap_info" | awk '/Swap:/ {print $2}')
    used=$(echo "$swap_info" | awk '/Swap:/ {print $3}')
    
    if [ "$total" -eq 0 ]; then
        echo "0.00"
    else
        usage=$(echo "scale=2; $used * 100 / $total" | bc)
        printf "%.2f" "$usage"
    fi
}

# 检查内存使用率是否超过阈值
check_memory_threshold() {
    local threshold="$1"
    local current_usage
    current_usage=$(get_memory_usage)
    
    if (( $(echo "$current_usage > $threshold" | bc -l) )); then
        return 0  # 超过阈值
    else
        return 1  # 未超过阈值
    fi
} 