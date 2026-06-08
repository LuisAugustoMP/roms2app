#!/bin/bash

# PATHS
SOURCE_DIR_PS2="/Volumes/SanDiskDriv/Jogos/ps2"
SOURCE_DIR_SWITCH="/Volumes/SanDiskDriv/Jogos/nswitch"
DEST_DIR="/Applications/Jogos"
EMULATOR_PS2="/Applications/Jogos/PCSX2.app"

# UI SETTINGS
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
MAGENTA='\033[1;35m'

S_INFO="${CYAN}ℹ${RESET}"
S_OK="${GREEN}✔${RESET}"
S_WARN="${YELLOW}⚠${RESET}"
S_ERR="${RED}✖${RESET}"
S_BUL="${DIM}➔${RESET}"

clear
echo -e "${CYAN}${BOLD}╭────────────────────────────────────────────────╮${RESET}"
echo -e "${CYAN}${BOLD}│                                                │${RESET}"
echo -e "${CYAN}${BOLD}│         GAME LAUNCHER GENERATOR (macOS)        │${RESET}"
echo -e "${CYAN}${BOLD}│                                                │${RESET}"
echo -e "${CYAN}${BOLD}╰────────────────────────────────────────────────╯${RESET}\n"

echo -e "${S_INFO} Initializing environment...\n"

# DEPENDENCY CHECK
echo -e "${YELLOW}${BOLD}⚙ CHECKING DEPENDENCIES${RESET}"

if ! command -v magick &> /dev/null; then
    echo -e "  ${S_WARN} ImageMagick not found. Starting installation..."
    
    if ! command -v brew &> /dev/null; then
        echo -e "  ${S_ERR} Homebrew is not installed. Please install it first: https://brew.sh/"
        exit 1
    fi
    
    echo -e "  ${S_INFO} Running: ${DIM}brew install imagemagick${RESET} (This may take a while)..."
    brew install imagemagick > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "  ${S_OK} ImageMagick installed successfully!"
    else
        echo -e "  ${S_ERR} Error installing ImageMagick. Try running 'brew install imagemagick' manually."
        exit 1
    fi
else
    echo -e "  ${S_OK} ImageMagick is ready."
fi

# Create destination directory
if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
    echo -e "  ${S_OK} Destination directory created: ${DIM}$DEST_DIR${RESET}"
else
    echo -e "  ${S_OK} Destination directory verified: ${DIM}$DEST_DIR${RESET}"
fi

echo ""

# 1. PROCESS PS2 GAMES (.iso)
echo -e "${MAGENTA}${BOLD}[1/2] PROCESSING PLAYSTATION 2 GAMES${RESET}"

