#!/usr/bin/env bash

set -e

LUSER="liveuser"
KEYS=('AEFB411B072836CD48FF0381AE252C284B5DBA5D' '9E4F11C6A072942A7B3FD3B0B81EB14A09A25EB0' '35F52A02854DCCAEC9DD5CC410443C7F54B00041')
TXT="<big><b>Welcome to ArchLabs Live Session</b></big>

The live session allows you to test ArchLabs without
needing to make changes to your computer's storage drive.

Among other things, it can be used to check hardware compatibility,
perform system recovery, or work anonymously on a public computer.

Right-click the anywhere on the desktop to access the openbox menu,
or enter the super (meta or windows) key or Ctrl+Space to open a launcher.

The live session username is '<b>liveuser</b>' and the password is '<b>archlabs</b>'.
For obvious reasons the live account has been given full sudo permissions.


To install the system, select the 'Install' option from the openbox menu.


Thank you for trying <b>ArchLabs Linux</b>"

WEL="zenity --info --window-icon=/usr/share/icons/ArchLabs-Light/64x64/places/distributor-logo-archlabs.png"
WEL="$WEL --width=500 --height=400 --title='ArchLabs Welcome' --text=\"$TXT\""

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
groupadd -r autologin
useradd -m -u 1000 -g users -G audio,autologin,floppy,log,network,rfkill,scanner,storage,optical,power,wheel -s /bin/zsh $LUSER
passwd $LUSER </tmp/.passwd >/dev/null
rm -f /tmp/.passwd

# xinit
rm -f /etc/systemd/system/getty.target.wants/getty@tty1.service
ln -s /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
sed -i "/ExecStart/ c ExecStart=-/sbin/agetty -a ${LUSER} %I \$TERM" /etc/systemd/system/autologin@.service

# system services
systemctl enable NetworkManager.service -f
# systemctl enable NetworkManager-dispatcher.service -f
systemctl enable ntpd.service -f

# fonts
ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh

# Welcome message
echo "$WEL" > /home/$LUSER/bin/welcome.sh
chmod +x /home/$LUSER/bin/welcome.sh
echo "sleep 5 ; welcome.sh &" >> /home/$LUSER/.config/openbox/autostart

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
    <separator\/>' /home/$LUSER/.config/openbox/menu.xml

# installer window rules
sed -i '/<\/applications>/ i\
    <application class="installer">\
      <maximized>yes<\/maximized>\
    <\/application>' /home/$LUSER/.config/openbox/rc.xml

# Setup keyring & pacman
dirmngr </dev/null
gpg --receive-keys C1A60EACE707FDA5
pacman-key --init
pacman-key --populate archlinux
for i in "${KEYS[@]}"; do
    gpg --receive-keys "$i"
    pacman-key -r "$i"
done
pacman-key --populate archlabs
pacman -Sy --noconfirm
