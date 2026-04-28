# Build version selection
$webFlutterVersion = if ($env:WEB_FLUTTER_VERSION) { $env:WEB_FLUTTER_VERSION } else { "3.27.4" }

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
Write-Host "Flutter SDK: $webFlutterVersion" -ForegroundColor Cyan
Write-Host ""

# Determine project root (works from scripts/ or project root)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$langFilePath = Join-Path $projectRoot "lib/utils/app_lang_version_utils.dart"
$pubspecPath = Join-Path $projectRoot "pubspec.yaml"
$pubspecLockPath = Join-Path $projectRoot "pubspec.lock"
$vscodeSettingsPath = Join-Path $projectRoot ".vscode/settings.json"
$manifestPath = Join-Path $projectRoot "android/app/src/main/AndroidManifest.xml"
$gradlePath = Join-Path $projectRoot "android/app/build.gradle.kts"
$l10nDir = Join-Path $projectRoot "lib/l10n"

# Read original content for restore
$originalLang = Get-Content $langFilePath -Raw
$originalPubspec = Get-Content $pubspecPath -Raw
$originalVscodeSettings = if (Test-Path $vscodeSettingsPath) { Get-Content $vscodeSettingsPath -Raw } else { $null }
$originalManifest = Get-Content $manifestPath -Raw
$originalGradle = Get-Content $gradlePath -Raw
$originalL10n = @{}
Get-ChildItem $l10nDir -Filter "app_localizations*.dart" -ErrorAction SilentlyContinue | ForEach-Object {
    $originalL10n[$_.FullName] = Get-Content $_.FullName -Raw
}
$fvmCacheDir = if ($env:FVM_CACHE_DIR) { $env:FVM_CACHE_DIR } else { Join-Path $HOME "fvm/versions" }
$script:FvmStateBackedUp = $false
$script:OriginalFvmrc = $null
$script:OriginalFvmConfig = $null
$script:OriginalFvmRelease = $null
$script:OriginalFvmVersion = $null
$script:OriginalFlutterSdkTarget = $null
$script:OriginalFvmVersionLinks = @()

function Backup-FvmState {
    $script:FvmStateBackedUp = $true

    $fvmrcPath = Join-Path $projectRoot ".fvmrc"
    $fvmDir = Join-Path $projectRoot ".fvm"
    $fvmConfigPath = Join-Path $fvmDir "fvm_config.json"
    $fvmReleasePath = Join-Path $fvmDir "release"
    $fvmVersionPath = Join-Path $fvmDir "version"
    $flutterSdkPath = Join-Path $fvmDir "flutter_sdk"
    $versionsDir = Join-Path $fvmDir "versions"

    if (Test-Path $fvmrcPath) { $script:OriginalFvmrc = Get-Content $fvmrcPath -Raw }
    if (Test-Path $fvmConfigPath) { $script:OriginalFvmConfig = Get-Content $fvmConfigPath -Raw }
    if (Test-Path $fvmReleasePath) { $script:OriginalFvmRelease = Get-Content $fvmReleasePath -Raw }
    if (Test-Path $fvmVersionPath) { $script:OriginalFvmVersion = Get-Content $fvmVersionPath -Raw }
    if (Test-Path $flutterSdkPath) { $script:OriginalFlutterSdkTarget = (Get-Item $flutterSdkPath).Target }

    if (Test-Path $versionsDir) {
        $script:OriginalFvmVersionLinks = Get-ChildItem $versionsDir | Where-Object { $_.LinkType } | ForEach-Object {
            [pscustomobject]@{
                Name = $_.Name
                Target = $_.Target
            }
        }
    }
}

