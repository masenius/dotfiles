# Environment / tool setup shared in spirit with the bash config.

export EDITOR=nvim

# Kubernetes
export KUBE_CONFIG_PATH="$HOME/.kube/config"

# Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Node (nvm) — only if installed
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# fzf key bindings + completion
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
