#!/usr/bin/env bash
set -euo pipefail

UPDATE=1
DRY_RUN=0

usage() {
  cat <<'EOF'
Install the dotfiles prerequisites.

Usage:
  ./install-prereqs.sh [--no-update] [--dry-run]

Options:
  --no-update   Only install missing tools; skip all upgrade steps.
  --dry-run     Print the commands without executing them.
  -h, --help    Show this help.

Supported systems: Debian/Ubuntu, Fedora/RHEL/CentOS, macOS.
Rust tools are installed with cargo-binstall (compiling as a fallback).
Re-running the script is safe and updates tools to the latest release.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-update) UPDATE=0 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'error: unknown argument: %s\n' "$1" >&2; exit 1 ;;
  esac
  shift
done

log() { printf '\n== %s ==\n' "$*"; }

have() { command -v "$1" >/dev/null 2>&1; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '+ %s\n' "$*"
    return 0
  fi
  "$@"
}

run_sh() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '+ %s\n' "$*"
    return 0
  fi
  bash -c "$*"
}

SUDO=()
if [ "$(id -u)" -ne 0 ] && have sudo; then
  SUDO=(sudo)
fi

OS=""
DISTRO_ID=""
case "$(uname -s)" in
  Darwin)
    OS=macos
    ;;
  Linux)
    if [ -r /etc/os-release ]; then
      . /etc/os-release
      DISTRO_ID="${ID:-}"
      case " ${ID:-} ${ID_LIKE:-} " in
        *debian*|*ubuntu*) OS=debian ;;
        *fedora*|*rhel*|*centos*) OS=fedora ;;
      esac
    fi
    ;;
esac

if [ -z "$OS" ]; then
  printf 'error: unsupported OS. Supported: Debian/Ubuntu, Fedora/RHEL/CentOS, macOS.\n' >&2
  exit 1
fi

case "$(uname -m)" in
  x86_64|amd64) ARCH=x86_64 ;;
  aarch64|arm64) ARCH=aarch64 ;;
  *)
    printf 'error: unsupported architecture: %s\n' "$(uname -m)" >&2
    exit 1
    ;;
esac

LOCAL_BIN="$HOME/.local/bin"
CARGO_BIN="$HOME/.cargo/bin"
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
KITTY_APP="$HOME/.local/kitty.app"

NVIM_DIR="nvim-linux-x86_64"
FZF_ARCH="amd64"
if [ "$ARCH" = aarch64 ]; then
  NVIM_DIR="nvim-linux-arm64"
  FZF_ARCH="arm64"
fi

