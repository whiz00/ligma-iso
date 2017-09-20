#!/usr/bin/env bash

pkill polybar
polybar --config=$HOME/.config/polybar/config-i3 bar1 &
#polybar --config=$HOME/.config/polybar/config-i3 bar2 &

exit 0
