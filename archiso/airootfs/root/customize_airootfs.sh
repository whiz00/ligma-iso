#!/bin/bash

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root

sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

useradd -m -p "archlabs" -u 500 -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/zsh liveuser
chown -R liveuser:users /home/liveuser

#enable autologin
groupadd -r autologin
gpasswd -a liveuser autologin
#enabling interactive passwordless login
groupadd -r nopasswdlogin
gpasswd -a liveuser nopasswdlogin

systemctl enable lightdm.service
systemctl set-default graphical.target
systemctl enable pacman-init.service choose-mirror.service NetworkManager.service org.cups.cupsd.service bluetooth.service
systemctl enable ntpd.service

#export _EDITOR=nano
#echo "EDITOR=${_EDITOR}" >> /etc/environment
#echo "EDITOR=${_EDITOR}" >> /etc/skel/.bashrc
#echo "EDITOR=${_EDITOR}" >> /etc/profile

# Remove liveuser locale set to avoid mixed locales
sed -i 's/en_US.UTF-8 UTF-8/#en_US.UTF-8 UTF-8/g' /etc/locale.gen

pacman -Syy
gpg --receive-keys C1A60EACE707FDA5
