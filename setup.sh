dir="/home/$1/ligma-iso"
pacman -Scc
mkdir -pv $dir/build
cp -r $dir/src $dir/build/
cd $dir/build/
./build