if [ -d "$SOURCE_DIR_PS2" ]; then
    if [ ! -d "$EMULATOR_PS2" ]; then
        echo -e "  ${S_WARN} PCSX2 emulator not found. Skipping."
    else
        COUNT_PS2=0
        while IFS= read -r ISO_PATH; do
            GAME_NAME=$(basename "$ISO_PATH" .iso)
            APP_PATH="$DEST_DIR/$GAME_NAME.app"

            if [ -d "$APP_PATH" ]; then
                echo -e "  ${S_BUL} ${DIM}$GAME_NAME${RESET} (Already exists)"
                continue
            fi

            echo -e "  ${S_OK} Creating: ${GREEN}$GAME_NAME${RESET}"
            
            MACOS_DIR="$APP_PATH/Contents/MacOS"
            mkdir -p "$MACOS_DIR"

            # Generate Icon
            RES_DIR="$APP_PATH/Contents/Resources"
            mkdir -p "$RES_DIR"
            
            LETTER=$(echo "${GAME_NAME:0:1}" | tr '[:lower:]' '[:upper:]')
            ICONSET_DIR="/tmp/${GAME_NAME// /_}.iconset"
            mkdir -p "$ICONSET_DIR"
            
            magick -size 512x512 canvas:"#2D2D2D" -gravity center -fill white -pointsize 300 -font Helvetica-Bold -annotate +0+0 "$LETTER" "$ICONSET_DIR/icon_512x512.png" 2>/dev/null
            iconutil -c icns -o "$RES_DIR/AppIcon.icns" "$ICONSET_DIR" 2>/dev/null
            rm -rf "$ICONSET_DIR"

            # Create Info.plist
            cat > "$APP_PATH/Contents/Info.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>run_game</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.pcsx2.launcher.${GAME_NAME// /}</string>
    <key>CFBundleName</key>
    <string>${GAME_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
</dict>
</plist>
EOL

            # Create Executable
            cat > "$MACOS_DIR/run_game" << EOL
#!/bin/bash
if [ ! -d "$SOURCE_DIR_PS2" ]; then
    osascript -e 'display dialog "Please insert the external drive to play." with title "Drive Disconnected" buttons {"OK"} default button "OK" with icon caution'
    exit 1
fi
open -a "$EMULATOR_PS2" --args "$ISO_PATH"
EOL
            chmod +x "$MACOS_DIR/run_game"
            ((COUNT_PS2++))
        done < <(find "$SOURCE_DIR_PS2" -maxdepth 1 -name "*.iso" -not -name "._*")
        
        if [ $COUNT_PS2 -eq 0 ]; then
            echo -e "  ${S_INFO} No new PS2 games added."
        fi
    fi
else
    echo -e "  ${S_ERR} PS2 folder not found on the drive."
fi

echo ""

# 2. PROCESS SWITCH GAMES (.nsp)
echo -e "${RED}${BOLD}[2/2] PROCESSING NINTENDO SWITCH GAMES${RESET}"

if [ -d "$SOURCE_DIR_SWITCH" ]; then
    COUNT_NSW=0
    while IFS= read -r NSP_PATH; do
        GAME_NAME=$(basename "$NSP_PATH" .nsp)
        APP_PATH="$DEST_DIR/$GAME_NAME.app"

        if [ -d "$APP_PATH" ]; then
            echo -e "  ${S_BUL} ${DIM}$GAME_NAME${RESET} (Already exists)"
            continue
        fi

        echo -e "  ${S_OK} Creating: ${GREEN}$GAME_NAME${RESET}"
        
        MACOS_DIR="$APP_PATH/Contents/MacOS"
        mkdir -p "$MACOS_DIR"

        # Generate Icon
        RES_DIR="$APP_PATH/Contents/Resources"
        mkdir -p "$RES_DIR"
        
        LETTER=$(echo "${GAME_NAME:0:1}" | tr '[:lower:]' '[:upper:]')
        ICONSET_DIR="/tmp/${GAME_NAME// /_}.iconset"
        mkdir -p "$ICONSET_DIR"
        
        magick -size 512x512 canvas:"#2D2D2D" -gravity center -fill white -pointsize 300 -font Helvetica-Bold -annotate +0+0 "$LETTER" "$ICONSET_DIR/icon_512x512.png" 2>/dev/null
        iconutil -c icns -o "$RES_DIR/AppIcon.icns" "$ICONSET_DIR" 2>/dev/null
        rm -rf "$ICONSET_DIR"

        # Create Info.plist
        cat > "$APP_PATH/Contents/Info.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>run_game</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.switch.launcher.${GAME_NAME// /}</string>
    <key>CFBundleName</key>
    <string>${GAME_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
</dict>
</plist>
EOL

        # Create Executable (Using binary directly)
        cat > "$MACOS_DIR/run_game" << EOL
#!/bin/bash
if [ ! -d "$SOURCE_DIR_SWITCH" ]; then
    osascript -e 'display dialog "Please insert the external drive to play." with title "Drive Disconnected" buttons {"OK"} default button "OK" with icon caution'
    exit 1
fi
open "$NSP_PATH"
EOL
        chmod +x "$MACOS_DIR/run_game"
        ((COUNT_NSW++))
    done < <(find "$SOURCE_DIR_SWITCH" -maxdepth 1 -name "*.nsp" -not -name "._*")
    
    if [ $COUNT_NSW -eq 0 ]; then
        echo -e "  ${S_INFO} No new Switch games added."
    fi
else
    echo -e "  ${S_ERR} Switch folder not found on the drive."
fi

echo ""

# ==========================================
# WRAP UP
# ==========================================
echo -e "${CYAN}──────────────────────────────────────────────────${RESET}"
echo -e "${S_OK} ${BOLD}Process successfully completed!${RESET}"
echo -e "${S_INFO} Your games are ready at: ${CYAN}$DEST_DIR${RESET}\n"