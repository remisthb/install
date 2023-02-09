#!/bin/sh
sgdisk -Zo "$drive"
cryptsetup luksFormat "$drive"
cryptsetup open --type plain -d /dev/urandom "$drive" crypt
dd if=/dev/zero of=/dev/mapper/crypt status=progress
cryptsetup close crypt

