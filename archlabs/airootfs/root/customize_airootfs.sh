#!/bin/bash

set -e -u

edit=nano
files=('/etc/environment' '/etc/profile')
servs=('lightdm' 'NetworkManager' 'ntpd')
langs=('en_US' 'fr_FR' 'ru_RU' 'zh_CN' 'es_AR' 'pt_BR' 'de_DE' 'it_IT')
keys=('AEFB411B072836CD48FF0381AE252C284B5DBA5D'
      '9E4F11C6A072942A7B3FD3B0B81EB14A09A25EB0'
      '35F52A02854DCCAEC9DD5CC410443C7F54B00041')

# setup locale
sed -i 's/#hi_IN UTF-8/hi_IN UTF-8/g' /etc/locale.gen
for i in "${langs[@]}"; do
    sed -i "s/#${i}.UTF-8 UTF-8/${i}.UTF-8 UTF-8/g" /etc/locale.gen
done
locale-gen
sed -i 's/hi_IN UTF-8/#hi_IN UTF-8/g' /etc/locale.gen
for i in "${langs[@]}"; do
    sed -i "s/${i}.UTF-8 UTF-8/#${i}.UTF-8 UTF-8/g" /etc/locale.gen
done

for i in "${files[@]}"; do
    echo -e "\nEDITOR=${edit}\n" >> "$i"
done

# timezone & mirrors
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
set_password() {
    dialog --title " Enter Password " --clear --insecure --passwordbox "Enter Password" 0 0 2> /tmp/.answer || exit 0
    PASSWD=$(cat /tmp/.answer)
    dialog --title " Re-Enter Password " --clear --insecure --passwordbox "Enter Password Again" 0 0 2> /tmp/.answer || exit 0
    PASSWD2=$(cat /tmp/.answer)
    if [[ $PASSWD == "$PASSWD2" ]]; then
       echo -e "${PASSWD}\n${PASSWD}" > /tmp/.passwd
       rm -f /tmp/.answer
       clear
    else
       dialog --title " Error " --msgbox "Passwords do not match" 0 0
       set_password
    fi
}

set_password
# setup root
passwd < /tmp/.passwd >/dev/null
usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
#chmod 700 /root

# setup liveuser
groupadd -r autologin
useradd -m -u 1000 -g users -G "audio,autologin,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/zsh liveuser
passwd liveuser < /tmp/.passwd >/dev/null
rm -f /tmp/.passwd

# system services
systemctl set-default graphical.target
for i in "${servs[@]}"; do
    systemctl enable "$i.service"
done

# link rofi to dmenu
ln -s /usr/bin/rofi /usr/bin/dmenu
ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh
# set installer rules to be fullscreen
sed -i '/<\/applications>/ i\
    <application class="archlabs-installer">\
      <fullscreen>yes<\/fullscreen>\
    <\/application>' /home/liveuser/.config/openbox/rc.xml

# Setup keyrings
dirmngr </dev/null  # sometimes prevents failure to connect to keyserver
gpg --receive-keys C1A60EACE707FDA5
pacman-key --init && pacman-key --populate archlinux
for i in "${keys[@]}"; do
    gpg --receive-keys "$i"
    pacman-key -r "$i"
done
pacman-key --populate archlabs
pacman -Syy --noconfirm

