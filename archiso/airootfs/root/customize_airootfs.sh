#!/bin/bash

set -e -u
edit=nano
files=('/etc/environment' '/etc/skel/.bashrc' '/etc/profile')
servs=('lightdm' 'pacman-init' 'choose-mirror' 'NetworkManager' 'ntpd')
langs=('en_US' 'fr_FR' 'ru_RU' 'zh_CN' 'es_AR' 'pt_BR' 'de_DE' 'it_IT')
keys=('AEFB411B072836CD48FF0381AE252C284B5DBA5D'
      '9E4F11C6A072942A7B3FD3B0B81EB14A09A25EB0'
      '35F52A02854DCCAEC9DD5CC410443C7F54B00041')

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

# timezone & mirrors
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

# setup root HOME folder
usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root

# create liveuser & enable passwordless autologin
useradd -m -u 500 -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/zsh liveuser
passwd -d liveuser && groupadd -r autologin && gpasswd -a liveuser autologin

# system services
systemctl set-default graphical.target
for i in ${servs[@]}; do
    systemctl enable ${i}.service
done

# link rofi & dmenu
ln -s /usr/bin/rofi /usr/bin/dmenu

# fonts
ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh

# terminal editor
for i in ${files[@]}; do
    echo "EDITOR=${edit}" >> $i
done

# Setup keyrings
gpg --receive-keys C1A60EACE707FDA5
pacman-key --init && pacman-key --populate archlinux
for i in ${keys[@]}; do
    gpg --receive-keys $i
    pacman-key -r $i
done
pacman-key --populate archlabs
pacman -Syy --noconfirm

