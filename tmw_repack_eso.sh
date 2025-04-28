#!/usr/bin/env bash
# tmw_repack_eso.sh – repacks EsoFramework
set -euo pipefail

# Make sure the script is started with sudo
if [[ -z "${SUDO_USER:-}" ]]; then
  echo "This script must be run with sudo -> sudo ./tmw_repack_eso.sh" >&2
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

# Create /data target and make it writable
mkdir -p "$TARGET_BASE"
chmod -R 777 /data

# Create user-side structure and run repack script as normal user
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

echo "✅  Repacking finished successfully."

# Prompt for Broadcastradio-HAL build
read -r -p 'Continue with Broadcastradio HAL build? [y/N] ' ANSWER
if [[ "${ANSWER,,}" == "y" ]]; then
  BR_SCRIPT="$UH/tmw_build_broadcastradiohal.sh"
  if [[ -f \"$BR_SCRIPT\" ]]; then
    chmod +x \"$BR_SCRIPT\"
    echo '🚀  Running tmw_build_broadcastradiohal.sh …'
    runuser -u \"$U\" -- bash \"$BR_SCRIPT\"
  else
    echo \"❌  $BR_SCRIPT not found.\"
  fi
else
  echo 'ℹ️  Skipped Broadcastradio HAL build.'
fi
