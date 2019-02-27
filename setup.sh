#!/bin/bash
dir="/home/$1/ligma-iso"
mkdir -pv $dir/build
sudo rsync -av $dir/* $dir/build/ --exclude $dir/build README.md setup.sh
pacman -Scc
