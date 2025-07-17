
# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set your preferred Oh My Zsh theme
ZSH_THEME="bira"

# Plugins you want to load — keep them minimal for faster startup
plugins=(git z sudo zsh-autosuggestions zsh-syntax-highlighting)

# Source Oh My Zsh core
source $ZSH/oh-my-zsh.sh

# User configuration

# Show random Pokémon on startup (optional, comment out if slow)
#pokemon-colorscripts -r

# === NVM Lazy Loading Setup ===
export NVM_DIR="$HOME/.nvm"

load_nvm() {
  unset -f node npm npx  # remove wrappers to avoid recursion
  # Load NVM scripts
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

# Define wrappers that trigger NVM loading only when node/npm/npx commands run
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

# Load zsh colors for syntax highlighting & prompt colors
autoload -Uz colors && colors



###############
### ALIASES ###
###############
alias gar="/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME"
alias zshconfig="nano ~/.zshrc"
alias ohmyzsh="nano ~/.oh-my-zsh"



# Clear screen and show colorful Pokémon (no parsing, full colors)
clear
pokemon-colorscripts -r

