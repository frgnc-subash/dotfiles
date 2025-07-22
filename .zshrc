#----------------------------------------------
#                    .__
#     ________  _____|  |_________   ____
#     \___   / /  ___/  |  \_  __ \_/ ___\
#      /    /  \___ \|   Y  \  | \/\  \___
#  /\ /_____ \/____  >___|  /__|    \___  >
#  \/       \/     \/     \/            \/
#
#----------------------------------------------


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
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

autoload -Uz colors && colors

alias ola="/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME"
alias zshconfig="nano ~/.zshrc"
alias ohmyzsh="nano ~/.oh-my-zsh"
alias cat='bat'

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

clear
pokemon-colorscripts -r  --no-title


#nvidia things
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __VK_LAYER_NV_optimus=NVIDIA_only
export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
export __VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json

