#!/bin/bash
# Build Flutter web with version selection
# Run: bash scripts/build_web.sh

WEB_FLUTTER_VERSION="${WEB_FLUTTER_VERSION:-3.27.4}"

# Build version selection
echo "Select build version:"
echo "  1 = cn  (91,    live.bogo.app.live_app.cn,  icon=chinese)"
echo "  2 = yd  (XO,    live.bogo.app.live_app.xo,  icon=ic_launcher)"
echo "  3 = tk  (Tk,    live.bogo.app.live_app.tk,   icon=tik)"
echo ""

read -p "Enter choice (1, 2, or 3): " choice

if [[ ! "$choice" =~ ^[123]$ ]]; then
    echo "Invalid choice. Exiting."
    exit 1
fi

case "$choice" in
  1)
    APP_NAME="91"
    APP_ID="live.bogo.app.live_app.cn"
    APP_ICON="@mipmap/chinese"
    ;;
  2)
    APP_NAME="XO"
    APP_ID="live.bogo.app.live_app.xo"
    APP_ICON="@mipmap/ic_launcher"
    ;;
  3)
    APP_NAME="TikTok"
    APP_ID="live.bogo.app.live_app.tk"
    APP_ICON="@mipmap/tik"
    ;;
esac

echo ""
echo "Building Flutter Web: version=$choice  appName=$APP_NAME  appId=$APP_ID"
echo "Flutter SDK: $WEB_FLUTTER_VERSION"
echo ""

# Determine project root (works from scripts/ or project root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LANG_FILE_PATH="$PROJECT_ROOT/lib/utils/app_lang_version_utils.dart"
PUBSPEC_PATH="$PROJECT_ROOT/pubspec.yaml"
PUBSPEC_LOCK_PATH="$PROJECT_ROOT/pubspec.lock"
VSCODE_SETTINGS_PATH="$PROJECT_ROOT/.vscode/settings.json"
MANIFEST="$PROJECT_ROOT/android/app/src/main/AndroidManifest.xml"
GRADLE="$PROJECT_ROOT/android/app/build.gradle.kts"
L10N_DIR="$PROJECT_ROOT/lib/l10n"
FVM_CACHE_DIR="${FVM_CACHE_DIR:-$HOME/fvm/versions}"

# Read original content for restore
BACKUP_DIR=$(mktemp -d)
cp "$LANG_FILE_PATH" "$BACKUP_DIR/app_lang_version_utils.dart"
cp "$PUBSPEC_PATH" "$BACKUP_DIR/pubspec.yaml"
[ -f "$VSCODE_SETTINGS_PATH" ] && cp "$VSCODE_SETTINGS_PATH" "$BACKUP_DIR/vscode_settings.json"
cp "$MANIFEST" "$BACKUP_DIR/AndroidManifest.xml"
cp "$GRADLE" "$BACKUP_DIR/build.gradle.kts"
mkdir -p "$BACKUP_DIR/l10n"
cp "$L10N_DIR"/app_localizations*.dart "$BACKUP_DIR/l10n/" 2>/dev/null || true

backup_fvm_state() {
    [ -f "$PROJECT_ROOT/.fvmrc" ] && cp "$PROJECT_ROOT/.fvmrc" "$BACKUP_DIR/.fvmrc"
    [ -f "$PROJECT_ROOT/.fvm/fvm_config.json" ] && cp "$PROJECT_ROOT/.fvm/fvm_config.json" "$BACKUP_DIR/fvm_config.json"
    [ -f "$PROJECT_ROOT/.fvm/release" ] && cp "$PROJECT_ROOT/.fvm/release" "$BACKUP_DIR/fvm_release"
    [ -f "$PROJECT_ROOT/.fvm/version" ] && cp "$PROJECT_ROOT/.fvm/version" "$BACKUP_DIR/fvm_version"

    if [ -L "$PROJECT_ROOT/.fvm/flutter_sdk" ]; then
        readlink "$PROJECT_ROOT/.fvm/flutter_sdk" > "$BACKUP_DIR/flutter_sdk.link"
    fi

    if [ -d "$PROJECT_ROOT/.fvm/versions" ]; then
        find "$PROJECT_ROOT/.fvm/versions" -maxdepth 1 -mindepth 1 -type l | while read -r link_path; do
            printf '%s\t%s\n' "$(basename "$link_path")" "$(readlink "$link_path")"
        done > "$BACKUP_DIR/fvm_version_links.tsv"
    fi
}

