# Neovim
export EDITOR=nvim
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# Kubernetes
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export KUBE_CONFIG_PATH=$HOME/.kube/config

# Java — lazy-load SDKMAN: sourcing it eagerly costs ~70ms on every shell
# start. It initialises on first use of sdk/java/mvn/gradle/kotlin/spring/jar/javac.
export SDKMAN_DIR="$HOME/.sdkman"
_sdkman_lazy_init() {
  unset -f sdk java javac jar mvn gradle kotlin spring
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  # Re-invoke the original command now that SDKMAN is loaded
  "$@"
}
for _sdkman_cmd in sdk java javac jar mvn gradle kotlin spring; do
  # shellcheck disable=SC2139
  eval "${_sdkman_cmd}() { _sdkman_lazy_init ${_sdkman_cmd} \"\$@\"; }"
done
unset _sdkman_cmd

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
