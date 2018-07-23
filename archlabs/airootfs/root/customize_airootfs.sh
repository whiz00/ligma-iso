#!/usr/bin/env bash

# exit on first error encountered
set -e


# locale
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen

# timezone & mirrors
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

# archiso defaults
sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

# password
echo -e "archlabs\narchlabs" >/tmp/.passwd

# root
passwd </tmp/.passwd >/dev/null
usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/

# liveuser
grep -q "^autologin:" /etc/group || groupadd -r autologin

if ! id liveuser 2>/dev/null; then
    g="audio,autologin,floppy,log,network,rfkill,scanner,storage,optical,power,wheel"
    useradd -m -u 1000 -g users -G $g -s /bin/zsh liveuser
    passwd liveuser </tmp/.passwd >/dev/null

    # Welcome message
    echo "zenity --info --icon-name= --window-icon=/usr/share/icons/ArchLabs-Dark/64x64/places/distributor-logo-archlabs.png --width=600 --height=500 --title='ArchLabs Welcome' --text=\"<big><b>Welcome to the ArchLabs Live Session</b></big>

The live session allows testing ArchLabs without needing to make changes to your computer.
Use it to check hardware compatibility, perform system recovery/maintenance, or to work anonymously on a public computer.


<big>Live User</big>

The live session user name is '<b>liveuser</b>' with the password '<b>archlabs</b>'. For ease of use the live account has been given <b>sudo</b> permissions, without need to enter a password (in most cases).


<big>Openbox</big>

Right-click the anywhere on the desktop to access the openbox menu. The <b>Super</b> key
(Meta or Windows) or <b>Alt-F1</b> can be used to open a application launcher.


<big>Install</big>

To begin the system install, select '<b>Run Installer</b>' from the openbox menu, or execute
'<b>/installer/installer</b>' in a terminal (as <b>root</b>).


Thank you for trying out <b>ArchLabs Linux</b>\"" > /home/liveuser/bin/welcome.sh

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

    # remove xorg configs in virtualbox
    sed -i '/automatically run startx/ i\
grep -qi "hypervisor" <<< "$(dmesg)" && sudo rm -rf \/etc\/X11\/xorg.conf.d || sed -i "\/dmesg\/d" ~\/.zprofile' /home/liveuser/.zprofile

fi

rm -f /tmp/.passwd

# system services
systemctl enable systemd-timesyncd.service NetworkManager.service -f

# fonts
ln -sf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh

# Setup keyring & pacman
gpg --receive-keys C1A60EACE707FDA5
pacman-key --init
pacman-key --populate archlinux
pacman-key --populate archlabs
pacman -Syyu --noconfirm
