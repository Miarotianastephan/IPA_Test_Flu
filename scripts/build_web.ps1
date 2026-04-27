# Build version selection
Write-Host "Select build version:" -ForegroundColor Cyan
Write-Host "  1 = cn  (91,    live.bogo.app.live_app.cn,  icon=chinese)"
Write-Host "  2 = yd  (XO,    live.bogo.app.live_app.xo,  icon=ic_launcher)"
Write-Host "  3 = tk  (Tk,    live.bogo.app.live_app.tk,   icon=tik)"
Write-Host ""

$choice = Read-Host "Enter choice (1, 2, or 3)"

if ($choice -notin @("1", "2", "3")) {
    Write-Host "Invalid choice. Exiting." -ForegroundColor Red
    exit 1
}

switch ($choice) {
    "1" {
        $appName = "91"
        $appId = "live.bogo.app.live_app.cn"
        $appIcon = "@mipmap/chinese"
    }
    "2" {
        $appName = "XO"
        $appId = "live.bogo.app.live_app.xo"
        $appIcon = "@mipmap/ic_launcher"
    }
    "3" {
        $appName = "TikTok"
        $appId = "live.bogo.app.live_app.tk"
        $appIcon = "@mipmap/tik"
    }
}

Write-Host ""
Write-Host "Building Flutter Web: version=$choice  appName=$appName  appId=$appId" -ForegroundColor Cyan
Write-Host ""

# Determine project root (works from scripts/ or project root)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$langFilePath = Join-Path $projectRoot "lib/utils/app_lang_version_utils.dart"
$pubspecPath = Join-Path $projectRoot "pubspec.yaml"
$manifestPath = Join-Path $projectRoot "android/app/src/main/AndroidManifest.xml"
$gradlePath = Join-Path $projectRoot "android/app/build.gradle.kts"

# Read original content for restore
$originalLang = Get-Content $langFilePath -Raw
$originalPubspec = Get-Content $pubspecPath -Raw
$originalManifest = Get-Content $manifestPath -Raw
$originalGradle = Get-Content $gradlePath -Raw

function Restore-OriginalFiles {
    Set-Content $langFilePath $originalLang -NoNewline
    Set-Content $pubspecPath $originalPubspec -NoNewline
    Set-Content $manifestPath $originalManifest -NoNewline
    Set-Content $gradlePath $originalGradle -NoNewline
    Write-Host "Restored original files" -ForegroundColor Yellow
}

function Replace-InFile {
    param(
        [string]$Path,
        [string]$Pattern,
        [string]$Replacement
    )

    $content = [System.IO.File]::ReadAllText($Path)
    $content = [regex]::Replace($content, $Pattern, $Replacement)
    [System.IO.File]::WriteAllText($Path, $content)
}

function New-BuildHash {
    param([string]$Choice)

    $gitRef = "nogit"
    try {
        $gitRef = (& git rev-parse --short HEAD 2>$null).Trim()
        if ([string]::IsNullOrWhiteSpace($gitRef)) {
            $gitRef = "nogit"
        }
    }
    catch {
        $gitRef = "nogit"
    }

    $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $inputText = "$Choice-$gitRef-$timestamp"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($inputText)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hashBytes = $sha256.ComputeHash($bytes)
        return ([BitConverter]::ToString($hashBytes).Replace("-", "").ToLower()).Substring(0, 12)
    }
    finally {
        $sha256.Dispose()
    }
}

