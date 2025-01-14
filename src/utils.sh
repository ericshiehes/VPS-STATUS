#!/bin/bash

CONFIG_FILE="/usr/local/vps-monitor/config/settings.conf"

# 获取配置项
get_config() {
    local key=$1
    local value=$(grep "^${key}=" "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '"')
    echo "$value"
}

# 设置配置项
set_config() {
    local key=$1
    local value=$2
    sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$CONFIG_FILE"
}

# 检查更新
check_update() {
    # 这里替换为实际的GitHub仓库地址
    REPO="your_username/vps-monitor"
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    echo "$LATEST_VERSION"
}

# 更新程序
update_program() {
    local current_version="$VERSION"
    local latest_version=$(check_update)
    
    if [ "$current_version" = "$latest_version" ]; then
        echo "当前已是最新版本"
        return 0
    fi
    
    echo "发现新版本: $latest_version"
    echo "当前版本: $current_version"
    echo "是否更新？(y/n)"
    read -p "> " confirm
    
    if [ "$confirm" = "y" ]; then
        # 下载新版本文件
        REPO="your_username/vps-monitor"
        wget -O /tmp/vps-monitor.tar.gz "https://github.com/$REPO/archive/$latest_version.tar.gz"
        
        # 解压并更新文件
        cd /tmp
        tar xzf vps-monitor.tar.gz
        cp -rf vps-monitor-*/* /usr/local/vps-monitor/
        
        # 清理临时文件
        rm -rf /tmp/vps-monitor*
        
        # 重启服务
        systemctl restart vps-monitor
        
        echo "更新完成！"
        exit 0
    fi
}

# 格式化流量数值
format_traffic() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        echo "$(echo "scale=2; $bytes/1024" | bc)KB"
    elif [ $bytes -lt 1073741824 ]; then
        echo "$(echo "scale=2; $bytes/1048576" | bc)MB"
    else
        echo "$(echo "scale=2; $bytes/1073741824" | bc)GB"
    fi
}

# 获取当前月份流量统计
get_monthly_traffic() {
    local interface=$1
    local month=$(date +%Y%m)
    local traffic_file="/var/log/vps-monitor/traffic_${interface}_${month}.log"
    
    if [ -f "$traffic_file" ]; then
        cat "$traffic_file"
    else
        echo "0 0" # rx tx
    fi
}

# 记录流量数据
log_traffic() {
    local interface=$1
    local rx_bytes=$2
    local tx_bytes=$3
    local month=$(date +%Y%m)
    local traffic_dir="/var/log/vps-monitor"
    local traffic_file="${traffic_dir}/traffic_${interface}_${month}.log"
    
    mkdir -p "$traffic_dir"
    echo "$rx_bytes $tx_bytes" > "$traffic_file"
}

# 检查是否超出流量限制
check_traffic_limit() {
    local monthly_limit=$(get_config MONTHLY_TRAFFIC_LIMIT)
    if [ -z "$monthly_limit" ]; then
        return 0
    fi
    
    local total_bytes=0
    for interface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v "lo"); do
        read rx tx < <(get_monthly_traffic "$interface")
        total_bytes=$((total_bytes + rx + tx))
    done
    
    local limit_bytes=$((monthly_limit * 1024 * 1024 * 1024))
    if [ $total_bytes -gt $limit_bytes ]; then
        return 1
    fi
    return 0
} 