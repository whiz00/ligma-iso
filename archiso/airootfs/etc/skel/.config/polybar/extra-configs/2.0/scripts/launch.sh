#!/usr/bin/env bash

# config location
CONF_PATH=$HOME/.config/polybar


MASTER=$CONF_PATH/master.conf
MODULES=$CONF_PATH/modules.conf
sed -i '/base/{n;N;N;d}' $CONF_PATH/config
sed -i "/base/ a\
include-file = ${MODULES}" $CONF_PATH/config
sed -i "/base/ a\
include-file = ${MASTER}" $CONF_PATH/config
sed -i '6,15d' $CONF_PATH/scripts/launch-polybar.sh


# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Check WM
cur_wm='wmctrl -m | grep Name | cut -d " " -f2'

# if i3 launch the i3-bar
if [ "$cur_wm" == "i3" ]; then
  polybar -r --config=$CONF_PATH/config i3-bar &

else  # otherwise we assume openbox
  polybar -r --config=$CONF_PATH/config openbox-bar &

fi

echo "Bars launched..."
