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

eval "$(fzf --zsh)"
#eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/themes/tokyo_night.omp.json)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

export PATH=$PATH:/home/axosis/.spicetify

# pnpm
export PNPM_HOME="/home/axosis/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# opencode
export PATH=/home/axosis/.opencode/bin:$PATH
