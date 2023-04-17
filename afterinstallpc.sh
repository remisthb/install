#!/bin/bash
sudo pacman -Syu
sudo pacman -S firefox xclip ranger pcmanfm p7zip openssh neofetch mpv man-pages man-db lxappearance htop feh bash-completion reflector wireguard-tools qbittorrent 
cd ~/repos
git clone https://github.com/remisthb/main
git clone https://github.com/remisthb/dwm
git clone https://github.com/remisthb/dmenu
git clone https://github.com/remisthb/st
git clone https://github.com/remisthb/dwmblocks
git clone https://aur.archlinux.org/yay-bin.git
cd ~/repos/dwm
sudo make clean
sudo make install
cd ~/repos/dmenu
sudo make clean
sudo make install
cd ~/repos/st
sudo make clean
sudo make install
cd ~/repos/dwmblocks
sudo make clean
sudo make install
cd ~/repos/yay-bin
makepkg -si
sudo rm ~/.bashrc
cp ~/repos/main/.bashrc ~/
cp ~/repos/main/.vimrc ~/
cp -a  ~/repos/main/.config ~/
rm -drf ~/repos/main
