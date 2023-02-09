#!/bin/sh
user="hunter"
host="arch"
drive="/dev/sda"
bootdrive="${drive}1"
cryptdrive="${drive}2"
swap="2G"
micro="amd-ucode" 
network="dhcpcd"
xinit="xrandr -s 1280x720 &\n~/.fehbg &\nexec dwm"
netenable() {
	sudo systemctl start dhcpcd.service 
	sudo systemctl enable dhcpcd.service	
}
if [[ $1 == setupchroot ]]
  then
    sed -i "/^HOOKS=/c\HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block lvm2 encrypt filesystems fsck)" /etc/mkinitcpio.conf
    ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
    hwclock --systohc
    sed -i '/en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
    echo "LANG=en_US.UTF-8" | tee /etc/locale.conf
    echo "$host" | tee /etc/hostname 
    mkinitcpio -P
    bootctl install
    printf "default arch.conf\ntimeout 4\nconsole-mode max\neditor no" | tee /boot/loader/loader.conf
    printf "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /"$micro".img\ninitrd /initramfs-linux.img\noptions cryptdevice="$cryptdrive":crypt root=/dev/MyVolGroup/root" |tee /boot/loader/entries/arch.conf
    echo "Set root password"
    passwd
    useradd -m -G wheel "$user"
    echo "Set user password"
    passwd "$user"
    netenable  
    mkdir /home/"$user"/repos
    cd /home/"$user"/repos
    git clone https://github.com/remisthb/install
    cp /etc/X11/xinit/xinitrc /home/"$user"/.xinitrc
    tail -n 8 /home/"$user"/.xinitrc | wc -c | xargs -I {} truncate /home/"$user"/.xinitrc -s -{}
    print {"$xinit"} | tee -a /home/"$user"/.xinitrc
    echo '$user ALL=(ALL:ALL) ALL' | EDITOR='tee -a' visudo 
    rm /root/archinstall.sh
    exit
  else
    echo "Setup for wipe"
    sgdisk -n 1:2048:+512M -t 1:ef00 -c 1:boot "$drive"
    sgdisk -n 2:0:0 -t 2:8300 -c 2:root "$drive"
    echo "Choose drive encryption password"
    cryptsetup luksFormat "$cryptdrive"
    echo "Open drive with encryption password"
    cryptsetup open "$cryptdrive" crypt
    pvcreate /dev/mapper/crypt
    vgcreate MyVolGroup /dev/mapper/crypt
    lvcreate -L "$swap" MyVolGroup -n swap
    lvcreate -l 100%FREE MyVolGroup -n root
    lvreduce -L -256M MyVolGroup/root
    mkfs.ext4 /dev/MyVolGroup/root
    mkswap /dev/MyVolGroup/swap
    mkfs.fat -F 32 "$bootdrive"
    mount /dev/MyVolGroup/root /mnt
    swapon /dev/MyVolGroup/swap 
    mount --mkdir "$bootdrive" /mnt/boot
    reflector --country US --age 24 --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    pacstrap -K /mnt base base-devel git linux linux-firmware vim lvm2 "$micro" sudo xorg-server xorg-xinit xorg-xsetroot libx11 libxft libxinerama ttf-jetbrains-mono-nerd "$network" 
    genfstab -U /mnt >> /mnt/etc/fstab
    cp archinstall.sh /mnt/root/archinstall.sh
    chmod +x /mnt/root/archinstall.sh
    arch-chroot /mnt /root/archinstall.sh setupchroot
fi
