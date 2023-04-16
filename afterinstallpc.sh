#!/bin/bash
sudo pacman -Syu
sudo pacman -S firefox xclip ranger pcmanfm p7zip openssh neofetch mpv man-pages man-db lxappearance htop feh bash-completion reflector wireguard-tools qbittorrent 
#sudo pacman -S lightdm lightdm-gtk-greeter
#sudo pacman -S i3 polybar
cd ~/repos
git clone https://github.com/remisthb/main
git clone https://github.com/remisthb/dwm
git clone https://github.com/remisthb/dmenu
git clone https://github.com/remisthb/st
cd ~/repos/dwm
sudo make clean install
cd ~/repos/dmenu
sudo make clean install
cd ~/repos/st
sudo make clean install
rm ~/.bashrc
cp ~/repos/main/.bashrc ~/
cp ~/repos/main/.vimrc ~/
cp -a  ~/repos/main/.config ~/
rm -drf ~/repos/main
