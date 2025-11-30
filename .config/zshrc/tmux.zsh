new_tmux() {
  session_dir=$(zoxide query --list | fzf --preview 'ls -la {}') || return
  session_name=$(basename "$session_dir")

  if tmux has-session -t "$session_name" 2>/dev/null; then
    if [ -n "$TMUX" ]; then
      tmux switch-client -t "$session_name"
    else
      tmux attach-session -t "$session_name"
    fi
  else
    if [ -n "$TMUX" ]; then
      tmux new-session -d -c "$session_dir" -s "$session_name"
      tmux switch-client -t "$session_name"
    else
      tmux new-session -c "$session_dir" -s "$session_name"
    fi
  fi
}

alias tm=new_tmux
alias tl='tmux list-sessions'
