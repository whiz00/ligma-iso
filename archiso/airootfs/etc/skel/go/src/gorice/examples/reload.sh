killall compton
killall polybar
killall conky
pkill dunst
i3-msg restart
gtk-theme-switch2 /home/steven/.themes/Dynamic\ Simple/

sleep 0.5
notify-send "Config loaded" "{{.Name}}"
