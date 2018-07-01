#!/usr/bin/env bash

set -e

# locale
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen

# timezone & mirrors
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

# password
echo -e "archlabs\narchlabs" >/tmp/.passwd

# root
passwd </tmp/.passwd >/dev/null
usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/

# liveuser
grep -q "^autologin:" /etc/group || groupadd -r autologin
id liveuser 2>/dev/null || useradd -m -u 1000 -g users -G audio,autologin,floppy,log,network,rfkill,scanner,storage,optical,power,wheel -s /bin/zsh liveuser
passwd liveuser </tmp/.passwd >/dev/null
rm -f /tmp/.passwd

# system services
systemctl enable systemd-timesyncd.service NetworkManager.service NetworkManager-dispatcher.service -f

# fonts
ln -sf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh

# Welcome message
echo "zenity --info --icon-name= --window-icon=/usr/share/icons/ArchLabs-Dark/64x64/places/distributor-logo-archlabs.png --width=600 --height=500 --title='ArchLabs Welcome' --text=\"<big><b>Welcome to the ArchLabs Live Session</b></big>

The live session allows testing ArchLabs without needing to make changes to your computer.
Use it to check hardware compatibility, perform system recovery, or work anonymously on a public computer.


<big>Live User</big>

The live session user name is '<b>liveuser</b>' with the password '<b>archlabs</b>'. For ease of use the live account has been given <b>sudo</b> permissions, without need to enter a password (in most cases).


<big>Openbox</big>

Right-click the anywhere on the desktop to access the openbox menu.
The <b>super</b> key (meta or windows) or <b>alt-F1</b> can be used to open a application launcher.


<big>Install</big>

To begin the system install, select '<b>Run Installer</b>' from the openbox menu,
or execute '<b>sudo /installer/installer</b>' in a terminal.


Thank you for trying <b>ArchLabs Linux</b>\"" > /home/liveuser/bin/welcome.sh

chmod +x /home/liveuser/bin/welcome.sh
echo "sleep 5 ; welcome.sh &" >> /home/liveuser/.config/openbox/autostart

# menu entries
sed -i '/separator label="ArchLabs"/ c\
    <item label="Welcome Screen">\
      <action name="Execute">\
        <command>welcome.sh<\/command>\
      <\/action>\
    <\/item>\
    <separator\/>\
    <item label="Run Installer">\
      <action name="Execute">\
        <command>install-al<\/command>\
      <\/action>\
    <\/item>\
    <separator\/>' /home/liveuser/.config/openbox/menu.xml

# installer window rules
sed -i '/<\/applications>/ i\
    <application class="installer">\
      <maximized>yes<\/maximized>\
    <\/application>' /home/liveuser/.config/openbox/rc.xml

# Setup keyring & pacman
gpg --receive-keys C1A60EACE707FDA5
pacman-key --init
pacman-key --populate archlinux
pacman-key --populate archlabs
pacman -Syu --noconfirm
