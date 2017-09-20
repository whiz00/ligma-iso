#!/usr/bin/env bash

pkill polybar
polybar --config=$HOME/.config/polybar/config-openbox bar1 &
#polybar --config=$HOME/.config/polybar/config-openbox bar2 &

exit 0
