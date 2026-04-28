#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LANG_FILE_PATH="$PROJECT_ROOT/lib/utils/app_lang_version_utils.dart"
PUBSPEC_PATH="$PROJECT_ROOT/pubspec.yaml"
PUBSPEC_LOCK_PATH="$PROJECT_ROOT/pubspec.lock"
VSCODE_SETTINGS_PATH="$PROJECT_ROOT/.vscode/settings.json"
MANIFEST="$PROJECT_ROOT/android/app/src/main/AndroidManifest.xml"
GRADLE="$PROJECT_ROOT/android/app/build.gradle.kts"
L10N_DIR="$PROJECT_ROOT/lib/l10n"
MOBILE_FLUTTER_VERSION="${MOBILE_FLUTTER_VERSION:-3.41.7}"
FVM_CACHE_DIR="${FVM_CACHE_DIR:-$HOME/fvm/versions}"
CONTENT_BACKUP_DIR=$(mktemp -d)
FVM_STATE_BACKUP_DIR=$(mktemp -d)
FVM_STATE_BACKED_UP=false

cp "$LANG_FILE_PATH" "$CONTENT_BACKUP_DIR/app_lang_version_utils.dart"
cp "$PUBSPEC_PATH" "$CONTENT_BACKUP_DIR/pubspec.yaml"
[ -f "$VSCODE_SETTINGS_PATH" ] && cp "$VSCODE_SETTINGS_PATH" "$CONTENT_BACKUP_DIR/vscode_settings.json"
cp "$MANIFEST" "$CONTENT_BACKUP_DIR/AndroidManifest.xml"
cp "$GRADLE" "$CONTENT_BACKUP_DIR/build.gradle.kts"
mkdir -p "$CONTENT_BACKUP_DIR/l10n"
cp "$L10N_DIR"/app_localizations*.dart "$CONTENT_BACKUP_DIR/l10n/" 2>/dev/null || true

backup_fvm_state() {
  mkdir -p "$FVM_STATE_BACKUP_DIR"
  FVM_STATE_BACKED_UP=true

  [ -f "$PROJECT_ROOT/.fvmrc" ] && cp "$PROJECT_ROOT/.fvmrc" "$FVM_STATE_BACKUP_DIR/.fvmrc"
  [ -f "$PROJECT_ROOT/.fvm/fvm_config.json" ] && cp "$PROJECT_ROOT/.fvm/fvm_config.json" "$FVM_STATE_BACKUP_DIR/fvm_config.json"
  [ -f "$PROJECT_ROOT/.fvm/release" ] && cp "$PROJECT_ROOT/.fvm/release" "$FVM_STATE_BACKUP_DIR/release"
  [ -f "$PROJECT_ROOT/.fvm/version" ] && cp "$PROJECT_ROOT/.fvm/version" "$FVM_STATE_BACKUP_DIR/version"

  if [ -L "$PROJECT_ROOT/.fvm/flutter_sdk" ]; then
    readlink "$PROJECT_ROOT/.fvm/flutter_sdk" > "$FVM_STATE_BACKUP_DIR/flutter_sdk.link"
  fi

  if [ -d "$PROJECT_ROOT/.fvm/versions" ]; then
    find "$PROJECT_ROOT/.fvm/versions" -maxdepth 1 -mindepth 1 -type l | while read -r link_path; do
      printf '%s\t%s\n' "$(basename "$link_path")" "$(readlink "$link_path")"
    done > "$FVM_STATE_BACKUP_DIR/version_links.tsv"
  fi
}

restore_fvm_state() {
  if [ "$FVM_STATE_BACKED_UP" != true ]; then
    rm -rf "$FVM_STATE_BACKUP_DIR"
    return
  fi

  if [ -f "$FVM_STATE_BACKUP_DIR/.fvmrc" ]; then
    cp "$FVM_STATE_BACKUP_DIR/.fvmrc" "$PROJECT_ROOT/.fvmrc"
  else
    rm -f "$PROJECT_ROOT/.fvmrc"
  fi

  mkdir -p "$PROJECT_ROOT/.fvm"

  if [ -f "$FVM_STATE_BACKUP_DIR/fvm_config.json" ]; then
    cp "$FVM_STATE_BACKUP_DIR/fvm_config.json" "$PROJECT_ROOT/.fvm/fvm_config.json"
  else
    rm -f "$PROJECT_ROOT/.fvm/fvm_config.json"
  fi

  if [ -f "$FVM_STATE_BACKUP_DIR/release" ]; then
    cp "$FVM_STATE_BACKUP_DIR/release" "$PROJECT_ROOT/.fvm/release"
  else
    rm -f "$PROJECT_ROOT/.fvm/release"
  fi

  if [ -f "$FVM_STATE_BACKUP_DIR/version" ]; then
    cp "$FVM_STATE_BACKUP_DIR/version" "$PROJECT_ROOT/.fvm/version"
  else
    rm -f "$PROJECT_ROOT/.fvm/version"
  fi

  rm -f "$PROJECT_ROOT/.fvm/flutter_sdk"
  if [ -f "$FVM_STATE_BACKUP_DIR/flutter_sdk.link" ]; then
    ln -s "$(cat "$FVM_STATE_BACKUP_DIR/flutter_sdk.link")" "$PROJECT_ROOT/.fvm/flutter_sdk"
  fi

  mkdir -p "$PROJECT_ROOT/.fvm/versions"
  find "$PROJECT_ROOT/.fvm/versions" -maxdepth 1 -mindepth 1 -type l -delete
  if [ -f "$FVM_STATE_BACKUP_DIR/version_links.tsv" ]; then
    while IFS=$'\t' read -r link_name link_target; do
      [ -n "$link_name" ] && ln -s "$link_target" "$PROJECT_ROOT/.fvm/versions/$link_name"
    done < "$FVM_STATE_BACKUP_DIR/version_links.tsv"
  fi

  rm -rf "$FVM_STATE_BACKUP_DIR"
}

