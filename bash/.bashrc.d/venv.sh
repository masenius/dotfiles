#!/bin/bash

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
    current_project="${VIRTUAL_ENV%/.venv}"
    if [ -z "$venv_path" ] || [ "$venv_path" != "$current_project/.venv" ]; then
      deactivate 2>/dev/null || true
    fi
  fi

  if [ -z "$VIRTUAL_ENV" ] && [ -n "$venv_path" ]; then
    # shellcheck disable=SC1090
    . "$venv_path/bin/activate"
  fi
}

# Run before each prompt (catches directory changes)
PROMPT_COMMAND="_auto_venv${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
