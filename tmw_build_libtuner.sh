#!/bin/bash
set -e
 
echo "🚀 Starting Libtuner Build Script..."
 
# === 1. Zielverzeichnisse erstellen ===
echo "📁 Creating working directories..."
mkdir -p "$HOME/tmwoi"
mkdir -p "$HOME/eRDwithHD"
 
# === 2. ZIPs entpacken ===
echo "📦 Extracting TMW-OI into $HOME/tmwoi..."
unzip -q "$HOME"/TMW-OI*.zip -d "$HOME/tmwoi"
 
echo "📦 Extracting eRDwithHD into $HOME/eRDwithHD..."
unzip -q "$HOME"/eRDwithHD*.zip -d "$HOME/eRDwithHD"
 
# === 3. Falls ZIP einen Unterordner enthält, Inhalt eine Ebene hochziehen ===
echo "📦 Cleaning up folder structures (if needed)..."
shopt -s dotglob nullglob
 
TMW_SUBDIRS=("$HOME"/tmwoi/*/)
if [ ${#TMW_SUBDIRS[@]} -eq 1 ]; then
    echo "↪️ Moving contents of nested TMW-OI folder up..."
    mv "$HOME"/tmwoi/*/* "$HOME"/tmwoi/
    rmdir "$HOME"/tmwoi/* 2>/dev/null || true
fi
 
ERD_SUBDIRS=("$HOME"/eRDwithHD/*/)
if [ ${#ERD_SUBDIRS[@]} -eq 1 ]; then
    echo "↪️ Moving contents of nested eRDwithHD folder up..."
    mv "$HOME"/eRDwithHD/*/* "$HOME"/eRDwithHD/

    rmdir "$HOME"/eRDwithHD/* 2>/dev/null || true
fi
 
shopt -u dotglob nullglob
 
# === 4. Build-Abhängigkeiten installieren ===
echo "🔧 Installing required packages..."
sudo apt update
sudo apt install -y ninja-build cmake openjdk-17-jdk wget unzip git
 
# === 5. Android SDK einrichten ===
echo "📥 Setting up Android SDK..."
mkdir -p "$HOME/android-sdk"
cd "$HOME/android-sdk"
wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O cmdtools.zip
 
mkdir -p cmdline-tools
unzip -q cmdtools.zip -d cmdline-tools/tmp
mv cmdline-tools/tmp/cmdline-tools/* cmdline-tools/
rm -rf cmdline-tools/tmp cmdtools.zip
 
# === 6. Umgebungsvariablen setzen ===
echo "🌍 Exporting environment variables..."
export ANDROID_HOME="$HOME/android-sdk"
export PATH=$ANDROID_HOME/cmdline-tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
 
# === 7. NDK installieren ===
echo "📦 Installing Android NDK 26.3..."
$ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "ndk;26.3.11579264"
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/26.3.11579264
 
# === 8. Toolchain-Pfad setzen ===
echo "🛠 Updating DEFAULT_TOOLCHAIN_FILE path..."
TOOLCHAIN_PATH="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake"
BUILD_SCRIPT="$HOME/tmwoi/buildSystem/scripts/android_clang_Linux.sh"
sed -i "s|DEFAULT_TOOLCHAIN_FILE=.*|DEFAULT_TOOLCHAIN_FILE=$TOOLCHAIN_PATH|g" "$BUILD_SCRIPT"
 
# === 9. eRD Struktur unter nxp-erd erstellen ===
echo "📁 Creating eRD structure (nxp-erd)..."
ERD_TARGET="$HOME/tmwoi/external/iav-tunerhal-nxp-erd/nxp-erd/eRD_Customer/src"
mkdir -p "$ERD_TARGET"
cp -r "$HOME/eRDwithHD/src/radioDriver" "$ERD_TARGET/"
rm -f "$ERD_TARGET/radioDriver/CMakeLists.txt"
 
# === 10. eRD Struktur unter thirdParty ergänzen ===
echo "📁 Creating eRD structure under thirdParty..."
ERD_THIRD_PARTY="$HOME/tmwoi/external/iav-tunerhal-nxp-erd/thirdParty/nxp-erd/eRD_Customer/src"
mkdir -p "$ERD_THIRD_PARTY"
cp -r "$HOME/eRDwithHD/src/radioDriver" "$ERD_THIRD_PARTY/"
rm -f "$ERD_THIRD_PARTY/radioDriver/CMakeLists.txt"
 
# === 11. Build-Skript ausführbar machen ===
echo "🔓 Making build script executable..."
chmod +x "$BUILD_SCRIPT"
 
# === 12. Build starten ===
echo "⚙️ Starting Libtuner build..."
cd "$HOME/tmwoi"
./buildSystem/scripts/android_clang_Linux.sh
 
echo ""
echo "🎉 Build process started – watch for 'Computed build environment' at the end!"
