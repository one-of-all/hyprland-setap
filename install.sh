#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------
# 0. Determine script location
# ---------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=$(date +%Y%m%d_%H%M%S)

# ---------------------------------------------------------------------
# 1. Safety checks
# ---------------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root (sudo)."
    exit 1
fi

echo "Checking internet connection..."
if ! ping -c 1 8.8.8.8 &>/dev/null; then
    echo "ERROR: No internet connection. Please check your network."
    exit 1
fi

# ---------------------------------------------------------------------
# 2. Ask for wallpaper directory
# ---------------------------------------------------------------------
ORIGINAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo ~$ORIGINAL_USER)
DEFAULT_WALLPAPER_DIR="$USER_HOME/wallpapers"

echo ""
echo "Wallpaper setup:"
echo "The repository contains a 'wallpapers/' folder with images."
read -p "Enter the directory where you want to store wallpapers [default: $DEFAULT_WALLPAPER_DIR]: " WALLPAPER_DIR
WALLPAPER_DIR=${WALLPAPER_DIR:-$DEFAULT_WALLPAPER_DIR}
WALLPAPER_DIR=$(eval echo "$WALLPAPER_DIR")  # expand ~

# Create the directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Copy wallpapers from the repo (if the folder exists)
if [[ -d "$SCRIPT_DIR/wallpapers" ]]; then
    echo "Copying wallpapers from $SCRIPT_DIR/wallpapers/ to $WALLPAPER_DIR/"
    cp -r "$SCRIPT_DIR/wallpapers/"* "$WALLPAPER_DIR/" 2>/dev/null || echo "No files to copy (folder might be empty)."
else
    echo "Warning: 'wallpapers/' folder not found in the repository – skipping wallpaper copy."
fi

# Save the wallpaper directory to a system-wide config file
echo "Saving wallpaper directory to /etc/wallpaper.conf"
echo "WALLPAPER_DIR=\"$WALLPAPER_DIR\"" > /etc/wallpaper.conf

# ---------------------------------------------------------------------
# 3. System update & package installation
# ---------------------------------------------------------------------
echo "Updating system..."
pacman -Syu --noconfirm

PKGS=(
    hyprland hyprpaper hyprlock
    waybar rofi rofi-wayland fzf cava
    kitty nemo
    firejail git zsh
    wine vulkan-icd-loader vulkan-tools
    lightdm
    grim slurp
    noto-fonts-emoji ttf-nerd-fonts-symbols ttf-dejavu
    xorg-xsetroot   # Required for setting wallpaper in LightDM greeter
)

for pkg in "${PKGS[@]}"; do
    if ! pacman -Q "$pkg" &>/dev/null; then
        echo "Installing package: $pkg"
        pacman -S --noconfirm "$pkg"
    else
        echo "Package $pkg already installed."
    fi
done

# AUR helper (yay)
if ! command -v yay &>/dev/null; then
    echo "Installing yay (AUR helper)..."
    pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd /
fi

AUR_PKGS=(
    proton
    zim
)

for pkg in "${AUR_PKGS[@]}"; do
    if ! pacman -Q "$pkg" &>/dev/null; then
        echo "Installing AUR package: $pkg"
        yay -S --noconfirm "$pkg"
    else
        echo "Package $pkg already installed."
    fi
done

