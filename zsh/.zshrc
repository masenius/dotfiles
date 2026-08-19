# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Use a stable compdump path (avoids per-hostname churn, makes caching reliable)
export ZSH_COMPDUMP="$HOME/.zcompdump"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# Empty: starship handles the prompt, no need for OMZ to load a theme
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Disable magic functions (bracket paste slowness, not needed with starship)
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)
ZSH_DISABLE_COMPFIX=true

# Let oh-my-zsh run compinit itself (after it has populated fpath with its
# completion directories) so the cached dump is complete. Running compinit
# manually beforehand captured an incomplete fpath and wrote a tiny, broken
# dump that disabled most completions.
source $ZSH/oh-my-zsh.sh

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
