# macOS Game Launcher Generator

A bash script that automatically scans an external drive for ROMs (`.iso` for PS2 and `.nsp` for Nintendo Switch) and generates native macOS Application bundles (`.app`) for each game. 

These generated `.app` wrappers allow you to launch your emulated games directly from Launchpad, Spotlight, or Finder as if they were native Mac apps, checking if your external drive is plugged in before launching.

## Features
* **Auto-App Generation:** Creates native macOS folder structures (`.app/Contents/MacOS`).
* **Dynamic Custom Icons:** Automatically generates a dark, minimalist `.icns` file for each game using the first letter of the game's title via ImageMagick.
* **Dependency Management:** Automatically checks for `magick` and installs it via Homebrew if missing.
* **Drive Verification:** Displays a native macOS alert (via AppleScript) if you try to open a game while the external drive is disconnected.
* **Duplicate Prevention:** Skips generating wrappers for games that already exist in the destination folder.

## Prerequisites
1. **macOS** environment.
2. [**Homebrew**](https://brew.sh/) installed (required to auto-install ImageMagick).
3. **Emulators Installed**:
   * [PCSX2](https://pcsx2.net/) for PS2.
   * [Ryujinx](https://ryujinx.org/) (or Yuzu/Suyu/Astris) for Nintendo Switch.

## Setup & Configuration
1. Clone this repository or download the script.
2. Open the script in a text editor and update the paths at the top of the file to match your environment:
   ```bash
   SOURCE_DIR_PS2="/Volumes/YourDriveName/Games/ps2"
   SOURCE_DIR_SWITCH="/Volumes/YourDriveName/Games/nswitch"
   DEST_DIR="/Applications/Games"
   
   # Emulator Paths
   EMULATOR_PS2="/Applications/PCSX2.app"
   EMULATOR_SWITCH_BIN="/Applications/Ryujinx.app/Contents/MacOS/Ryujinx"