#!/usr/bin/env bash
# tmw_install_aosp13.sh – fast AOSP-13 checkout
set -euo pipefail

echo "📻  Welcome to the TunerMiddleware automatic script"
echo "🔜  Installing AOSP 13 …"

# 1. Target directory
TARGET_DIR="${1:-$HOME/android/aosp-13}"
mkdir -p "$TARGET_DIR"
echo "➡️  Target directory: $TARGET_DIR"

# 2. Make sure curl exists
if ! command -v curl >/dev/null 2>&1; then
  echo "☑️  curl is missing – installing it now …"
  sudo apt update -qq
  sudo apt install -y curl
  echo "✅  curl installed"
fi

# 3. Ensure a recent repo tool (≥ 2.54)
if ! command -v repo >/dev/null 2>&1 || \
   [[ "$(repo --version 2>/dev/null | awk 'NR==1{print $NF}')" < 2.54 ]]; then
  echo "☑️  Installing latest repo tool …"
  mkdir -p "$HOME/bin"
  curl -Lo "$HOME/bin/repo" https://storage.googleapis.com/git-repo-downloads/repo
  chmod +x "$HOME/bin/repo"
  export PATH="$HOME/bin:$PATH"
  echo "✅  repo tool installed"
fi

# 4. Initialise repository (fast options)
cd "$TARGET_DIR"
if [[ ! -d .repo ]]; then
  echo "📦  Initialising AOSP repository …"
  repo init -u https://android.googlesource.com/platform/manifest \
            -b android-13.0.0_r82 \
            --depth=1 \
            --partial-clone --clone-filter=blob:limit=10M \
            --no-clone-bundle
fi

# 5. First (serial) sync – fail fast
echo "📥  First sync (serial) – please wait …"
repo sync -c -j1 --fail-fast

# 6. Parallel sync to finish
echo "📥  Second sync (parallel) …"
repo sync -c -j"$(nproc)" --force-sync

echo "✅  AOSP 13 download completed successfully."

# 7. Optional: run EsoFramework repack
read -r -p "Continue with EsoFramework repack now? [y/N] " ANSWER
if [[ "${ANSWER,,}" == "y" ]]; then
  ESO_SCRIPT="$HOME/tmw_repack_eso.sh"
  if [[ -f "$ESO_SCRIPT" ]]; then
      chmod +x "$ESO_SCRIPT"
      echo "🚀  Running tmw_repack_eso.sh …"
      sudo bash "$ESO_SCRIPT"
  else
      echo "❌  $ESO_SCRIPT not found."
  fi
else
  echo "ℹ️  Skipped EsoFramework repack."
fi
