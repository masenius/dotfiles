# Auto-activate a project's .venv when entering its directory tree,
# and deactivate when leaving. zsh port of the bash PROMPT_COMMAND version.

_auto_venv() {
  local venv_path=""
  local dir="$PWD"

  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.venv/bin/activate" ]; then
      venv_path="$dir/.venv"
      break
    fi
    dir="$(dirname "$dir")"
  done

  if [ -n "$VIRTUAL_ENV" ]; then
    local current_project="${VIRTUAL_ENV%/.venv}"
    if [ -z "$venv_path" ] || [ "$venv_path" != "$current_project/.venv" ]; then
      deactivate 2>/dev/null || true
    fi
  fi

  if [ -z "$VIRTUAL_ENV" ] && [ -n "$venv_path" ]; then
    source "$venv_path/bin/activate"
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _auto_venv
_auto_venv
