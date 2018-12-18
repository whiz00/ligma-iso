#!/usr/bin/env bash

set -e

sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 750 /root /etc/sudoers.d

cat >> /root/.zshrc << EOF
[[ \$SHLVL -eq 1 ]] && printf "\n Welcome, thank you for trying out ArchLabs Linux.\n\n\n To start the install simply run: archlabs-installer\n\n"
EOF

systemctl enable systemd-timesyncd.service NetworkManager.service
sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh

gpg --receive-keys C1A60EACE707FDA5
pacman-key --init
pacman-key --populate archlinux
pacman-key --populate archlabs
pacman -Rs nano --noconfirm
pacman -Sy
