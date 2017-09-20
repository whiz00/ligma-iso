#!/bin/bash

if [[ `checkupdates | wc -l` > 0 ]]; then
    termite --geometry=600x400 --exec="sudo pacman -Syu" &
fi

exit 0
