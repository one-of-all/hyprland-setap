# Arch Linux Hyprland Setup

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/WM-Hyprland-58c4dc)](https://hyprland.org/)
[![Zsh](https://img.shields.io/badge/shell-Zsh-f15a24)](https://www.zsh.org/)
[![Kitty](https://img.shields.io/badge/terminal-Kitty-008080)](https://sw.kovidgoyal.net/kitty/)
[![Waybar](https://img.shields.io/badge/bar-Waybar-00aaff)](https://github.com/Alexays/Waybar)
[![Rofi](https://img.shields.io/badge/launcher-Rofi-2d2d2d)](https://github.com/davatorium/rofi)
[![Security](https://img.shields.io/badge/security-Firejail-green)](https://firejail.wordpress.com/)
[![Proton](https://img.shields.io/badge/Proton-6a1b9a)](https://github.com/ValveSoftware/Proton)

## Overview

This repository delivers a **fully automated installer** for a modern Arch Linux desktop environment centered around **Hyprland** – a dynamic tiling Wayland compositor. The setup combines eye‑candy visuals, robust security, and a highly productive workflow. Everything is configured with a consistent dark/light theme and can be deployed with a single command.

The environment is built from carefully selected components:

- **Hyprland** – smooth animations, transparency, and Vim‑style window controls.
- **Kitty** – GPU‑accelerated terminal with ligatures and a custom theme.
- **Waybar** – highly customisable status bar (theme adapted from [minimal-waybar-themes](https://github.com/atif-1402/minimal-waybar-themes/)).
- **Rofi** – versatile launcher and window switcher (configuration based on [rofi-config](https://github.com/anhsirk0/rofi-config)).
- **Zsh** with **Zim** framework and **Powerlevel10k** prompt.
- **Firejail** – sandboxing for all applications.
- **Proton** – seamless Windows `.exe` execution via binfmt.
- **LightDM** – lightweight display manager with a custom greeter.

All configuration files are stored in this repository and deployed automatically, with backups of your existing settings.

---

## Features

| Component         | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| **Hyprland**      | Dynamic tiling with rounded corners, blur, and smooth animations.           |
| **Hyprpaper**     | Lightweight wallpaper daemon with dynamic reloading.                       |
| **Hyprlock**      | Simple and elegant lock screen.                                            |
| **Kitty**         | Terminal with GPU acceleration, ligatures, and a clean theme.              |
| **Waybar**        | Fully styled status bar with workspaces, volume, battery, and more.       |
| **Rofi**          | Application launcher, window switcher, and custom powermenu.               |
| **Nemo**          | Feature‑rich file manager with a modern look.                              |
| **Firejail**      | Global sandboxing via `firecfg` – all apps run with reduced privileges.   |
| **Proton binfmt** | Double‑click any `.exe` – automatically runs with Proton/Wine.            |
| **Zsh + Zim**     | Lightning‑fast Zsh with Powerlevel10k prompt, plugins, and completions.   |
| **LightDM**       | Customized login screen with a clean theme.                               |
| **Wallpaper Script** | Easy script to rotate or set wallpapers from the command line.          |
| **Security**      | Firejail, binfmt isolation, and minimal attack surface.                    |
| **Theme Switching** | Light/dark mode support via Rofi and GTK themes (automatically detected). |

---

## Screenshots & Gallery

> *Replace the placeholder image paths with your own screenshots. All images are stored in the `screenshots/` directory of this repository.*

<div align="center">
  <img src="screenshots/desktop.png" alt="Desktop Overview" width="800"/>
  <p><strong>Figure 1:</strong> Main desktop with Hyprland, Waybar, and Kitty</p>
</div>

<div align="center">
  <img src="screenshots/rofi_launcher.png" alt="Rofi Launcher" width="600"/>
  <p><strong>Figure 2:</strong> Rofi application launcher in action</p>
</div>

<div align="center">
  <img src="screenshots/waybar.png" alt="Waybar and Hyprland" width="800"/>
  <p><strong>Figure 3:</strong> Waybar with system tray, workspaces, and clock</p>
</div>

<div align="center">
  <img src="screenshots/kitty.png" alt="Kitty Terminal" width="700"/>
  <p><strong>Figure 4:</strong> Kitty with Zsh and Powerlevel10k prompt</p>
</div>

<div align="center">
  <img src="screenshots/powermenu.png" alt="Rofi Powermenu" width="400"/>
  <p><strong>Figure 5:</strong> Rofi powermenu for logout, reboot, and shutdown</p>
</div>

<div align="center">
  <img src="screenshots/wallpaper_selector.png" alt="Rofi Wallpaper Selector" width="500"/>
  <p><strong>Figure 6:</strong> Rofi wallpaper selector – pick any image from your wallpaper directory</p>
</div>

<div align="center">
  <img src="screenshots/lightdm.png" alt="LightDM Login" width="600"/>
  <p><strong>Figure 7:</strong> Custom LightDM greeter with wallpaper background</p>
</div>

<div align="center">
  <img src="screenshots/nemo.png" alt="Nemo File Manager" width="700"/>
  <p><strong>Figure 8:</strong> Nemo file manager with a clean interface</p>
</div>

<div align="center">
  <img src="screenshots/workspaces.png" alt="Hyprland Workspaces" width="800"/>
  <p><strong>Figure 9:</strong> Dynamic tiling and workspace overview</p>
</div>

---

## Video Demo

Watch a full walkthrough of the system in action, including Hyprland navigation, Rofi usage, and wallpaper switching.

<video width="800" controls>
  <source src="screenshots/demo.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

<!-- You can also view the demo on [YouTube](https://youtu.be/your-video-link). -->

---

## Repository Structure

```
hyprland-setap/
├── hypr/                 # Hyprland configuration files
│   ├── hyprland.conf
│   ├── hyprlock.conf
│   └── hyprpaper.conf
├── kitty/                # Kitty terminal config
│   └── kitty.conf
├── lightdm/              # LightDM config (greeter and display manager)
│   └── lightdm.conf
├── rofi/                 # Rofi themes and scripts (from anhsirk0/rofi-config)
│   ├── applaunch/
│   ├── colors/
│   ├── emoji/
│   ├── powermenu/
│   ├── wallpaper/        # Custom wallpaper selector using Rofi
│   │   ├── config.rasi
│   │   └── wallpaper.sh
│   ├── config.rasi
│   ├── change-theme.pl
│   └── rofi-theme-selector.sh
├── wallpapers/           # Default wallpapers (copy to user directory)
│   └── wallpaper.jpg
├── wallpaper_setup.sh    # Script to set wallpapers and update Hyprpaper
├── install.sh            # One‑click installation script
└── README.md
```

All configuration files are designed to be modular – you can tweak any part to match your personal style.

---

## Installation

### Prerequisites

- A working **Arch Linux** system with a network connection.
- `sudo` privileges.
- Basic familiarity with the terminal.

### Steps

1. **Clone the repository**  
   ```bash
   git clone https://github.com/one-of-all/hyprland-setap.git;
   cd hyprland-setap
   ```

2. **Make the installer executable**  
   ```bash
   chmod +x install.sh
   ```

3. **Run the installer with sudo**  
   ```bash
   sudo ./install.sh
   ```

   The script will:
   - Ask for the wallpaper directory (default: `~/wallpapers/`).
   - Update your system.
   - Install all required packages (official + AUR).
   - Backup existing configs (`~/.config/hypr`, `kitty`, `waybar`, `rofi`) with a timestamp.
   - Deploy the new configuration files.
   - Set up Firejail, Proton binfmt, Zsh, and LightDM.
   - Enable the LightDM service.
   - Set the default wallpaper (`wallpaper.jpg`).

4. **Reboot** to start your new environment  
   ```bash
   reboot
   ```

   After restart, LightDM will greet you. Log in and enjoy your fresh Hyprland session.

---

## Post-Installation Customization

- **Wallpaper** – Run `wallpaper_rofi.sh` to select a new wallpaper from your directory. The script updates Hyprpaper and creates a blurred version for the lock screen.
- **Hyprland keybindings** – Modify `~/.config/hypr/hyprland.conf` to add or change shortcuts.
- **Waybar modules** – Edit `~/.config/waybar/config` to adjust the status bar layout. The theme is adapted from [minimal-waybar-themes](https://github.com/atif-1402/minimal-waybar-themes/).
- **Rofi themes** – Replace files in `~/.config/rofi/` with your own. The current setup is based on [anhsirk0/rofi-config](https://github.com/anhsirk0/rofi-config).
- **Zsh plugins** – Add more modules in `~/.zshrc` via Zim.
- **LightDM** – Adjust `/etc/lightdm/lightdm.conf` to change the greeter or autologin settings.
- **Theme switching** – The Rofi theme automatically adapts to your GTK theme (light/dark). You can force a theme using `change-theme.pl` or the `rofi-theme-selector.sh` script.

All deployed configs are fully commented – feel free to explore and tailor them to your workflow.

---

## Security Features

This setup emphasises security without sacrificing usability:

- **Firejail** – Every application is sandboxed by default (via `firecfg`). This restricts access to your system and personal files.
- **Proton binfmt** – Windows executables run inside a Proton sandbox, minimising exposure to malicious code.
- **Minimal attack surface** – The system runs only essential services. LightDM is lightweight and does not expose unnecessary network ports.
- **Zsh hardening** – The shell is configured with safe defaults and no insecure plugins.
- **User separation** – The installer runs as root but uses `sudo -u` for user‑specific tasks, avoiding privilege escalation issues.

---

## Credits & Acknowledgments

This project would not be possible without the amazing work of the open‑source community:

- **Hyprland** – the incredible Wayland compositor – [hyprland.org](https://hyprland.org/)
- **Kitty** – the terminal that makes everything look good – [sw.kovidgoyal.net/kitty/](https://sw.kovidgoyal.net/kitty/)
- **Waybar** – the bar that ties it all together – [github.com/Alexays/Waybar](https://github.com/Alexays/Waybar)  
  *Waybar theme adapted from* [minimal-waybar-themes](https://github.com/atif-1402/minimal-waybar-themes/)
- **Rofi** – the launcher that keeps you fast – [github.com/davatorium/rofi](https://github.com/davatorium/rofi)  
  *Rofi configuration based on* [rofi-config](https://github.com/anhsirk0/rofi-config)
- **Zim** – the Zsh framework that stays out of your way – [zimfw.sh](https://zimfw.sh/)
- **Powerlevel10k** – the prompt that makes you smile – [github.com/romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k)
- **Firejail** – for security without hassle – [firejail.wordpress.com](https://firejail.wordpress.com/)
- **Proton** – bringing Windows apps to Linux – [github.com/ValveSoftware/Proton](https://github.com/ValveSoftware/Proton)

