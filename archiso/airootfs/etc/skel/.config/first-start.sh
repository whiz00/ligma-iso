#!/usr/bin/env bash


# set firefox homepage
sed -i "s/liveuser/${USER}/g" /home/$USER/.mozilla/firefox/archlabs.default/prefs.js
sed -i "s/liveuser/${USER}/g" /home/$USER/.mozilla/firefox/archlabs.default/sessionstore.js

# set bookmarks
sed -i "s/liveuser/${USER}/g" /home/$USER/.config/gtk-3.0/bookmarks

# remove some stuff from autostart
sed -i '30,32d' /home/$USER/.config/openbox/autostart
sed -i '22d' /home/$USER/.config/openbox/autostart
sed -i '6,7d' /home/$USER/.config/openbox/autostart

rm -f /home/$USER/.config/first-start.sh
