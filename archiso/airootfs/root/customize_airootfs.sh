#!/bin/bash

set -e -u

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen

locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Remove liveuser locale set to avoid mixed locales
sed -i 's/en_US.UTF-8 UTF-8/#en_US.UTF-8 UTF-8/g' /etc/locale.gen

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root

# setup mirrors
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

#sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
#sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf
#sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
#sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
#sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf


useradd -m -p "archlabs" -u 500 -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/zsh liveuser
chown -R liveuser:users /home/liveuser

#enable autologin
groupadd -r autologin
gpasswd -a liveuser autologin

#enabling passwordless login
groupadd -r nopasswdlogin
gpasswd -a liveuser nopasswdlogin

systemctl enable lightdm.service
systemctl set-default graphical.target
systemctl enable pacman-init.service NetworkManager.service
systemctl enable ntpd.service
# choose-mirror.service

# fix networkmanager
#sed -i 's/#!\/usr\/bin\/env python/#!\/usr\/bin\/env python2/g' /usr/bin/networkmanager_dmenu

# link rofi to dmenu
ln -s /usr/bin/rofi /usr/bin/dmenu

# fonts setup
#ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh


export _EDITOR=nano
echo "EDITOR=${_EDITOR}" >> /etc/environment
echo "EDITOR=${_EDITOR}" >> /etc/skel/.bashrc
echo "EDITOR=${_EDITOR}" >> /etc/profile


pacman -Syy

gpg --receive-keys C1A60EACE707FDA5


#pacman-key --init && sudo pacman-key --populate archlinux
#gpg --receive-keys 35F52A02854DCCAEC9DD5CC410443C7F54B00041
#pacman-key --keyserver keys.gnupg.net -r 35F52A02854DCCAEC9DD5CC410443C7F54B00041
#pacman-key --lsign-key 35F52A02854DCCAEC9DD5CC410443C7F54B00041
