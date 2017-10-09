#!/bin/bash

set -e -u

# setup locale and time then uncomment mirrors
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/# hi_IN UTF-8/hi_IN UTF-8/g' /etc/locale.gen
sed -i 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/# es_AR.UTF-8 UTF-8/es_AR.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
sed -i 's/en_US.UTF-8 UTF-8/# en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/hi_IN UTF-8/# hi_IN UTF-8/g' /etc/locale.gen
sed -i 's/fr_FR.UTF-8 UTF-8/# fr_FR.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/ru_RU.UTF-8 UTF-8/# ru_RU.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/zh_CN.UTF-8 UTF-8/# zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/es_AR.UTF-8 UTF-8/# es_AR.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/pt_BR.UTF-8 UTF-8/# pt_BR.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/de_DE.UTF-8 UTF-8/# de_DE.UTF-8 UTF-8/g' /etc/locale.gen
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

# setup root HOME folder
usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root


sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf


# create liveuser & enable passwordless autologin
useradd -m -u 500 -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/zsh liveuser
passwd -d liveuser
groupadd -r autologin
gpasswd -a liveuser autologin


# setup system srevices
systemctl enable lightdm.service
systemctl set-default graphical.target
systemctl enable pacman-init.service NetworkManager.service
systemctl enable ntpd.service

# link rofi to dmenu
ln -s /usr/bin/rofi /usr/bin/dmenu

# fonts setup
ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh


#export _EDITOR=nano
#echo "EDITOR=${_EDITOR}" >> /etc/environment
#echo "EDITOR=${_EDITOR}" >> /etc/skel/.bashrc
#echo "EDITOR=${_EDITOR}" >> /etc/profile


gpg --receive-keys C1A60EACE707FDA5
gpg --receive-keys AEFB411B072836CD48FF0381AE252C284B5DBA5D
gpg --receive-keys 9E4F11C6A072942A7B3FD3B0B81EB14A09A25EB0
gpg --receive-keys 35F52A02854DCCAEC9DD5CC410443C7F54B00041

pacman-key --init
pacman-key --populate archlinux

pacman-key -r AEFB411B072836CD48FF0381AE252C284B5DBA5D
pacman-key -r 9E4F11C6A072942A7B3FD3B0B81EB14A09A25EB0
pacman-key -r 35F52A02854DCCAEC9DD5CC410443C7F54B00041
pacman-key --populate archlabs

pacman -Syyu --noconfirm