function Restore-FvmState {
    if (-not $script:FvmStateBackedUp) {
        return
    }

    $fvmrcPath = Join-Path $projectRoot ".fvmrc"
    $fvmDir = Join-Path $projectRoot ".fvm"
    $fvmConfigPath = Join-Path $fvmDir "fvm_config.json"
    $fvmReleasePath = Join-Path $fvmDir "release"
    $fvmVersionPath = Join-Path $fvmDir "version"
    $flutterSdkPath = Join-Path $fvmDir "flutter_sdk"
    $versionsDir = Join-Path $fvmDir "versions"

    if ($null -ne $script:OriginalFvmrc) { Set-Content $fvmrcPath $script:OriginalFvmrc -NoNewline } else { Remove-Item $fvmrcPath -Force -ErrorAction SilentlyContinue }

    New-Item -ItemType Directory -Path $fvmDir -Force | Out-Null

    if ($null -ne $script:OriginalFvmConfig) { Set-Content $fvmConfigPath $script:OriginalFvmConfig -NoNewline } else { Remove-Item $fvmConfigPath -Force -ErrorAction SilentlyContinue }
    if ($null -ne $script:OriginalFvmRelease) { Set-Content $fvmReleasePath $script:OriginalFvmRelease -NoNewline } else { Remove-Item $fvmReleasePath -Force -ErrorAction SilentlyContinue }
    if ($null -ne $script:OriginalFvmVersion) { Set-Content $fvmVersionPath $script:OriginalFvmVersion -NoNewline } else { Remove-Item $fvmVersionPath -Force -ErrorAction SilentlyContinue }

    Remove-Item $flutterSdkPath -Force -ErrorAction SilentlyContinue
    if ($null -ne $script:OriginalFlutterSdkTarget) {
        New-Item -ItemType SymbolicLink -Path $flutterSdkPath -Target $script:OriginalFlutterSdkTarget -Force | Out-Null
    }

    New-Item -ItemType Directory -Path $versionsDir -Force | Out-Null
    Get-ChildItem $versionsDir -ErrorAction SilentlyContinue | Where-Object { $_.LinkType } | Remove-Item -Force
    foreach ($link in $script:OriginalFvmVersionLinks) {
        New-Item -ItemType SymbolicLink -Path (Join-Path $versionsDir $link.Name) -Target $link.Target -Force | Out-Null
    }
}

function Use-FvmVersion {
    param([string]$Version)

    if (-not (Get-Command fvm -ErrorAction SilentlyContinue)) {
        throw "fvm is required to build web with Flutter $Version."
    }

    if (-not (Test-Path (Join-Path $fvmCacheDir $Version))) {
        Write-Host "Flutter $Version is not installed in FVM. Installing..." -ForegroundColor Yellow
        & fvm install $Version
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to install Flutter $Version with FVM."
        }
    }

    Write-Host "Running: fvm use $Version --skip-pub-get" -ForegroundColor Yellow
    & fvm use $Version --skip-pub-get
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to switch Flutter SDK to $Version."
    }
}

function Restore-OriginalFiles {
    Set-Content $langFilePath $originalLang -NoNewline
    Set-Content $pubspecPath $originalPubspec -NoNewline
    if ($null -ne $originalVscodeSettings) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $vscodeSettingsPath) -Force | Out-Null
        Set-Content $vscodeSettingsPath $originalVscodeSettings -NoNewline
    }
    else {
        Remove-Item $vscodeSettingsPath -Force -ErrorAction SilentlyContinue
    }
    Set-Content $manifestPath $originalManifest -NoNewline
    Set-Content $gradlePath $originalGradle -NoNewline
    foreach ($entry in $originalL10n.GetEnumerator()) {
        Set-Content $entry.Key $entry.Value -NoNewline
    }
    Remove-Item (Join-Path $projectRoot ".flutter-plugins") -Force -ErrorAction SilentlyContinue
    Restore-FvmState
    Write-Host "Restored original files" -ForegroundColor Yellow
}

function Invoke-Flutter {
    param([string[]]$Arguments)

    & fvm flutter @Arguments
}

