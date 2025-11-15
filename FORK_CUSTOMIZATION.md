# Fork 独立发布配置指南

## 核心原则
**修改包名 = 独立应用** - 不会覆盖原开发者的应用

---

## 需要修改的文件

### 1. Android 包名
**文件**: `android/app/build.gradle.kts`
```diff
- applicationId = "com.psyche.kelivo"
+ applicationId = "com.bh3mei.kelivo"  # 或你的唯一标识
```

### 2. iOS Bundle ID
**文件**: `ios/Runner.xcodeproj/project.pbxproj`

搜索并替换所有（4处）：
```diff
- PRODUCT_BUNDLE_IDENTIFIER = com.psyche.kelivo;
+ PRODUCT_BUNDLE_IDENTIFIER = com.bh3mei.kelivo;
```

### 3. 应用显示名称（可选，建议修改）

**Android**:
文件: `android/app/src/main/AndroidManifest.xml`
```xml
<application
    android:label="Kelivo Fork"  <!-- 或 "Kelivo BH3Mei" -->
```

**iOS**:
文件: `ios/Runner/Info.plist`
```diff
<key>CFBundleDisplayName</key>
- <string>Kelivo</string>
+ <string>Kelivo Fork</string>
```

### 4. GitHub Actions 产物名称

**文件**: `.github/workflows/build.yml`

修改所有构建产物的文件名前缀（可选，但建议）：

**114-120行** (Android APK重命名):
```diff
- mv "$file" "Kelivo_android_${VERSION}_${abi}.apk"
+ mv "$file" "KelivoFork_android_${VERSION}_${abi}.apk"
```

**188行** (iOS IPA):
```diff
- zip -r ../../../Kelivo_ios_${VERSION}.ipa Payload
+ zip -r ../../../KelivoFork_ios_${VERSION}.ipa Payload
```

**248行** (macOS DMG):
```diff
- "Kelivo_macos_${VERSION}.dmg"
+ "KelivoFork_macos_${VERSION}.dmg"
```

**323行** (Windows ZIP):
```diff
- Compress-Archive -Path ... -DestinationPath "Kelivo_windows_$env:VERSION.zip"
+ Compress-Archive -Path ... -DestinationPath "KelivoFork_windows_$env:VERSION.zip"
```

**386行** (Windows安装器):
```diff
- OutputBaseFilename=Kelivo_windows_{#MyAppVersion}_setup
+ OutputBaseFilename=KelivoFork_windows_{#MyAppVersion}_setup
```

**487行** (Linux tar.gz):
```diff
- tar -czf ../../../../../Kelivo_linux_${VERSION}.tar.gz .
+ tar -czf ../../../../../KelivoFork_linux_${VERSION}.tar.gz .
```

以及所有其他出现 `Kelivo_` 的地方。

### 5. Windows 安装器 AppId（重要！）

**文件**: `.github/workflows/build.yml` 第379行

```diff
- AppId={{A7B8C9D0-E1F2-4A5B-8C9D-0E1F2A3B4C5D}}
+ AppId={{B8C9D0E1-F2A3-5B6C-9D0E-1F2A3B4C5D6E}}  # 生成新的GUID
```

生成新GUID: 在PowerShell运行 `[guid]::NewGuid()`

---

## 快速修改命令（批量替换）

### Windows PowerShell:
```powershell
# 替换包名
(Get-Content android/app/build.gradle.kts) -replace 'com\.psyche\.kelivo', 'com.bh3mei.kelivo' | Set-Content android/app/build.gradle.kts

(Get-Content ios/Runner.xcodeproj/project.pbxproj) -replace 'com\.psyche\.kelivo', 'com.bh3mei.kelivo' | Set-Content ios/Runner.xcodeproj/project.pbxproj

# 替换产物名称
(Get-Content .github/workflows/build.yml) -replace 'Kelivo_', 'KelivoFork_' | Set-Content .github/workflows/build.yml
(Get-Content .github/workflows/build.yml) -replace '"Kelivo"', '"Kelivo Fork"' | Set-Content .github/workflows/build.yml
```

### Linux/macOS:
```bash
# 替换包名
sed -i 's/com\.psyche\.kelivo/com.bh3mei.kelivo/g' android/app/build.gradle.kts
sed -i 's/com\.psyche\.kelivo/com.bh3mei.kelivo/g' ios/Runner.xcodeproj/project.pbxproj

# 替换产物名称
sed -i 's/Kelivo_/KelivoFork_/g' .github/workflows/build.yml
sed -i 's/"Kelivo"/"Kelivo Fork"/g' .github/workflows/build.yml
```

---

## 验证清单

构建前检查：

- [ ] Android `applicationId` 已修改
- [ ] iOS `PRODUCT_BUNDLE_IDENTIFIER` 全部修改（4处）
- [ ] 应用显示名称已修改（可选）
- [ ] GitHub Actions 文件名前缀已修改（可选）
- [ ] Windows AppId 已生成新GUID
- [ ] 测试本地构建: `flutter build apk`

---

## 效果对比

| 项目 | 原版 | Fork版 |
|------|------|--------|
| Android包名 | com.psyche.kelivo | com.bh3mei.kelivo |
| iOS Bundle ID | com.psyche.kelivo | com.bh3mei.kelivo |
| 显示名称 | Kelivo | Kelivo Fork |
| 安装位置 | 独立 | 独立（可共存） |
| 数据目录 | 独立 | 独立（互不干扰） |
| 更新通道 | 原作者 | 你的仓库 |

---

## 为什么这样做有效？

### 数据结构决定身份

```text
Android系统识别应用 → applicationId
iOS系统识别应用 → Bundle Identifier  
Windows系统识别 → AppUserModelId (Inno Setup的AppId)
```

**不同包名 = 完全独立的应用**

- ✅ 可以同时安装原版和Fork版
- ✅ 数据互不干扰
- ✅ 更新不会冲突
- ✅ 用户可以自由选择

### Linus的建议
**"改包名，一次性解决所有问题"** - 不要用任何hack或workaround，直接改数据结构。

---

## 推荐包名命名

```text
com.yourgithub.kelivo          # 最简洁
com.yourname.kelivo.fork       # 明确是Fork
io.github.yourusername.kelivo  # GitHub风格
```

**避免使用**:
- ❌ 保留原包名（会冲突）
- ❌ 只修改显示名（系统仍认为是同一应用）
- ❌ 使用奇怪的包名（com.kelivo.fork123）