restore_fvm_state() {
    if [ -f "$BACKUP_DIR/.fvmrc" ]; then
        cp "$BACKUP_DIR/.fvmrc" "$PROJECT_ROOT/.fvmrc"
    else
        rm -f "$PROJECT_ROOT/.fvmrc"
    fi

    mkdir -p "$PROJECT_ROOT/.fvm"

    if [ -f "$BACKUP_DIR/fvm_config.json" ]; then
        cp "$BACKUP_DIR/fvm_config.json" "$PROJECT_ROOT/.fvm/fvm_config.json"
    else
        rm -f "$PROJECT_ROOT/.fvm/fvm_config.json"
    fi

    if [ -f "$BACKUP_DIR/fvm_release" ]; then
        cp "$BACKUP_DIR/fvm_release" "$PROJECT_ROOT/.fvm/release"
    else
        rm -f "$PROJECT_ROOT/.fvm/release"
    fi

    if [ -f "$BACKUP_DIR/fvm_version" ]; then
        cp "$BACKUP_DIR/fvm_version" "$PROJECT_ROOT/.fvm/version"
    else
        rm -f "$PROJECT_ROOT/.fvm/version"
    fi

    rm -f "$PROJECT_ROOT/.fvm/flutter_sdk"
    if [ -f "$BACKUP_DIR/flutter_sdk.link" ]; then
        ln -s "$(cat "$BACKUP_DIR/flutter_sdk.link")" "$PROJECT_ROOT/.fvm/flutter_sdk"
    fi

    mkdir -p "$PROJECT_ROOT/.fvm/versions"
    find "$PROJECT_ROOT/.fvm/versions" -maxdepth 1 -mindepth 1 -type l -delete
    if [ -f "$BACKUP_DIR/fvm_version_links.tsv" ]; then
        while IFS=$'\t' read -r link_name link_target; do
            [ -n "$link_name" ] && ln -s "$link_target" "$PROJECT_ROOT/.fvm/versions/$link_name"
        done < "$BACKUP_DIR/fvm_version_links.tsv"
    fi
}

ensure_fvm_version() {
    local version="$1"

    if ! command -v fvm >/dev/null 2>&1; then
        echo "fvm is required to build web with Flutter $version."
        return 1
    fi

    if [ ! -d "$FVM_CACHE_DIR/$version" ]; then
        echo "Flutter $version is not installed in FVM. Installing..."
        fvm install "$version" || return 1
    fi
}

use_fvm_version() {
    local version="$1"

    ensure_fvm_version "$version"
    echo "Running: fvm use $version --skip-pub-get"
    fvm use "$version" --skip-pub-get || return 1
}

backup_fvm_state

# Change to project root for all commands
cd "$PROJECT_ROOT"

WEB_RENDERER="${WEB_RENDERER:-html}"
PRUNE_CANVASKIT="${PRUNE_CANVASKIT:-true}"
FLUTTER_CMD=(fvm flutter)

BUILD_ARGS=(--release --no-pub --no-web-resources-cdn --pwa-strategy=none)
if [ -n "$WEB_RENDERER" ]; then
    BUILD_ARGS+=(--web-renderer "$WEB_RENDERER")
fi

APP_VERSION_FULL=$(awk -F': *' '/^version:/ {print $2; exit}' "$PUBSPEC_PATH")
APP_VERSION_NAME="${APP_VERSION_FULL%%+*}"
APP_BUILD_NUMBER=""
if [[ "$APP_VERSION_FULL" == *"+"* ]]; then
    APP_BUILD_NUMBER="${APP_VERSION_FULL#*+}"
