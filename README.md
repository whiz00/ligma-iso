# Archlabs-Iso

Source for ArchLabs iso builds


### Building the iso

Make sure that you have the package `archiso` installed and it must build on an `Arch x86_64` system.

Clone the Archlabs-Iso repo onto your system.

    git clone https://github.com/ARCHLabs/Archlabs-Iso


Make a directory to build the iso in. It can be in your home directory, it's just a place to work.
I usually just make a directory called 'build' in my home folder.


You need to move the entire 'archlabs' folder into the new directory that you made,
but it is very important that you do it as root. Every file needs to be owned by `root`.
You can do this by opening a file manager as root. Or from the command line.

If you cloned the repo to `~/Downloads` and made a working directory called 'build'

    sudo cp -r ~/Downloads/Archlabs-Iso/archlabs ~/build/


In the archlabs folder, there is a file called packages.both
This file is a list of packages that will be included in the iso.
You can add or remove items from this list for them to be included or removed.


The efiboot, isolinux, and syslinux folders contain the files for configuring the boot
of the iso. If you want to change the background of the boot screen of the iso or any of the
entries you can do it by making the changes to the files in the syslinux folder. I'd leave
the efiboot folder alone, as well as the isolinux folder.


The pacman.conf file that is in the archlabs directory is the pacman.conf that is used only when
building the iso. If you open the file, at the bottom there is the entry to the archlabs repo.


In the airootfs folder is the file system.

That is where you can add anything that you want to the iso. Remember, everything must be
done as root, so if you add something, do it as root or by using sudo.

When everything is added, go back to the archlabs directory. You will see a script called
build.sh that is the build script.

Before building, you will need to clean out the pacman cache.
I know, nobody likes to do that, but it avoids problems.

    sudo pacman -Scc

Now just run: *(the -v is verbose, so it will show you more output.)*

    sudo ./build.sh -v


When it's finished, there will be a directory called out, and the iso will be in there.

I know that I'm missing stuff, so feel free to ask questions.

Hope this helps.
