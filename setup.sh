#!/bin/bash
dir="/home/$1/ligma-iso"
mkdir -pv $dir/build
sudo cp -r $dir $dir/build
sudo rsync -av --progress $dir $dir/build --exclude $dir/build
pacman -Scc
