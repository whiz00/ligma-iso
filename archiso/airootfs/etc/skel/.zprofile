# ~/.zprofile

XDG_CONFIG_HOME="$HOME/.config"
export XDG_CONFIG_HOME


[[ -f ~/.zshrc ]] && . ~/.zshrc

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
