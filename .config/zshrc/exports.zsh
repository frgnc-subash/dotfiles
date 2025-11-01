export STARSHIP_CONFIG="$HOME/.config/starship/themes/misc.toml"
export PATH=$HOME/.config/hypr/scripts:$PATH
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
