# VPS监控系统

一个支持多种Linux发行版的VPS状态监控程序，支持Telegram通知，可监控系统资源、流量使用和SSH登录等信息。

## 功能特点

- 支持多种Linux发行版（CentOS、Ubuntu、Debian等）
- Telegram机器人通知
- 系统资源监控（CPU、内存、磁盘）
- 网络流量统计和限制提醒
- SSH登录监控和实时通知
- 自动检查更新
- 一键安装/卸载

## 系统要求

- Linux操作系统（支持CentOS 7+、Ubuntu 16.04+、Debian 9+）
- systemd支持
- root权限
- curl或wget

## 快速安装

使用以下命令一键安装：
bash

curl -fsSL https://raw.githubusercontent.com/ericshiehes/VPS-STATUS/main/online_install.sh | sudo bash


或者：
bash

wget -O- https://raw.githubusercontent.com/ericshiehes/VPS-STATUS/main/online_install.sh | sudo bash



## 使用方法

安装完成后，使用`vpsm`命令来操作程序：

bash
显示监控面板
vpsm
查看帮助信息
vpsm help
测试Telegram通知
vpsm test
启动监控服务
sudo vpsm start
停止监控服务
sudo vpsm stop
重启监控服务
sudo vpsm restart
检查更新
sudo vpsm update
卸载程序
sudo vpsm uninstall


## 配置说明

首次运行时需要配置以下内容：

1. Telegram配置
   - Bot Token
   - Chat ID

2. VPS信息
   - 购买日期
   - 有效期（默认1年）
   - 续费状态

3. 监控设置
   - 通知时间（默认每天0点）
   - 月度流量限制
   - SSH登录通知

## 监控项目

- 系统信息
  - 操作系统版本
  - 内核版本
  - CPU信息和使用率
  - 内存使用情况
  - 磁盘使用情况
  
- 网络监控
  - 实时网络速度
  - 当月流量统计
  - 当日流量统计
  - 流量限制提醒
  
- 安全监控
  - SSH登录记录
  - 登录IP地址
  - 实时登录通知

## 通知内容

每日定时通知包含：
- 系统基本信息
- 资源使用情况
- 流量使用统计
- 剩余有效期

实时通知包含：
- SSH登录信息
- 流量超限警告

## 常见问题

1. 如何获取Telegram Bot Token？
   - 在Telegram中找到 @BotFather
   - 发送 /newbot 创建新机器人
   - 按提示设置机器人名称
   - 获取API Token

2. 如何获取Chat ID？
   - 在Telegram中找到 @userinfobot
   - 发送任意消息
   - 获取返回的ID

3. 找不到vpsm命令？
   - 确认安装是否成功
   - 尝试重新运行安装脚本

## 问题反馈

如有问题，请在GitHub Issues中反馈：
- 描述遇到的问题
- 提供系统信息
- 提供错误日志

## 开源协议

MIT License

## 更新日志

### v1.0.0
- 初始版本发布
- 基本监控功能
- Telegram通知支持