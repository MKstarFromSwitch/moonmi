#!/usr/bin/env bash
set -euo pipefail
# Some logic was fixed and remade by ChatGPT

cleanup() {
  [[ -n "${tmpdir:-}" && -d "$tmpdir" && "$tmpdir" != "/" ]] && rm -rf "$tmpdir"
}

trap cleanup EXIT SIGINT SIGTERM

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

nova_url="https://archive.org/download/nova-launcher-6.2.19/NovaLauncher_6.2.19.apk"
gms_url="https://www.apkmirror.com/apk/google-inc/google-play-services/google-play-services-26-09-31-release/google-play-services-26-09-31-040300-877989800-2-android-apk-download/"
playstore_url="https://www.apkmirror.com/apk/google-inc/google-play-store/google-play-store-44-5-23-release/google-play-store-44-5-23-23-0-pr-715840561-android-apk-download/"

error() { printf "${RED}[Error] %s${RESET}\n" "$*" >&2; }
log() { printf "${GREEN}[Log] %s${RESET}\n" "$*"; }
warn() { printf "${YELLOW}[Warning] %s${RESET}\n" "$*"; }
inform() { printf "${BLUE}[Info] %s${RESET}\n" "$*"; }

header() {
  clear
  echo "=== Sunmi-M2-Toolbox ==="
  echo "A toolbox for your Sunmi M2"
  inform "There is an option to fix Play Store as it is hidden when you are connected to the Internet."
}

pause() { read -p "Press ENTER to continue... "; }
pause_exit() { read -p "Press ENTER to exit... "; }

install_nova() {
  local disable=true
  [[ "${1:-}" == "--no-disable" ]] && disable=false

  log "Downloading Nova Launcher..."
  tmpdir=$(mktemp -d)
  curl -fsSL -o "$tmpdir/nova.apk" "$nova_url" || wget -O "$tmpdir/nova.apk" "$nova_url"

  log "Installing Nova Launcher APK..."
  adb install "$tmpdir/nova.apk"

  $disable && adb shell pm disable-user --user 0 com.woyou.launcher

  log "Install successful."
}

main() {
  while true; do
    header
    echo
    echo "1. M2 Mods"
    inform "More will be added later, I'm just lazy for now."
    read -rp "Choose your option: " main_menu_opt
    case "$main_menu_opt" in
      1)
        header
        echo
        echo "1. Install Nova Launcher while disabling Sunmi Launcher"
        echo "2. Install Nova Launcher without disabling Sunmi Launcher"
        echo "3. Update Google services to enable Play Store"
        inform "Other mods will be added later."
        echo
        read -rp "Choose an option: " sub_menu_opt
        case "$sub_menu_opt" in
          1)
            header
            echo
            inform "You will now install Nova Launcher on your Sunmi M2."
            inform "This will also disable the default Sunmi Launcher to make it persist reboots."
            read -rp "Are you sure? [y/N] " yes_no
            if [[ "$yes_no" =~ ^[Yy]$ ]]; then
              install_nova
              pause
              continue
            else
              log "Nothing done."
              pause
              continue
            fi
            ;;
          2)
            header
            echo
            inform "You will now install Nova Launcher on your Sunmi M2."
            inform "This will NOT disable the Sunmi Launcher."
            read -rp "Are you sure? [y/N] " yes_no
            if [[ "$yes_no" =~ ^[Yy]$ ]]; then
              install_nova --no-disable
              pause
              continue
            else
              log "Nothing done."
              pause
              continue
            fi
            ;;
          3)
            header
            echo
            inform "Manual download required for Google services."
            log "GMS: $gms_url"
            log "Play Store: $playstore_url"
            pause_exit
            exit 0
            ;;
          *)
            error "Invalid option."
            pause
            ;;
        esac
        ;;
      *)
        error "Invalid option."
        pause
        ;;
    esac
  done
}

header
echo
log "Performing dependency check..."
for cmd in curl wget adb lsusb; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    error "Required command $cmd is not installed."
    inform "Please install the package that provides it."
    exit 1
  fi
done # The logic below is made by ChatGPT

log "Waiting for Sunmi M2..."
until device_found=$(lsusb | grep -E '05c6:(9008|9091|9039)' | sed -E 's/(9008|9091|9039)//' | xargs); do
  sleep 1
done

if lsusb | grep -q '05c6:9008'; then
    error "Your Sunmi M2 is in EDL mode."
    inform "Hold the Power button for 15-20 seconds to exit EDL mode."
    exit 1
fi

log "Sunmi M2 detected as: $device_found"
main
