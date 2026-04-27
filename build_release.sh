#!/usr/bin/env bash
set -e

# ─────────────────────────────────────────────
# Flutter APK release builder — lang version selector
# Usage: bash build_release.sh
# ─────────────────────────────────────────────

LANG_UTILS="lib/utils/app_lang_version_utils.dart"
MANIFEST="android/app/src/main/AndroidManifest.xml"
GRADLE="android/app/build.gradle.kts"

# macOS (BSD) sed compatibility: use -i '' on Darwin, -i elsewhere
inplace_sed() {
  local script="$1"; shift
  local file="$1"; shift
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "$script" "$file"
  else
    sed -i "$script" "$file"
  fi
}

echo ""
echo "Select lang version to build:"
echo "  1 = cn  (91,    live.bogo.app.live_app.cn,  icon=chinese)"
echo "  2 = yd  (XO,    live.bogo.app.live_app.xo,  icon=ic_launcher)"
echo "  3 = tk  (Tk,    live.bogo.app.live_app.tk,   icon=tik)"
echo ""
read -rp "Enter version [1/2/3]: " VERSION

case "$VERSION" in
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
  *)
    echo "Invalid version. Exiting."
    exit 1
    ;;
esac

echo ""
echo "Building: version=$VERSION  appName=$APP_NAME  appId=$APP_ID  icon=$APP_ICON"
echo ""

# ── 1. Patch app_lang_version_utils.dart ──────────────────────────────────────
inplace_sed "s/return [123];/return $VERSION;/" "$LANG_UTILS"
echo "[OK] $LANG_UTILS  →  getLangVersion() = $VERSION"

# ── 2. Patch AndroidManifest.xml: android:label ───────────────────────────────
inplace_sed "s/android:label=\"[^\"]*\"/android:label=\"$APP_NAME\"/" "$MANIFEST"
echo "[OK] $MANIFEST  →  android:label = \"$APP_NAME\""

# ── 3. Patch AndroidManifest.xml: android:icon ────────────────────────────────
inplace_sed "s|android:icon=\"@mipmap/[^\"]*\"|android:icon=\"$APP_ICON\"|" "$MANIFEST"
echo "[OK] $MANIFEST  →  android:icon = \"$APP_ICON\""

# ── 4. Patch build.gradle.kts applicationId ───────────────────────────────────
inplace_sed "s|applicationId = \"live\.bogo\.app\.live_app\.[a-z]*\"|applicationId = \"$APP_ID\"|" "$GRADLE"
echo "[OK] $GRADLE  →  applicationId = \"$APP_ID\""

# ── 5. Clean previous build ───────────────────────────────────────────────────
echo ""
echo "Running: flutter clean"
flutter clean

# ── 6. Build APK release ──────────────────────────────────────────────────────
echo ""
echo "Running: flutter build apk --release"
echo ""
flutter build apk --release

# ── 7. Copy APK with flavor name ──────────────────────────────────────────────
BUILD_DATE=$(date +"%Y%m%d_%H%M")
APP_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: *//' | cut -d'+' -f1 | tr -d '[:space:]')
APK_SRC="build/app/outputs/flutter-apk/app-release.apk"
APK_DST="build/app/outputs/flutter-apk/app-release-${APP_NAME}-${APP_VERSION}-${BUILD_DATE}.apk"

if [ -f "$APK_SRC" ]; then
  cp "$APK_SRC" "$APK_DST"
  APK_SIZE=$(du -sh "$APK_DST" | cut -f1)

  echo ""
  echo "════════════════════════════════════════════"
  echo "  BUILD COMPLETE"
  echo "════════════════════════════════════════════"
  echo "  Lang version : $VERSION"
  echo "  App name     : $APP_NAME"
  echo "  App ID       : $APP_ID"
  echo "  Icon         : $APP_ICON"
  echo "  App version  : $APP_VERSION"
  echo "  APK file     : $APK_DST"
  echo "  APK size     : $APK_SIZE"
  echo "  Built at     : $BUILD_DATE"
  echo "════════════════════════════════════════════"
  echo ""
else
  echo ""
  echo "Build finished. APK expected at: $APK_SRC"
fi
