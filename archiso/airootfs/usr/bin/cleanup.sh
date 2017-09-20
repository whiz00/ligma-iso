#!/bin/bash


# bulk (best not to touch these unless you are certain)
rm -f /etc/sudoers.d/g_wheel
rm -R /etc/systemd/system/getty@tty1.service.d
rm /etc/systemd/system/default.target
rm -f /etc/polkit-1/rules.d/49-nopasswd_global.rules
systemctl disable pacman-init.service choose-mirror.service
rm -r /etc/systemd/system/{choose-mirror.service,pacman-init.service,etc-pacman.d-gnupg.mount,getty@tty1.service.d}
rm /etc/systemd/scripts/choose-mirror
rm /root/{.automated_script.sh,.zlogin}
rm /etc/mkinitcpio-archiso.conf
rm -r /etc/initcpio

# remove installers
rm -rf /etc/calamares
rm -rf /usr/lib/calamares
rm -rf /abif-master

# remove unwanted scripts & .desktop files
rm /usr/share/applications/calamares.desktop
rm /usr/bin/install-al
rm /usr/bin/al-obthemes
sed -i '/launcher_item_app = \/usr\/share\/applications\/calamares.desktop/d' /etc/skel/.config/tint2/tint2rc
sed -i '/launcher_item_app = \/usr\/share\/applications\/archlabs-hello.desktop/d' /etc/skel/.config/tint2/tint2rc

# touch up
sed -i 's/user-session=i3/user-session=openbox/g' /etc/lightdm/lightdm.conf
sed -i 's/Name=File Manager/Name=Thunar Settings/g' /usr/share/applications/thunar-settings.desktop
sed -i 's/    <item label="Install Archlabs">/    <item label="Lock Screen">/g' /etc/skel/.config/openbox/menu.xml
sed -i 's/install-al/slimlock/g' /etc/skel/.config/openbox/menu.xml
sed -i 's/QT_QPA_PLATFORMTHEME=qt5ct/#/g' /etc/environment

# setup screen in polybar config
screen_1=`xrandr -q | grep " connected" | cut -d ' ' -f1 | head -n1`
screen_2=`xrandr -q | grep " connected" | cut -d ' ' -f1 | tail -n1`
sed -i "s/monitor =/monitor = ${screen_1}/g" /etc/skel/.config/polybar/config-openbox
sed -i "s/monitor =/monitor = ${screen_1}/g" /etc/skel/.config/polybar/config-i3

# check for second screen
if [[ `xrandr -q | grep " connected" | cut -d ' ' -f1 | wc -l` > 1 ]]
  then
    sed -i "s/;monitor =/monitor = ${screen_2}/g" /etc/skel/.config/polybar/config-openbox
    sed -i "s/;monitor =/monitor = ${screen_2}/g" /etc/skel/.config/polybar/config-i3
    sed -i 's/#polybar/polybar/g' /etc/skel/.config/polybar/launch-ob-polybar.sh
    sed -i 's/#polybar/polybar/g' /etc/skel/.config/polybar/launch-i3-polybar.sh
fi

# remove this script
rm /usr/bin/cleanup.sh
