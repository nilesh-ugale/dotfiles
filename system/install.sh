#!/usr/bin/env bash
# Rebuild the bare-metal Arch desktop (Hyprland) on a new machine.
#
# This is not wsl/install.sh, which sets up Arch under WSL and skips everything
# below that touches boot, firmware or the desktop.
#
# Start from a finished base install (archinstall is fine): GRUB installed to
# the ESP, a user in wheel with working sudo, and a network connection. Clone
# the repo and run this as that user, not as root:
#
#   git clone https://github.com/nilesh-ugale/dotfiles.git ~/dotfiles
#   ~/dotfiles/system/install.sh
#
# It does not partition, write fstab or run grub-install: those depend on the
# disk layout. Every step checks before it acts, so re-running is safe.
set -euo pipefail

# --- what to build ----------------------------------------------------------

SYSTEM_DIR=$(cd "$(dirname "$0")" && pwd)
DOTFILES=$(dirname "$SYSTEM_DIR")

TIMEZONE=Asia/Kolkata
LOCALE=en_US.UTF-8
HOSTNAME_VALUE=archlinux

DOTFILES_SSH=git@github.com:nilesh-ugale/dotfiles.git

GIT_NAME="Nilesh Ugale"
GIT_EMAIL=nilesh.r.ugale@gmail.com

# Stowed with --no-folding: these targets are directories that other programs
# also write into (~/.claude holds credentials and chat history, ~/.config/gtk-*
# gets bookmarks), so the directory itself must stay real.
STOW_PACKAGES=(bin btop fastfetch hypr kitty nvim tmux waybar wofi yazi zsh)
STOW_PACKAGES_NOFOLD=(claude desktop)

CONDA_DIR_NAME=miniforge3
CONDA_ENV=py314
CONDA_ENV_PKGS=(python=3.14 click pycryptodome ecdsa pypdf)

# The explicitly installed packages off the current desktop. The CPU microcode
# and the NVIDIA driver are added below depending on the hardware and flags.
PACKAGES=(
    accountsservice base base-devel bluetui bluez bluez-utils btop cage cliphist
    cmake cpio dmidecode edk2-shell efibootmgr fastfetch fzf git greetd
    greetd-regreet grim grub gst-plugin-pipewire hivex htop hypridle hyprland
    hyprlock hyprpaper hyprpolkitagent kitty kitty-terminfo less libpulse linux
    linux-firmware mako memtest86+-efi meson nano nautilus neovim
    network-manager-applet networkmanager ninja ntfs-3g ntfsprogs obsidian
    pacman-contrib pipewire pipewire-alsa pipewire-jack pipewire-pulse qt6-base
    qt6-declarative qt6-svg ripgrep rpi-imager rsync slurp smartmontools stow
    tailscale terminus-font tmux ttf-jetbrains-mono-nerd vim wayland-protocols wget
    wireless_tools wiremix wireplumber wl-clipboard wofi
    xdg-desktop-portal-hyprland xdg-utils xorg-server xorg-xhost xorg-xinit
    xorg-xwayland yazi zram-generator zsh
)
NVIDIA_PACKAGES=(nvidia-open-dkms dkms linux-headers libva-nvidia-driver)
AUR_PACKAGES=(brave-bin claude-desktop ttf-quicksand-variable waybar-git)

SERVICES=(bluetooth NetworkManager nftables tailscaled systemd-timesyncd
          fstrim.timer paccache.timer)

# The SSD this was tuned on drops off the bus in NVMe/PCIe low-power states.
NVME_QUIRKS="nvme_core.default_ps_max_latency_us=0 pcie_aspm=off pcie_port_pm=off"

# GRUB theme: upstream vimix, 1080p, color icons, with the menu font swapped
# from DejaVu Sans to the JetBrainsMono Nerd Font.
GRUB_THEMES_REPO=https://github.com/vinceliuice/grub2-themes.git
GRUB_THEME_DIR=/boot/grub/themes/vimix
GRUB_FONT_TTF=/usr/share/fonts/TTF/JetBrainsMonoNerdFont-Bold.ttf