# ---------------------------------------------------------------------
# 4. Deploy configurations with backup
# ---------------------------------------------------------------------
backup_and_deploy() {
    local src_dir="$1"
    local dest_dir="$2"
    local config_name="$3"

    if [[ -d "$src_dir" ]]; then
        if [[ -d "$dest_dir" ]]; then
            local backup_dir="${dest_dir}_backup_$BACKUP_SUFFIX"
            echo "Backing up $dest_dir to $backup_dir"
            mv "$dest_dir" "$backup_dir"
        fi
        mkdir -p "$dest_dir"
        echo "Copying $config_name configs from $src_dir to $dest_dir"
        cp -r "$src_dir"/* "$dest_dir/"
    else
        echo "Warning: $src_dir not found – skipping $config_name config."
    fi
}

backup_and_deploy "$SCRIPT_DIR/hypr" "$HOME/.config/hypr" "Hyprland"
backup_and_deploy "$SCRIPT_DIR/kitty" "$HOME/.config/kitty" "Kitty"
backup_and_deploy "$SCRIPT_DIR/waybar" "$HOME/.config/waybar" "Waybar"
backup_and_deploy "$SCRIPT_DIR/rofi" "$HOME/.config/rofi" "Rofi"

# ---------------------------------------------------------------------
# 5. Deploy LightDM configuration (copy the whole folder)
# ---------------------------------------------------------------------
if [[ -d "$SCRIPT_DIR/lightdm" ]]; then
    echo "Copying all files from lightdm/ folder to /etc/lightdm/"
    cp -r "$SCRIPT_DIR/lightdm/"* /etc/lightdm/ 2>/dev/null || echo "No files in lightdm/ folder."
else
    echo "Warning: lightdm/ folder not found – skipping LightDM config."
fi

# Ensure the LightDM config references the wallpaper scripts
if [[ -f /etc/lightdm/lightdm.conf ]]; then
    if ! grep -q "greeter-setup-script=/usr/local/bin/wallpaper_lightdm.sh" /etc/lightdm/lightdm.conf; then
        echo "Adding greeter-setup-script to LightDM config..."
        sed -i '/^\[Seat:\*\]/a greeter-setup-script=/usr/local/bin/wallpaper_lightdm.sh' /etc/lightdm/lightdm.conf
    fi
    if ! grep -q "session-setup-script=/usr/local/bin/wallpaper_setup.sh" /etc/lightdm/lightdm.conf; then
        sed -i '/^\[Seat:\*\]/a session-setup-script=/usr/local/bin/wallpaper_setup.sh' /etc/lightdm/lightdm.conf
    fi
fi

# ---------------------------------------------------------------------
# 6. Create wallpaper_lightdm.sh for LightDM greeter
# ---------------------------------------------------------------------
cat > /usr/local/bin/wallpaper_lightdm.sh <<'EOF'
#!/bin/bash
# Set wallpaper for LightDM greeter using xsetroot
CONFIG_FILE="/etc/wallpaper.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    WALLPAPER_DIR="$HOME/wallpapers"
fi
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/wallpapers}"
CURRENT_LINK="$WALLPAPER_DIR/current"
if [[ -L "$CURRENT_LINK" && -f "$CURRENT_LINK" ]]; then
    export DISPLAY=:0
    xsetroot -bitmap "$CURRENT_LINK" 2>/dev/null || xsetroot -solid "#000000"
else
    export DISPLAY=:0
    xsetroot -solid "#000000"
fi
EOF
chmod +x /usr/local/bin/wallpaper_lightdm.sh

# ---------------------------------------------------------------------
# 7. Install wallpaper_setup.sh (from repository)
# ---------------------------------------------------------------------
if [[ -f "$SCRIPT_DIR/wallpaper_setup.sh" ]]; then
    echo "Installing wallpaper_setup.sh to /usr/local/bin..."
    cp "$SCRIPT_DIR/wallpaper_setup.sh" /usr/local/bin/
    chmod +x /usr/local/bin/wallpaper_setup.sh
else
    echo "Warning: wallpaper_setup.sh not found – skipping."
fi

# ---------------------------------------------------------------------
# 8. Install Rofi wallpaper selector (from repository)
# ---------------------------------------------------------------------
if [[ -f "$SCRIPT_DIR/rofi/wallpaper/wallpaper.sh" ]]; then
    echo "Installing wallpaper_rofi.sh from repository..."
    cp "$SCRIPT_DIR/rofi/wallpaper/wallpaper.sh" /usr/local/bin/wallpaper_rofi.sh
    chmod +x /usr/local/bin/wallpaper_rofi.sh
else
    echo "Warning: rofi/wallpaper/wallpaper.sh not found – generating fallback script."
    cat > /usr/local/bin/wallpaper_rofi.sh <<'EOF'
#!/usr/bin/env bash
# Fallback wallpaper selector using rofi -dmenu
CONFIG_FILE="/etc/wallpaper.conf"
source "$CONFIG_FILE" 2>/dev/null || WALLPAPER_DIR="$HOME/wallpapers"
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/wallpapers}"
shopt -s nullglob
images=("$WALLPAPER_DIR"/*.{jpg,jpeg,png,gif,bmp,JPG,JPEG,PNG,GIF,BMP})
shopt -u nullglob
if [[ ${#images[@]} -eq 0 ]]; then
    echo "No images found in $WALLPAPER_DIR"
    exit 1
fi
names=()
for img in "${images[@]}"; do names+=("$(basename "$img")"); done
selected=$(printf "%s\n" "${names[@]}" | rofi -dmenu -p "Select Wallpaper")
if [[ -z "$selected" ]]; then exit 0; fi
for img in "${images[@]}"; do
    if [[ "$(basename "$img")" == "$selected" ]]; then
        /usr/local/bin/wallpaper_setup.sh "$img"
        echo "Wallpaper set to: $img"
        break
    fi
done
EOF
    chmod +x /usr/local/bin/wallpaper_rofi.sh
fi

# ---------------------------------------------------------------------
# 9. Firejail integration
# ---------------------------------------------------------------------
echo "Setting up firejail with firecfg..."
firecfg --fix

# ---------------------------------------------------------------------
# 10. Proton binfmt (run .exe with Proton)
# ---------------------------------------------------------------------
echo "Registering binfmt for .exe files (Proton)..."
BINFMT_FILE="/usr/lib/binfmt.d/wine.conf"
cat > "$BINFMT_FILE" <<EOF
:Wine:M::MZ::/usr/bin/proton:OC
EOF
systemctl restart systemd-binfmt

# ---------------------------------------------------------------------
# 11. Zsh + Zim + Powerlevel10k
# ---------------------------------------------------------------------
if [[ ! -d "$HOME/.zim" ]]; then
    echo "Installing Zim framework..."
    curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
fi

ZSHRC="$HOME/.zshrc"
if ! grep -q "zimfw" "$ZSHRC" 2>/dev/null; then
    echo "Configuring .zshrc for Zim..."
    cat <<'EOF' >> "$ZSHRC"
export ZIM_HOME=$HOME/.zim
source $ZIM_HOME/init.zsh
zstyle ':zim:zmodule' use 'degite/zsh-powerlevel10k'
zmodule degite/zsh-powerlevel10k
EOF
fi

zsh -c "source $HOME/.zim/init.zsh && zimfw install"

echo "Changing default shell to zsh for user $ORIGINAL_USER..."
chsh -s /bin/zsh "$ORIGINAL_USER" 2>/dev/null || echo "Warning: Could not change shell."

KITTY_CONFIG="$HOME/.config/kitty/kitty.conf"
if [[ -f "$KITTY_CONFIG" ]]; then
    if ! grep -q "^shell" "$KITTY_CONFIG"; then
        echo "shell /bin/zsh" >> "$KITTY_CONFIG"
    else
        sed -i 's/^shell .*/shell \/bin\/zsh/' "$KITTY_CONFIG"
    fi
fi

# ---------------------------------------------------------------------
# 12. Set default wallpaper (wallpaper.jpg)
# ---------------------------------------------------------------------
if [[ -f "$WALLPAPER_DIR/wallpaper.jpg" ]]; then
    echo "Setting default wallpaper (wallpaper.jpg) as current..."
    sudo -u "$ORIGINAL_USER" /usr/local/bin/wallpaper_setup.sh "$WALLPAPER_DIR/wallpaper.jpg"
else
    echo "Warning: wallpaper.jpg not found in $WALLPAPER_DIR – skipping default wallpaper setup."
fi

# ---------------------------------------------------------------------
# 13. Enable LightDM service
# ---------------------------------------------------------------------
echo "Enabling LightDM service..."
systemctl enable lightdm

# ---------------------------------------------------------------------
# 14. Completion message
# ---------------------------------------------------------------------
echo "Setup completed successfully!"
echo " - Wallpapers copied to: $WALLPAPER_DIR"
echo " - Wallpaper directory saved in /etc/wallpaper.conf"
echo " - Default wallpaper set to wallpaper.jpg"
echo " - All configs deployed (with backups)."
echo " - LightDM greeter will use current wallpaper."
echo " - Rofi wallpaper selector installed: wallpaper_rofi.sh"
echo " - Firejail, Proton binfmt, Zsh, and LightDM are set up."
echo " - A reboot is highly recommended."
