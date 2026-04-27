#!/bin/bash
# Build Flutter web with version selection
# Run: bash scripts/build_web.sh

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
echo ""

# Determine project root (works from scripts/ or project root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LANG_FILE_PATH="$PROJECT_ROOT/lib/utils/app_lang_version_utils.dart"
PUBSPEC_PATH="$PROJECT_ROOT/pubspec.yaml"
MANIFEST="$PROJECT_ROOT/android/app/src/main/AndroidManifest.xml"
GRADLE="$PROJECT_ROOT/android/app/build.gradle.kts"

# Read original content for restore
BACKUP_DIR=$(mktemp -d)
cp "$LANG_FILE_PATH" "$BACKUP_DIR/app_lang_version_utils.dart"
cp "$PUBSPEC_PATH" "$BACKUP_DIR/pubspec.yaml"
cp "$MANIFEST" "$BACKUP_DIR/AndroidManifest.xml"
cp "$GRADLE" "$BACKUP_DIR/build.gradle.kts"

# Change to project root for all commands
cd "$PROJECT_ROOT"

BUILD_ARGS=(--release --no-pub --no-web-resources-cdn --pwa-strategy=none)

# Function to restore original content
restore_original() {
    cp "$BACKUP_DIR/app_lang_version_utils.dart" "$LANG_FILE_PATH"
    cp "$BACKUP_DIR/pubspec.yaml" "$PUBSPEC_PATH"
    cp "$BACKUP_DIR/AndroidManifest.xml" "$MANIFEST"
    cp "$BACKUP_DIR/build.gradle.kts" "$GRADLE"
    rm -rf "$BACKUP_DIR"
    echo "Restored original files"
}

replace_in_file() {
    local pattern="$1"
    local replacement="$2"
    local file="$3"
    PATTERN="$pattern" REPLACEMENT="$replacement" perl -0pi -e 's{$ENV{PATTERN}}{$ENV{REPLACEMENT}}g' "$file"
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

    if [ ! -d "$canvaskit_path" ]; then
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

    # Move CanvasKit into a versioned directory and point Flutter loader/engine at it.
    mv "$canvaskit_path" "$build_output/$hashed_canvaskit_name"
    replace_in_file '_flutter\.loader\.load\(\{' "_flutter.loader.load({config:{canvasKitBaseUrl:\"$hashed_canvaskit_name/\"}," "$bootstrap_path" || return 1
    replace_in_file 'engineInitializer\.initializeEngine\(\)' "engineInitializer.initializeEngine({canvasKitBaseUrl:\"$hashed_canvaskit_name/\"})" "$bootstrap_path" || return 1
    rm -f "$bootstrap_path.br" "$bootstrap_path.gz"

    # Rename the bootstrap entry itself so browsers cannot reuse stale loader config.
    replace_in_file 'flutter_bootstrap\.js' "$hashed_bootstrap_name" "$index_path" || return 1
    mv "$bootstrap_path" "$build_output/$hashed_bootstrap_name"

    echo "[OK] flutter_bootstrap.js -> $hashed_bootstrap_name"
    echo "[OK] main.dart.js -> $hashed_main_name"
    echo "[OK] canvaskit -> $hashed_canvaskit_name/"
}

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
echo "Running: flutter clean"
flutter clean
if [ $? -ne 0 ]; then
    echo "Clean failed!"
    restore_original
    exit 1
fi

echo ""

# Step 2: Refresh packages
echo "Running: flutter pub get"
flutter pub get
if [ $? -ne 0 ]; then
    echo "flutter pub get failed!"
    restore_original
    exit 1
fi

echo ""

# Step 3: Build
echo "Running: flutter build web ${BUILD_ARGS[*]}"
flutter build web "${BUILD_ARGS[@]}"
if [ $? -ne 0 ]; then
    echo "Build failed!"
    restore_original
    exit 1
fi

echo ""

# Step 4: Add build hash to cache-sensitive web artifacts
version_web_build_assets
if [ $? -ne 0 ]; then
    echo "Web asset hash step failed!"
    restore_original
    exit 1
fi

echo ""

# Step 5: Verify Drift wasm asset
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
