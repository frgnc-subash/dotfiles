alias search='yay -Ss'
alias update='sudo pacman -Syyu'
alias ping='ping -c 5'

alias ls='ls --color'
alias cat='bat --paging=never'
alias ls='eza --icons'

alias ll='eza -l --icons'                # Long format
alias la='eza -lah --color=always --group-directories-first'
alias lah='eza -lah --icons --group-directories-first'             # Long + all + human-readable sizes
alias l.='eza -la --icons | grep "^\."'  # Only dotfiles
alias ..='cd ..'
alias rm='rm -i'

alias lt='eza --tree -L 2 --icons'   # Tree with depth 2
alias ld='eza -lD --icons'           # Only directories

alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME --no-pager'
# alias cmatrix='cmatrix -ba -u 2 -C blue'
alias wf-recorder="wf-recorder -a default -f $HOME/Videos/recording-$(date +'%Y%m%d-%H%M%S').mp4"
