# Ligma-Iso

Source for Ligma iso builds. Work currently only on arch-based distributions.

### Manually building the iso by hand.

The package `archiso` must be intalled since it is used in the build script. Likewise `rsync` is used for in the setup script.

1. Begin by cloning the repo:

    git clone --depth 1 https://github.com/whiz00/ligma-iso $HOME/ligma-iso

2. Read and run the setup script. Build files must be owned by root and the pacman chache will be cleared in order for the iso to be created properly.

    cd $HOME/ligma-iso
    sudo ./setup.sh $USER

3. Last step is to build the iso (-v flag for verbose output). When the script is finished the iso will be located in a directory called 'out'

    sudo ./build.sh -v

### Customization

You can modify the packages included in the iso by editing the `packages` file.

`efiboot`, `isolinux`, and `syslinux` folders contain files configuring iso boot option. Proceed with caution editing contents in those folders.

The `pacman.conf` file includes the ligma repo used for personal packages.

The `airootfs` represents the file sytem used for the iso. Add files here if you want them in the live environment.
