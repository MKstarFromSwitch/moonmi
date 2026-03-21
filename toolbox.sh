#!/usr/bin/env bash
set -euo pipefail

cleanup() {
  rm -rf "${tmpdir:-}"
}

trap cleanup EXIT SIGINT SIGTERM

# ANSI escape codes for colors added by ChatGPT
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

# some stuff we kinda need
nova_url="https://archive.org/download/nova-launcher-6.2.19/NovaLauncher_6.2.19.apk"
gms_url="https://www.apkmirror.com/apk/google-inc/google-play-services/google-play-services-26-09-31-release/google-play-services-26-09-31-040300-877989800-2-android-apk-download/"
playstore_url="https://www.apkmirror.com/apk/google-inc/google-play-store/google-play-store-44-5-23-release/google-play-store-44-5-23-23-0-pr-715840561-android-apk-download/"

error() {
    echo -e "${RED}[Error] $*${RESET}"
}

log() {
    echo -e "${GREEN}[Log] $@${RESET}"
}

warn() {
    echo -e "${YELLOW}[Warning] $@${RESET}"
}

inform() {
    echo -e "${BLUE}[Info] $@${RESET}"
}

header() {
  clear
  echo "=== Sunmi-M2-Toolbox ==="
  echo "A toolbox for your Sunmi M2"
  inform "There is an option to fix Play Store as it is hidden when you are connected to the Internet."
  # Note for me here: Don't forget to add 'echo' after header to get a newline for readability
}

pause() {
  read -p "Press ENTER to continue... " -s
}

pause_exit() {
  read -p "Press ENTER to exit... " -s
}

main() {
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
         echo
         log "Downloading Nova Launcher..."
         tmpdir=$(mktemp -d)
         curl -fsSL -o "$tmpdir/nova.apk" "$nova_url" || wget -O "$tmpdir/nova.apk" "$nova_url"
         log "Installing Nova Launcher APK..."
         adb install "$tmpdir/nova.apk"
         log "Disabling Sunmi Launcher..."
         adb shell pm disable-user --user 0 com.woyou.launcher
         log "Install successful."
         rm -rf "$tmpdir/"
         pause
         main
       else
         log "Nothing done."
         pause
         main
       fi
       ;;
      2)
         header
        echo
        inform "You will now install Nova Launcher on your Sunmi M2."
        inform "This will NOT disable the Sunmi Launcher, so the M2 will return to the Sunmi Launcher on reboot even when Nova is set to the default launcher in Settings."
        read -rp "Are you sure? [y/N] " yes_no
         if [[ "$yes_no" =~ ^[Yy]$ ]]; then
         echo
         log "Downloading Nova Launcher..."
         tmpdir=$(mktemp -d)
         curl -fsSL -o "$tmpdir/nova.apk" "$nova_url" || wget -O "$tmpdir/nova.apk" "$nova_url"
         log "Installing Nova Launcher APK..."
         adb install "$tmpdir/nova.apk"
         log "Install successful."
         rm -rf "$tmpdir/"
         pause
         main
       else
         log "Nothing done."
         pause
         main
       fi
       ;;
    3)
     header
     echo
     inform "Unfortunately most if not all APK sites block curl/wget downloads (due to JavaScript and Cloudflare) so you will need to do this one manually."
     inform "Don't worry, it's not that scary."
     echo
     log "Go to this link on your browser and click Download (scroll down if you don't see it): $gms_url"
     log "After the download finishes, run this command (you're not done yet, wait for the next step): mv com.google.android.gms_26.09.31_\(040300-877989800\)-260931000_minAPI23\(armeabi-v7a\)\(nodpi\)_apkmirror.com.apk gms.apk && adb install -r gms.apk"
     log "After adb says 'Success', go to this link on your browser and click Download: $playstore_url"
     log "After the download finishes, run this command (you are done once this finishes): mv com.android.vending_44.5.23-23_0_PR_715840561-84452300_minAPI23\(arm64-v8a,armeabi-v7a,x86,x86_64\)\(nodpi\)_apkmirror.com.apk pstore.apk && adb install -r pstore.apk"
     log "After adb says 'Success', you are done!"
     echo
     pause_exit
     exit 0
     ;;
   *)
     error "Invalid option."
     pause
     main
     ;;
   esac
esac
         
echo "=== Sunmi-M2-Toolbox ==="
echo "A toolbox for your Sunmi M2"
echo
log "Performing dependency check..."

for cmd in curl wget adb lsusb; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    error "Required command $cmd is not installed."
    inform "Please install the package that provides it."
    exit 1
  fi
done

log "Waiting for Sunmi M2..." # the logic below is a little implemented by ChatGPT

# Detect Sunmi M2 IDs (slightly implemented by ChatGPT)
device_found=$(lsusb | grep -E '05c6:(9008|9091|9039)' | sed -E 's/(9008|9091|9039)//' | xargs)

if [[ -z "$device_found" ]]; then
    warn "No Sunmi M2 detected. Make sure it is plugged in."
    exit 1
fi

# Check if the device is in EDL mode (05c6:9008) (implemented by ChatGPT)
if lsusb | grep -q '05c6:9008'; then
    error "Your Sunmi M2 is in EDL mode."
    inform "Hold the Power button for 15-20 seconds to exit EDL mode."
    exit 1
fi

log "Sunmi M2 detected as: $device_found"
main


