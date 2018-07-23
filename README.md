# Archlabs-Iso

Source for ArchLabs iso builds


### Building the iso

The package `archiso` must be installed and it needs to be built on an `Arch x86_64` system.

First clone the repo to your system.

    git clone --depth 1 https://bitbucket.org/archlabslinux/iso ~/Downloads/iso


Next make a directory to build the iso in. It can be anywhere you like, it's just a place to work.

    mkdir ~/build


Now you need to move the entire 'archlabs' folder into the new directory that you made.
**NOTE: It is very important that you do it as root**. Every file needs to be owned by `root`.
This can be done by opening a file manager as root, or from a terminal.

If you cloned the repo and made a directory as shown above, then you can run

    sudo cp -r ~/Downloads/iso/archlabs ~/build/

Before building, you will need to clean your pacman cache.
I know, nobody likes to do that, but it avoids problems.

    sudo pacman -Scc


Now just run the build script *(the -v is verbose, so it will show you more output.)*

    sudo ./build.sh -v


When it's finished, there will be a directory called `out`, the iso will be in there.


### Customization

In the archlabs folder, there is a file called `packages`
This file is a list of packages that will be included in the iso.
You can add or remove items from this list for them to be included or removed.


The `efiboot`, `isolinux`, and `syslinux` folders contain the files for configuring the boot
of the iso. If you want to change the background of the boot screen of the iso or any of the
entries you can do it by making the changes to the files in the `syslinux` folder. I'd leave
the `efiboot` folder alone, as well as the `isolinux` folder.


The `pacman.conf` file that is in the archlabs directory is the `pacman.conf` that is used when
building the iso. If you open the file, at the bottom there is the entry to the `archlabs_repo`
and the `archlabs_unstable` repo.


In the `airootfs` folder is the file system.

That is where you can add anything that you want to the iso.
Remember, **everything must be done as root**, if you add something, do it with as root or with
`sudo`.

When everything is added, go back to the `archlabs` directory. You will see a script called
`build.sh` that is the build script.


I know that I'm missing stuff, so feel free to ask questions.
