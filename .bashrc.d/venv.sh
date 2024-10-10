#!/bin/bash

function cd() {
  builtin cd "$@"

  if [[ -z "$VIRTUAL_ENV" ]]; then
    ## If env folder is found then activate the vitualenv
    if [[ -d ./.venv ]]; then
      source ./.venv/bin/activate
    fi
  else
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
    parentdir="$(dirname "$VIRTUAL_ENV")"
    if [[ "$PWD"/ != "$parentdir"/* ]]; then
      deactivate
    fi
  fi
}

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
