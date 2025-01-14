#!/usr/bin/env bash

# CPU监控模块

# 获取CPU使用率
get_cpu_usage() {
    local cpu_usage
    
    # 使用top命令获取CPU使用率
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | \
                sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
                awk '{print 100 - $1}')
    
    printf "%.2f" "$cpu_usage"
}

# 获取CPU负载
get_cpu_load() {
    local load_average
    load_average=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    echo "$load_average"
}

# 获取CPU详细信息
get_cpu_info() {
    local cpu_info
    cpu_info=$(lscpu | grep -E "^(Model name|CPU\(s\)|Thread|Core|Socket)")
    echo "$cpu_info"
}

# 检查CPU使用率是否超过阈值
check_cpu_threshold() {
    local threshold="$1"
    local current_usage
    current_usage=$(get_cpu_usage)
    
    if (( $(echo "$current_usage > $threshold" | bc -l) )); then
        return 0  # 超过阈值
    else
        return 1  # 未超过阈值
    fi
} 