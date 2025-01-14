#!/bin/bash

CONFIG_FILE="/usr/local/vps-monitor/config/settings.conf"

# 初始化配置文件
init_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << EOF
TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""
VPS_PURCHASE_DATE=""
VPS_EXPIRE_DAYS="365"
VPS_RENEWED="false"
NOTIFICATION_TIME="00:00"
NOTIFICATION_FREQUENCY="daily"
MONTHLY_TRAFFIC_LIMIT=""
EOF
    fi
}

# 配置Telegram机器人
configure_telegram() {
    echo "请输入Telegram Bot Token:"
    read -p "> " bot_token
    if [ ! -z "$bot_token" ]; then
        sed -i "s/TELEGRAM_BOT_TOKEN=.*/TELEGRAM_BOT_TOKEN=\"$bot_token\"/" "$CONFIG_FILE"
    fi
    
    echo "请输入Telegram Chat ID:"
    read -p "> " chat_id
    if [ ! -z "$chat_id" ]; then
        sed -i "s/TELEGRAM_CHAT_ID=.*/TELEGRAM_CHAT_ID=\"$chat_id\"/" "$CONFIG_FILE"
    fi
}

# 设置VPS信息
configure_vps() {
    echo "请输入VPS购买日期 (YYYY-MM-DD):"
    read -p "> " purchase_date
    if [ ! -z "$purchase_date" ]; then
        sed -i "s/VPS_PURCHASE_DATE=.*/VPS_PURCHASE_DATE=\"$purchase_date\"/" "$CONFIG_FILE"
    fi
    
    echo "请输入VPS有效期（天数，默认365）:"
    read -p "> " expire_days
    if [ ! -z "$expire_days" ]; then
        sed -i "s/VPS_EXPIRE_DAYS=.*/VPS_EXPIRE_DAYS=\"$expire_days\"/" "$CONFIG_FILE"
    fi
}

# 主配置函数
main_config() {
    init_config
    configure_telegram
    configure_vps
    echo "配置完成！"
}

main_config 