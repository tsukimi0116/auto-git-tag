#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const readline = require('readline');

// 顏色輸出
const colors = {
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  reset: '\x1b[0m'
};

const log = (message, color = 'reset') => {
  console.log(`${colors[color]}${message}${colors.reset}`);
};

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const question = (prompt) => {
  return new Promise((resolve) => {
    rl.question(prompt, resolve);
  });
};

async function main() {
  try {
    log('🏷️  自動化 Git Tag 工具', 'blue');
    log('=================================');

    // 1. 檢查是否在 Git 專案中
    if (!fs.existsSync('.git')) {
      log('❌ 錯誤: 請在 Git 專案根目錄執行此腳本', 'red');
      process.exit(1);
    }

    // 2. 檢查 package.json
    const packageJsonPath = path.join(process.cwd(), 'package.json');
    if (!fs.existsSync(packageJsonPath)) {
      log('❌ 錯誤: 找不到 package.json 檔案', 'red');
      process.exit(1);
    }

    // 3. 讀取版本
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
    const packageVersion = packageJson.version;
    
    if (!packageVersion) {
      log('❌ 錯誤: package.json 中沒有 version 欄位', 'red');
      process.exit(1);
    }

    log(`📦 Package Version: ${packageVersion}`, 'green');

    // 4. 獲取分支名稱
    const branchName = execSync('git branch --show-current', { encoding: 'utf8' }).trim();
    log(`🌿 當前分支: ${branchName}`, 'blue');

    // 5. 提取票號
    const ticketMatch = branchName.match(/([A-Z]+-\d+|\d+)/);
    let ticketNumber = ticketMatch ? ticketMatch[1] : null;

    if (!ticketNumber) {
      log('⚠️  無法從分支名稱提取票號', 'yellow');
      ticketNumber = await question('請輸入票號: ');
      if (!ticketNumber.trim()) {
        log('❌ 票號不能為空', 'red');
        process.exit(1);
      }
      ticketNumber = ticketNumber.trim();
    }

    // 6. 處理 package version，如果已包含 -fc 就不重複加
    let baseVersion = packageVersion;
    if (packageVersion.endsWith('-fc')) {
      baseVersion = packageVersion; // 保持原樣
    }
    
    // 7. 移除票號前綴，只保留數字部分
    const ticketNumberOnly = ticketNumber.replace(/^[A-Z]+-/, '');
    log(`🎫 Ticket Number: ${ticketNumber} (使用: ${ticketNumberOnly})`, 'green');

    // 8. 計算 QA 版本號
    const tagPrefix = `${baseVersion}-${ticketNumberOnly}`;
    
    let existingTags;
    try {
      existingTags = execSync(`git tag -l "${tagPrefix}.*"`, { encoding: 'utf8' })
        .trim()
        .split('\n')
        .filter(tag => tag.length > 0);
    } catch (error) {
      existingTags = [];
    }

    const qaVersion = existingTags.length;
    log(`📊 目前分支已有 ${existingTags.length} 個相關 tag`, 'blue');
    log(`🔢 QA Version: ${qaVersion}`, 'green');

    // 9. 生成完整 tag 名稱
    const fullTag = `${tagPrefix}.${qaVersion}`;
    log(`🏷️  即將創建 tag: ${fullTag}`, 'yellow');

    // 8. 顯示現有 tags (如果有的話)
    if (existingTags.length > 0) {
      log('\n📝 現有相關 tags:', 'blue');
      existingTags.forEach(tag => log(`   - ${tag}`, 'blue'));
      log('');
    }

    // 9. 確認
    const confirm = await question('是否繼續創建並推送此 tag? (y/N): ');
    if (!/^[Yy]$/.test(confirm)) {
      log('❌ 操作已取消', 'yellow');
      process.exit(0);
    }

    // 10. 創建 tag
    log('📝 創建 git tag...', 'blue');
    try {
      execSync(`git tag "${fullTag}"`, { stdio: 'inherit' });
      log(`✅ Tag 創建成功: ${fullTag}`, 'green');
    } catch (error) {
      log('❌ Tag 創建失敗', 'red');
      process.exit(1);
    }

    // 11. 推送 tag
    log('🚀 推送 tag 到 origin...', 'blue');
    try {
      execSync(`git push origin "${fullTag}"`, { stdio: 'inherit' });
      log('🎉 Tag 推送成功!', 'green');
      log(`✨ 完成! Tag '${fullTag}' 已成功創建並推送`, 'green');
    } catch (error) {
      log('❌ Tag 推送失敗', 'red');
      log(`💡 你可以稍後手動推送: git push origin ${fullTag}`, 'yellow');
      process.exit(1);
    }

    // 12. 顯示摘要
    log('\n=================================', 'blue');
    log('📋 摘要:', 'blue');
    log(`   Package Version: ${packageVersion}`);
    log(`   Ticket Number: ${ticketNumberOnly}`);
    log(`   QA Version: ${qaVersion}`);
    log(`   Created Tag: ${fullTag}`);
    log('=================================');

  } catch (error) {
    log(`❌ 發生錯誤: ${error.message}`, 'red');
    process.exit(1);
  } finally {
    rl.close();
  }
}

// 處理 Ctrl+C
process.on('SIGINT', () => {
  log('\n❌ 操作已中斷', 'yellow');
  rl.close();
  process.exit(0);
});

main();