ensure_fvm_version() {
  local version="$1"

  if ! command -v fvm >/dev/null 2>&1; then
    echo "fvm is required to build mobile with Flutter $version."
    exit 1
  fi

  if [ ! -d "$FVM_CACHE_DIR/$version" ]; then
    echo "Flutter $version is not installed in FVM. Installing..."
    fvm install "$version"
  fi
}

use_fvm_version() {
  local version="$1"

  ensure_fvm_version "$version"
  echo "Running: fvm use $version --skip-pub-get"
  fvm use "$version" --skip-pub-get
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

restore_original() {
  cp "$CONTENT_BACKUP_DIR/app_lang_version_utils.dart" "$LANG_FILE_PATH"
  cp "$CONTENT_BACKUP_DIR/pubspec.yaml" "$PUBSPEC_PATH"
  if [ -f "$CONTENT_BACKUP_DIR/vscode_settings.json" ]; then
    mkdir -p "$(dirname "$VSCODE_SETTINGS_PATH")"
    cp "$CONTENT_BACKUP_DIR/vscode_settings.json" "$VSCODE_SETTINGS_PATH"
  else
    rm -f "$VSCODE_SETTINGS_PATH"
  fi
  cp "$CONTENT_BACKUP_DIR/AndroidManifest.xml" "$MANIFEST"
  cp "$CONTENT_BACKUP_DIR/build.gradle.kts" "$GRADLE"
  if compgen -G "$CONTENT_BACKUP_DIR/l10n/app_localizations*.dart" >/dev/null; then
    mkdir -p "$L10N_DIR"
    cp "$CONTENT_BACKUP_DIR"/l10n/app_localizations*.dart "$L10N_DIR/"
  fi
  restore_fvm_state
  rm -rf "$CONTENT_BACKUP_DIR"
  echo "Restored original files"
}

trap restore_original EXIT

cd "$PROJECT_ROOT"

if [ "$#" -eq 0 ]; then
  echo "Usage: bash scripts/build_mobile.sh build <platform> [flutter build args...]"
  echo "Examples:"
  echo "  bash scripts/build_mobile.sh build ios --release"
  echo "  bash scripts/build_mobile.sh build apk --release"
  exit 1
fi

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
echo "Building Flutter mobile: version=$choice  appName=$APP_NAME  appId=$APP_ID"
echo "Flutter SDK: $MOBILE_FLUTTER_VERSION"
echo ""

backup_fvm_state
use_fvm_version "$MOBILE_FLUTTER_VERSION"
FLUTTER_CMD=(fvm flutter)

# 1. Patch app_lang_version_utils.dart
replace_in_file 'return [123];' "return $choice;" "$LANG_FILE_PATH"
echo "[OK] $LANG_FILE_PATH  -> getLangVersion() = $choice"

# 2. Patch AndroidManifest.xml: android:label
replace_in_file 'android:label="[^"]*"' "android:label=\"$APP_NAME\"" "$MANIFEST"
echo "[OK] $MANIFEST  -> android:label = \"$APP_NAME\""

# 3. Patch AndroidManifest.xml: android:icon
replace_in_file 'android:icon="@mipmap/[^"]*"' "android:icon=\"$APP_ICON\"" "$MANIFEST"
echo "[OK] $MANIFEST  -> android:icon = \"$APP_ICON\""

# 4. Patch build.gradle.kts applicationId
replace_in_file 'applicationId = "live\.bogo\.app\.live_app\.[a-z]*"' "applicationId = \"$APP_ID\"" "$GRADLE"
echo "[OK] $GRADLE  -> applicationId = \"$APP_ID\""

echo ""
clear_pubspec_lock

BUILD_ARGS=("$@")

strip_target_platform_args() {
  local filtered=()
  local skip_next=0

  for arg in "$@"; do
    if [ "$skip_next" -eq 1 ]; then
      skip_next=0
      continue
    fi

    case "$arg" in
      --target-platform)
        skip_next=1
        ;;
      --target-platform=*)
        ;;
      *)
        filtered+=("$arg")
        ;;
    esac
  done

  printf '%s\n' "${filtered[@]}"
}

if [ "${BUILD_ARGS[0]}" = "build" ] && [ "${BUILD_ARGS[1]:-}" = "apk" ]; then
  BASE_ARGS=()
  while IFS= read -r line; do
    BASE_ARGS+=("$line")
  done < <(strip_target_platform_args "${BUILD_ARGS[@]}")

  if [[ ! " ${BASE_ARGS[*]} " =~ " --split-per-abi " ]]; then
    BASE_ARGS+=(--split-per-abi)
  fi

  echo "Running: ${FLUTTER_CMD[*]} ${BASE_ARGS[*]}"
  "${FLUTTER_CMD[@]}" "${BASE_ARGS[@]}"
else
  echo "Running: ${FLUTTER_CMD[*]} ${BUILD_ARGS[*]}"
  "${FLUTTER_CMD[@]}" "${BUILD_ARGS[@]}"
fi

echo ""
echo "Mobile build successful!"
