# Fork 自定义脚本 - 批量修改包名和产物名称
# 使用方法: .\customize_fork.ps1 -NewPackageName "com.bh3mei.kelivo" -NewDisplayName "Kelivo Fork"

param(
    [Parameter(Mandatory=$true)]
    [string]$NewPackageName,
    
    [Parameter(Mandatory=$false)]
    [string]$NewDisplayName = "Kelivo Fork",
    
    [Parameter(Mandatory=$false)]
    [string]$NewArtifactPrefix = "KelivoFork"
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Kelivo Fork 自定义配置脚本" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$oldPackageName = "com.psyche.kelivo"
$oldDisplayName = "Kelivo"
$oldPrefix = "Kelivo"

Write-Host "📝 配置信息:" -ForegroundColor Yellow
Write-Host "  旧包名: $oldPackageName" -ForegroundColor Gray
Write-Host "  新包名: $NewPackageName" -ForegroundColor Green
Write-Host "  新显示名: $NewDisplayName" -ForegroundColor Green
Write-Host "  新产物前缀: $NewArtifactPrefix" -ForegroundColor Green
Write-Host ""

# 确认
$confirm = Read-Host "确认修改? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "❌ 已取消" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "🔧 开始修改..." -ForegroundColor Cyan
Write-Host ""

# 1. Android build.gradle.kts
Write-Host "1️⃣  修改 Android 包名..." -ForegroundColor Yellow
$androidGradle = "android/app/build.gradle.kts"
if (Test-Path $androidGradle) {
    (Get-Content $androidGradle) -replace [regex]::Escape($oldPackageName), $NewPackageName | Set-Content $androidGradle
    Write-Host "  ✅ $androidGradle" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  未找到 $androidGradle" -ForegroundColor Red
}

# 2. iOS project.pbxproj
Write-Host "2️⃣  修改 iOS Bundle Identifier..." -ForegroundColor Yellow
$iosPbxproj = "ios/Runner.xcodeproj/project.pbxproj"
if (Test-Path $iosPbxproj) {
    (Get-Content $iosPbxproj) -replace [regex]::Escape($oldPackageName), $NewPackageName | Set-Content $iosPbxproj
    Write-Host "  ✅ $iosPbxproj" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  未找到 $iosPbxproj" -ForegroundColor Red
}

# 3. iOS Info.plist (显示名称)
Write-Host "3️⃣  修改 iOS 显示名称..." -ForegroundColor Yellow
$iosInfoPlist = "ios/Runner/Info.plist"
if (Test-Path $iosInfoPlist) {
    $content = Get-Content $iosInfoPlist -Raw
    $content = $content -replace "<string>$oldDisplayName</string>", "<string>$NewDisplayName</string>"
    Set-Content $iosInfoPlist -Value $content -NoNewline
    Write-Host "  ✅ $iosInfoPlist" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  未找到 $iosInfoPlist" -ForegroundColor Red
}

# 4. Android AndroidManifest.xml (显示名称)
Write-Host "4️⃣  修改 Android 显示名称..." -ForegroundColor Yellow
$androidManifest = "android/app/src/main/AndroidManifest.xml"
if (Test-Path $androidManifest) {
    $content = Get-Content $androidManifest -Raw
    $content = $content -replace 'android:label="[^"]*"', "android:label=`"$NewDisplayName`""
    Set-Content $androidManifest -Value $content -NoNewline
    Write-Host "  ✅ $androidManifest" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  未找到 $androidManifest" -ForegroundColor Red
}

# 5. GitHub Actions workflows
Write-Host "5️⃣  修改 GitHub Actions 产物名称..." -ForegroundColor Yellow
$workflows = @(
    ".github/workflows/build.yml",
    ".github/workflows/build-stable.yml"
)

foreach ($workflow in $workflows) {
    if (Test-Path $workflow) {
        $content = Get-Content $workflow -Raw
        
        # 替换产物文件名前缀
        $content = $content -replace "${oldPrefix}_", "${NewArtifactPrefix}_"
        $content = $content -replace "OutputBaseFilename=${oldPrefix}_", "OutputBaseFilename=${NewArtifactPrefix}_"
        
        # 替换显示名称
        $content = $content -replace "`"$oldDisplayName`"", "`"$NewDisplayName`""
        $content = $content -replace "volname `"$oldDisplayName`"", "volname `"$NewDisplayName`""
        
        # 生成新的Windows AppId GUID
        $newGuid = [guid]::NewGuid().ToString().ToUpper()
        $content = $content -replace "AppId=\{[A-F0-9\-]+\}", "AppId={$newGuid}"
        
        Set-Content $workflow -Value $content -NoNewline
        Write-Host "  ✅ $workflow (新GUID: $newGuid)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  未找到 $workflow" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "✅ 修改完成!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 下一步操作:" -ForegroundColor Yellow
Write-Host "  1. 运行 'flutter clean' 清理缓存" -ForegroundColor White
Write-Host "  2. 运行 'flutter pub get' 获取依赖" -ForegroundColor White
Write-Host "  3. 测试本地构建: 'flutter build apk'" -ForegroundColor White
Write-Host "  4. 提交更改到你的仓库" -ForegroundColor White
Write-Host "  5. 在GitHub Actions手动触发构建" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  重要提示:" -ForegroundColor Red
Write-Host "  - 新应用和原应用可以共存，互不影响" -ForegroundColor White
Write-Host "  - 数据目录完全独立" -ForegroundColor White
Write-Host "  - 不会覆盖用户已安装的原版应用" -ForegroundColor White
Write-Host ""
