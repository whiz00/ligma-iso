#!/usr/bin/env bash

set -e

TXT="<big><b>Welcome to ArchLabs Live Session</b></big>

The live session allows you to test ArchLabs without
needing to make changes to your computer's storage drive.

Among other things, it can be used to check hardware compatibility,
perform system recovery, or work anonymously on a public computer.

Right-click the anywhere on the desktop to access the openbox menu.
Hit Super (meta or windows) or Alt-F1 to open a launcher.

The live session username is '<b>liveuser</b>' and the password is '<b>archlabs</b>'.
For obvious reasons the live account has been given full sudo permissions.


To install the system, select the 'Install' option from the openbox menu.


Thank you for trying <b>ArchLabs Linux</b>"
WEL="zenity --info --window-icon=/usr/share/icons/ArchLabs-Dark/64x64/places/distributor-logo-archlabs.png --width=500 --height=400 --title='ArchLabs Welcome' --text=\"$TXT\""

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
! grep -q "^autologin:" /etc/group && groupadd -r autologin
! id liveuser && useradd -m -u 1000 -g users \
    -G audio,autologin,floppy,log,network,rfkill,scanner,storage,optical,power,wheel \
    -s /bin/zsh liveuser
passwd liveuser </tmp/.passwd >/dev/null
rm -f /tmp/.passwd

# autologin to console
mkdir -p /etc/systemd/system/getty@tty1.service.d
OVERRIDE="[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin liveuser --noclear %I \$TERM"
echo -e "$OVERRIDE" > /etc/systemd/system/getty@tty1.service.d/override.conf

# system services
systemctl enable systemd-timesyncd.service NetworkManager.service NetworkManager-dispatcher.service -f
# systemctl enable ntpd.service -f

# fonts
ln -sf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh

# Welcome message
echo "$WEL" > /home/liveuser/bin/welcome.sh
chmod +x /home/liveuser/bin/welcome.sh
echo "sleep 5 ; welcome.sh &" >> /home/liveuser/.config/openbox/autostart

# menu entries
sed -i '/separator label="ArchLabs"/ c\
    <item label="W e l c o m e">\
      <action name="Execute">\
        <command>welcome.sh<\/command>\
      <\/action>\
    <\/item>\
    <separator\/>\
    <item label="I n s t a l l e r">\
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
pacman-key --init && pacman-key --populate archlinux && pacman-key --populate archlabs
pacman -Syu --noconfirm

