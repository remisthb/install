#!/bin/bash
sudo pacman -Syu
sudo pacman -S firefox xclip ranger picom pcmanfm p7zip openssh neofetch mpv man-pages man-db lxappearance htop feh bash-completion reflector wireguard-tools
#sudo pacman -S lightdm lightdm-gtk-greeter
#sudo pacman -S i3 polybar
#sudo pacman -S firefox qbittorrent
cd ~/repos
git clone https://github.com/remisthb/main
git clone https://github.com/remisthb/dwm
git clone https://github.com/remisthb/dmenu
git clone https://github.com/remisthb/st
git clone https://github.com/remisthb/dwmblocks
cd ~/repos/dwm
make clean
sudo make install
cd ~/repos/dmenu
make clean
sudo make install
cd ~/repos/st
make clean
sudo make install
cd ~/repos/dwmblocks
make clean
sudo make install
rm ~/.bashrc
cp ~/repos/main/.bashrc ~/
cp ~/repos/main/.vimrc ~/
cp -a  ~/repos/main/.config ~/
rm -drf ~/repos/main
