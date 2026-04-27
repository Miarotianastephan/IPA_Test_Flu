#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LANG_FILE_PATH="$PROJECT_ROOT/lib/utils/app_lang_version_utils.dart"
PUBSPEC_PATH="$PROJECT_ROOT/pubspec.yaml"
MANIFEST="$PROJECT_ROOT/android/app/src/main/AndroidManifest.xml"
GRADLE="$PROJECT_ROOT/android/app/build.gradle.kts"

BACKUP_DIR="$(mktemp -d)"
cp "$LANG_FILE_PATH" "$BACKUP_DIR/app_lang_version_utils.dart"
cp "$PUBSPEC_PATH" "$BACKUP_DIR/pubspec.yaml"
cp "$MANIFEST" "$BACKUP_DIR/AndroidManifest.xml"
cp "$GRADLE" "$BACKUP_DIR/build.gradle.kts"

restore_original() {
  cp "$BACKUP_DIR/app_lang_version_utils.dart" "$LANG_FILE_PATH"
  cp "$BACKUP_DIR/pubspec.yaml" "$PUBSPEC_PATH"
  cp "$BACKUP_DIR/AndroidManifest.xml" "$MANIFEST"
  cp "$BACKUP_DIR/build.gradle.kts" "$GRADLE"
  rm -rf "$BACKUP_DIR"
  echo "Restored original files"
}

trap restore_original EXIT

sed_in_place() {
  local expression="$1"
  local file="$2"

  sed -i.bak "$expression" "$file"
  rm -f "$file.bak"
}

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
echo ""

# 1. Patch app_lang_version_utils.dart
sed_in_place "s/return [123];/return $choice;/" "$LANG_FILE_PATH"
echo "[OK] $LANG_FILE_PATH  -> getLangVersion() = $choice"

# 2. Patch AndroidManifest.xml: android:label
sed_in_place "s/android:label=\"[^\"]*\"/android:label=\"$APP_NAME\"/" "$MANIFEST"
echo "[OK] $MANIFEST  -> android:label = \"$APP_NAME\""

# 3. Patch AndroidManifest.xml: android:icon
sed_in_place "s|android:icon=\"@mipmap/[^\"]*\"|android:icon=\"$APP_ICON\"|" "$MANIFEST"
echo "[OK] $MANIFEST  -> android:icon = \"$APP_ICON\""

# 4. Patch build.gradle.kts applicationId
sed_in_place "s|applicationId = \"live\.bogo\.app\.live_app\.[a-z]*\"|applicationId = \"$APP_ID\"|" "$GRADLE"
echo "[OK] $GRADLE  -> applicationId = \"$APP_ID\""

echo ""

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

  echo "Running: flutter ${BASE_ARGS[*]}"
  flutter "${BASE_ARGS[@]}"
else
  echo "Running: flutter ${BUILD_ARGS[*]}"
  flutter "${BUILD_ARGS[@]}"
fi

echo ""
echo "Mobile build successful!"