# Wallpapers for regreet and hyprpaper, fetched from wallhaven by ID rather
# than committed to this public repo. Saved as /usr/share/backgrounds/wallhaven_<id>.
WALLPAPERS=(
    01qpg4.jpg 2em38y.jpg 2ero7g.jpg 43lej9.png 54l6l4.jpg 5yd6d5.png 5yyjm9.jpg
    7jjyd9.png 9496w4.jpg l3zmwy.jpg lmd95y.jpg lyyv2l.jpg md3vjm.jpg nmodk4.jpg
    oggmym.png r25x6m.png x8ye3z.jpg z8odwg.jpg zmr6qv.png
)

# --- flags ------------------------------------------------------------------

WANT_NVIDIA=1       # --no-nvidia       other GPU: no NVIDIA driver, keep the kms hook
WANT_NVME_QUIRKS=1  # --no-nvme-quirks  drop the NVMe/PCIe power-saving workarounds
WANT_WINDOWS=1      # --no-windows      no Windows: RTC in UTC, no Windows menu entry
WANT_CONDA=1        # --no-conda        skip miniforge and the py314 env
WANT_CLAUDE=1       # --no-claude       skip Claude Code

usage() {
    awk 'NR == 1 { next } /^#/ { sub(/^# ?/, ""); print; next } { exit }' "$0"
    cat <<USAGE

Options:
  --no-nvidia        not an NVIDIA GPU: skip the driver, keep the kms hook
  --no-nvme-quirks   drop the NVMe/PCIe power-saving kernel parameters
  --no-windows       no Windows on this disk: hardware clock in UTC and no
                     Windows entry in GRUB
  --no-conda         skip miniforge and the $CONDA_ENV environment
  --no-claude        skip Claude Code
  -h, --help         this text
USAGE
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-nvidia)      WANT_NVIDIA=0 ;;
        --no-nvme-quirks) WANT_NVME_QUIRKS=0 ;;
        --no-windows)     WANT_WINDOWS=0 ;;
        --no-conda)       WANT_CONDA=0 ;;
        --no-claude)      WANT_CLAUDE=0 ;;
        -h|--help)        usage; exit 0 ;;
        *)                echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

# --- helpers ----------------------------------------------------------------

