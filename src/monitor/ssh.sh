#!/usr/bin/env bash

# SSH监控模块

# 获取当前SSH连接数
get_ssh_connections() {
    local connections
    connections=$(netstat -tn | grep :22 | grep ESTABLISHED | wc -l)
    echo "$connections"
}

# 获取SSH登录历史
get_ssh_login_history() {
    local lines="${1:-10}"
    local history
    history=$(last -n "$lines" | grep -v "reboot" | grep -v "^$")
    echo "$history"
}

# 获取失败的SSH登录尝试
get_failed_ssh_attempts() {
    local lines="${1:-10}"
    local attempts
    attempts=$(grep "Failed password" /var/log/auth.log | tail -n "$lines")
    echo "$attempts"
}

# 检查SSH配置安全性
check_ssh_security() {
    local issues=()
    
    # 检查root登录设置
    if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
        issues+=("允许root直接登录")
    fi
    
    # 检查密码认证设置
    if ! grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
        issues+=("未禁用密码认证")
    fi
    
    # 检查默认端口
    if ! grep -q "^Port" /etc/ssh/sshd_config || grep -q "^Port 22" /etc/ssh/sshd_config; then
        issues+=("使用默认22端口")
    fi
    
    if [ ${#issues[@]} -eq 0 ]; then
        echo "SSH配置安全"
        return 0
    else
        printf "发现安全问题：\n"
        printf '%s\n' "${issues[@]}"
        return 1
    fi
}

# 监控SSH登录事件
monitor_ssh_login() {
    local log_file="/var/log/auth.log"
    local last_position
    
    # 获取文件当前位置
    last_position=$(wc -l < "$log_file")
    
    while true; do
        local current_position
        current_position=$(wc -l < "$log_file")
        
        if [ "$current_position" -gt "$last_position" ]; then
            # 读取新的登录记录
            tail -n $((current_position - last_position)) "$log_file" | \
            grep "sshd.*Accepted" | while read -r line; do
                local user ip
                user=$(echo "$line" | grep -oP "for \K\w+")
                ip=$(echo "$line" | grep -oP "from \K[\d.]+")
                echo "检测到新的SSH登录：用户 $user 从 $ip"
            done
        fi
        
        last_position=$current_position
        sleep 1
    done
} 