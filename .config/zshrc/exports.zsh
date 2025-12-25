export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export PATH=$HOME/.config/hypr/scripts:$PATH
export PATH=$PATH:/home/axosis/.spicetify
# pnpm
export PNPM_HOME="/home/axosis/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


export PATH=$PATH:/home/axosis/.spicetify

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bun completions
[ -s "/home/axosis/.bun/_bun" ] && source "/home/axosis/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"