say()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m warning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m error:\033[0m %s\n' "$*" >&2; exit 1; }

# install_etc <path under etc/> <mode>: copy a tracked file into /etc as root.
install_etc() {
    sudo install -Dm"$2" -o root -g root "$SYSTEM_DIR/etc/$1" "/etc/$1"
}

clone_if_missing() {
    local url=$1 dest=$2
    if [[ -d $dest ]]; then
        echo "  $(basename "$dest") already there"
    else
        git clone --depth 1 "$url" "$dest"
    fi
}

# =============================================================================
# system
# =============================================================================

install_packages() {
    say "packages"
    local pkgs=("${PACKAGES[@]}")
    if grep -q GenuineIntel /proc/cpuinfo; then pkgs+=(intel-ucode); else pkgs+=(amd-ucode); fi
    if [[ $WANT_NVIDIA -eq 1 ]]; then pkgs+=("${NVIDIA_PACKAGES[@]}"); fi
    sudo pacman -Syu --needed --noconfirm "${pkgs[@]}"
}

setup_system_settings() {
    say "time zone, clock, locale, hostname"
    sudo ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    # Windows keeps the hardware clock in local time; Linux on its own uses UTC.
    if [[ $WANT_WINDOWS -eq 1 ]]; then
        sudo timedatectl set-local-rtc 1
    else
        sudo timedatectl set-local-rtc 0
    fi
    sudo sed -i "s/^#\s*\($LOCALE\)/\1/" /etc/locale.gen
    sudo locale-gen >/dev/null
    echo "LANG=$LOCALE" | sudo tee /etc/locale.conf >/dev/null
    sudo hostnamectl set-hostname "$HOSTNAME_VALUE"
}

install_system_files() {
    say "files in /etc"
    install_etc nftables.conf 644
    install_etc NetworkManager/dispatcher.d/70-wifi-wired-exclusive 755
    install_etc sysctl.d/90-arp.conf 644
    install_etc systemd/zram-generator.conf 644
    install_etc vconsole.conf 644
    install_etc X11/xorg.conf.d/00-keyboard.conf 644
    install_etc greetd/config.toml 644
    install_etc greetd/regreet.toml 644
    install_etc mkinitcpio.d/linux.preset 644
    install_etc mkinitcpio.conf 644
    install_etc default/grub 644

    # The tracked mkinitcpio.conf drops kms because it pulls nouveau into the
    # initramfs; any other GPU needs it back.
    if [[ $WANT_NVIDIA -eq 1 ]]; then
        install_etc modprobe.d/blacklist-nouveau.conf 644
    else
        sudo sed -i 's/^\(HOOKS=(.*\bmodconf\) keyboard/\1 kms keyboard/' /etc/mkinitcpio.conf
        sudo rm -f /etc/modprobe.d/blacklist-nouveau.conf
    fi
    if [[ $WANT_NVME_QUIRKS -eq 0 ]]; then
        sudo sed -i "s/ $NVME_QUIRKS//" /etc/default/grub
    fi
}

# Print the UUID of the ESP that holds Windows Boot Manager, or nothing.
find_windows_esp() {
    local part mnt uuid
    while read -r part; do
        mnt=$(findmnt -nro TARGET -S "$part" | head -1)
        if [[ -z $mnt ]]; then
            mnt=$(mktemp -d)
            sudo mount -o ro "$part" "$mnt" 2>/dev/null || { rmdir "$mnt"; continue; }
            [[ -f $mnt/EFI/Microsoft/Boot/bootmgfw.efi ]] && uuid=$(lsblk -no UUID "$part")
            sudo umount "$mnt"
            rmdir "$mnt"
        else
            [[ -f $mnt/EFI/Microsoft/Boot/bootmgfw.efi ]] && uuid=$(lsblk -no UUID "$part")
        fi
        if [[ -n ${uuid:-} ]]; then echo "$uuid"; return; fi
    done < <(lsblk -rnpo PATH,PARTTYPE | awk '$2 == "c12a7328-f81f-11d2-ba4b-00a0c93ec93b" { print $1 }')
}

setup_grub() {
    say "GRUB menu"
    # 40_custom.in holds the Windows, rescue ISO, memtest, UEFI shell and
    # firmware entries, with this machine's UUIDs as placeholders.
    local root_uuid win_uuid out
    root_uuid=$(findmnt -no UUID /)
    out=$(mktemp)
    sed "s/@ROOT_UUID@/$root_uuid/g" "$SYSTEM_DIR/etc/grub.d/40_custom.in" > "$out"

    win_uuid=""
    if [[ $WANT_WINDOWS -eq 1 ]]; then
        win_uuid=$(find_windows_esp)
        [[ -n $win_uuid ]] || warn "no ESP with Windows Boot Manager found, leaving out the Windows entry"
    fi
    if [[ -n $win_uuid ]]; then
        sed -i "s/@WIN_ESP_UUID@/$win_uuid/g" "$out"
    else
        sed -i '/^#@windows-begin@$/,/^#@windows-end@$/d' "$out"
    fi
    if [[ ! -f /boot/iso/archlinux-x86_64.iso ]]; then
        sed -i '/^#@iso-begin@$/,/^#@iso-end@$/d' "$out"
    fi
    sed -i '/^#@\(windows\|iso\)-\(begin\|end\)@$/d' "$out"
    sudo install -m755 -o root -g root "$out" /etc/grub.d/40_custom
    rm -f "$out"

    # These would add entries that 40_custom already covers, or (bootnext,
    # os-prober) were turned off on purpose.
    local f
    for f in 30_os-prober 30_uefi-firmware 31_efi_bootnext 60_memtest86+-efi; do
        [[ -f /etc/grub.d/$f ]] && sudo chmod -x "/etc/grub.d/$f"
    done

    say "GRUB theme"
    if [[ -f $GRUB_THEME_DIR/theme.txt ]] && grep -q 'JetBrainsMono NF Bold 16' "$GRUB_THEME_DIR/theme.txt"; then
        echo "already installed"
    else
        local src
        src=$(mktemp -d)
        git clone -q --depth 1 "$GRUB_THEMES_REPO" "$src"
        # The same files upstream's install.sh copies for "-t vimix -i color
        # -s 1080p", without letting it edit /etc/default/grub.
        sudo mkdir -p "$GRUB_THEME_DIR"
        sudo cp -a --no-preserve=ownership "$src/common/"*.pf2 "$GRUB_THEME_DIR/"
        sudo cp --no-preserve=ownership "$src/config/theme-1080p.txt" "$GRUB_THEME_DIR/theme.txt"
        sudo cp --no-preserve=ownership "$src/backgrounds/1080p/background-vimix.jpg" "$GRUB_THEME_DIR/background.jpg"
        sudo rm -rf "$GRUB_THEME_DIR/icons"
        sudo cp -a --no-preserve=ownership "$src/assets/assets-color/icons-1080p" "$GRUB_THEME_DIR/icons"
        sudo cp -a --no-preserve=ownership "$src/assets/assets-select/select-1080p/"*.png "$GRUB_THEME_DIR/"
        sudo cp --no-preserve=ownership "$src/assets/info-1080p.png" "$GRUB_THEME_DIR/info.png"
        rm -rf "$src"
        sudo grub-mkfont -s 16 -o "$GRUB_THEME_DIR/jetbrainsmono_nf_bold_16.pf2" "$GRUB_FONT_TTF" 2>/dev/null
        sudo sed -i 's/"DejaVu Sans Regular 16"/"JetBrainsMono NF Bold 16"/' "$GRUB_THEME_DIR/theme.txt"
    fi
}

install_wallpapers() {
    say "wallpapers"
    sudo mkdir -p /usr/share/backgrounds
    local w dest
    for w in "${WALLPAPERS[@]}"; do
        dest=/usr/share/backgrounds/wallhaven_$w
        [[ -f $dest ]] && continue
        sudo curl -fsSL -o "$dest" "https://w.wallhaven.cc/full/${w:0:2}/wallhaven-$w" \
            || warn "could not download wallpaper $w"
    done
}

rebuild_boot() {
    say "initramfs and grub.cfg"
    sudo mkinitcpio -P
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

enable_services() {
    say "services"
    sudo nft -c -f /etc/nftables.conf
    sudo sysctl --system >/dev/null
    sudo systemctl enable --now "${SERVICES[@]}"
    # Enabled but not started: starting it here would put the login screen
    # on top of the console this script is running in.
    sudo systemctl enable greetd
}

# =============================================================================
# user
# =============================================================================

install_aur() {
    if command -v yay >/dev/null 2>&1; then
        say "yay already installed"
    else
        say "yay"
        local build
        build=$(mktemp -d)
        git clone --depth 1 https://aur.archlinux.org/yay.git "$build/yay"
        ( cd "$build/yay" && makepkg -si --noconfirm )
        rm -rf "$build"
    fi
    say "AUR packages"
    yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
}

install_oh_my_zsh() {
    local zsh_custom=$HOME/.oh-my-zsh/custom
    if [[ -d $HOME/.oh-my-zsh ]]; then
        say "oh-my-zsh already installed"
    else
        say "oh-my-zsh"
        # KEEP_ZSHRC stops the installer writing its own .zshrc over the one
        # stow is about to symlink in. RUNZSH stops it dropping into a shell.
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
            "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    if [[ $(getent passwd "$USER" | cut -d: -f7) != /usr/bin/zsh ]]; then
        sudo chsh -s /usr/bin/zsh "$USER"
    fi

    say "zsh theme and plugins"
    clone_if_missing https://github.com/romkatv/powerlevel10k.git \
        "$zsh_custom/themes/powerlevel10k"
    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git \
        "$zsh_custom/plugins/zsh-autosuggestions"
    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$zsh_custom/plugins/zsh-syntax-highlighting"
}

setup_dotfiles() {
    say "dotfiles"
    git -C "$DOTFILES" remote set-url origin "$DOTFILES_SSH"

    # stow refuses to replace anything it does not own, and the base install,
    # oh-my-zsh or a first run of an app may already have written some of
    # these files. Move them aside rather than lose them.
    local pkg rel target
    for pkg in "${STOW_PACKAGES[@]}" "${STOW_PACKAGES_NOFOLD[@]}"; do
        while IFS= read -r rel; do
            target=$HOME/$rel
            [[ -e $target || -L $target ]] || continue
            [[ $(readlink -f "$target") == "$(readlink -f "$DOTFILES/$pkg/$rel")" ]] && continue
            warn "moving existing ~/$rel aside to $(basename "$rel").pre-stow"
            mv "$target" "$target.pre-stow"
        done < <(cd "$DOTFILES/$pkg" && find . \( -type f -o -type l \) -printf '%P\n')
    done

    stow -d "$DOTFILES" -t "$HOME" --restow "${STOW_PACKAGES[@]}"
    stow -d "$DOTFILES" -t "$HOME" --restow --no-folding "${STOW_PACKAGES_NOFOLD[@]}"
}

write_local_config() {
    # Machine-local, so not in the repo: .zshrc sources it if it is there.
    say "~/.config.zsh"
    if [[ -f $HOME/.config.zsh ]]; then
        echo "already there, leaving it alone"
    elif [[ $WANT_CONDA -eq 1 ]]; then
        cat > "$HOME/.config.zsh" <<ZSHCFG

# conda is set up on first use: running its shell hook in every new shell
# cost ~0.5 s. The first \`conda ...\` call loads the real conda function
# (which replaces this one) and then runs the command.
conda() {
    unfunction conda
    eval "\$('$HOME/$CONDA_DIR_NAME/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    conda "\$@"
}
ZSHCFG
    fi

    say "~/.gitconfig"
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
}

setup_ssh_key() {
    local key=$HOME/.ssh/id_ed25519
    if [[ -f $key ]]; then
        say "ssh key already present"
        return 0
    fi
    say "ssh key"
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$key" -N ""
    cat <<KEY

Add this to https://github.com/settings/keys before the first push:

$(cat "$key.pub")

KEY
}

install_conda() {
    [[ $WANT_CONDA -eq 1 ]] || return 0
    local dir=$HOME/$CONDA_DIR_NAME
    if [[ -d $dir ]]; then
        say "miniforge already installed"
    else
        say "miniforge"
        local sh=$HOME/miniforge.sh
        curl -fsSL -o "$sh" \
            https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
        bash "$sh" -b -p "$dir"
        rm -f "$sh"
    fi

    say "conda env $CONDA_ENV"
    if "$dir/bin/conda" env list | grep -qE "^$CONDA_ENV\s"; then
        echo "already there"
    else
        "$dir/bin/conda" create -y -n "$CONDA_ENV" "${CONDA_ENV_PKGS[@]}"
    fi
}

install_claude() {
    [[ $WANT_CLAUDE -eq 1 ]] || return 0
    if command -v claude >/dev/null 2>&1 || [[ -x $HOME/.local/bin/claude ]]; then
        say "claude already installed"
        return 0
    fi
    say "claude code"
    curl -fsSL https://claude.ai/install.sh | bash \
        || warn "claude install failed -- see https://docs.claude.com/en/docs/claude-code/setup"
}

# =============================================================================

[[ $(id -u) -ne 0 ]] || die "run this as your user, not root -- it uses sudo where needed"
command -v sudo >/dev/null 2>&1 || die "no sudo"
sudo -v || die "sudo does not work for $USER"

install_packages
setup_system_settings
install_system_files
setup_grub
install_wallpapers
rebuild_boot
enable_services

install_aur
install_oh_my_zsh
setup_dotfiles
write_local_config
setup_ssh_key
install_conda
install_claude

cat <<DONE

Done. Reboot to get the greetd login screen.

Still to do by hand:
  * add the printed SSH key to GitHub, if it generated one
  * "sudo tailscale up" to join the tailnet
  * run "claude" once to sign in
  * nvim fetches its plugins through lazy.nvim on first start
  * GRUB's "Arch Linux rescue (ISO)" entry is only added when
    /boot/iso/archlinux-x86_64.iso exists: download the ISO there and run
    "sudo grub-mkconfig -o /boot/grub/grub.cfg" if you want it
  * hyprland.lua has this machine's monitor (DP-1, 2560x1440@144, HDR):
    change it if the new screen differs

DONE
