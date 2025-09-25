#!/bin/bash

# Auto Git Tag 工具安裝腳本
# 使用方法: curl -fsSL https://raw.githubusercontent.com/your-username/auto-git-tag/main/install.sh | bash

set -e

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}${BOLD}"
    echo "╔══════════════════════════════════════╗"
    echo "║         Auto Git Tag 安裝工具        ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

log() {
    echo -e "${GREEN}✅ $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 檢查依賴
check_dependencies() {
    info "檢查系統依賴..."
    
    # 檢查 Node.js
    if ! command -v node &> /dev/null; then
        error "需要 Node.js 才能運行此工具。請先安裝 Node.js: https://nodejs.org/"
    fi
    
    # 檢查 Git
    if ! command -v git &> /dev/null; then
        error "需要 Git 才能運行此工具。請先安裝 Git。"
    fi
    
    log "依賴檢查通過"
}

# 偵測 Shell
detect_shell() {
    # 優先檢查當前 Shell 環境
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_TYPE="zsh"
        RC_FILE="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_TYPE="bash"
        RC_FILE="$HOME/.bashrc"
    else
        # 從 $SHELL 環境變數判斷
        case "$SHELL" in
            */zsh)
                SHELL_TYPE="zsh"
                RC_FILE="$HOME/.zshrc"
                ;;
            */bash)
                SHELL_TYPE="bash" 
                RC_FILE="$HOME/.bashrc"
                ;;
            *)
                # 檢查哪個設定檔存在或更常用
                if [ -f "$HOME/.zshrc" ] && command -v zsh >/dev/null 2>&1; then
                    SHELL_TYPE="zsh"
                    RC_FILE="$HOME/.zshrc"
                    warn "無法確定 Shell 類型，但偵測到 zsh，使用 .zshrc"
                else
                    SHELL_TYPE="bash"
                    RC_FILE="$HOME/.bashrc"
                    warn "無法確定 Shell 類型，預設使用 bash"
                fi
                ;;
        esac
    fi
    
    info "偵測到 Shell: $SHELL_TYPE"
    info "設定檔: $RC_FILE"
}

# 下載腳本
download_script() {
    info "下載 Auto Git Tag 腳本..."
    
    # 創建目錄
    mkdir -p "$HOME/.local/bin"
    
    # 下載腳本 
    SCRIPT_URL="https://raw.githubusercontent.com/tsukimi0116/auto-git-tag/main/auto-git-tag.js"
    SCRIPT_PATH="$HOME/.local/bin/auto-git-tag.js"
    
    # 如果是本地安裝，從當前目錄複製
    if [ -f "./auto-git-tag.js" ]; then
        info "從本地複製腳本檔案..."
        cp "./auto-git-tag.js" "$SCRIPT_PATH"
    else
        info "從網路下載腳本檔案..."
        if command -v curl &> /dev/null; then
            curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH"
        elif command -v wget &> /dev/null; then
            wget -q "$SCRIPT_URL" -O "$SCRIPT_PATH"
        else
            error "需要 curl 或 wget 來下載檔案"
        fi
    fi
    
    # 設定執行權限
    chmod +x "$SCRIPT_PATH"
    
    log "腳本下載完成: $SCRIPT_PATH"
}

# 設定別名
setup_alias() {
    info "設定命令別名..."
    
    ALIAS_LINE="alias gtag='node ~/.local/bin/auto-git-tag.js'"
    
    # 同時設定 bash 和 zsh，確保覆蓋率
    local files_updated=0
    
    # 設定 zsh
    if [ -f "$HOME/.zshrc" ] || command -v zsh >/dev/null 2>&1; then
        if ! grep -q "alias gtag=" "$HOME/.zshrc" 2>/dev/null; then
            echo "" >> "$HOME/.zshrc"
            echo "# Auto Git Tag alias" >> "$HOME/.zshrc"
            echo "$ALIAS_LINE" >> "$HOME/.zshrc"
            info "已設定 zsh 別名 (~/.zshrc)"
            files_updated=$((files_updated + 1))
        else
            warn "zsh 別名已存在，跳過"
        fi
    fi
    
    # 設定 bash
    if [ -f "$HOME/.bashrc" ] || command -v bash >/dev/null 2>&1; then
        if ! grep -q "alias gtag=" "$HOME/.bashrc" 2>/dev/null; then
            echo "" >> "$HOME/.bashrc"
            echo "# Auto Git Tag alias" >> "$HOME/.bashrc" 
            echo "$ALIAS_LINE" >> "$HOME/.bashrc"
            info "已設定 bash 別名 (~/.bashrc)"
            files_updated=$((files_updated + 1))
        else
            warn "bash 別名已存在，跳過"
        fi
    fi
    
    # 也嘗試設定 .profile 作為備用
    if ! grep -q "alias gtag=" "$HOME/.profile" 2>/dev/null; then
        echo "" >> "$HOME/.profile"
        echo "# Auto Git Tag alias" >> "$HOME/.profile"
        echo "$ALIAS_LINE" >> "$HOME/.profile"
        info "已設定通用別名 (~/.profile)"
        files_updated=$((files_updated + 1))
    fi
    
    if [ $files_updated -gt 0 ]; then
        log "別名設定完成（更新了 $files_updated 個檔案）"
    else
        warn "所有設定檔中別名都已存在"
    fi
}

# 驗證安裝
verify_installation() {
    info "驗證安裝..."
    
    if [ ! -f "$HOME/.local/bin/auto-git-tag.js" ]; then
        error "腳本檔案不存在"
    fi
    
    if ! node "$HOME/.local/bin/auto-git-tag.js" --help 2>/dev/null; then
        warn "腳本執行測試失敗，但檔案已安裝"
    fi
    
    log "安裝驗證完成"
}

# 顯示使用說明
show_usage() {
    echo -e "${BLUE}${BOLD}"
    echo "╔══════════════════════════════════════╗"
    echo "║            安裝完成！                ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${GREEN}✨ Auto Git Tag 工具已成功安裝！${NC}"
    echo ""
    echo -e "${YELLOW}📋 使用方法：${NC}"
    echo "   1. 重新載入 Shell 設定："
    echo -e "      ${BLUE}# Zsh 用戶：${NC}"
    echo -e "      ${BLUE}source ~/.zshrc${NC}"
    echo -e "      ${BLUE}# Bash 用戶：${NC}" 
    echo -e "      ${BLUE}source ~/.bashrc${NC}"
    echo -e "      ${BLUE}# 或者：${NC}"
    echo -e "      ${BLUE}source ~/.profile${NC}"
    echo ""
    echo "   2. 或者重新開啟終端機"
    echo ""
    echo "   3. 在任何有 package.json 的 Git 專案中執行："
    echo -e "      ${BLUE}gtag${NC}"
    echo ""
    echo -e "${YELLOW}🔧 工具功能：${NC}"
    echo "   • 自動讀取 package.json 版本"
    echo "   • 自動提取分支票號"
    echo "   • 自動計算 QA 版本號"
    echo "   • 創建並推送 Git tag"
    echo ""
    echo -e "${YELLOW}📝 Tag 格式：${NC}"
    echo "   package.version-fc-ticketNumber.qaVersion"
    echo "   例如：6.30.0-fc-3361.0"
    echo ""
    echo -e "${GREEN}🎉 現在就可以開始使用了！${NC}"
}

# 主要安裝流程
main() {
    print_header
    
    echo -e "${BLUE}開始安裝 Auto Git Tag 工具...${NC}"
    echo ""
    
    
    check_dependencies
    download_script
    setup_alias
    verify_installation
    
    echo ""
    show_usage
}

# 執行主程式
main "$@"