# Zshrc

# not running interactively then bail
[[ $- != *i* ]] && return

export ZDOTDIR="$HOME"

# shell opts
setopt autocd
setopt completealiases
setopt histignorealldups
setopt histfindnodups
setopt incappendhistory
setopt sharehistory

# colors in less
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# reload zshrc
function zsrc() {
    local cache=""
    if [[ -n $ZSH_CACHE_DIR ]]; then
        cache=$ZSH_CACHE_DIR
    else
        cache="$HOME/.cache"
    fi

    autoload -U compinit zrecompile
    compinit -d "$cache/zcomp-$HOST"

    for f in $ZDOTDIR/.zshrc "$cache/zcomp-$HOST"; do
        zrecompile -p $f && command rm -f $f.zwc.old
    done

    source $ZDOTDIR/.zshrc
}

# if .zwc compiled shell is missing recompile and source
[[ ! -e $ZDOTDIR/.zshrc.zwc ]] && zsrc &>/dev/null

# aliases
alias l='ls'
alias la='ls -A'
alias ll='ls -lA'
alias ls='ls --color=auto'
alias upd='sudo pacman -Syyu'
alias pac='sudo pacman --color auto'
alias merge='xrdb -merge ~/.Xresources'
alias grubup='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias mirrors='sudo reflector --score 100 --fastest 25 \
    --sort rate --save /etc/pacman.d/mirrorlist --verbose'

al-info
