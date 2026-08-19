# fzf-powered `cd` (zoxide) navigation, bound to Tab.
# After `cd <partial>`, press Tab to open an fzf menu containing BOTH the
# subdirectories of the current directory AND zoxide's ranked matches.
# Pressing Enter in the menu changes into the selected directory immediately.

_z_fzf_widget() {
  emulate -L zsh
  setopt local_options no_aliases

  local -a parts
  parts=(${(z)LBUFFER})

  # Strip the leading command word (cd) to get the query keywords.
  local -a keywords
  if [[ ${#parts} -gt 1 ]]; then
    keywords=(${parts[2,-1]})
  fi
  local query="${keywords[*]}"

  # Local subdirectories of $PWD (relative names).
  local -a local_dirs
  local_dirs=(${(f)"$(print -l -- *(-/N) .*(-/N) 2>/dev/null | command grep -vx '\.\|\.\.')"})

  # zoxide database matches (absolute paths).
  local -a zoxide_dirs
  zoxide_dirs=(${(f)"$(zoxide query --list -- "${keywords[@]}" 2>/dev/null)"})

  local -a candidates
  candidates=("${local_dirs[@]}" "${zoxide_dirs[@]}")
  candidates=(${(u)candidates})

  if (( ! ${#candidates} )); then
    zle redisplay
    return 0
  fi

  local selected
  selected="$(
    print -l -- "${candidates[@]}" \
      | fzf --height 40% --reverse \
            --query "$query" --select-1 --exit-0
  )"

  if [[ -n "$selected" ]]; then
    builtin cd -- "$selected" 2>/dev/null
    # Reset the command line and run zoxide's chpwd hook via reset-prompt.
    LBUFFER=''
    RBUFFER=''
  fi

  zle reset-prompt
}

if [[ -o zle ]]; then
  zle -N _z_fzf_widget

  # Bind Tab to the widget ONLY when the current line starts with `cd `.
  # Otherwise fall back to normal completion.
  _z_fzf_tab() {
    if [[ "$LBUFFER" == "cd "* ]]; then
      _z_fzf_widget
    else
      zle expand-or-complete
    fi
  }
  zle -N _z_fzf_tab
  bindkey '^I' _z_fzf_tab
fi