fi
BUILD_ARGS+=(--dart-define "APP_VERSION=$APP_VERSION_NAME")
BUILD_ARGS+=(--dart-define "APP_BUILD_NUMBER=$APP_BUILD_NUMBER")

# Function to restore original content
restore_original() {
    cp "$BACKUP_DIR/app_lang_version_utils.dart" "$LANG_FILE_PATH"
    cp "$BACKUP_DIR/pubspec.yaml" "$PUBSPEC_PATH"
    if [ -f "$BACKUP_DIR/vscode_settings.json" ]; then
        mkdir -p "$(dirname "$VSCODE_SETTINGS_PATH")"
        cp "$BACKUP_DIR/vscode_settings.json" "$VSCODE_SETTINGS_PATH"
    else
        rm -f "$VSCODE_SETTINGS_PATH"
    fi
    cp "$BACKUP_DIR/AndroidManifest.xml" "$MANIFEST"
    cp "$BACKUP_DIR/build.gradle.kts" "$GRADLE"
    if compgen -G "$BACKUP_DIR/l10n/app_localizations*.dart" >/dev/null; then
        mkdir -p "$L10N_DIR"
        cp "$BACKUP_DIR"/l10n/app_localizations*.dart "$L10N_DIR/"
    fi
    rm -f "$PROJECT_ROOT/.flutter-plugins"
    restore_fvm_state
    rm -rf "$BACKUP_DIR"
    echo "Restored original files"
}

replace_in_file() {
    local pattern="$1"
    local replacement="$2"
    local file="$3"
    PATTERN="$pattern" REPLACEMENT="$replacement" perl -0pi -e 's{$ENV{PATTERN}}{$ENV{REPLACEMENT}}g' "$file"
}

clear_pubspec_lock() {
    rm -f "$PUBSPEC_LOCK_PATH"
    echo "[OK] removed pubspec.lock; dependencies will be resolved again"
}

