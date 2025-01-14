#!/usr/bin/env bash

# 开发依赖安装脚本

# 设置错误处理
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查系统类型
check_system() {
    if command -v apt-get &> /dev/null; then
        echo "debian"
    elif command -v yum &> /dev/null; then
        echo "redhat"
    else
        echo "unknown"
    fi
}

# 安装依赖
install_dependencies() {
    local system
    system=$(check_system)
    
    echo -e "${GREEN}正在安装开发依赖...${NC}"
    
    case "$system" in
        debian)
            sudo apt-get update
            sudo apt-get install -y \
                shellcheck \
                bc \
                curl \
                jq \
                git \
                make
            ;;
        redhat)
            sudo yum install -y epel-release
            sudo yum install -y \
                shellcheck \
                bc \
                curl \
                jq \
                git \
                make
            ;;
        *)
            echo -e "${RED}不支持的系统类型${NC}"
            exit 1
            ;;
    esac
}

# 设置开发环境
setup_dev_env() {
    echo -e "${GREEN}正在设置开发环境...${NC}"
    
    # 创建开发配置
    mkdir -p .vscode
    cat > .vscode/settings.json << EOF
{
    "editor.insertSpaces": true,
    "editor.tabSize": 4,
    "files.eol": "\n",
    "files.trimTrailingWhitespace": true,
    "shellcheck.enable": true,
    "shellcheck.useWorkspaceRootAsCwd": true,
    "shellcheck.run": "onSave"
}
EOF
    
    # 创建编辑器配置
    cat > .editorconfig << EOF
root = true

[*]
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
charset = utf-8

[*.sh]
indent_style = space
indent_size = 4

[*.md]
trim_trailing_whitespace = false
EOF
}

# 主函数
main() {
    echo -e "${GREEN}开始设置开发环境...${NC}"
    
    # 安装依赖
    install_dependencies
    
    # 设置开发环境
    setup_dev_env
    
    echo -e "${GREEN}开发环境设置完成！${NC}"
}

# 执行主函数
main "$@" 