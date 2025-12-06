#  ┌─┐┌─┐┬ ┬┬─┐┌─┐
#  ┌─┘└─┐├─┤├┬┘│  
# o└─┘└─┘┴ ┴┴└─└─┘


ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

autoload -Uz compinit && compinit

#sources
source ~/.config/zshrc/exports.zsh
source ~/.config/zshrc/aliases.zsh
source ~/.config/zshrc/settings.zsh
source ~/.config/zshrc/tmux.zsh
source ~/.config/zshrc/extra.zsh

eval "$(fzf --zsh)"
# eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/themes/tokyo_night.omp.json)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

export EDITOR=nvim
export VISUAL=nvim

. "$HOME/.local/bin/env"


export PATH=$PATH:/home/axosis/.spicetify

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
