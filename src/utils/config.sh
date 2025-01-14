#!/usr/bin/env bash

# 配置管理模块

# 默认配置文件路径
CONFIG_FILE="/etc/vps-monitor/config.conf"
CONFIG_DIR="/etc/vps-monitor"

# 默认配置
declare -A DEFAULT_CONFIG=(
    ["TELEGRAM_BOT_TOKEN"]=""
    ["TELEGRAM_CHAT_ID"]=""
    ["CHECK_INTERVAL"]="300"
    ["CPU_THRESHOLD"]="80"
    ["MEMORY_THRESHOLD"]="80"
    ["DISK_THRESHOLD"]="80"
    ["TRAFFIC_LIMIT"]="1000"
    ["NOTIFICATION_TIME"]="00:00"
    ["MONITOR_NETWORK"]="true"
    ["MONITOR_SSH"]="true"
    ["LOG_LEVEL"]="info"
)

# 初始化配置目录和文件
init_config() {
    # 创建配置目录
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
    fi
    
    # 如果配置文件不存在，创建默认配置
    if [[ ! -f "$CONFIG_FILE" ]]; then
        for key in "${!DEFAULT_CONFIG[@]}"; do
            echo "${key}=${DEFAULT_CONFIG[$key]}" >> "$CONFIG_FILE"
        done
        chmod 600 "$CONFIG_FILE"
    fi
}

# 读取配置
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "配置文件不存在"
        return 1
    fi
    
    # 加载配置文件
    while IFS='=' read -r key value; do
        if [[ ! "$key" =~ ^[[:space:]]*# && -n "$key" ]]; then
            declare -g "$key"="$value"
        fi
    done < "$CONFIG_FILE"
}

# 更新配置
update_config() {
    local key="$1"
    local value="$2"
    
    if [[ -z "$key" ]]; then
        echo "配置键不能为空"
        return 1
    fi
    
    # 检查是否是有效的配置项
    if [[ -z "${DEFAULT_CONFIG[$key]}" ]]; then
        echo "无效的配置项: $key"
        return 1
    fi
    
    # 更新配置文件
    if grep -q "^${key}=" "$CONFIG_FILE"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$CONFIG_FILE"
    else
        echo "${key}=${value}" >> "$CONFIG_FILE"
    fi
    
    # 重新加载配置
    load_config
}

# 验证配置
validate_config() {
    local missing_keys=()
    
    for key in "${!DEFAULT_CONFIG[@]}"; do
        if [[ -z "${!key}" ]]; then
            missing_keys+=("$key")
        fi
    done
    
    if [[ ${#missing_keys[@]} -gt 0 ]]; then
        echo "缺少必要的配置项："
        printf '%s\n' "${missing_keys[@]}"
        return 1
    fi
    
    return 0
}

# 初始化配置
init_config
# 加载配置
load_config 