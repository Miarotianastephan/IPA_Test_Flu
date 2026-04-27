$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$langFilePath = Join-Path $projectRoot "lib/utils/app_lang_version_utils.dart"
$pubspecPath = Join-Path $projectRoot "pubspec.yaml"
$manifestPath = Join-Path $projectRoot "android/app/src/main/AndroidManifest.xml"
$gradlePath = Join-Path $projectRoot "android/app/build.gradle.kts"

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
    Write-Host ""

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
        Write-Host "Running: flutter $($baseArgs -join ' ')" -ForegroundColor Yellow
        & flutter @baseArgs
        if ($LASTEXITCODE -ne 0) {
            throw "Flutter mobile APK build failed."
        }
    }
    else {
        Write-Host "Running: flutter $($buildArgs -join ' ')" -ForegroundColor Yellow
        & flutter @buildArgs
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
