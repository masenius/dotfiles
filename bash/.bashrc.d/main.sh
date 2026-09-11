# Neovim
export EDITOR=nvim
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# Kubernetes
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export KUBE_CONFIG_PATH=$HOME/.kube/config

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Rust
export PATH="$HOME/.cargo/bin:$PATH"
. "$HOME/.cargo/env"

# TIDB
export PATH="$HOME/.tiup/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

eval "$(fzf --bash)"
# Use zoxide as `cd` (frequency-ranked jumps). `cdi` is the interactive picker.
eval "$(zoxide init --cmd cd bash)"
eval "$(starship init bash)"
