#!/bin/bash

if [[ `cower -u | wc -l` > 0 ]]; then
    termite --geometry=600x400 --exec="packer -Syu" &
fi

exit 0
