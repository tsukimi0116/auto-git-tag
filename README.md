# Auto Git Tag 🏷️

> 自動化 Git Tag 創建工具，讓版本標籤管理變得簡單快速！

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js Version](https://img.shields.io/badge/node-%3E%3D12.0.0-brightgreen)](https://nodejs.org/)

## 🎯 解決什麼問題？

每次要建立 Git tag 都要經歷繁瑣的流程：
1. 查看 package.json 版本號 📋
2. 從分支名稱找出票號 🎫
3. 檢查已有幾個相關 tag 🔍
4. 手動組合 tag 名稱 ✍️
5. 建立並推送 tag 🚀

現在一個命令就搞定！ ⚡

## ✨ 主要功能

- 🚀 **一鍵執行** - 自動完成整個 tag 創建流程
- 📦 **智能解析** - 自動從 `package.json` 讀取版本號
- 🎫 **票號提取** - 自動從分支名稱提取票號 (`feature/OFC-1234` → `1234`)
- 🔢 **版本計算** - 自動計算 QA 版本號，避免重複
- ✅ **安全預覽** - 操作前顯示預覽並要求確認
- 🌈 **美觀輸出** - 彩色介面和清楚的步驟說明
- 🔧 **跨專案使用** - 安裝一次，到處可用

## 📋 Tag 格式

**格式模板：** `{package.version}-{ticketNumber}.{qaVersion}`

### 範例說明：

| 項目 | 值 | 說明 |
|------|----|----|
| Package Version | `6.30.0-fc` | 從 package.json 讀取 |
| 分支名稱 | `feature/OFC-3361` | 當前 Git 分支 |
| 票號 | `3361` | 自動提取數字部分 |
| QA 版本 | `0` | 自動計算（第一次為 0） |
| **最終 Tag** | **`6.30.0-fc-3361.0`** | 自動組合生成 |

## 🚀 快速安裝

### 方式一：一鍵安裝（推薦）⭐

```bash
curl -fsSL https://raw.githubusercontent.com/tsukimi0116/auto-git-tag/main/install.sh | bash
```

### 方式二：本地安裝

```bash
# 1. 下載專案
git clone https://github.com/tsukimi0116/auto-git-tag.git
cd auto-git-tag

# 2. 執行安裝
./install.sh
```

### 方式三：手動安裝

<details>
<summary>點擊展開手動安裝步驟</summary>

```bash
# 1. 創建目錄
mkdir -p ~/.local/bin

# 2. 下載腳本
curl -fsSL https://raw.githubusercontent.com/tsukimi0116/auto-git-tag/main/auto-git-tag.js \
  -o ~/.local/bin/auto-git-tag.js

# 3. 設定權限
chmod +x ~/.local/bin/auto-git-tag.js

# 4. 設定別名（選擇你的 Shell）
# For Zsh users:
echo "alias gtag='node ~/.local/bin/auto-git-tag.js'" >> ~/.zshrc
source ~/.zshrc

# For Bash users:
echo "alias gtag='node ~/.local/bin/auto-git-tag.js'" >> ~/.bashrc
source ~/.bashrc
```

</details>

## 📖 使用方法

### 基本使用

1. **進入你的專案目錄**
   ```bash
   cd your-project
   ```

2. **確保分支名稱包含票號**
   ```bash
   # ✅ 支援的分支格式：
   feature/OFC-1234
   bugfix/ABC-567
   hotfix/PROJ-890
   OFC-1234
   ```

3. **執行命令**
   ```bash
   gtag
   ```

就這麼簡單！ 🎉

### 實際使用範例

```bash
$ gtag

🏷️  自動化 Git Tag 工具
=================================
📦 Package Version: 6.30.0-fc
🌿 當前分支: feature/OFC-3361
🎫 Ticket Number: OFC-3361 (使用: 3361)
📊 目前分支已有 0 個相關 tag
🔢 QA Version: 0
🏷️  即將創建 tag: 6.30.0-fc-3361.0

是否繼續創建並推送此 tag? (y/N): y

📝 創建 git tag...
✅ Tag 創建成功: 6.30.0-fc-3361.0
🚀 推送 tag 到 origin...
🎉 Tag 推送成功!
✨ 完成! Tag '6.30.0-fc-3361.0' 已成功創建並推送

=================================
📋 摘要:
   Package Version: 6.30.0-fc
   Ticket Number: 3361
   QA Version: 0
   Created Tag: 6.30.0-fc-3361.0
=================================
```

## ⚙️ 系統需求

| 需求 | 版本 | 說明 |
|------|------|------|
| **Node.js** | >= 12.0.0 | 用於執行 JavaScript |
| **Git** | 任何版本 | 版本控制工具 |
| **Shell** | Bash/Zsh | 用於設定別名 |
| **專案需求** | package.json | 必須包含 `version` 欄位 |

## 🔧 支援的分支格式

| 分支名稱範例 | 提取結果 | 說明 |
|-------------|----------|------|
| `feature/OFC-1234` | `1234` | 標準格式 |
| `bugfix/ABC-567` | `567` | Bug 修復分支 |
| `hotfix/PROJ-890` | `890` | 緊急修復 |
| `OFC-1234` | `1234` | 簡化格式 |
| `feature/1234-new-feature` | `1234` | 數字開頭 |

如果無法自動提取，工具會提示手動輸入票號。

## 🛠️ 故障排除

### ❌ 常見問題

<details>
<summary><strong>找不到 gtag 命令</strong></summary>

```bash
# 檢查別名是否設定
alias | grep gtag

# 如果沒有，重新載入設定
source ~/.zshrc    # Zsh 用戶
source ~/.bashrc   # Bash 用戶

# 或重新開啟終端機
```

</details>

<details>
<summary><strong>權限被拒絕</strong></summary>

```bash
# 確認腳本有執行權限
chmod +x ~/.local/bin/auto-git-tag.js

# 檢查檔案是否存在
ls -la ~/.local/bin/auto-git-tag.js
```

</details>

<details>
<summary><strong>Node.js 版本過舊</strong></summary>

```bash
# 檢查版本
node --version

# 如果低於 v12，請更新 Node.js
# 訪問: https://nodejs.org/
```

</details>

<details>
<summary><strong>找不到 package.json</strong></summary>

```bash
# 確認在正確目錄
pwd
ls -la package.json

# 確認 package.json 包含 version 欄位
cat package.json | grep version
```

</details>

<details>
<summary><strong>Git 推送失敗</strong></summary>

```bash
# 檢查 Git 遠端設定
git remote -v

# 檢查是否有推送權限
git push origin main  # 測試推送權限
```

</details>

## 🔄 更新工具

```bash
# 重新執行安裝腳本即可更新
curl -fsSL https://raw.githubusercontent.com/tsukimi0116/auto-git-tag/main/install.sh | bash
```

## 🗑️ 解除安裝

```bash
# 1. 刪除腳本檔案
rm ~/.local/bin/auto-git-tag.js

# 2. 移除別名 (編輯你的 shell 設定檔)
nano ~/.zshrc    # 或 ~/.bashrc
# 刪除包含 "alias gtag=" 的行

# 3. 重新載入設定
source ~/.zshrc  # 或 ~/.bashrc
```

## 🎨 客製化

### 修改別名名稱

如果想要使用不同的命令名稱：

```bash
# 編輯 shell 設定檔
nano ~/.zshrc

# 修改別名
alias my-tag='node ~/.local/bin/auto-git-tag.js'

# 重新載入
source ~/.zshrc
```

### 修改 Tag 格式

要修改 tag 格式，請編輯腳本中的相關邏輯：

```javascript
// 在 auto-git-tag.js 中找到這一行
const fullTag = `${baseVersion}-${ticketNumberOnly}.${qaVersion}`;

// 修改成你想要的格式
const fullTag = `${baseVersion}-${ticketNumberOnly}-v${qaVersion}`;
```

## 🤝 貢獻指南

歡迎提交 Issue 和 Pull Request！

### 開發流程

1. **Fork 專案**
2. **創建功能分支**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **提交修改**
   ```bash
   git commit -m 'Add some amazing feature'
   ```
4. **推送分支**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **開啟 Pull Request**

### 報告問題

發現 Bug 或有功能建議？請[開啟 Issue](https://github.com/tsukimi0116/auto-git-tag/issues)

## 📄 開源許可

MIT License - 詳見 [LICENSE](LICENSE) 檔案

## 🌟 支持專案

如果這個工具對你有幫助：

- ⭐ 給專案一個 Star
- 🐛 報告 Bug 或建議功能
- 📢 分享給你的朋友
- 🤝 貢獻程式碼

## 📞 聯絡資訊

- 作者：[Your Name]
- 問題回報：[GitHub Issues](https://github.com/tsukimi0116/auto-git-tag/issues)
- 電子郵件：your.email@example.com

---

<div align="center">

**讓版本管理變得更輕鬆！** 🚀

Made with ❤️ by developers, for developers

</div>