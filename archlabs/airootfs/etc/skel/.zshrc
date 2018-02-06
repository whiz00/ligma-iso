# Zshrc

# If not running interactively return
[[ $- != *i* ]] && return

export EDITOR=nano
export PATH=$HOME/bin:$PATH

setopt AUTO_CD BANG_HIST EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY SHARE_HISTORY

# Alias
alias l='ls'
alias la='ls -A'
alias ll='ls -lA'
alias ls='ls --color=auto'
alias update='sudo pacman -Syu'
alias pacman='sudo pacman --color auto'
alias pmsyu='sudo pacman -Syu --color=auto'
alias merge='xrdb -merge ~/.Xresources'
alias mirrors='sudo reflector --score 100 --fastest 25 --sort rate --save /etc/pacman.d/mirrorlist --verbose'

neofetch