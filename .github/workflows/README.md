# GitHub Actions - Android Debug 自动构建

## 配置说明

### `android-build.yml` - Debug APK 自动构建

**触发条件：**
- Push 到 `master` 或 `main` 分支
- Pull Request
- 手动触发（Actions 页面点击 "Run workflow"）

**输出产物：**
- Debug APK（3 个架构独立包）
  - `app-arm64-v8a-debug.apk` - 64位 ARM（主流手机）
  - `app-armeabi-v7a-debug.apk` - 32位 ARM（老手机）
  - `app-x86_64-debug.apk` - 64位 x86（模拟器）

**保留时间：** 30 天

---

## 使用方法

### 1. Push 代码自动构建
```bash
git add .
git commit -m "your changes"
git push
```

### 2. 下载 APK
1. 前往 GitHub 仓库页面
2. 点击 `Actions` 标签
3. 选择最新的 workflow run
4. 滚动到底部的 `Artifacts` 区域
5. 下载 `kelivo-debug-apks` 压缩包

### 3. 手动触发构建
1. 前往 `Actions` 标签
2. 左侧选择 "Build Android Debug APK"
3. 点击 `Run workflow` → 选择分支 → `Run workflow`

---

## 技术细节

- **Flutter 版本：** 3.27.2 stable
- **Java 版本：** 17 (Temurin)
- **构建时间：** 首次 ~8 分钟，后续缓存 ~4 分钟
- **Runner：** ubuntu-latest

---

## 故障排查

### 构建失败：依赖问题
→ 检查 `pubspec.yaml` 依赖是否都能正常解析

### 构建失败：Flutter 版本不匹配
→ 修改 `android-build.yml` 第 33 行的 `flutter-version`

### APK 无法安装
→ Debug APK 需要允许"未知来源"安装

---

## 为什么只构建 Debug？

Debug APK 的特点：
- ✅ 零配置 - 不需要签名密钥
- ✅ 快速验证 - 功能测试够用
- ✅ 包含调试信息 - 方便排查问题
- ❌ 性能略差 - 未优化，包体积大

如果需要发布到 Play Store，需要配置签名的 Release 版本。
