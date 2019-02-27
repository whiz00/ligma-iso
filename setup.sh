#!/bin/bash
mkdir -pv $HOME/ligma-iso/build
cp -r $HOME/ligma-iso/ $HOME/ligma-iso/build
pacman -Scc
