#!/usr/bin/env bash
# tmw_build_libtuner.sh – prepares and builds Libtuner
set -euo pipefail

echo "📻  Welcome to the TunerMiddleware automatic script"
echo "🔜  Installing Libtuner …"

# 1. Create working directories
mkdir -p "$HOME/tmwoi"
mkdir -p "$HOME/eRDwithHD"

# 2. Unpack ZIP archives
echo "📦  Unpacking TMW-OI repo …"
unzip -q "$HOME"/TMW-OI*.zip  -d "$HOME/tmwoi"

echo "📦  Unpacking RadioDriver repo …"
unzip -q "$HOME"/eRDwithHD*.zip -d "$HOME/eRDwithHD"

# 3. Remove single top-level wrapper directory, if any
shopt -s dotglob nullglob
TMW_SUBDIRS=("$HOME"/tmwoi/*/)
[[ ${#TMW_SUBDIRS[@]} -eq 1 ]] && {
    mv "$HOME"/tmwoi/*/* "$HOME/tmwoi/"
    rmdir "$HOME"/tmwoi/* 2>/dev/null || true
}
ERD_SUBDIRS=("$HOME"/eRDwithHD/*/)
[[ ${#ERD_SUBDIRS[@]} -eq 1 ]] && {
    mv "$HOME"/eRDwithHD/*/* "$HOME/eRDwithHD/"
    rmdir "$HOME"/eRDwithHD/* 2>/dev/null || true
}
shopt -u dotglob nullglob

# 4. Install required packages
echo "📥  Installing required packages …"
sudo apt update
sudo apt install -y ninja-build cmake openjdk-17-jdk wget unzip git

# 5. Install Android SDK
echo "📥  Setting up Android SDK …"
mkdir -p "$HOME/android-sdk"
cd       "$HOME/android-sdk"
wget -q https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O cmdtools.zip
mkdir -p cmdline-tools
unzip -q cmdtools.zip -d cmdline-tools/tmp
mv cmdline-tools/tmp/cmdline-tools/* cmdline-tools/
rm -rf cmdline-tools/tmp cmdtools.zip

export ANDROID_HOME="$HOME/android-sdk"
export PATH="$ANDROID_HOME/cmdline-tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
export JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"

# 6. Install Android NDK
echo "📥  Installing Android NDK 26.3 …"
$ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root="$ANDROID_HOME" "ndk;26.3.11579264"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/26.3.11579264"

# 7. Update DEFAULT_TOOLCHAIN_FILE path
TOOLCHAIN_PATH="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake"
BUILD_SCRIPT="$HOME/tmwoi/buildSystem/scripts/android_clang_Linux.sh"
sed -i "s|DEFAULT_TOOLCHAIN_FILE=.*|DEFAULT_TOOLCHAIN_FILE=$TOOLCHAIN_PATH|" "$BUILD_SCRIPT"

# 8. Integrate RadioDriver
echo "📻  Integrating RadioDriver …"
ERD_TARGET="$HOME/tmwoi/external/iav-tunerhal-nxp-erd/nxp-erd/eRD_Customer/src"
ERD_THIRD_PARTY="$HOME/tmwoi/external/iav-tunerhal-nxp-erd/thirdParty/nxp-erd/eRD_Customer/src"
mkdir -p "$ERD_TARGET" "$ERD_THIRD_PARTY"
cp -r "$HOME/eRDwithHD/src/radioDriver" "$ERD_TARGET/"
cp -r "$HOME/eRDwithHD/src/radioDriver" "$ERD_THIRD_PARTY/"
rm -f "$ERD_TARGET/radioDriver/CMakeLists.txt" "$ERD_THIRD_PARTY/radioDriver/CMakeLists.txt"

# 9. Build Libtuner
chmod +x "$BUILD_SCRIPT"
echo "⚙️  Building Libtuner …"
cd "$HOME/tmwoi"
./buildSystem/scripts/android_clang_Linux.sh

echo "✅  Libtuner installation finished successfully."

# 10. Prompt for AOSP-13 installation
read -r -p "Continue with AOSP 13 installation? [y/N] " ANSWER
if [[ "${ANSWER,,}" == "y" ]]; then
    AOSP_SCRIPT="$HOME/tmw_install_aosp13.sh"
    if [[ -f "$AOSP_SCRIPT" ]]; then
        chmod +x "$AOSP_SCRIPT"
        echo "🚀  Running tmw_install_aosp13.sh …"
        bash "$AOSP_SCRIPT"
    else
        echo "❌  $AOSP_SCRIPT not found."
    fi
else
    echo "ℹ️  Skipped AOSP 13 installation."
fi
