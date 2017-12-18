#!/bin/bash

set -e -u

edit=nano
files=('/etc/environment' '/etc/profile')
servs=('lightdm' 'NetworkManager' 'ntpd')
langs=('en_US' 'fr_FR' 'ru_RU' 'zh_CN' 'es_AR' 'pt_BR' 'de_DE' 'it_IT')
keys=('AEFB411B072836CD48FF0381AE252C284B5DBA5D'
      '9E4F11C6A072942A7B3FD3B0B81EB14A09A25EB0'
      '35F52A02854DCCAEC9DD5CC410443C7F54B00041')

zrc="#
[[ \$- != *i* ]] && return
\nexport PATH=\$HOME/bin:\$PATH
export EDITOR='nano'
\nsetopt AUTO_CD # No cd needed to change directories
setopt BANG_HIST # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history.
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS # Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_DUPS # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_SPACE # Don't record an entry starting with a space.
setopt HIST_REDUCE_BLANKS # Remove superfluous blanks before recording entry.
setopt HIST_SAVE_NO_DUPS # Don't write duplicate entries in the history file.
setopt INC_APPEND_HISTORY # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY # Share history between all sessions.
\nPS1='[\\\u@\h \W]\\\$ '
\nalias ls='ls --color=auto'
alias la='ls -A'
alias ll='ls -lA'
alias l='ls'
alias l.=\"ls -A | egrep '^\.'\"
alias merge='xrdb -merge ~/.Xresources'
alias pmsyu='sudo pacman -Syu --color=auto'
alias pacman='sudo pacman --color auto'
alias update='sudo pacman -Syu'
alias mirrors='sudo reflector --score 100 --fastest 25 --sort rate --save /etc/pacman.d/mirrorlist --verbose'
\nneofetch\n"

brc="#
[[ \$- != *i* ]] && return
\nexport PATH=\$HOME/bin:\$PATH
export EDITOR='nano'
export HISTCONTROL=ignoreboth:erasedups
\nPS1='[\\\u@\h \W]\\\$ '
\nalias ls='ls --color=auto'
alias la='ls -A'
alias ll='ls -lA'
alias l='ls'
alias l.=\"ls -A | egrep '^\.'\"
alias merge='xrdb -merge ~/.Xresources'
alias pmsyu='sudo pacman -Syu --color=auto'
alias pacman='sudo pacman --color auto'
alias update='sudo pacman -Syu'
alias upmirrors='sudo reflector --score 100 --fastest 25 --sort rate --save /etc/pacman.d/mirrorlist --verbose'
\nshopt -s autocd # change to named directory
shopt -s cdspell # autocorrects cd misspellings
shopt -s cmdhist # save multi-line commands in history as single line
shopt -s histappend # do not overwrite history
shopt -s expand_aliases # expand aliases
\nneofetch\n"

# setup locale
sed -i 's/#hi_IN UTF-8/hi_IN UTF-8/g' /etc/locale.gen
for i in ${langs[@]}; do
    sed -i "s/#${i}.UTF-8 UTF-8/${i}.UTF-8 UTF-8/g" /etc/locale.gen
done
locale-gen
sed -i 's/hi_IN UTF-8/#hi_IN UTF-8/g' /etc/locale.gen
for i in ${langs[@]}; do
    sed -i "s/${i}.UTF-8 UTF-8/#${i}.UTF-8 UTF-8/g" /etc/locale.gen
done

# shell stuff must happen before liveuser is created
echo -e "$brc" > /etc/skel/.bashrc
echo -e "$zrc" > /etc/skel/.zshrc
for i in ${files[@]}; do
    echo -e "\nEDITOR=${edit}\n" >> $i
done

# timezone & mirrors
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
set_password() {
    dialog --title " Enter Password " --clear --insecure --passwordbox "Enter Password" 0 0 2> /tmp/.answer || exit 0
    PASSWD=$(cat /tmp/.answer)
    dialog --title " Re-Enter Password " --clear --insecure --passwordbox "Enter Password Again" 0 0 2> /tmp/.answer || exit 0
    PASSWD2=$(cat /tmp/.answer)
    if [[ $PASSWD == $PASSWD2 ]]; then
       echo -e "${PASSWD}\n${PASSWD}" > /tmp/.passwd
       rm -f /tmp/.answer
       clear
    else
       dialog --title " Error " --msgbox "Passwords do not match" 0 0
       set_password
    fi
}

set_password
# setup root
passwd < /tmp/.passwd >/dev/null
usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
#chmod 700 /root

# setup liveuser
groupadd -r autologin
useradd -m -u 1000 -g users -G "audio,autologin,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/zsh liveuser
passwd liveuser < /tmp/.passwd >/dev/null
rm -f /tmp/.passwd

# system services
systemctl set-default graphical.target
for i in ${servs[@]}; do
    systemctl enable ${i}.service
done

# link rofi to dmenu
ln -s /usr/bin/rofi /usr/bin/dmenu
ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh

# set installer rules to be fullscreen
sed -i '/<\/applications>/ i\
    <application class="archlabs-installer">\
      <fullscreen>yes<\/fullscreen>\
    <\/application>' /home/liveuser/.config/openbox/rc.xml

# Setup keyrings
dirmngr </dev/null  # sometimes prevents failure to connect to keyserver
gpg --receive-keys C1A60EACE707FDA5
pacman-key --init && pacman-key --populate archlinux
for i in ${keys[@]}; do
    gpg --receive-keys $i
    pacman-key -r $i
done
pacman-key --populate archlabs
pacman -Syy --noconfirm

