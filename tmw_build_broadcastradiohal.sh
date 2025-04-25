#!/usr/bin/env bash
#  tmw_build_broadcastradiohal.sh  –  v4
set -euo pipefail

# --------------------------------------------------------------------------- #
# 0.  Pfad-Variablen
H="$HOME"
AOSP="$H/android/aosp-13"
DEST_VENDOR="$AOSP/vendor/tmoi"
BR="$DEST_VENDOR/broadcastradio"

ZIP_SRC=$(ls "$H"/vendor-cariad*.zip 2>/dev/null | head -n1) || true
[[ -f "${ZIP_SRC:-}" ]] || { echo "❌  Keine vendor-cariad*.zip im Home gefunden."; exit 1; }

# --------------------------------------------------------------------------- #
# 1.  ZIP entpacken & Quellordner ermitteln
TMP_UNZIP=$(mktemp -d)
echo ">> Entpacke $(basename "$ZIP_SRC") …"
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
fi

# --------------------------------------------------------------------------- #
# 2.  Zielstruktur neu aufsetzen
echo ">> Erstelle $DEST_VENDOR …"
mkdir -p "$DEST_VENDOR"
rm -rf  "$BR"                            # alte Kopie sicher entfernen

echo ">> Kopiere iav-androidHal als broadcastradio …"
cp -a "$H/tmwoi/external/iav-androidHal" "$BR"

echo ">> Kopiere vendor-cariad → vendor-cariad-hardware_interfaces …"
mkdir -p "$BR/thirdParty"
cp -a "$VENDOR_SRC" "$BR/thirdParty/vendor-cariad-hardware_interfaces"

echo ">> Kopiere buildArtifacts …"
cp -a "$H/tmwoi/buildArtifacts" "$BR/"

echo ">> Kopiere cariad-lum-ipc …"
cp -a "$H/tmwoi/external/cariad-lum-ipc" "$DEST_VENDOR/"

# --------------------------------------------------------------------------- #
# 3.  Broadcastradio-HAL bauen
echo ">> Starte Broadcastradio-HAL-Build …"
cd "$AOSP"
./vendor/tmoi/broadcastradio/aospResources/build_broadcastradio.sh

echo "✅  Broadcastradio-HAL-Build abgeschlossen."