function Set-WebBuildAssetHash {
    param(
        [string]$ProjectRoot,
        [string]$Choice
    )

    $buildOutput = Join-Path $ProjectRoot "build/web"
    $bootstrapPath = Join-Path $buildOutput "flutter_bootstrap.js"
    $indexPath = Join-Path $buildOutput "index.html"
    $mainJsPath = Join-Path $buildOutput "main.dart.js"
    $canvaskitPath = Join-Path $buildOutput "canvaskit"

    if (-not (Test-Path $indexPath)) {
        throw "Missing Flutter index output: $indexPath"
    }
    if (-not (Test-Path $bootstrapPath)) {
        throw "Missing Flutter bootstrap output: $bootstrapPath"
    }
    if (-not (Test-Path $mainJsPath)) {
        throw "Missing Flutter main JS output: $mainJsPath"
    }
    if (-not (Test-Path $canvaskitPath)) {
        throw "Missing Flutter CanvasKit output: $canvaskitPath"
    }

    $buildHash = New-BuildHash -Choice $Choice
    $hashedBootstrapName = "flutter_bootstrap.$buildHash.js"
    $hashedMainName = "main.dart.$buildHash.js"
    $hashedCanvaskitName = "canvaskit_$buildHash"

    Write-Host "Applying web asset hash: $buildHash" -ForegroundColor Yellow

    Get-ChildItem $buildOutput -Filter "main.dart.js_*.part.js" | ForEach-Object {
        $partName = $_.Name
        $hashedPartName = $partName -replace '\.js$', ".$buildHash.js"
        Replace-InFile -Path $mainJsPath -Pattern ([regex]::Escape($partName)) -Replacement $hashedPartName
        Move-Item $_.FullName (Join-Path $buildOutput $hashedPartName) -Force
        Remove-Item ($_.FullName + ".br") -Force -ErrorAction SilentlyContinue
        Remove-Item ($_.FullName + ".gz") -Force -ErrorAction SilentlyContinue
    }

    Replace-InFile -Path $bootstrapPath -Pattern '"mainJsPath":"main\.dart\.js"' -Replacement ('"mainJsPath":"' + $hashedMainName + '"')
    Move-Item $mainJsPath (Join-Path $buildOutput $hashedMainName) -Force
    Remove-Item ($mainJsPath + ".br") -Force -ErrorAction SilentlyContinue
    Remove-Item ($mainJsPath + ".gz") -Force -ErrorAction SilentlyContinue

    Move-Item $canvaskitPath (Join-Path $buildOutput $hashedCanvaskitName) -Force
    Replace-InFile -Path $bootstrapPath -Pattern '_flutter\.loader\.load\(\{' -Replacement ("_flutter.loader.load({`n  config: {`n    canvasKitBaseUrl: `"$hashedCanvaskitName/`",`n  },")
    Replace-InFile -Path $bootstrapPath -Pattern 'engineInitializer\.initializeEngine\(\)' -Replacement ("engineInitializer.initializeEngine({`n      canvasKitBaseUrl: `"$hashedCanvaskitName/`",`n    })")
    Remove-Item ($bootstrapPath + ".br") -Force -ErrorAction SilentlyContinue
    Remove-Item ($bootstrapPath + ".gz") -Force -ErrorAction SilentlyContinue

    Replace-InFile -Path $indexPath -Pattern 'flutter_bootstrap\.js' -Replacement $hashedBootstrapName
    Move-Item $bootstrapPath (Join-Path $buildOutput $hashedBootstrapName) -Force

    Write-Host "[OK] flutter_bootstrap.js -> $hashedBootstrapName" -ForegroundColor Green
    Write-Host "[OK] main.dart.js -> $hashedMainName" -ForegroundColor Green
    Write-Host "[OK] canvaskit -> $hashedCanvaskitName/" -ForegroundColor Green
}

# Change to project root for all commands
Push-Location $projectRoot

$buildArgs = @("--release", "--no-pub", "--no-web-resources-cdn", "--pwa-strategy=none")

try {
    # 1. Patch app_lang_version_utils.dart
    $langPatched = [regex]::Replace($originalLang, 'return [123];', "return $choice;", 1)
    Set-Content $langFilePath $langPatched -NoNewline
    Write-Host "[OK] $langFilePath  -> getLangVersion() = $choice" -ForegroundColor Green

    # 2. Patch AndroidManifest.xml: android:label
    $manifestPatched = [regex]::Replace($originalManifest, 'android:label="[^"]*"', ('android:label="' + $appName + '"'), 1)
    Set-Content $manifestPath $manifestPatched -NoNewline
    Write-Host "[OK] $manifestPath  -> android:label = $appName" -ForegroundColor Green

    # 3. Patch AndroidManifest.xml: android:icon
    $manifestPatched = [regex]::Replace((Get-Content $manifestPath -Raw), 'android:icon="@mipmap/[^"]*"', ('android:icon="' + $appIcon + '"'), 1)
    Set-Content $manifestPath $manifestPatched -NoNewline
    Write-Host "[OK] $manifestPath  -> android:icon = $appIcon" -ForegroundColor Green

    # 4. Patch build.gradle.kts applicationId
    $gradlePatched = [regex]::Replace($originalGradle, 'applicationId = "live\.bogo\.app\.live_app\.[a-z]*"', ('applicationId = "' + $appId + '"'), 1)
    Set-Content $gradlePath $gradlePatched -NoNewline
    Write-Host "[OK] $gradlePath  -> applicationId = $appId" -ForegroundColor Green

    Write-Host ""

    # Step 1: Clean
    Write-Host "Running: flutter clean" -ForegroundColor Yellow
    & flutter clean
    if ($LASTEXITCODE -ne 0) {
        throw "Clean failed!"
    }

    Write-Host ""

    # Step 2: Refresh packages
    Write-Host "Running: flutter pub get" -ForegroundColor Yellow
    & flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw "flutter pub get failed!"
    }

    Write-Host ""

    # Step 3: Build
    Write-Host "Running: flutter build web $($buildArgs -join ' ')" -ForegroundColor Yellow
    & flutter build web @buildArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed!"
    }

    Write-Host ""

    # Step 4: Add build hash to cache-sensitive web artifacts
    Set-WebBuildAssetHash -ProjectRoot $projectRoot -Choice $choice

    Write-Host ""

    # Step 5: Verify Drift wasm asset
    $wasmOutput = Join-Path $projectRoot "build/web/sqlite3.wasm"
    if (-not (Test-Path $wasmOutput)) {
        throw "Missing required Drift wasm asset: $wasmOutput"
    }
    Write-Host "[OK] Found Drift wasm asset at $wasmOutput" -ForegroundColor Green

    Write-Host ""
    Write-Host "Build successful!" -ForegroundColor Green
}
finally {
    Restore-OriginalFiles
    Pop-Location
}