function Clear-PubspecLock {
    Remove-Item $pubspecLockPath -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] removed pubspec.lock; dependencies will be resolved again" -ForegroundColor Green
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

    $bootstrapContent = [System.IO.File]::ReadAllText($bootstrapPath)
    $isHtmlRenderer = $bootstrapContent.Contains('"renderer":"html"')

    if (-not $isHtmlRenderer -and -not (Test-Path $canvaskitPath)) {
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

    if ($isHtmlRenderer) {
        if ((Test-Path $canvaskitPath) -and $script:PruneCanvasKit) {
            Remove-Item $canvaskitPath -Recurse -Force
            Write-Host "[OK] removed unused CanvasKit output for HTML renderer" -ForegroundColor Green
        }
        else {
            Write-Host "[OK] HTML renderer build; CanvasKit hashing skipped" -ForegroundColor Green
        }
    }
    else {
        Move-Item $canvaskitPath (Join-Path $buildOutput $hashedCanvaskitName) -Force
        Replace-InFile -Path $bootstrapPath -Pattern '_flutter\.loader\.load\(\{' -Replacement ("_flutter.loader.load({`n  config: {`n    canvasKitBaseUrl: `"$hashedCanvaskitName/`",`n  },")
        Replace-InFile -Path $bootstrapPath -Pattern 'engineInitializer\.initializeEngine\(\)' -Replacement ("engineInitializer.initializeEngine({`n      canvasKitBaseUrl: `"$hashedCanvaskitName/`",`n    })")
    }
    Remove-Item ($bootstrapPath + ".br") -Force -ErrorAction SilentlyContinue
    Remove-Item ($bootstrapPath + ".gz") -Force -ErrorAction SilentlyContinue

    Replace-InFile -Path $indexPath -Pattern 'flutter_bootstrap\.js' -Replacement $hashedBootstrapName
    Move-Item $bootstrapPath (Join-Path $buildOutput $hashedBootstrapName) -Force

    Write-Host "[OK] flutter_bootstrap.js -> $hashedBootstrapName" -ForegroundColor Green
    Write-Host "[OK] main.dart.js -> $hashedMainName" -ForegroundColor Green
    if (-not $isHtmlRenderer) {
        Write-Host "[OK] canvaskit -> $hashedCanvaskitName/" -ForegroundColor Green
    }
}

function Remove-WebRuntimeRequests {
    param([string]$ProjectRoot)

    $buildOutput = Join-Path $ProjectRoot "build/web"
    $bootstrapPath = Join-Path $buildOutput "flutter_bootstrap.js"
    $mainJsPath = Join-Path $buildOutput "main.dart.js"
    $serviceWorkerPath = Join-Path $buildOutput "flutter_service_worker.js"
    $versionJsonPath = Join-Path $buildOutput "version.json"
    $wakelockAssetPath = Join-Path $buildOutput "assets/packages/wakelock_plus"
    $wakeLockDataUrl = "data:text/javascript;charset=utf-8,(function()%7Bvar%20sentinel%3Dnull%3Bwindow.Wakelock%3D%7Btoggle%3Afunction(enable)%7Bif(enable%26%26navigator.wakeLock)%7Bnavigator.wakeLock.request(%27screen%27).then(function(s)%7Bsentinel%3Ds%3B%7D).catch(function()%7B%7D)%3B%7Delse%20if(sentinel)%7Bsentinel.release()%3Bsentinel%3Dnull%3B%7D%7D%2Cenabled%3Afunction()%7Breturn%20Promise.resolve(!!sentinel)%3B%7D%7D%3B%7D)()%3B"

    if ((Test-Path $bootstrapPath) -and ((Get-Content $bootstrapPath -Raw).Contains("serviceWorkerSettings"))) {
        Replace-InFile -Path $bootstrapPath -Pattern "`n\s*serviceWorkerSettings:\s*\{[^{}]*\}\s*,?" -Replacement ""
        Write-Host "[OK] disabled Flutter service worker registration" -ForegroundColor Green
    }

    if (Test-Path $serviceWorkerPath) {
        $cleanupServiceWorker = @'
self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    if ('caches' in self) {
      const keys = await caches.keys();
      await Promise.all(
        keys
          .filter((key) => key.indexOf('flutter-') === 0)
          .map((key) => caches.delete(key))
      );
    }

    await self.clients.claim();

    const clients = await self.clients.matchAll({
      type: 'window',
      includeUncontrolled: true,
    });

    await self.registration.unregister();

    for (const client of clients) {
      if (client.url && client.url.indexOf(self.location.origin) === 0) {
        client.navigate(client.url);
      }
    }
  })());
});
'@
        Set-Content -Path $serviceWorkerPath -Value $cleanupServiceWorker -NoNewline
        Remove-Item ($serviceWorkerPath + ".br") -Force -ErrorAction SilentlyContinue
        Remove-Item ($serviceWorkerPath + ".gz") -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] replaced flutter_service_worker.js with cleanup worker" -ForegroundColor Green
    }

    if ((Test-Path $mainJsPath) -and ((Get-Content $mainJsPath -Raw).Contains('"assets/no_sleep.js"'))) {
        Replace-InFile -Path $mainJsPath -Pattern '"assets/no_sleep\.js"' -Replacement ('"' + $wakeLockDataUrl + '"')
        Remove-Item $wakelockAssetPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] removed wakelock_plus NoSleep.js web asset request" -ForegroundColor Green
    }

    if (Test-Path $versionJsonPath) {
        Remove-Item $versionJsonPath -Force
        Write-Host "[OK] removed package_info_plus version.json output" -ForegroundColor Green
    }
}

