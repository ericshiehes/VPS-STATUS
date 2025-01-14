# 项目结构说明

VPS-STATUS/
├── src/                      # 源代码目录
│   ├── monitor/             # 监控模块
│   │   ├── cpu.sh          # CPU监控
│   │   ├── memory.sh       # 内存监控
│   │   ├── disk.sh         # 磁盘监控
│   │   ├── network.sh      # 网络监控
│   │   └── ssh.sh          # SSH监控
│   ├── notify/             # 通知模块
│   │   └── telegram.sh     # Telegram通知
│   ├── utils/              # 工具模块
│   │   ├── config.sh       # 配置管理
│   │   └── logger.sh       # 日志管理
│   └── vpsm                # 主程序
├── docs/                    # 文档目录
│   ├── installation.md     # 安装指南
│   ├── configuration.md    # 配置指南
│   ├── usage.md           # 使用教程
│   ├── faq.md            # 常见问题
│   └── troubleshooting.md # 故障排除
├── install.sh             # 安装脚本
├── README.md             # 中文说明
├── README_EN.md          # 英文说明
├── CHANGELOG.md         # 更新日志
├── CONTRIBUTING.md      # 贡献指南
├── LICENSE              # 许可证
└── SECURITY.md         # 安全策略 