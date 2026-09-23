# Widescreen KDE Setup

Configuration for the KDE Plasma **widescreen** workstation (ultrawide / multi-monitor,
primary geometry `5120x1440`). This covers two third-party plugins used on that setup:

- **KZones** — window tiling/snapping KWin script
- **Compact Pager** — a compact virtual-desktop pager Plasma widget

The plugins themselves are **not vendored** in this repo — install them from the KDE
Store (steps below). Only the KZones *settings* are tracked and applied automatically;
Compact Pager settings are configured manually (see notes).

---

## KZones (KWin script)

Snaps windows into custom zones on the ultrawide screen.

### Install
1. System Settings → **Window Management** → **KWin Scripts**
2. Click **Get New Scripts…** and search for **KZones** (KDE Store id: `kzones`)
3. Install and tick the checkbox to enable it
   - Upstream: https://github.com/gerritdevriese/kzones

### Tracked settings

The KZones settings are split into two human-friendly files (requires `jq`):

- [`kzones/layouts.json`](kzones/layouts.json) — the zone layouts, as pretty
  JSON. **This is the source of truth** — edit it freely.
- [`kzones/settings.conf`](kzones/settings.conf) — the non-layout scalar
  options (`autoSnapAllNew`, `filterMode`, etc.).

Tracked layouts:
- **Priority Grid** — 30% / 40% / 30% columns
- **Equal Grid** — 33% / 34% / 33% columns

### Two-way workflow

The scripts write into `~/.config/kwinrc` via `kwriteconfig6` (never symlinking
the volatile shared `kwinrc`) and read it back via `kreadconfig6`.

**Repo → KDE** (apply your tracked settings to the live system):

```sh
./kde/apply-kde.sh
```

Reads `layouts.json` + `settings.conf`, writes the `[Script-kzones]` group,
sets `[Plugins] kzonesEnabled=true`, and live-reloads KWin. Also run
automatically by the repo's `setup.sh`.

**KDE → repo** (save changes you made in the KZones GUI back into the repo):

```sh
./kde/save-kde.sh
git commit -am "kde: update kzones layout"
```

Reads the live `[Script-kzones]` values and rewrites `layouts.json` (pretty)
and `settings.conf`.

So the loop is: **edit `layouts.json` → `apply-kde.sh`**, or **tweak in the GUI
→ `save-kde.sh` → commit**.

---

## Compact Pager (Plasma widget)

Widget id: `com.github.tilorenz.compact_pager`

### Install
1. Right-click the panel → **Add Widgets…**
2. Click **Get New Widgets…** → **Download New Plasma Widgets**
3. Search for **Compact Pager**, install it, then drag it onto the panel
   - Upstream: https://github.com/tilorenz/compact_pager

### Settings (NOT auto-tracked)
Compact Pager's settings are **not** tracked by this repo. They live inside
`~/.config/plasma-org.kde.plasma.desktop-appletsrc` under machine-specific applet
IDs tied to the widescreen panel geometry, e.g.:

```
[Containments][1][Applets][34][Configuration]
popupHeight=400
popupWidth=560
```

Because those applet IDs and the `5120x1440` geometry differ per machine, they are
not portable. Configure the widget by hand after installing:

- Right-click the pager widget → **Configure Compact Pager…** (popup size, layout, etc.)

If you want to eyeball your current values, look at the
`[Containments][*][Applets][*][Configuration]` groups whose parent applet has
`plugin=com.github.tilorenz.compact_pager` in
`~/.config/plasma-org.kde.plasma.desktop-appletsrc`.