version_web_build_assets() {
    local build_output="$PROJECT_ROOT/build/web"
    local bootstrap_path="$build_output/flutter_bootstrap.js"
    local index_path="$build_output/index.html"
    local main_js_path="$build_output/main.dart.js"
    local canvaskit_path="$build_output/canvaskit"
    local git_ref
    local build_hash
    local hashed_bootstrap_name
    local hashed_main_name
    local hashed_canvaskit_name
    local is_html_renderer=false

    if [ ! -f "$index_path" ]; then
        echo "Missing Flutter index output: $index_path"
        return 1
    fi

    if [ ! -f "$bootstrap_path" ]; then
        echo "Missing Flutter bootstrap output: $bootstrap_path"
        return 1
    fi

    if [ ! -f "$main_js_path" ]; then
        echo "Missing Flutter main JS output: $main_js_path"
        return 1
    fi

    if grep -q '"renderer":"html"' "$bootstrap_path"; then
        is_html_renderer=true
    fi

    if [ "$is_html_renderer" != true ] && [ ! -d "$canvaskit_path" ]; then
        echo "Missing Flutter CanvasKit output: $canvaskit_path"
        return 1
    fi

    git_ref="$(git rev-parse --short HEAD 2>/dev/null || echo nogit)"
    build_hash="$(printf '%s-%s-%s' "$choice" "$git_ref" "$(date +%s)" | shasum -a 256 | awk '{print substr($1, 1, 12)}')"
    hashed_bootstrap_name="flutter_bootstrap.$build_hash.js"
    hashed_main_name="main.dart.$build_hash.js"
    hashed_canvaskit_name="canvaskit_$build_hash"

    echo "Applying web asset hash: $build_hash"

    # Rename deferred loading chunks and patch their references inside main.dart.js.
    shopt -s nullglob
    local part_file
    for part_file in "$build_output"/main.dart.js_*.part.js; do
        local part_name
        local hashed_part_name
        part_name="$(basename "$part_file")"
        hashed_part_name="${part_name%.js}.$build_hash.js"
        replace_in_file "$part_name" "$hashed_part_name" "$main_js_path" || return 1
        mv "$part_file" "$build_output/$hashed_part_name"
        rm -f "$part_file.br" "$part_file.gz"
    done
    shopt -u nullglob

    # Rename main.dart.js and patch Flutter's generated build config.
    replace_in_file '"mainJsPath":"main\.dart\.js"' "\"mainJsPath\":\"$hashed_main_name\"" "$bootstrap_path" || return 1
    mv "$main_js_path" "$build_output/$hashed_main_name"
    rm -f "$main_js_path.br" "$main_js_path.gz"

    if [ "$is_html_renderer" = true ]; then
        if [ -d "$canvaskit_path" ] && [ "$PRUNE_CANVASKIT" != false ]; then
            rm -rf "$canvaskit_path"
            echo "[OK] removed unused CanvasKit output for HTML renderer"
        else
            echo "[OK] HTML renderer build; CanvasKit hashing skipped"
        fi
    else
        # Move CanvasKit into a versioned directory and point Flutter loader/engine at it.
        mv "$canvaskit_path" "$build_output/$hashed_canvaskit_name"
        replace_in_file '_flutter\.loader\.load\(\{' "_flutter.loader.load({config:{canvasKitBaseUrl:\"$hashed_canvaskit_name/\"}," "$bootstrap_path" || return 1
        replace_in_file 'engineInitializer\.initializeEngine\(\)' "engineInitializer.initializeEngine({canvasKitBaseUrl:\"$hashed_canvaskit_name/\"})" "$bootstrap_path" || return 1
    fi
    rm -f "$bootstrap_path.br" "$bootstrap_path.gz"

    # Rename the bootstrap entry itself so browsers cannot reuse stale loader config.
    replace_in_file 'flutter_bootstrap\.js' "$hashed_bootstrap_name" "$index_path" || return 1
    mv "$bootstrap_path" "$build_output/$hashed_bootstrap_name"

    echo "[OK] flutter_bootstrap.js -> $hashed_bootstrap_name"
    echo "[OK] main.dart.js -> $hashed_main_name"
    if [ "$is_html_renderer" != true ]; then
        echo "[OK] canvaskit -> $hashed_canvaskit_name/"
    fi
}

prune_web_runtime_requests() {
    local build_output="$PROJECT_ROOT/build/web"
    local bootstrap_path="$build_output/flutter_bootstrap.js"
    local main_js_path="$build_output/main.dart.js"
    local service_worker_path="$build_output/flutter_service_worker.js"
    local version_json_path="$build_output/version.json"
    local wakelock_asset_dir="$build_output/assets/packages/wakelock_plus"
    local wake_lock_data_url

    if [ -f "$bootstrap_path" ] && grep -q 'serviceWorkerSettings' "$bootstrap_path"; then
        perl -0pi -e 's/\n\s*serviceWorkerSettings:\s*\{[^{}]*\}\s*,?//g' "$bootstrap_path" || return 1
        echo "[OK] disabled Flutter service worker registration"
    fi

    if [ -f "$service_worker_path" ]; then
        cat > "$service_worker_path" <<'EOF'
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
EOF
        rm -f "$service_worker_path.br" "$service_worker_path.gz"
        echo "[OK] replaced flutter_service_worker.js with cleanup worker"
    fi

    # Keep wakelock_plus usable on modern browsers without loading its bundled
    # NoSleep.js fallback asset.
    wake_lock_data_url='data:text/javascript;charset=utf-8,(function()%7Bvar%20sentinel%3Dnull%3Bwindow.Wakelock%3D%7Btoggle%3Afunction(enable)%7Bif(enable%26%26navigator.wakeLock)%7Bnavigator.wakeLock.request(%27screen%27).then(function(s)%7Bsentinel%3Ds%3B%7D).catch(function()%7B%7D)%3B%7Delse%20if(sentinel)%7Bsentinel.release()%3Bsentinel%3Dnull%3B%7D%7D%2Cenabled%3Afunction()%7Breturn%20Promise.resolve(!!sentinel)%3B%7D%7D%3B%7D)()%3B'

    if [ -f "$main_js_path" ] && grep -q '"assets/no_sleep.js"' "$main_js_path"; then
        replace_in_file '"assets/no_sleep\.js"' "\"$wake_lock_data_url\"" "$main_js_path" || return 1
        rm -rf "$wakelock_asset_dir"
        echo "[OK] removed wakelock_plus NoSleep.js web asset request"
    fi

    if [ -f "$version_json_path" ]; then
        rm -f "$version_json_path"
        echo "[OK] removed package_info_plus version.json output"
    fi
}

