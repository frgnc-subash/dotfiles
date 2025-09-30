#alias
alias ls='ls --color'
alias cat='bat --paging=never --style=plain'
alias ls='eza --icons'

# Common variations
alias ll='eza -l --icons'            # Long format
alias la='eza -la --icons'           # Long + hidden files
alias lah='eza -lah --icons'         # Long + all + human-readable sizes
alias lt='eza --tree --icons'        # Tree view
alias lg='eza -l --git --icons'      # Git-aware lozzng view
alias l.='eza -la --icons | grep "^\."'  # Only dotfiles
alias ..='cd ..'

# Extra helpers
alias lsx='eza -l --icons'           # Long with icons
alias lT='eza --tree -L 2 --icons'   # Tree with depth 2
alias ld='eza -lD --icons'           # Only directories
alias bare='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME --no-pager'
alias cmatrix='cmatrix -ba -u 2 -C blue'
alias wf-recorder="wf-recorder -a default -f $HOME/Videos/recording-$(date +'%Y%m%d-%H%M%S').mp4"