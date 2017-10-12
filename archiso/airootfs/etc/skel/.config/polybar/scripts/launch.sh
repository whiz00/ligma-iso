#!/usr/bin/env bash

# config location
CONF_PATH=$HOME/.config/polybar


sed -i '/base/{n;N;N;d}' $CONF_PATH/config
sed -i "/base/ a\
include-file = ${CONF_PATH}/master.conf" $CONF_PATH/config
sed -i "/base/ a\
include-file = ${CONF_PATH}/modules.conf" $CONF_PATH/config
# set firefox homepage
sed -i "s/liveuser/${USER}/g" $HOME/.mozilla/firefox/archlabs.default/prefs.js
sed -i "s/liveuser/${USER}/g" $HOME/.mozilla/firefox/archlabs.default/sessionstore.js
# set bookmarks
sed -i "s/liveuser/${USER}/g" $HOME/.config/gtk-3.0/bookmarks
# remove some stuff from autostart
sed -i '6,19d' $CONF_PATH/scripts/launch.sh


# Check WM
cur_wm=$(wmctrl -m | grep Name | cut -d " " -f2)

if [ "$1" == "--reload" ]; then
  if ! [ "$cur_wm" == "i3" ]; then
    openbox --restart
    al-compositor --restart
    al-tint2restart
  fi
fi

# Terminate already running bar instances
killall -q polybar

if pgrep -x "tint2" >/dev/null; then
  echo "Tint is running, not launching bars"
  exit 1
fi

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.5; done


# if i3 launch the i3-bar
if [ "$cur_wm" == "i3" ]; then
  polybar -r --config=$CONF_PATH/config i3-bar &

else  # otherwise we assume openbox
  polybar -r --config=$CONF_PATH/config openbox-bar &

fi

echo "Bars launched..."
