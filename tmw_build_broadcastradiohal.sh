#!/usr/bin/env bash
# tmw_build_broadcastradiohal.sh – builds the Broadcastradio HAL
set -euo pipefail

# 1. Directory variables
H="$HOME"
AOSP="$H/android/aosp-13"
DEST_VENDOR="$AOSP/vendor/tmoi"
BR="$DEST_VENDOR/broadcastradio"

# 2. Locate vendor-cariad ZIP
ZIP_SRC=$(ls "$H"/vendor-cariad*.zip 2>/dev/null | head -n1) || true
[[ -f "${ZIP_SRC:-}" ]] || { echo "❌  No vendor-cariad*.zip found in \$HOME."; exit 1; }

# 3. Unpack the ZIP (handles both with/without top-level dir)
TMP_UNZIP=$(mktemp -d)
echo "📦  Unpacking $(basename "$ZIP_SRC") …"
unzip -q "$ZIP_SRC" -d "$TMP_UNZIP"

mapfile -t TOPS < <(find "$TMP_UNZIP" -mindepth 1 -maxdepth 1 -type d)
if [[ ${#TOPS[@]} -eq 1 ]]; then
    VENDOR_SRC="${TOPS[0]}"
else
    VENDOR_SRC="$TMP_UNZIP/vendor-cariad-content"
    mkdir -p "$VENDOR_SRC"
    shopt -s dotglob
    for f in "$TMP_UNZIP"/*; do
        [[ "$f" == "$VENDOR_SRC" ]] && continue
        mv "$f" "$VENDOR_SRC/"
    done
    shopt -u dotglob
fi

# 4. Build packing structure
echo "📁  Preparing $DEST_VENDOR …"
mkdir -p "$DEST_VENDOR"
rm -rf "$BR"
cp -a "$H/tmwoi/external/iav-androidHal" "$BR"

mkdir -p "$BR/thirdParty"
cp -a "$VENDOR_SRC" "$BR/thirdParty/vendor-cariad-hardware_interfaces"
cp -a "$H/tmwoi/buildArtifacts" "$BR/"
cp -a "$H/tmwoi/external/cariad-lum-ipc" "$DEST_VENDOR/"

# 5. Execute the build script
echo "⚙️  Executing Broadcastradio HAL build …"
cd "$AOSP"
./vendor/tmoi/broadcastradio/aospResources/build_broadcastradio.sh

echo "✅  Broadcastradio HAL build finished successfully."
