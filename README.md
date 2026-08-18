# dotfiles

Personal dotfiles managed with [Dotter](https://github.com/SuperCuber/dotter),
a symlink-based dotfile manager. Config lives in this repo and is symlinked into
`$HOME` on deploy.

## Managed packages

| Package    | Deploys to              |
| ---------- | ----------------------- |
| `bash`     | `~/.bashrc`, `~/.bashrc.d/` |
| `nvim`     | `~/.config/nvim/`       |
| `kitty`    | `~/.config/kitty/`      |
| `k9s`      | `~/.config/k9s/`        |
| `starship` | `~/.config/starship.toml` |
| `mcphub`   | `~/.config/mcphub/`     |

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
- **mcphub** — MCP server config

## Setup on a new machine

```bash
# 1. Clone
git clone https://github.com/masenius/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Select which packages to deploy on THIS machine.
#    local.toml is gitignored (per-machine). Adjust the list as needed.
printf 'packages = ["bash", "nvim", "kitty", "k9s", "starship", "mcphub"]\n' \
  > .dotter/local.toml

# 3. Preview what will happen (recommended)
dotter deploy --dry-run -v

# 4. Deploy (creates the symlinks)
dotter deploy -v
```

If a target file already exists in `$HOME`, Dotter skips it rather than
overwriting. Back up and remove the conflicting file first, then re-run
`dotter deploy`. To overwrite unconditionally, use `dotter deploy --force`
(destructive — be sure you have backups).

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
- **`.dotter/local.toml`** — controls which packages deploy per machine
  (gitignored).

## Repository layout

```
dotfiles/
├── .dotter/
│   ├── global.toml    # package definitions + target mappings (tracked)
│   └── local.toml     # per-machine package selection (gitignored)
├── bash/     .bashrc, .bashrc.d/
├── nvim/     .config/nvim/
├── kitty/    .config/kitty/
├── k9s/      .config/k9s/
├── starship/ .config/starship.toml
└── mcphub/   .config/mcphub/
```

## Adding a new config

1. Place the file under a package folder, mirroring its `$HOME` path
   (e.g. `foo/.config/foo/config.toml`).
2. Add a mapping in `.dotter/global.toml`:
   ```toml
   [foo.files]
   "foo/.config/foo" = "~/.config/foo"
   ```
3. Enable it in `.dotter/local.toml`'s `packages` list.
4. `dotter deploy -v`.
