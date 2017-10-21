#!/usr/bin/env bash

# remove nopassword stuff & disable unwanted services
rm -f /etc/sudoers.d/g_wheel
rm -f /etc/mkinitcpio-archiso.conf
rm -f /root/{.automated_script.sh,.zlogin}
rm -f /etc/polkit-1/rules.d/49-nopasswd_global.rules
rm -rf /etc/systemd/system/default.target

# remove installers
rm -rf /etc/calamares
rm -rf /usr/lib/calamares
rm -rf /abif-master

# remove unwanted scripts & .desktop files
rm /usr/share/applications/qv412.desktop
rm /usr/share/applications/calamares.desktop
rm /usr/bin/install-al

# touch up
sed -i 's/Name=File Manager/Name=Thunar Settings/g' /usr/share/applications/thunar-settings.desktop
sed -i '189,194d' /etc/skel/.config/openbox/menu.xml

# enable al-hello after install
sed -i '/al-hello/ c\
termite --geometry=650x450 --exec=/usr/bin/al-hello &' /etc/skel/.config/openbox/autostart
sed -i '/al-panel-chooser/d' /etc/skel/.config/openbox/autostart

# fix boot messages
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/ c\
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nowatchdog systemd.legacy_systemd_cgroup_controller=true"' /etc/default/grub

# remove script
rm /usr/bin/cleanup.sh
