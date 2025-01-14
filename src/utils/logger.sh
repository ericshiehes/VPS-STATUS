#!/usr/bin/env bash

# 日志管理模块

# 日志级别
declare -A LOG_LEVELS=(
    ["debug"]=0
    ["info"]=1
    ["warn"]=2
    ["error"]=3
)

# 日志文件路径
LOG_FILE="/var/log/vps-monitor/monitor.log"
LOG_DIR="/var/log/vps-monitor"

# 初始化日志目录
init_logger() {
    if [[ ! -d "$LOG_DIR" ]]; then
        mkdir -p "$LOG_DIR"
    fi
    
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE"
        chmod 644 "$LOG_FILE"
    fi
}

# 日志轮转
rotate_logs() {
    local max_size=$((10 * 1024 * 1024)) # 10MB
    
    if [[ -f "$LOG_FILE" ]]; then
        local size
        size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE")
        
        if (( size > max_size )); then
            mv "$LOG_FILE" "${LOG_FILE}.1"
            touch "$LOG_FILE"
            chmod 644 "$LOG_FILE"
        fi
    fi
}

# 写入日志
_log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 检查日志级别
    if [[ -n "$LOG_LEVEL" && "${LOG_LEVELS[$level]}" -lt "${LOG_LEVELS[$LOG_LEVEL]}" ]]; then
        return
    fi
    
    # 格式化日志消息
    local log_message="[${timestamp}] [${level^^}] $message"
    
    # 写入日志文件
    echo "$log_message" >> "$LOG_FILE"
    
    # 如果是错误级别，同时输出到标准错误
    if [[ "$level" == "error" ]]; then
        echo "$log_message" >&2
    fi
    
    # 检查是否需要轮转日志
    rotate_logs
}

# 日志函数
log_debug() { _log "debug" "$1"; }
log_info() { _log "info" "$1"; }
log_warn() { _log "warn" "$1"; }
log_error() { _log "error" "$1"; }

# 清理旧日志
clean_old_logs() {
    local max_days=30
    find "$LOG_DIR" -name "*.log.*" -type f -mtime +"$max_days" -delete
}

# 获取日志内容
get_recent_logs() {
    local lines="${1:-50}"
    tail -n "$lines" "$LOG_FILE"
}

# 搜索日志
search_logs() {
    local pattern="$1"
    local context="${2:-0}"
    grep -A "$context" -B "$context" "$pattern" "$LOG_FILE"
}

# 初始化日志系统
init_logger 