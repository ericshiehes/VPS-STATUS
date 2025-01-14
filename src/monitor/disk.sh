#!/usr/bin/env bash

# 磁盘监控模块

# 获取磁盘使用率
get_disk_usage() {
    local disk_usage
    disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    echo "$disk_usage"
}

# 获取所有磁盘分区使用情况
get_all_disk_usage() {
    local disk_info
    disk_info=$(df -h | grep -v "tmpfs\|devtmpfs")
    echo "$disk_info"
}

# 获取磁盘IO状态
get_disk_io() {
    local io_stat
    io_stat=$(iostat -x 1 2 | awk 'END{print}')
    echo "$io_stat"
}

# 检查磁盘使用率是否超过阈值
check_disk_threshold() {
    local threshold="$1"
    local current_usage
    current_usage=$(get_disk_usage)
    
    if (( current_usage > threshold )); then
        return 0  # 超过阈值
    else
        return 1  # 未超过阈值
    fi
}

# 获取磁盘剩余空间
get_disk_free() {
    local free_space
    free_space=$(df -h / | awk 'NR==2 {print $4}')
    echo "$free_space"
} 