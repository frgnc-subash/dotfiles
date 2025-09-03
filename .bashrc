

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
#alias
alias ls='ls --color'
alias cat='bat --paging=never --style=plain'
alias ls='eza --icons'

# Common variations
alias ll='eza -l --icons'            # Long format
alias la='eza -la --icons'           # Long + hidden files
alias lah='eza -lah --icons'         # Long + all + human-readable sizes
alias lt='eza --tree --icons'        # Tree view
alias lg='eza -l --git --icons'      # Git-aware long view
alias l.='eza -la --icons | grep "^\."'  # Only dotfiles
alias ..='cd ..'

# Extra helpers
alias lsx='eza -l --icons'           # Long with icons
alias lT='eza --tree -L 2 --icons'   # Tree with depth 2
alias ld='eza -lD --icons'           # Only directories
alias bare='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias cmatrix='cmatrix -ba -u 2 -C blue'

# Tokyo Night Bright colors
RESET="\[\e[0m\]"
BLUE="\[\e[38;5;75m\]"
PURPLE="\[\e[38;5;141m\]"
CYAN="\[\e[38;5;80m\]"
GREEN="\[\e[38;5;120m\]"
YELLOW="\[\e[38;5;226m\]"
RED="\[\e[38;5;203m\]"

# Function to show git branch and status
git_info() {
    local branch
    local status
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        status=""
        # staged changes
        if ! git diff --cached --quiet 2>/dev/null; then
            status+="+"
        fi
        # unstaged changes
        if ! git diff --quiet 2>/dev/null; then
            status+="*"
        fi
        # untracked files
        if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
            status+="!"
        fi
        echo "(${branch}${status})"
    fi
}

# Set PS1
PS1="${BLUE} \u${RESET}|${PURPLE}\h${RESET}|${CYAN}\W${RESET} ${YELLOW}\$(git_info)${RESET}|
${GREEN}❯ ${RESET}"


#eval "$(starship init bash)"