if ! use_fvm_version "$WEB_FLUTTER_VERSION"; then
    echo "Failed to switch Flutter SDK to $WEB_FLUTTER_VERSION."
    restore_original
    exit 1
fi

# ── 1. Patch app_lang_version_utils.dart ─────────────────────────────────────
replace_in_file 'return [123];' "return $choice;" "$LANG_FILE_PATH"
echo "[OK] $LANG_FILE_PATH  →  getLangVersion() = $choice"

# ── 2. Patch AndroidManifest.xml: android:label ──────────────────────────────
replace_in_file 'android:label="[^"]*"' "android:label=\"$APP_NAME\"" "$MANIFEST"
echo "[OK] $MANIFEST  →  android:label = \"$APP_NAME\""

# ── 3. Patch AndroidManifest.xml: android:icon ───────────────────────────────
replace_in_file 'android:icon="@mipmap/[^"]*"' "android:icon=\"$APP_ICON\"" "$MANIFEST"
echo "[OK] $MANIFEST  →  android:icon = \"$APP_ICON\""

# ── 4. Patch build.gradle.kts applicationId ──────────────────────────────────
replace_in_file 'applicationId = "live\.bogo\.app\.live_app\.[a-z]*"' "applicationId = \"$APP_ID\"" "$GRADLE"
echo "[OK] $GRADLE  →  applicationId = \"$APP_ID\""

echo ""

# Step 1: Clean
echo "Running: ${FLUTTER_CMD[*]} clean"
"${FLUTTER_CMD[@]}" clean
if [ $? -ne 0 ]; then
    echo "Clean failed!"
    restore_original
    exit 1
fi

echo ""

# Step 2: Refresh packages
clear_pubspec_lock
echo "Running: ${FLUTTER_CMD[*]} pub get"
"${FLUTTER_CMD[@]}" pub get
if [ $? -ne 0 ]; then
    echo "flutter pub get failed!"
    restore_original
    exit 1
fi

echo ""

# Step 3: Build
echo "Running: ${FLUTTER_CMD[*]} build web ${BUILD_ARGS[*]}"
"${FLUTTER_CMD[@]}" build web "${BUILD_ARGS[@]}"
if [ $? -ne 0 ]; then
    echo "Build failed!"
    restore_original
    exit 1
fi

echo ""

# Step 4: Remove avoidable web runtime requests
prune_web_runtime_requests
if [ $? -ne 0 ]; then
    echo "Web runtime request pruning failed!"
    restore_original
    exit 1
fi

echo ""

# Step 5: Add build hash to cache-sensitive web artifacts
version_web_build_assets
if [ $? -ne 0 ]; then
    echo "Web asset hash step failed!"
    restore_original
    exit 1
fi

echo ""

# Step 6: Verify Drift wasm asset
WASM_OUTPUT="$PROJECT_ROOT/build/web/sqlite3.wasm"
if [ ! -f "$WASM_OUTPUT" ]; then
    echo "Missing required Drift wasm asset: $WASM_OUTPUT"
    echo "Expected web/sqlite3.wasm to be copied by flutter build web."
    restore_original
    exit 1
fi
echo "[OK] Found Drift wasm asset at $WASM_OUTPUT"

echo ""

# Restore original content
restore_original

echo ""
echo "Build successful!"
