# Neovim
export EDITOR=nvim
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# Kubernetes
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export KUBE_CONFIG_PATH=$HOME/.kube/config

# Java
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Rust
export PATH="$HOME/.cargo/bin:$PATH"
. "$HOME/.cargo/env"

# TIDB
export PATH="$HOME/.tiup/bin:$PATH"

eval "$(starship init bash)"
