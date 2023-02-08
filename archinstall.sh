#!/bin/bash
user="hunter"
host="arch"
drive="/dev/sda"
bootdrive="${drive}1"
cryptdrive="${drive}2"
swap="2G"
micro="amd-ucode" 
cryptsetup luksFormat "$drive"
cryptsetup open --type plain -d /dev/urandom "$drive" crypt
dd if=/dev/zero of=/dev/mapper/crypt status=progress 
cryptsetup close crypt
sgdisk -Zo "$cryptdrive"
sgdisk -n 1:2048:+512M -t 1:ef00 -c 1:boot "$drive"
sgdisk -n 2:0:0 -t 2:8300 -c 2:root "$drive"
cryptsetup luksFormat "$cryptdrive"
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
pacstrap -K /mnt base base-devel git linux linux-firmware iwd vim lvm2 "$micro" 
genfstab -U /mnt >> /mnt/etc/fstab

