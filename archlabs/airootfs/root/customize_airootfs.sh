#!/bin/bash

set -e

ISO_USER="liveuser"
SERVS=('lightdm' 'NetworkManager' 'ntpd')
GRP="audio,autologin,floppy,log,network,rfkill,scanner,storage,optical,power,wheel"
KEYS=(
'AEFB411B072836CD48FF0381AE252C284B5DBA5D'
'9E4F11C6A072942A7B3FD3B0B81EB14A09A25EB0'
'35F52A02854DCCAEC9DD5CC410443C7F54B00041'
)

WELTXT="<big><b>Welcome to ArchLabs Live Session</b></big>

The live session allows you to test ArchLabs without
needing to make changes to your computer's storage drive.



Among other things, it can be used to check hardware compatibility,
perform system recovery, or work anonymously on a public computer.


Right-click the anywhere on the desktop to access the openbox menu,
or enter the super (meta or windows) key or Ctrl+Space to open a launcher

The live session username is '<b>liveuser</b>' and the password is '<b>archlabs</b>'.
For obvious reasons the live account has been given full sudo permissions.

To install the system to your hard-disk, select the 'Install ArchLabs' entry.



Thank you for trying <b>ArchLabs Linux</b>"

WEL="zenity --info --window-icon=/usr/share/icons/ArchLabs-Light/64x64/places/distributor-logo-archlabs.png"
WEL="$WEL --width=500 --height=450 --title='ArchLabs Welcome' --text=\"$WELTXT\""

# setup locale
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
sed -i "s/en_US.UTF-8 UTF-8/#en_US.UTF-8 UTF-8/g" /etc/locale.gen

# timezone & mirrors
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

# password file
echo -e "archlabs\narchlabs" >/tmp/.passwd

# setup root
passwd </tmp/.passwd >/dev/null
usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/

# setup liveuser
groupadd -r autologin
useradd -m -u 1000 -g users -G "$GRP" -s /bin/zsh $ISO_USER
passwd $ISO_USER </tmp/.passwd >/dev/null
rm -f /tmp/.passwd

# system services
systemctl set-default graphical.target
for i in "${SERVS[@]}"; do
    systemctl enable "$i.service"
done

# Link rofi to dmenu
ln -s /usr/bin/rofi /usr/bin/dmenu

# Nice fonts
ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh

# Welcome message
echo "$WEL" > /home/$ISO_USER/bin/welcome.sh
chmod +x /home/$ISO_USER/bin/welcome.sh
echo "sleep 5 ; welcome.sh &" >> /home/$ISO_USER/.config/openbox/autostart
sed -i '/separator label="ArchLabs"/ c\
    <item label="ArchLabs Welcome">\
      <action name="Execute">\
        <command>welcome.sh<\/command>\
      <\/action>\
    <\/item>\
    <separator\/>' /home/$ISO_USER/.config/openbox/menu.xml

# Set installer to be fullscreen
sed -i '/<\/applications>/ i\
    <application class="archlabs-installer">\
      <fullscreen>yes<\/fullscreen>\
    <\/application>' /home/$ISO_USER/.config/openbox/rc.xml

# Add installer entry to the menu
sed -i '/al-kb-pipemenu/ a\
    <separator\/>\
    <item label="Install Archlabs">\
      <action name="Execute">\
        <command>install-al<\/command>\
      <\/action>\
    <\/item>' /home/$ISO_USER/.config/openbox/menu.xml

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
pacman -Syy --noconfirm
