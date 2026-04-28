$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$langFilePath = Join-Path $projectRoot "lib/utils/app_lang_version_utils.dart"
$pubspecPath = Join-Path $projectRoot "pubspec.yaml"
$pubspecLockPath = Join-Path $projectRoot "pubspec.lock"
$vscodeSettingsPath = Join-Path $projectRoot ".vscode/settings.json"
$manifestPath = Join-Path $projectRoot "android/app/src/main/AndroidManifest.xml"
$gradlePath = Join-Path $projectRoot "android/app/build.gradle.kts"
$l10nDir = Join-Path $projectRoot "lib/l10n"
$mobileFlutterVersion = if ($env:MOBILE_FLUTTER_VERSION) { $env:MOBILE_FLUTTER_VERSION } else { "3.41.7" }
$fvmCacheDir = if ($env:FVM_CACHE_DIR) { $env:FVM_CACHE_DIR } else { Join-Path $HOME "fvm/versions" }

$originalLang = Get-Content $langFilePath -Raw
$originalPubspec = Get-Content $pubspecPath -Raw
$originalVscodeSettings = if (Test-Path $vscodeSettingsPath) { Get-Content $vscodeSettingsPath -Raw } else { $null }
$originalManifest = Get-Content $manifestPath -Raw
$originalGradle = Get-Content $gradlePath -Raw
$originalL10n = @{}
Get-ChildItem $l10nDir -Filter "app_localizations*.dart" -ErrorAction SilentlyContinue | ForEach-Object {
    $originalL10n[$_.FullName] = Get-Content $_.FullName -Raw
}
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
        throw "fvm is required to build mobile with Flutter $Version."
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

function Invoke-Flutter {
    param([string[]]$Arguments)

    & fvm flutter @Arguments
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
    Restore-FvmState
    Write-Host "Restored original files" -ForegroundColor Yellow
}

function Clear-PubspecLock {
    Remove-Item $pubspecLockPath -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] removed pubspec.lock; dependencies will be resolved again" -ForegroundColor Green
}

try {
    Push-Location $projectRoot

    if ($args.Count -eq 0) {
        throw "Usage: ./scripts/build_mobile.ps1 build <platform> [flutter build args...]`nExamples:`n  ./scripts/build_mobile.ps1 build ios --release`n  ./scripts/build_mobile.ps1 build apk --release"
    }

    Write-Host "Select build version:" -ForegroundColor Cyan
    Write-Host "  1 = cn  (91,    live.bogo.app.live_app.cn,  icon=chinese)"
    Write-Host "  2 = yd  (XO,    live.bogo.app.live_app.xo,  icon=ic_launcher)"
    Write-Host "  3 = tk  (Tk,    live.bogo.app.live_app.tk,   icon=tik)"
    Write-Host ""

    $choice = Read-Host "Enter choice (1, 2, or 3)"
    if ($choice -notin @("1", "2", "3")) {
        throw "Invalid choice. Exiting."
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
    Write-Host "Building Flutter mobile: version=$choice  appName=$appName  appId=$appId" -ForegroundColor Cyan
    Write-Host "Flutter SDK: $mobileFlutterVersion" -ForegroundColor Cyan
    Write-Host ""

    Backup-FvmState
    Use-FvmVersion -Version $mobileFlutterVersion

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
    Clear-PubspecLock

    $buildArgs = @($args)

    function Get-BaseBuildArgs([string[]]$inputArgs) {
        $filtered = New-Object System.Collections.Generic.List[string]

        for ($i = 0; $i -lt $inputArgs.Count; $i++) {
            $arg = $inputArgs[$i]
            if ($arg -eq "--target-platform") {
                $i++
                continue
            }
            if ($arg.StartsWith("--target-platform=")) {
                continue
            }
            $filtered.Add($arg)
        }

        return $filtered.ToArray()
    }

    if ($buildArgs.Count -ge 2 -and $buildArgs[0] -eq "build" -and $buildArgs[1] -eq "apk") {
        $baseArgs = @(Get-BaseBuildArgs $buildArgs)
        if (-not ($baseArgs -contains "--split-per-abi")) {
            $baseArgs += "--split-per-abi"
        }
        Write-Host "Running: fvm flutter $($baseArgs -join ' ')" -ForegroundColor Yellow
        Invoke-Flutter -Arguments $baseArgs
        if ($LASTEXITCODE -ne 0) {
            throw "Flutter mobile APK build failed."
        }
    }
    else {
        Write-Host "Running: fvm flutter $($buildArgs -join ' ')" -ForegroundColor Yellow
        Invoke-Flutter -Arguments $buildArgs
        if ($LASTEXITCODE -ne 0) {
            throw "Flutter mobile build failed."
        }
    }

    Write-Host ""
    Write-Host "Mobile build successful!" -ForegroundColor Green
}
finally {
    Restore-OriginalFiles
    Pop-Location
}
