#!/bin/sh
user="hunter"
host="arch"
drive="/dev/nvme0n1"
bootdrive="${drive}p1"
cryptdrive="${drive}p2"
swap="8G"
micro="amd-ucode" 
network="iwd"
xinit="dwmblocks &\n~/.fehbg &\nexec dwm"
netenable() {
	sudo systemctl enable iwd.service	
	sudo systemctl enable systemd-timesyncd.service
}
if [[ $1 == setupchroot ]]
  then
    sed -i "/^HOOKS=/c\HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block lvm2 encrypt filesystems fsck)" /etc/mkinitcpio.conf
    ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
    hwclock --systohc
    sed -i '/en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
    echo "LANG=en_US.UTF-8" | tee /etc/locale.conf
    echo "$host" | tee /etc/hostname 
    locale-gen
    mkinitcpio -P
    bootctl install
    printf "default arch.conf\ntimeout 4\nconsole-mode max\neditor no" | tee /boot/loader/loader.conf
    printf "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /"$micro".img\ninitrd /initramfs-linux.img\noptions cryptdevice="$cryptdrive":crypt root=/dev/MyVolGroup/root" | tee /boot/loader/entries/arch.conf
    printf "[General]\nEnableNetworkConfiguration=True\n[Network]\nNameResolvingService=resolvconf" > /etc/iwd/main.conf
    printf "[IPv4]\nAddress=192.168.1.136\nNetmask=255.255.255.0\nGateway=192.168.1.1" > /var/lib/iwd/NETGEAR70.psk
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
    tail -n 6 /home/"$user"/.xinitrc | wc -c | xargs -I {} truncate /home/"$user"/.xinitrc -s -{}
    printf "$xinit" | tee -a /home/"$user"/.xinitrc
    echo ""$user" ALL=(ALL:ALL) ALL" | EDITOR='tee -a' visudo 
    chown -R "$user" /home/"$user"/repos
    rm /root/archinstall.sh
    exit
  else
    echo "Setup for wipe"
    sgdisk -Zo "$drive"
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
    reflector --country US --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
    pacstrap -K /mnt base base-devel git linux linux-firmware vim lvm2 "$micro" sudo xorg-server xorg-xinit xorg-xsetroot libx11 libxft libxinerama ttf-jetbrains-mono-nerd "$network" openresolv 
    genfstab -U /mnt >> /mnt/etc/fstab
    cp archinstallpc.sh /mnt/root/archinstall.sh
    chmod +x /mnt/root/archinstall.sh
    arch-chroot /mnt /root/archinstall.sh setupchroot
fi
