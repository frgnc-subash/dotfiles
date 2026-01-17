#  ┌┐ ┌─┐┌─┐┬ ┬┬─┐┌─┐
#  ├┴┐├─┤└─┐├─┤├┬┘│
# o└─┘┴ ┴└─┘┴ ┴┴└─└─┘

PS1="\[\e[1;36m\]\u\[\e[0m\]\[\e[1;35m\]@\[\e[0m\]\[\e[1;33m\]\h\[\e[0m\] \[\e[1;32m\]\$\[\e[0m\] "

[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

#aliases
alias ls='ls --color'
alias cat='bat --paging=never --style=plain'
alias ls='eza --icons'
alias hl='rg --passthrough'

# Common variations
alias ll='eza -l --icons'               # Long format
alias la='eza -la --icons'              # Long + hidden files
alias lah='eza -lah --icons'            # Long + all + human-readable sizes
alias lt='eza --tree --icons'           # Tree view
alias lg='eza -l --git --icons'         # Git-aware long view
alias l.='eza -la --icons | grep "^\."' # Only dotfiles
alias ..='cd ..'

# Extra helpers
alias lsx='eza -l --icons'         # Long with icons
alias lT='eza --tree -L 2 --icons' # Tree with depth 2
alias ld='eza -lD --icons'         # Only directories
alias bare='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias cmatrix='cmatrix -ba -u 2 -C blue'

#exports
# eval "$(starship init bash)"
# export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
