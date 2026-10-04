#!/usr/bin/env bash
# Rebuild this Arch-on-WSL machine from a fresh "wsl --install archlinux".
#
# This is not system/install.sh. That one sets up bare-metal Arch -- grub,
# mkinitcpio, nftables, greetd -- and none of it applies under WSL.
#
# A fresh Arch WSL has root and no user account, so the work splits in two and
# the script picks its half from whoever runs it:
#
#   sudo ./install.sh   root half: wsl.conf, locale, timezone, pacman keyring,
#                       the user account. WSL then needs a shutdown.
#   ./install.sh        user half: packages, yay, oh-my-zsh, dotfiles, conda.
#
# Every step checks before it acts, so re-running after a failure is safe.
set -euo pipefail

# --- what to build ----------------------------------------------------------

USERNAME=nilesh
TIMEZONE=Asia/Calcutta
LOCALE=en_US.UTF-8

DOTFILES_HTTPS=https://github.com/nilesh-ugale/dotfiles.git
DOTFILES_SSH=git@github.com:nilesh-ugale/dotfiles.git

# Only these four packages apply under WSL. hypr, waybar, wofi, kitty, btop,
# fastfetch and yazi are for the desktop and are left unstowed here.
STOW_PACKAGES=(zsh tmux bin nvim)

# Stowed separately, with --no-folding. ~/.claude holds credentials and chat
# transcripts alongside the settings, so the directory itself must stay real:
# a folded symlink would send all of that into the repo, which is public.
# Only CLAUDE.md is tracked; settings.json stays local to each machine. The
# SEDEMAC C style guide CLAUDE.md refers to is deliberately not tracked
# either, and is copied over by hand.
STOW_PACKAGES_NOFOLD=(claude)

GIT_NAME="Nilesh Ugale"
GIT_EMAIL=nilesh.r.ugale@gmail.com
# The Windows user name differs between PCs, so ask Windows for it. cmd.exe
# is called by full path, runs from /mnt/c to avoid its warning about UNC
# working directories, and ends its output with \r, which tr strips. If
# interop is off this is empty, and the paths below just won't exist.
WIN_USER=$(cd /mnt/c && /mnt/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r') || true
WIN_HOME=/mnt/c/Users/$WIN_USER
# Lives on the Windows side. The template is only wired up if the file is
# actually there.
GIT_COMMIT_TEMPLATE=$WIN_HOME/.gitmessage
# The Windows side's ssh key, already on GitHub. It is copied in if present;
# otherwise a new key is made and has to be added to GitHub by hand.
WIN_SSH_DIR=$WIN_HOME/.ssh

# Roots for tmux-sessionizer, separated like PATH. /mnt/e is this machine's
# second drive -- change it if the new PC letters its drives differently.
TMUX_SEARCH_DIR_VALUE='/mnt/e/repos:$HOME/dotfiles:$HOME/work'

CONDA_DIR_NAME=miniforge3
CONDA_ENV=py314
# The explicitly requested packages. conda pulls gmpy2 and the rest as deps.
CONDA_ENV_PKGS=(python=3.14 click pycryptodome ecdsa pypdf)

# The full explicit package list off the old box, minus qemu-full, which is a
# ~1 GB download and is behind --qemu instead. fastfetch is not installed here
# either, though .zshrc calls it and the repo carries a config: add --fastfetch.
PACKAGES=(
    base base-devel bazel bc clang cmake cpio curl docker docker-buildx eza fd fzf
    git htop less lib32-gcc-libs lua51 luarocks neovim ninja openssh pandoc-cli
    python-pip python-pynvim ripgrep rsync stow sudo tmux tree tree-sitter-cli
    uboot-tools wget xterm yazi zsh
)
AUR_PACKAGES=(osslsigncode)

# --- flags ------------------------------------------------------------------

WANT_DOCKER=0     # --docker     add the user to the docker group, enable the service
WANT_QEMU=0       # --qemu       also install qemu-full
WANT_FASTFETCH=0  # --fastfetch  also install fastfetch
WANT_CONDA=1      # --no-conda   skip miniforge and the py314 env
WANT_CLAUDE=1     # --no-claude  skip Claude Code

usage() {
    # The header block: every comment line after the shebang, stopping at the
    # first line of actual code. Beats a hardcoded line range that drifts.
    awk 'NR == 1 { next } /^#/ { sub(/^# ?/, ""); print; next } { exit }' "$0"
    cat <<USAGE

Options:
  --docker       add $USERNAME to the docker group and enable docker.service
  --qemu         also install qemu-full (~1 GB)
  --fastfetch    also install fastfetch
  --no-conda     skip miniforge and the $CONDA_ENV environment
  --no-claude    skip Claude Code
  -h, --help     this text
USAGE
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --docker)    WANT_DOCKER=1 ;;
        --qemu)      WANT_QEMU=1 ;;
        --fastfetch) WANT_FASTFETCH=1 ;;
        --no-conda)  WANT_CONDA=0 ;;
        --no-claude) WANT_CLAUDE=0 ;;
        -h|--help)   usage; exit 0 ;;
        *)           echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

