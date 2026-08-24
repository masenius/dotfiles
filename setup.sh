#!/usr/bin/env bash
#
# Setup dotfiles on a new machine.
#
# Usage:
#   ./setup.sh [-f|--force] [-e|--exclude PKG]...
#
# By default, deploys ALL packages defined in .dotter/global.toml.
# Use -e/--exclude to skip specific packages (repeatable), e.g.:
#   ./setup.sh -e bash            # everything except bash
#   ./setup.sh -e bash            # exclude multiple
#
# Use -f/--force to pass --force (and --noconfirm) to dotter, overwriting
# existing files in $HOME (destructive — be sure you have backups).
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

force=""
excludes=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    -f|--force) force="1" ;;
    -e|--exclude)
      shift
      [ "$#" -gt 0 ] || { echo "error: -e/--exclude requires a package name" >&2; exit 1; }
      excludes+=("$1")
      ;;
    *) echo "error: unknown argument: $1" >&2; exit 1 ;;
  esac
  shift
done

# Ensure dotter is available.
if ! command -v dotter >/dev/null 2>&1; then
  echo "error: dotter is not installed. See README.md prerequisites." >&2
  exit 1
fi

# Derive the full package set from global.toml's [<name>.files] headers.
all_packages=()
while IFS= read -r pkg; do
  all_packages+=("$pkg")
done < <(grep -oE '^\[[a-zA-Z0-9_-]+\.files\]' .dotter/global.toml | sed -E 's/^\[(.*)\.files\]$/\1/')

if [ "${#all_packages[@]}" -eq 0 ]; then
  echo "error: no packages found in .dotter/global.toml" >&2
  exit 1
fi

# Build the deploy list = all packages minus excludes.
packages=()
for pkg in "${all_packages[@]}"; do
  skip=""
  for ex in "${excludes[@]:-}"; do
    [ "$pkg" = "$ex" ] && { skip="1"; break; }
  done
  [ -n "$skip" ] || packages+=("$pkg")
done

if [ "${#packages[@]}" -eq 0 ]; then
  echo "error: all packages excluded, nothing to deploy" >&2
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

# Deploy (creates the symlinks).
echo "== Deploy =="
deploy_args=(deploy -v)
if [ -n "$force" ]; then
  deploy_args+=(--force -y)
fi
dotter "${deploy_args[@]}"

# SSH requires strict permissions on config files. Git doesn't track file
# modes beyond the executable bit, so enforce 600 after checkout/symlink.
chmod 600 "$HOME/.ssh/config"

echo "Done."
