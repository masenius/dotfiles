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
| `k9s`      | `~/.config/k9s/`        |
| `starship` | `~/.config/starship.toml` |
| `zellij`   | `~/.config/zellij/`     |
| `ssh`      | `~/.ssh/config`          |

## Prerequisites

Install these before deploying:

- **[dotter](https://github.com/SuperCuber/dotter)** — the dotfile manager
  - `cargo install dotter`, or `brew install dotter`, or (Arch) `paru -S dotter-rs-bin`
- **git**

Tools referenced by the shell/config (install the ones you use):

- **[neovim](https://neovim.io/)** — `$EDITOR`, `v` alias (LazyVim config)
- **[starship](https://starship.rs/)** — prompt (`starship init` in `.bashrc.d/main.sh`)
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — smarter `cd`
- **[fzf](https://github.com/junegunn/fzf)** — fuzzy finder
- **[kitty](https://sw.kovidgoyal.net/kitty/)** — terminal
- **[k9s](https://k9scli.io/)** — Kubernetes TUI
- **[zellij](https://zellij.dev/)** — terminal multiplexer

## Setup on a new machine

```bash
# 1. Clone
git clone https://github.com/masenius/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Run the setup script. It writes .dotter/local.toml (gitignored,
#    per-machine), previews the changes, then deploys the symlinks.
#    By default ALL packages are deployed.
./setup.sh

# Exclude specific packages with -e/--exclude (repeatable). e.g. on macOS
# you'd typically skip the Linux-oriented bash package:
./setup.sh -e bash

# Exclude multiple:
./setup.sh -e bash -e zellij

# Use -f/--force to overwrite existing files in $HOME (destructive; also
# passes --noconfirm so it never blocks on prompts):
./setup.sh --force
./setup.sh -f -e bash
```

Dotter's package selection is include-only (`local.toml`'s `packages` list),
so `setup.sh` emulates excludes: it derives the full package set from
`.dotter/global.toml` and writes everything except the `-e` packages.

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
├── k9s/      .config/k9s/
├── starship/ .config/starship.toml
├── zellij/   .config/zellij/
├── ssh/      config
└── setup.sh  # deploy helper for new machines
```

## Adding a new config

1. Place the file under a package folder, mirroring its `$HOME` path
   (e.g. `foo/.config/foo/config.toml`).
2. Add a mapping in `.dotter/global.toml`:
   ```toml
   [foo.files]
   "foo/.config/foo" = "~/.config/foo"
   ```
3. Run `./setup.sh` (it auto-discovers the new package from `global.toml`
   and deploys it), or add it manually to `.dotter/local.toml`'s `packages`
   list and run `dotter deploy -v`.
