#!/usr/bin/env bash
#
# save-kde.sh — save live KDE plugin settings back into the repo (KDE -> repo).
#
# Reads the current KZones settings from ~/.config/kwinrc and writes them into:
#   - kzones/settings.conf  (scalar keys)
#   - kzones/layouts.json   (pretty-printed layouts)
#
# Use this after tweaking layouts in the KZones GUI, then `git commit`.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="$SCRIPT_DIR/kzones/settings.conf"
LAYOUTS="$SCRIPT_DIR/kzones/layouts.json"

# Pick whichever kreadconfig is available (Plasma 6 = 6, Plasma 5 = 5).
KREAD=""
for bin in kreadconfig6 kreadconfig5; do
    if command -v "$bin" >/dev/null 2>&1; then
        KREAD="$bin"
        break
    fi
done

if [ -z "$KREAD" ]; then
    echo "[kde] error: kreadconfig not found (not a KDE machine?)." >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "[kde] error: jq is required to save KZones layouts. Install jq and retry." >&2
    exit 1
fi

echo "[kde] reading KZones settings from ~/.config/kwinrc using $KREAD"

# Scalar keys we track. Keep this list in sync with settings.conf.
scalar_keys=(
    autoSnapAllNew
    filterList
    filterMode
    trackLayoutPerScreen
    zoneOverlayHighlightTarget
    zoneSelectorTriggerDistance
)

{
    echo "# KZones [Script-kzones] scalar settings (non-layout)."
    echo "# Layouts live in layouts.json. Applied by ../apply-kde.sh."
    for key in "${scalar_keys[@]}"; do
        value="$("$KREAD" --file kwinrc --group Script-kzones --key "$key" || true)"
        echo "$key=$value"
    done
} > "$SETTINGS"
echo "[kde] wrote $SETTINGS"

# Layouts -> pretty JSON.
layouts_raw="$("$KREAD" --file kwinrc --group Script-kzones --key layoutsJson || true)"
if [ -z "$layouts_raw" ]; then
    echo "[kde] warning: no layoutsJson found in kwinrc; leaving layouts.json unchanged."
elif ! printf '%s' "$layouts_raw" | jq empty 2>/dev/null; then
    echo "[kde] warning: layoutsJson from kwinrc is not valid JSON; leaving layouts.json unchanged." >&2
else
    printf '%s' "$layouts_raw" | jq . > "$LAYOUTS"
    echo "[kde] wrote $LAYOUTS"
fi

echo "[kde] done. Review changes and 'git commit' when happy."
