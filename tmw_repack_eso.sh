#!/usr/bin/env bash
#  tmw_repack_eso.sh  –  minimales Setup- & Repack-Script
#  Aufruf:  sudo ./tmw_repack_eso.sh
set -euo pipefail
 
######## 1. Realen Benutzer & Pfade bestimmen ##################################
if [[ -z "${SUDO_USER:-}" ]]; then
  echo "Bitte mit sudo ausführen (braucht Schreibrechte unter /data)." >&2
  exit 1
fi
U="$SUDO_USER"
UH=$(eval echo "~$U")
 
TARGET_BASE="/data/o-drive/TMOI_DataStorage/ESO-Exchange/OIA Deliveries eso Framework (dev)"
ESOFW_DIR="$UH/esofw"
UNIT_SRC="$UH/UNIT"
UNIT_DST="$ESOFW_DIR/UNIT"
TMP_DIR="$ESOFW_DIR/tmp"
TMWOI_DIR="$UH/tmwoi"
REPACK_REL="external/iav-androidHal/thirdParty/EsoFramework/repack_esofw.sh"
 
######## 2. Root-Teil: /data-Pfad anlegen & freigeben ###########################
mkdir -p "$TARGET_BASE"
chmod -R 777 /data
 
######## 3. User-Teil: Struktur anlegen, UNIT verschieben, repack starten ######
runuser -u "$U" -- env \
  INPUT_RPESOFW_SOURCE_FOLDER="$UNIT_DST" \
  OUTPUT_RPESOFW_TARGET_FOLDER="$TARGET_BASE/" \
  TEMP_RPESOFW_WORKING_DIR="$TMP_DIR" \
  bash -euxc "
    mkdir -p \"$ESOFW_DIR\" \"$TMP_DIR\"
    if [[ -d \"$UNIT_SRC\" && ! -d \"$UNIT_DST\" ]]; then
      mv \"$UNIT_SRC\" \"$UNIT_DST\"
    fi
    cd \"$TMWOI_DIR\"
    \"./$REPACK_REL\"
  "
 
echo "✅  tmw_repack_eso.sh abgeschlossen."