# --- helpers ----------------------------------------------------------------

say()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m warning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m error:\033[0m %s\n' "$*" >&2; exit 1; }

# =============================================================================
# root half
# =============================================================================

install_as_root() {
    say "wsl.conf"
    # systemd is what docker.service and the rest need. appendWindowsPath keeps
    # the Windows toolchains (CC-RH, TI CGT, CubeCLT) reachable from here.
    # default= makes WSL open a shell as the user instead of root.
    if [[ -f /etc/wsl.conf ]]; then cp -n /etc/wsl.conf /etc/wsl.conf.bak; fi
    cat > /etc/wsl.conf <<WSLCONF
[boot]
systemd=true

[interop]
appendWindowsPath = true

[user]
default = $USERNAME
WSLCONF

    say "locale and timezone"
    sed -i "s/^#\s*\($LOCALE\)/\1/" /etc/locale.gen
    grep -q "^$LOCALE" /etc/locale.gen || echo "$LOCALE UTF-8" >> /etc/locale.gen
    locale-gen
    echo "LANG=$LOCALE" > /etc/locale.conf
    ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

    say "pacman"
    # The shipped image has an empty keyring, and the keyring package must be
    # refreshed on its own before any large upgrade.
    pacman-key --init
    pacman-key --populate archlinux
    pacman -Sy --noconfirm archlinux-keyring
    for opt in Color VerbosePkgLists; do
        grep -qE "^$opt\b" /etc/pacman.conf || sed -i "s/^\[options\]/[options]\n$opt/" /etc/pacman.conf
    done
    grep -qE '^ParallelDownloads' /etc/pacman.conf \
        || sed -i 's/^\[options\]/[options]\nParallelDownloads = 5/' /etc/pacman.conf
    pacman -Syu --noconfirm
    # Needed before chsh and useradd -s below.
    pacman -S --needed --noconfirm zsh sudo git

    say "user $USERNAME"
    if id -u "$USERNAME" >/dev/null 2>&1; then
        echo "already exists, leaving it alone"
        chsh -s /usr/bin/zsh "$USERNAME"
    else
        useradd -m -G wheel -s /usr/bin/zsh "$USERNAME"
        echo "set a password for $USERNAME:"
        passwd "$USERNAME"
    fi

    # A drop-in rather than an edit, so a pacman update to sudoers cannot
    # silently drop it.
    echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-wheel
    chmod 440 /etc/sudoers.d/10-wheel
    visudo -cf /etc/sudoers.d/10-wheel >/dev/null || die "sudoers drop-in is malformed"

    cat <<NEXT

Root half done. Now, from Windows:

    wsl --shutdown

Reopen the distro -- it should log you in as $USERNAME -- and run the user half:

    cd ~ && git clone $DOTFILES_HTTPS && ./dotfiles/wsl/install.sh

NEXT
}

# =============================================================================
# user half
# =============================================================================

install_packages() {
    say "packages"
    local pkgs=("${PACKAGES[@]}")
    if [[ $WANT_QEMU -eq 1 ]];      then pkgs+=(qemu-full); fi
    if [[ $WANT_FASTFETCH -eq 1 ]]; then pkgs+=(fastfetch);  fi
    sudo pacman -Syu --needed --noconfirm "${pkgs[@]}"
}

install_yay() {
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
    if [[ ${#AUR_PACKAGES[@]} -gt 0 ]]; then
        yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
    fi
}

setup_docker() {
    [[ $WANT_DOCKER -eq 1 ]] || return 0
    say "docker"
    sudo usermod -aG docker "$USER"
    sudo systemctl enable --now docker
    echo "log out and back in for the docker group to apply"
}

setup_ssh_key() {
    local key=$HOME/.ssh/id_ed25519
    if [[ -f $key ]]; then
        say "ssh key already present"
        return 0
    fi
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    # Files on /mnt/c show as 777, and ssh refuses a private key that open.
    if [[ -f $WIN_SSH_DIR/id_ed25519 && -f $WIN_SSH_DIR/id_ed25519.pub ]]; then
        say "ssh key (copied from $WIN_SSH_DIR)"
        cp "$WIN_SSH_DIR/id_ed25519" "$WIN_SSH_DIR/id_ed25519.pub" "$HOME/.ssh/"
        chmod 600 "$key"
        chmod 644 "$key.pub"
        return 0
    fi
    say "ssh key"
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$key" -N ""
    cat <<KEY

Add this to https://github.com/settings/keys before the first push:

$(cat "$key.pub")

KEY
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

    say "zsh theme and plugins"
    clone_if_missing https://github.com/romkatv/powerlevel10k.git \
        "$zsh_custom/themes/powerlevel10k"
    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git \
        "$zsh_custom/plugins/zsh-autosuggestions"
    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$zsh_custom/plugins/zsh-syntax-highlighting"
}

clone_if_missing() {
    local url=$1 dest=$2
    if [[ -d $dest ]]; then
        echo "  $(basename "$dest") already there"
    else
        git clone --depth 1 "$url" "$dest"
    fi
}

setup_dotfiles() {
    local dir=$HOME/dotfiles
    say "dotfiles"
    if [[ -d $dir/.git ]]; then
        echo "already cloned"
    else
        # HTTPS, because a brand-new box has no key on GitHub yet.
        git clone "$DOTFILES_HTTPS" "$dir"
    fi
    # Push over SSH from here on.
    git -C "$dir" remote set-url origin "$DOTFILES_SSH"

    # stow refuses to replace a real file, and oh-my-zsh, the skel or a
    # previous Claude install may have left one. Move those aside, not lose them.
    local f
    for f in "$HOME/.zshrc" "$HOME/.p10k.zsh" "$HOME/.claude/CLAUDE.md"; do
        if [[ -f $f && ! -L $f ]]; then
            warn "moving existing ${f#$HOME/} aside to $(basename "$f").pre-stow"
            mv "$f" "$f.pre-stow"
        fi
    done

    stow -d "$dir" -t "$HOME" --restow "${STOW_PACKAGES[@]}"
    stow -d "$dir" -t "$HOME" --restow --no-folding "${STOW_PACKAGES_NOFOLD[@]}"
}

write_local_config() {
    # Machine-local, so deliberately not in the repo: .zshrc sources it if it
    # is there and falls back to a bare TMUX_SEARCH_DIR if it is not.
    say "~/.config.zsh"
    if [[ -f $HOME/.config.zsh ]]; then
        echo "already there, leaving it alone"
    else
        : > "$HOME/.config.zsh"
        # Built in pieces rather than written whole and filtered: the conda
        # block is a nested if/else, so deleting its lines by pattern would
        # leave dangling else/fi behind and the file would not parse.
        if [[ $WANT_CONDA -eq 1 ]]; then
            cat >> "$HOME/.config.zsh" <<'ZSHCFG'
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('__CONDA_DIR__/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "__CONDA_DIR__/etc/profile.d/conda.sh" ]; then
        . "__CONDA_DIR__/etc/profile.d/conda.sh"
    else
        export PATH="__CONDA_DIR__/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
conda deactivate

ZSHCFG
        fi
        cat >> "$HOME/.config.zsh" <<'ZSHCFG'
# Roots for tmux-sessionizer, separated like PATH. Each is scanned 4 levels
# deep; a root that is itself a repo is offered as well.
export TMUX_SEARCH_DIR="__TMUX_SEARCH_DIR__"
ZSHCFG
        sed -i "s|__CONDA_DIR__|$HOME/$CONDA_DIR_NAME|g" "$HOME/.config.zsh"
        sed -i "s|__TMUX_SEARCH_DIR__|$TMUX_SEARCH_DIR_VALUE|g" "$HOME/.config.zsh"
    fi

    say "~/.gitconfig"
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global core.autocrlf input
    git config --global core.untrackedCache false
    git config --global pull.rebase true
    git config --global init.defaultBranch main
    if [[ -f $GIT_COMMIT_TEMPLATE ]]; then
        git config --global commit.template "$GIT_COMMIT_TEMPLATE"
    else
        warn "no commit template at $GIT_COMMIT_TEMPLATE, skipping commit.template"
    fi
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
    # Non-fatal: everything else is already in place, and this one is easy to
    # redo by hand if the installer URL has moved on.
    curl -fsSL https://claude.ai/install.sh | bash \
        || warn "claude install failed -- see https://docs.claude.com/en/docs/claude-code/setup"
}

install_as_user() {
    command -v sudo >/dev/null 2>&1 || die "no sudo -- run the root half first"
    sudo -v || die "sudo does not work for $USER -- run the root half first"

    install_packages
    install_yay
    setup_docker
    setup_ssh_key
    install_oh_my_zsh
    setup_dotfiles
    write_local_config
    install_conda
    install_claude

    mkdir -p "$HOME/work"

    cat <<DONE

Done. Open a new shell to pick it all up.

Still to do by hand:
  * add the printed SSH key to GitHub, if it generated one
  * copy ~/.claude/c-style-guide.md over by hand. CLAUDE.md points at it,
    but it is a SEDEMAC internal document and this repo is public
  * run "claude" once to sign in; that writes ~/.claude/.credentials.json,
    which is deliberately untracked
  * nvim will fetch its plugins through lazy.nvim on first start
  * Windows Terminal: merge wsl/manas-windows-terminal.json into its
    settings.json for the MANAS colour scheme, tab-row theme and
    background picture; the file says where each piece goes. Copy
    kitty/.config/kitty/dog-manas.png to the Windows side first, since
    Windows Terminal cannot read a \\wsl$ path reliably.

DONE
}

# =============================================================================

if [[ $(id -u) -eq 0 ]]; then
    install_as_root
else
    install_as_user
fi
