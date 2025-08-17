#----------------------------------------------
#                    .__
#     ________  _____|  |_________   ____
#     \___   / /  ___/  |  \_  __ \_/ ___\
#      /    /  \___ \|   Y  \  | \/\  \___
#  /\ /_____ \/____  >___|  /__|    \___  >
#  \/       \/     \/     \/            \/
#
#----------------------------------------------


#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi


export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git z sudo zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
export NVM_DIR="$HOME/.nvm"

load_nvm() {
  unset -f node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

node() {
  load_nvm
  node "$@"
}
npm() {
  load_nvm
  npm "$@"
}
npx() {
  load_nvm
  npx "$@"
}

###############
### ALIASES ###
###############

autoload -Uz colors && colors
# Git + config shortcuts
alias lala="/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME"
alias zshconfig="nano ~/.zshrc"
alias ohmyzsh="nano ~/.oh-my-zsh"

# Better cat
alias cat='bat --paging=never --style=plain'

# =========================
# eza (modern ls) aliases
# =========================

# Replace default ls with icons
alias ls='eza --icons'

# Common variations
alias ll='eza -l --icons'            # Long format
alias la='eza -la --icons'           # Long + hidden files
alias lah='eza -lah --icons'         # Long + all + human-readable sizes
alias lt='eza --tree --icons'        # Tree view
alias lg='eza -l --git --icons'      # Git-aware long view
alias l.='eza -la --icons | grep "^\."'  # Only dotfiles

# Extra helpers
alias lsx='eza -l --icons'           # Long with icons
alias lT='eza --tree -L 2 --icons'   # Tree with depth 2
alias ld='eza -lD --icons'           # Only directories

 
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

clear
#pokemon-colorscripts -r  --no-title
pokeget random --hide-name > ~/.cache/pokemon.txt
fastfetch

#nvidia things
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __VK_LAYER_NV_optimus=NVIDIA_only
export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
export __VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json


eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"
