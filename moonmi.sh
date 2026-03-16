#!/usr/bin/env bash
set -euo pipefail
scriptdir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
url="https://archive.org/download/nova-launcher-6.2.19/NovaLauncher_6.2.19.apk"
cleanup() {
  rm -f "$scriptdir/launcher.apk"
}
trap cleanup EXIT SIGINT

depcheck() {
   local cmd=
   local missing=0
   for cmd in "$@"; do
     if ! command -v "$cmd" >/dev/null 2>&1; then
       echo "Required command $cmd is not installed."
       echo "Install it and try again."
       missing=1
     fi
   done
   return $missing
}

echo "Moonmi 1.0"
echo "Turns your Sunmi M2 into an actually usable device with a good launcher (the Sunmi Launcher is bad)"
echo "I called it Moonmi because Moonmi escapes Sunmi's launcher (installs Nova Launcher, Moonmi is not a launcher)"
echo
echo "Performing dependency check..."
depcheck adb || exit 1

echo
echo "Fetching launcher..."
if command -v wget >/dev/null 2>&1; then
   echo "Downloading with wget..."
   wget -q -O "$scriptdir/launcher.apk" "$url" --show-progress
elif command -v curl >/dev/null 2>&1; then
   echo "wget is not installed. Falling back to curl."
   echo "Downloading with curl..."
   curl -L -o "$scriptdir/launcher.apk" "$url"
else
   echo "Neither wget nor curl are installed. Exiting."
   exit 1
fi

echo
echo "Waiting for ADB device... (Device must be in Android, not fastboot, recovery, etc.)"
adb wait-for-device
echo "Found ADB device."
echo "Installing Nova Launcher..."
adb install "$scriptdir/launcher.apk"
echo "Install successful."
echo "Disabling existing launcher..."
adb shell pm disable-user --user 0 com.woyou.launcher
echo
echo "Install successful."
echo "Enjoy your Moonmi M2!"
exit 0
