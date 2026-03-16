# Moonmi
A script that escapes the standard launcher on the Sunmi M2 (I don't have other Sunmi's, no testing for anything other than the M2)

## Features
   - Disables the regular Sunmi Launcher to prevent it returning on reboot
   - Installs Nova Launcher to replace it
   - Basically unlocks your Sunmi's launcher
   - The Sunmi launcher is: com.woyou.launcher, and the Nova Launcher version is 6.2.19.


## Requirements
 - A working Linux system with ```bash```
 - An Internet connection (to download the launcher)
 - A Sunmi M2 (with USB debugging enabled, and connected to ADB in normal mode)

## How to run the script
```shell
sudo apt install git -y
git clone https://github.com/MKstarFromSwitch/moonmi.git
cd moonmi
./moonmi.sh
```
