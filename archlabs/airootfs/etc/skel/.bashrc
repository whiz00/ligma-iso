# Bashrc

# If not running interactively return
[[ $- != *i* ]] && return

export EDITOR=nano
export PATH=$HOME/bin:$PATH
export HISTCONTROL=ignoreboth:erasedups

# Prompt
PS1='\u@\h \W \$ '

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

# Shell options
shopt -s autocd         # change to named directory
shopt -s cdspell        # autocorrects cd misspellings
shopt -s cmdhist        # save multi-line commands in history as single line
shopt -s histappend     # do not overwrite history
shopt -s expand_aliases # expand aliases

neofetch
