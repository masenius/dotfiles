#!/usr/bin/env bash
#
# apply-kde.sh — apply tracked KDE plugin settings for the widescreen setup
#                (repo -> KDE).
#
# Writes the KZones KWin script settings into ~/.config/kwinrc:
#   - scalar keys from kzones/settings.conf
#   - layouts from kzones/layouts.json (minified into the layoutsJson string)
#
# Compact Pager settings are NOT tracked here (see KDE.md) — configure that
# widget manually.
#
# Safe to run repeatedly. Skips gracefully on non-KDE machines.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="$SCRIPT_DIR/kzones/settings.conf"
LAYOUTS="$SCRIPT_DIR/kzones/layouts.json"

# Pick whichever kwriteconfig is available (Plasma 6 = 6, Plasma 5 = 5).
KWRITE=""
for bin in kwriteconfig6 kwriteconfig5; do
    if command -v "$bin" >/dev/null 2>&1; then
        KWRITE="$bin"
        break
    fi
done

if [ -z "$KWRITE" ]; then
    echo "[kde] kwriteconfig not found — skipping KDE settings (not a KDE machine?)."
    exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "[kde] error: jq is required to apply KZones layouts. Install jq and retry." >&2
    exit 1
fi

if [ ! -f "$SETTINGS" ] || [ ! -f "$LAYOUTS" ]; then
    echo "[kde] missing settings.conf or layouts.json — skipping."
    exit 0
fi

echo "[kde] applying KZones settings to ~/.config/kwinrc using $KWRITE"

# Enable the script itself.
"$KWRITE" --file kwinrc --group Plugins --key kzonesEnabled true

# Scalar settings.
while IFS= read -r line; do
    case "$line" in
        ""|\[*|\#*) continue ;;
    esac
    key="${line%%=*}"
    value="${line#*=}"
    "$KWRITE" --file kwinrc --group Script-kzones --key "$key" "$value"
done < "$SETTINGS"

# Layouts: validate, then write minified JSON. kwriteconfig handles escaping.
if ! jq empty "$LAYOUTS" 2>/dev/null; then
    echo "[kde] error: $LAYOUTS is not valid JSON." >&2
    exit 1
fi
layouts_min="$(jq -c . "$LAYOUTS")"
"$KWRITE" --file kwinrc --group Script-kzones --key layoutsJson "$layouts_min"

# Best-effort live reload of KWin so changes apply without logout.
if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
elif command -v qdbus >/dev/null 2>&1; then
    qdbus org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
fi

echo "[kde] done. If KZones was just installed, ensure it is enabled in"
echo "      System Settings -> Window Management -> KWin Scripts."
