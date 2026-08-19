#!/usr/bin/env bash
#
# Setup dotfiles on a new machine.
#
# Usage:
#   ./setup.sh [-f|--force] [package ...]
#
# With no arguments, deploys the default package set. Pass a custom list of
# package names to override it, e.g.:
#   ./setup.sh bash nvim starship
#
# Use -f/--force to pass --force to dotter, overwriting existing files in
# $HOME (destructive — be sure you have backups).
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

# Default packages to deploy on this machine.
DEFAULT_PACKAGES=(bash nvim kitty k9s starship mcphub zellij)

force=""
packages=()
for arg in "$@"; do
  case "$arg" in
    -f|--force) force="--force" ;;
    *) packages+=("$arg") ;;
  esac
done

if [ "${#packages[@]}" -eq 0 ]; then
  packages=("${DEFAULT_PACKAGES[@]}")
fi

# Ensure dotter is available.
if ! command -v dotter >/dev/null 2>&1; then
  echo "error: dotter is not installed. See README.md prerequisites." >&2
  exit 1
fi

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

# Preview what will happen.
echo "== Dry run =="
dotter deploy --dry-run -v

# Deploy (creates the symlinks).
echo "== Deploy =="
dotter deploy -v $force

echo "Done."
