#!/bin/bash

set -e

ISO_USER="liveuser"
SERVS=('lightdm' 'NetworkManager' 'ntpd')
GROUP="audio,autologin,floppy,log,network,rfkill,scanner,storage,optical,power,wheel"
KEYS=('AEFB411B072836CD48FF0381AE252C284B5DBA5D'
      '9E4F11C6A072942A7B3FD3B0B81EB14A09A25EB0'
      '35F52A02854DCCAEC9DD5CC410443C7F54B00041')

# setup locale
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
# sed -i "s/en_US.UTF-8 UTF-8/#en_US.UTF-8 UTF-8/g" /etc/locale.gen

# timezone & mirrors
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
set_password() {
    dialog --title " Enter Password " --clear --insecure \
        --passwordbox "Enter Password" 0 0 2>/tmp/.answer || exit 0
    PASSWD=$(cat /tmp/.answer)
    dialog --title " Re-Enter Password " --clear --insecure \
        --passwordbox "Enter Password Again" 0 0 2>/tmp/.answer || exit 0
    PASSWD2=$(cat /tmp/.answer)
    if [[ $PASSWD == "$PASSWD2" ]]; then
       echo -e "${PASSWD}\n${PASSWD}" >/tmp/.passwd
       rm -f /tmp/.answer
       clear
    else
       dialog --title " Error " --msgbox "Passwords do not match" 0 0
       set_password
    fi
}
# function so it can call itself when passwords dont match
set_password

# setup root
passwd </tmp/.passwd >/dev/null
usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/

# setup liveuser
groupadd -r autologin
useradd -m -u 1000 -g users -G "$GROUP" -s /bin/zsh $ISO_USER
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
pacman-key --init && pacman-key --populate archlinux
for i in "${KEYS[@]}"; do
    gpg --receive-keys "$i"
    pacman-key -r "$i"
done
pacman-key --populate archlabs && pacman -Syy --noconfirm
