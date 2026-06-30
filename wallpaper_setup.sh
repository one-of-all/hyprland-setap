#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------
# Load wallpaper directory from system config, with fallback
# ---------------------------------------------------------------------
CONFIG_FILE="/etc/wallpaper.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    WALLPAPER_DIR="${HOME}/wallpapers"
fi

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/wallpapers}"

src="${1:-$WALLPAPER_DIR/wallpaper.jpg}"

if [[ ! -f "$src" ]]; then
    echo "ERROR: Source file '$src' does not exist."
    exit 1
fi

ln -sfn "$src" "$WALLPAPER_DIR/current"

blurred="$WALLPAPER_DIR/.current-blurred.jpg"
if command -v magick >/dev/null 2>&1; then
    magick "$src" -filter Gaussian -blur 0x10 "$blurred"
else
    convert "$src" -filter Gaussian -blur 0x10 "$blurred"
fi

echo "Wallpaper set to: $src"
echo "Blurred version created: $blurred"

# ---------------------------------------------------------------------
# Force Hyprpaper to reload the wallpaper
# ---------------------------------------------------------------------
if command -v hyprctl &>/dev/null; then
#    if hyprctl dispatch setwallpaper "$src" 2>/dev/null; then
#        echo "Hyprpaper updated via hyprctl"
#    else
#        if pgrep -x hyprpaper >/dev/null; then
            echo "Restarting hyprpaper to apply new wallpaper..."
            killall hyprpaper
            hyprpaper &
            echo "Hyprpaper restarted."
#        fi
#    fi
else
    echo "hyprctl not found – skipping Hyprpaper update."
fi
