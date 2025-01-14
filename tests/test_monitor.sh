#!/usr/bin/env bash

# 设置严格模式
set -euo pipefail

# 导入被测试的脚本
source "../src/monitor/cpu.sh"
source "../src/monitor/memory.sh"
source "../src/monitor/disk.sh"
source "../src/monitor/network.sh"
source "../src/monitor/ssh.sh"

# 测试CPU监控
test_cpu_monitor() {
    local result
    result=$(get_cpu_usage)
    [[ $result =~ ^[0-9]+(\.[0-9]+)?$ ]] || return 1
}

# 测试内存监控
test_memory_monitor() {
    local result
    result=$(get_memory_usage)
    [[ $result =~ ^[0-9]+(\.[0-9]+)?$ ]] || return 1
}

# 测试磁盘监控
test_disk_monitor() {
    local result
    result=$(get_disk_usage)
    [[ $result =~ ^[0-9]+(\.[0-9]+)?$ ]] || return 1
}

# 运行所有测试
run_tests() {
    local failed=0
    
    echo "运行测试..."
    
    if test_cpu_monitor; then
        echo "CPU监控测试通过"
    else
        echo "CPU监控测试失败"
        failed=$((failed + 1))
    fi
    
    if test_memory_monitor; then
        echo "内存监控测试通过"
    else
        echo "内存监控测试失败"
        failed=$((failed + 1))
    fi
    
    if test_disk_monitor; then
        echo "磁盘监控测试通过"
    else
        echo "磁盘监控测试失败"
        failed=$((failed + 1))
    fi
    
    echo "测试完成。失败: $failed"
    return $failed
}

# 执行测试
run_tests 