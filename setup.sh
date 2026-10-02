#!/usr/bin/env bash
#
# Setup dotfiles on a new machine.
#
# Usage:
#   ./setup.sh <mac|laptop|desktop|server> [-f|--force] [-e|--exclude PKG]... [-i|--include PKG]...
#
# Modes (each deploys ALL packages from .dotter/global.toml, plus the
# non-dotter `kde` step, minus the excludes below):
#   mac      excludes bash, kde
#   laptop   excludes zsh, kde, aerospace
#   desktop  excludes zsh, aerospace
#   server   excludes zsh, kde, aerospace, kitty
#
# -e/--exclude PKG  additionally exclude a package (repeatable)
# -i/--include PKG  re-include a package excluded by the mode (repeatable)
# -f/--force        pass --force (and --noconfirm) to dotter, overwriting
#                   existing files in $HOME (destructive — have backups).
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

usage() {
  sed -n '6p' "$0" | sed 's/^#   //' >&2
  exit 1
}

mode=""
force=""
excludes=()
includes=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    -f|--force) force="1" ;;
    -e|--exclude)
      shift
      [ "$#" -gt 0 ] || { echo "error: -e/--exclude requires a package name" >&2; exit 1; }
      excludes+=("$1")
      ;;
    -i|--include)
      shift
      [ "$#" -gt 0 ] || { echo "error: -i/--include requires a package name" >&2; exit 1; }
      includes+=("$1")
      ;;
    -h|--help) usage ;;
    -*) echo "error: unknown argument: $1" >&2; usage ;;
    *)
      [ -z "$mode" ] || { echo "error: mode given twice: $mode, $1" >&2; usage; }
      mode="$1"
      ;;
  esac
  shift
done

case "$mode" in
  mac)     mode_excludes=(bash kde) ;;
  laptop)  mode_excludes=(zsh kde aerospace) ;;
  desktop) mode_excludes=(zsh aerospace) ;;
  server)  mode_excludes=(zsh kde aerospace kitty) ;;
  "")      echo "error: mode is required" >&2; usage ;;
  *)       echo "error: unknown mode: $mode" >&2; usage ;;
esac

# Ensure dotter is available.
if ! command -v dotter >/dev/null 2>&1; then
  echo "error: dotter is not installed. See README.md prerequisites." >&2
  exit 1
fi

# Derive the full package set from global.toml's [<name>.files] headers.
dotter_packages=()
while IFS= read -r pkg; do
  dotter_packages+=("$pkg")
done < <(grep -oE '^\[[a-zA-Z0-9_-]+\.files\]' .dotter/global.toml | sed -E 's/^\[(.*)\.files\]$/\1/')

if [ "${#dotter_packages[@]}" -eq 0 ]; then
  echo "error: no packages found in .dotter/global.toml" >&2
  exit 1
fi

# kde is not a dotter package but is selectable like one.
all_packages=("${dotter_packages[@]}" kde)

contains() {
  local needle="$1"; shift
  local x
  for x in "$@"; do [ "$x" = "$needle" ] && return 0; done
  return 1
}

for pkg in "${excludes[@]:-}" "${includes[@]:-}"; do
  [ -z "$pkg" ] && continue
  contains "$pkg" "${all_packages[@]}" || { echo "error: unknown package: $pkg" >&2; exit 1; }
done
for pkg in "${includes[@]:-}"; do
  [ -z "$pkg" ] && continue
  if contains "$pkg" "${excludes[@]:-}"; then
    echo "error: $pkg given to both -e and -i" >&2
    exit 1
  fi
done

# Selected = all - mode excludes - -e excludes + -i includes.
selected=()
for pkg in "${all_packages[@]}"; do
  if contains "$pkg" "${includes[@]:-}"; then
    selected+=("$pkg")
  elif contains "$pkg" "${mode_excludes[@]}" "${excludes[@]:-}"; then
    continue
  else
    selected+=("$pkg")
  fi
done

# Dotter packages to deploy (everything selected except kde).
packages=()
for pkg in "${selected[@]:-}"; do
  [ -n "$pkg" ] && [ "$pkg" != "kde" ] && packages+=("$pkg")
done

if [ "${#packages[@]}" -eq 0 ]; then
  echo "error: all packages excluded, nothing to deploy" >&2
  exit 1
fi

echo "Mode: $mode"
echo "Selected: ${selected[*]}"

# Build the package list as a TOML array: "a", "b", "c"
list=""
for pkg in "${packages[@]}"; do
  [ -n "$list" ] && list+=", "
  list+="\"$pkg\""
done

# Select which packages to deploy on THIS machine.
# local.toml is gitignored (per-machine).
mkdir -p .dotter
printf 'packages = [%s]\n' "$list" > .dotter/local.toml
echo "Wrote .dotter/local.toml: packages = [$list]"

# Deploy (creates the symlinks).
echo "== Deploy =="
deploy_args=(deploy -v)
if [ -n "$force" ]; then
  deploy_args+=(--force -y)
fi
dotter "${deploy_args[@]}"

# SSH requires strict permissions on config files. Git doesn't track file
# modes beyond the executable bit, so enforce 600 after checkout/symlink.
if contains ssh "${packages[@]}"; then
  chmod 600 "$HOME/.ssh/config"
fi

# Apply KDE plugin settings (KZones) on the widescreen setup. This is not a
# dotter package (nothing is symlinked); it merges keys into ~/.config/kwinrc
# via kwriteconfig. Runs in desktop mode or with `-i kde`.
if contains kde "${selected[@]}" && [ -x "$REPO_DIR/kde/apply-kde.sh" ]; then
  echo "== KDE =="
  "$REPO_DIR/kde/apply-kde.sh" || echo "warning: KDE settings step failed (continuing)."
fi

echo "Done."