# Change to project root for all commands
Push-Location $projectRoot

$webRenderer = if ($env:WEB_RENDERER) { $env:WEB_RENDERER } else { "html" }
$script:PruneCanvasKit = $env:PRUNE_CANVASKIT -notin @("0", "false", "False", "FALSE")
$buildArgs = @("--release", "--no-pub", "--no-web-resources-cdn", "--pwa-strategy=none")
if (-not [string]::IsNullOrWhiteSpace($webRenderer)) {
    $buildArgs += @("--web-renderer", $webRenderer)
}

$appVersionMatch = Select-String -Path $pubspecPath -Pattern '^version:\s*(.+)$' | Select-Object -First 1
$appVersionFull = if ($appVersionMatch) { $appVersionMatch.Matches[0].Groups[1].Value.Trim() } else { "1.3.3" }
$appVersionParts = $appVersionFull -split '\+', 2
$appVersionName = $appVersionParts[0]
$appBuildNumber = if ($appVersionParts.Length -gt 1) { $appVersionParts[1] } else { "" }
$buildArgs += @("--dart-define", "APP_VERSION=$appVersionName", "--dart-define", "APP_BUILD_NUMBER=$appBuildNumber")

try {
    Backup-FvmState
    Use-FvmVersion -Version $webFlutterVersion

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
    $flutterLabel = "fvm flutter"

    Write-Host "Running: $flutterLabel clean" -ForegroundColor Yellow
    Invoke-Flutter @("clean")
    if ($LASTEXITCODE -ne 0) {
        throw "Clean failed!"
    }

    Write-Host ""

    # Step 2: Refresh packages
    Clear-PubspecLock
    Write-Host "Running: $flutterLabel pub get" -ForegroundColor Yellow
    Invoke-Flutter @("pub", "get")
    if ($LASTEXITCODE -ne 0) {
        throw "flutter pub get failed!"
    }

    Write-Host ""

    # Step 3: Build
    Write-Host "Running: $flutterLabel build web $($buildArgs -join ' ')" -ForegroundColor Yellow
    Invoke-Flutter (@("build", "web") + $buildArgs)
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed!"
    }

    Write-Host ""

    # Step 4: Remove avoidable web runtime requests
    Remove-WebRuntimeRequests -ProjectRoot $projectRoot

    Write-Host ""

    # Step 5: Add build hash to cache-sensitive web artifacts
    Set-WebBuildAssetHash -ProjectRoot $projectRoot -Choice $choice

    Write-Host ""

    # Step 6: Verify Drift wasm asset
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
