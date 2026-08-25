# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH

# Completion system. Run the full security audit + dump rebuild at most once
# per 24h; use the fast `-C` path (skip audit, trust the cached dump) otherwise.
autoload -Uz compinit
_zcompdump="$HOME/.zcompdump"
# Glob with qualifiers: N=nullglob, .=plain file, mh+24=modified >24h ago.
# Non-empty result => dump is stale (or missing) => full audit + rebuild.
_zdump_stale=( $_zcompdump(N.mh+24) )
if [[ ! -s $_zcompdump || -n $_zdump_stale ]]; then
  compinit -d "$_zcompdump"
  touch "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi
unset _zdump_stale
{ [[ ! -s "${_zcompdump}.zwc" || "$_zcompdump" -nt "${_zcompdump}.zwc" ]] && zcompile "$_zcompdump" } &!

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias k=kubectl
alias kctx=kubectx
alias kns=kubens

alias gauth='gcloud auth login && gcloud auth application-default login'
alias kk='EDITOR=nvim k9s'

alias j22="export JAVA_HOME=`/usr/libexec/java_home -v 22`; java -version"
alias j17="export JAVA_HOME=`/usr/libexec/java_home -v 17`; java -version"
alias j11="export JAVA_HOME=`/usr/libexec/java_home -v 11`; java -version"
alias j8="export JAVA_HOME=`/usr/libexec/java_home -v 1.8`; java -version"

export K9S_CONFIG_DIR=$HOME/.config/k9s

eval "$(starship init zsh)"

# Lazy-load SDKMAN: sourcing it eagerly costs ~70ms on every shell start.
# It initialises on first use of sdk/java/mvn/gradle/kotlin/spring/jar/javac.
export SDKMAN_DIR="$HOME/.sdkman"
_sdkman_lazy_init() {
  unset -f sdk java javac jar mvn gradle kotlin spring
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  # Re-invoke the original command now that SDKMAN is loaded
  "$@"
}
for _sdkman_cmd in sdk java javac jar mvn gradle kotlin spring; do
  # shellcheck disable=SC2139
  eval "function ${_sdkman_cmd}() { _sdkman_lazy_init ${_sdkman_cmd} \"\$@\"; }"
done
unset _sdkman_cmd

export PATH=/Users/tempdaman/.tiup/bin:$PATH


# Source zsh.d scripts
local dir="$HOME/.zsh.d"
if [ -d "$dir" ]; then
  for file in "$dir"/*; do
    [ -f "$file" ] && source "$file"
  done
fi

# Use zoxide as `cd` (frequency-ranked jumps). `cdi` is the interactive picker.
eval "$(zoxide init --cmd cd zsh)"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Override zoxide's default completion with an fzf menu (must run after
# `zoxide init`, which registers its own completion).
[ -f "$HOME/.zsh.d/zoxide-fzf.sh" ] && source "$HOME/.zsh.d/zoxide-fzf.sh"
