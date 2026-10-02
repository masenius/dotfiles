# dotfiles

Personal dotfiles managed with [Dotter](https://github.com/SuperCuber/dotter),
a symlink-based dotfile manager. Config lives in this repo and is symlinked into
`$HOME` on deploy.

## Managed packages

| Package    | Deploys to              |
| ---------- | ----------------------- |
| `bash`     | `~/.bashrc`, `~/.bashrc.d/` (Linux) |
| `zsh`      | `~/.zshrc`, `~/.zsh.d/` (macOS) |
| `nvim`     | `~/.config/nvim/`       |
| `kitty`    | `~/.config/kitty/`      |
| `sofka`    | `~/.config/sofka/`      |
| `starship` | `~/.config/starship.toml` |
| `zellij`   | `~/.config/zellij/`     |
| `ssh`      | `~/.ssh/config`          |
| `opencode` | `~/.config/opencode/opencode.jsonc` |
| `aerospace` | `~/.config/aerospace/aerospace.toml` (macOS) |

Not a dotter package, but applied by `setup.sh`:

- **KDE (widescreen)** — KZones/Compact Pager plugin setup. See
  [`kde/KDE.md`](kde/KDE.md). Settings are merged into `~/.config/kwinrc`
  (no symlinks) by `kde/apply-kde.sh`; save GUI changes back with
  `kde/save-kde.sh`. Requires `jq`. Applied in `desktop` mode, or elsewhere with `-i kde`.

## Prerequisites

The easiest way to install everything is the installer, which supports
Debian/Ubuntu, Fedora/RHEL/CentOS, and macOS:

```bash
./install-prereqs.sh            # install missing tools and update existing ones
./install-prereqs.sh --dry-run  # preview the commands without running them
./install-prereqs.sh --no-update
```

It installs **dotter**, **git**, **jq**, **neovim**, **starship**, **zoxide**,
**fzf**, **lazygit**, **kitty**, **sofka**, **zellij**, and the **JetBrainsMono
Nerd Font** via cargo-binstall (for the Rust tools), the official upstream
binaries (fzf, lazygit, kitty, neovim, the Nerd Font), or the system package manager. On macOS it
prefers Homebrew. Re-running is safe and upgrades tools to the latest release.

To install manually instead:

- **[dotter](https://github.com/SuperCuber/dotter)** — the dotfile manager
  - `cargo install dotter`, or `brew install dotter`, or (Arch) `paru -S dotter-rs-bin`
- **git**
- **[JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads)** —
  required by `kitty.conf` (`font_family family="JetBrainsMono Nerd Font"`)

Tools referenced by the shell/config (install the ones you use):

- **[neovim](https://neovim.io/)** — `$EDITOR`, `v` alias (LazyVim config)
- **[starship](https://starship.rs/)** — prompt (`starship init` in `.bashrc.d/main.sh`)
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — smarter `cd`
- **[fzf](https://github.com/junegunn/fzf)** — fuzzy finder
- **[lazygit](https://github.com/jesseduffield/lazygit)** — git TUI
- **[kitty](https://sw.kovidgoyal.net/kitty/)** — terminal
- **[sofka](https://crates.io/crates/sofka)** — Kubernetes TUI (`cargo install sofka`)
- **[zellij](https://zellij.dev/)** — terminal multiplexer
- **[jq](https://jqlang.github.io/jq/)** — JSON processor (used by the KDE/KZones apply & save scripts)

## Setup on a new machine

```bash
# 1. Clone
git clone https://github.com/masenius/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Install prerequisites (dotter, git, CLI tools, Nerd Font).
./install-prereqs.sh

# 3. Run the setup script. It writes .dotter/local.toml (gitignored,
#    per-machine), previews the changes, then deploys the symlinks.
#    A mode is required; it picks which packages to skip:
#      mac      excludes bash, kde
#      laptop   excludes zsh, kde, aerospace
#      desktop  excludes zsh, aerospace
#      server   excludes zsh, kde, aerospace, kitty
./setup.sh mac

# Exclude more packages with -e/--exclude (repeatable):
./setup.sh laptop -e zellij -e sofka

# Re-include a package the mode excludes with -i/--include (repeatable):
./setup.sh server -i kitty

# Use -f/--force to overwrite existing files in $HOME (destructive; also
# passes --noconfirm so it never blocks on prompts):
./setup.sh mac --force
```

Dotter's package selection is include-only (`local.toml`'s `packages` list),
so `setup.sh` emulates excludes: it derives the full package set from
`.dotter/global.toml` and writes everything except the mode's and `-e`
packages (plus any `-i` packages).

If a target file already exists in `$HOME`, Dotter skips it rather than
overwriting. Back up and remove the conflicting file first, then re-run
`dotter deploy`. To overwrite unconditionally, use `./setup.sh --force`
(or `dotter deploy --force`) — destructive, be sure you have backups.

## Everyday usage

```bash
dotter deploy          # apply changes / add newly-tracked files
dotter deploy -v       # verbose, shows a diff of what changed
dotter deploy --dry-run # preview without touching anything
dotter undeploy        # remove all deployed symlinks
dotter watch           # auto-deploy on file changes
```

Because files are symlinked, editing a config in `$HOME` edits the repo file
directly — just `git commit` the change.

## Machine-local overrides

- **`~/.bashrc.d/local`** — `.bashrc` sources every file in `~/.bashrc.d/`.
  Drop machine-specific shell settings in `bash/.bashrc.d/local`; it is
  gitignored, so it stays out of version control while still being symlinked.
- **`~/.zsh.d/local`** — `.zshrc` sources every file in `~/.zsh.d/`. Same
  pattern as bash: put machine-specific zsh settings in `zsh/.zsh.d/local`
  (gitignored, still symlinked).
- **`.dotter/local.toml`** — controls which packages deploy per machine
  (gitignored).

## Repository layout

```
dotfiles/
├── .dotter/
│   ├── global.toml    # package definitions + target mappings (tracked)
│   └── local.toml     # per-machine package selection (gitignored)
├── bash/     .bashrc, .bashrc.d/
├── zsh/      .zshrc, .zsh.d/
├── nvim/     .config/nvim/
├── kitty/    .config/kitty/
├── starship/ .config/starship.toml
├── zellij/   .config/zellij/
├── ssh/      config
├── opencode/ .config/opencode/opencode.jsonc
├── aerospace/ .config/aerospace/aerospace.toml
├── kde/      KDE.md + kzones/ + apply-kde.sh + save-kde.sh (applied by setup.sh, not symlinked)
├── setup.sh  # deploy helper for new machines
└── install-prereqs.sh  # installs prerequisites (Debian/Fedora/macOS)
```

## Adding a new config

1. Place the file under a package folder, mirroring its `$HOME` path
   (e.g. `foo/.config/foo/config.toml`).
2. Add a mapping in `.dotter/global.toml`:
   ```toml
   [foo.files]
   "foo/.config/foo" = "~/.config/foo"
   ```
3. Run `./setup.sh <mode>` (it auto-discovers the new package from `global.toml`
   and deploys it in every mode unless excluded in `setup.sh`), or add it manually to `.dotter/local.toml`'s `packages`
   list and run `dotter deploy -v`.
