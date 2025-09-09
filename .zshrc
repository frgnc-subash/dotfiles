ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

#autoload -Uz _zinit
#(( ${+_comps} )) && _comps[zinit]=_zinit


autoload -Uz compinit && compinit


zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

zinit snippet OMZP::git
zinit snippet OMZP::sudo 
zinit snippet OMZP::archlinux
zinit snippet OMZP::kubectl
zinit snippet OMZP::aws
zinit snippet OMZP::kubectx 
zinit snippet OMZP::command-not-found

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward 

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory 
setopt sharehistory 
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups 
setopt hist_find_no_dups 

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


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
alias wf-recorder="wf-recorder -a default -f $HOME/Videos/recording-$(date +'%Y%m%d-%H%M%S').mp4"


#autostarts
#fastfetchqq

#exports
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH=$HOME/.config/hypr/scripts:$PATH
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"



eval "$(fzf --zsh)"
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/themes/tokyo_night.omp.json)"
eval "$(zoxide init --cmd cd zsh)"
#eval "$(starship init zsh)"
