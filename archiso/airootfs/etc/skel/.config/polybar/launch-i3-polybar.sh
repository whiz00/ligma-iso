#!/usr/bin/env bash


## you can launch it with -r to reload upon config changes

pkill polybar
polybar --config=$HOME/.config/polybar/config-i3 bar1 &
#polybar --config=$HOME/.config/polybar/config-i3 bar2 &

exit 0