load_cargo() {
  export PATH="$CARGO_BIN:$PATH"
  [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
  return 0
}

ensure_rust() {
  load_cargo
  if ! have cargo; then
    log "Installing Rust toolchain (rustup)"
    if [ "$OS" = macos ]; then
      run brew install rustup
      run rustup-init -y --no-modify-path --profile minimal
    else
      run_sh "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal"
    fi
  elif [ "$UPDATE" -eq 1 ]; then
    log "Updating Rust toolchain"
    run rustup update
  fi
  load_cargo
}

ensure_binstall() {
  load_cargo
  if ! have cargo-binstall; then
    log "Installing cargo-binstall"
    if [ "$OS" = macos ]; then
      run brew install cargo-binstall
    else
      run_sh "curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash"
    fi
  elif [ "$UPDATE" -eq 1 ]; then
    log "Updating cargo-binstall"
    run cargo binstall --no-confirm cargo-binstall
  fi
  load_cargo
}

crate_installed_version() {
  load_cargo
  cargo install --list 2>/dev/null | awk -v c="$1" '$1==c {print $2; exit}' | sed 's/^v//; s/:$//' || true
}

crate_latest_version() {
  curl -fsSL -A 'dotfiles-install-prereqs' "https://crates.io/api/v1/crates/$1" 2>/dev/null \
    | jq -r '.crate.max_stable_version // empty' 2>/dev/null || true
}

cargo_tool() {
  local crate="$1" installed latest
  load_cargo
  installed="$(crate_installed_version "$crate")"

  if [ -z "$installed" ]; then
    log "Installing $crate"
    run cargo binstall --no-confirm --locked "$crate"
    return 0
  fi

  [ "$UPDATE" -eq 1 ] || return 0

  latest="$(crate_latest_version "$crate")"
  if [ -n "$latest" ] && [ "$installed" = "$latest" ]; then
    log "$crate is up to date ($installed)"
    return 0
  fi

  log "Updating $crate (${installed:-?} -> ${latest:-latest})"
  run cargo binstall --no-confirm --locked --force "$crate"
}

install_fzf() {
  if [ "$UPDATE" -eq 0 ] && have fzf; then
    return 0
  fi
  log "Installing/updating fzf"
  local tag version asset tmp
  tag="$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/junegunn/fzf/releases/latest)"
  tag="${tag##*/}"
  version="${tag#v}"
  asset="fzf-${version}-linux_${FZF_ARCH}.tar.gz"
  tmp="$(mktemp -d)"
  run mkdir -p "$LOCAL_BIN"
  run curl -fsSL -o "$tmp/fzf.tar.gz" "https://github.com/junegunn/fzf/releases/download/${tag}/${asset}"
  run tar -C "$tmp" -xzf "$tmp/fzf.tar.gz"
  run install -m 0755 "$tmp/fzf" "$LOCAL_BIN/fzf"
  rm -rf "$tmp"
}

install_neovim() {
  if [ "$UPDATE" -eq 0 ] && [ -x "/opt/$NVIM_DIR/bin/nvim" ]; then
    return 0
  fi
  log "Installing/updating Neovim"
  local tmp
  tmp="$(mktemp -d)"
  run curl -fsSL -o "$tmp/nvim.tar.gz" "https://github.com/neovim/neovim/releases/latest/download/${NVIM_DIR}.tar.gz"
  run "${SUDO[@]}" rm -rf "/opt/$NVIM_DIR"
  run "${SUDO[@]}" tar -C /opt -xzf "$tmp/nvim.tar.gz"
  run "${SUDO[@]}" ln -sf "/opt/$NVIM_DIR/bin/nvim" /usr/local/bin/nvim
  rm -rf "$tmp"
}

install_kitty() {
  if [ "$UPDATE" -eq 0 ] && [ -x "$KITTY_APP/bin/kitty" ]; then
    return 0
  fi
  log "Installing/updating kitty"
  run_sh "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n"
  run mkdir -p "$LOCAL_BIN"
  run ln -sf "$KITTY_APP/bin/kitty" "$LOCAL_BIN/kitty"
  run ln -sf "$KITTY_APP/bin/kitten" "$LOCAL_BIN/kitten"
}

install_nerd_font() {
  if [ "$UPDATE" -eq 0 ] && [ -d "$FONT_DIR" ] && compgen -G "$FONT_DIR/*.ttf" >/dev/null; then
    return 0
  fi
  log "Installing/updating JetBrainsMono Nerd Font"
  local tmp
  tmp="$(mktemp -d)"
  run curl -fsSL -o "$tmp/JetBrainsMono.tar.xz" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
  run rm -rf "$FONT_DIR"
  run mkdir -p "$FONT_DIR"
  run tar -xJf "$tmp/JetBrainsMono.tar.xz" -C "$FONT_DIR"
  run fc-cache -f "$HOME/.local/share/fonts"
  rm -rf "$tmp"
}

install_linux_common() {
  ensure_rust
  ensure_binstall
  for crate in dotter sofka starship zoxide zellij; do
    cargo_tool "$crate"
  done
  install_fzf
  install_neovim
  install_kitty
  install_nerd_font
}

install_debian() {
  log "Debian/Ubuntu packages"
  run "${SUDO[@]}" apt-get update
  local pkgs=(build-essential pkg-config curl git jq xz-utils fontconfig ca-certificates unzip)
  if [ "$UPDATE" -eq 1 ]; then
    run "${SUDO[@]}" apt-get install -y "${pkgs[@]}"
  else
    run "${SUDO[@]}" apt-get install -y --no-upgrade "${pkgs[@]}"
  fi
  install_linux_common
}

install_fedora() {
  case " $DISTRO_ID " in
    *centos*|*rhel*|*rocky*|*almalinux*)
      log "Enabling EPEL"
      run "${SUDO[@]}" dnf install -y epel-release || true
      ;;
  esac
  log "Fedora/CentOS packages"
  local pkgs=(gcc gcc-c++ make pkgconf-pkg-config curl git jq xz fontconfig ca-certificates unzip)
  run "${SUDO[@]}" dnf install -y "${pkgs[@]}"
  if [ "$UPDATE" -eq 1 ]; then
    run "${SUDO[@]}" dnf upgrade -y "${pkgs[@]}"
  fi
  install_linux_common
}

install_macos() {
  if ! have brew; then
    printf 'error: Homebrew is required. Install it from https://brew.sh then re-run.\n' >&2
    exit 1
  fi
  log "Homebrew packages"
  run brew update
  local formulae=(git jq fzf neovim starship zoxide zellij dotter)
  local casks=(kitty font-jetbrains-mono-nerd-font)
  run brew install "${formulae[@]}"
  run brew install --cask "${casks[@]}"
  if [ "$UPDATE" -eq 1 ]; then
    run brew upgrade "${formulae[@]}"
    run brew upgrade --cask "${casks[@]}"
  fi
  ensure_rust
  ensure_binstall
  cargo_tool sofka
}

case "$OS" in
  debian) install_debian ;;
  fedora) install_fedora ;;
  macos) install_macos ;;
esac

log "Done"
printf 'Next: run ./setup.sh to deploy the dotfiles.\n'
