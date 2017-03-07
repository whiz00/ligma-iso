#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


alias pacman="pacman --color auto"
alias ls="ls --color"
alias syua="pacaur -Syu"
alias syu="sudo pacman -Syu"
alias merge="xrdb -merge ~/.Xresources"
PS1='[\u@\h \W]\$ '

neofetch
