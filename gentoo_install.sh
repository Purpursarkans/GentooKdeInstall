#!/bin/bash

(
  echo g;
  echo n;
  echo 1;
  echo;
  echo +2m;
  echo t;
  echo 4;
  echo n;
  echo 2;
  echo;
  echo +128m;
  echo n;
  echo 3;
  echo;
  echo;
  echo t;
  echo 2;
  echo 1;
  echo w;
) | fdisk /dev/sda

mkfs.fat -F 32 /dev/sda2
mkfs.ext4 /dev/sda3
mount /dev/sda3 /mnt/gentoo

ntpd -q -g

cd /mnt/gentoo
wget https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20200708T103427Z.tar.xz
tar xpf stage3-amd64-20200708T103427Z.tar.xz --xattrs-include='*.*' --numeric-owner

echo -e "MAKEOPTS=\"-j4\"\n\nGENTOO_MIRRORS=\"https://mirror.yandex.ru/gentoo-distfiles/\"" >> /mnt/gentoo/etc/portage/make.conf

mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/


mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev 



chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"

mount /dev/sda2 /boot
emerge-webrsync
emerge --sync --quiet

eselect profile list
eselect profile set 20

echo -e "WARNING!!!\ninstall sleep for 30 sec, check list"
sleep 30

emerge --ask --verbose --update --deep --newuse @world

echo "Europe/Saratov" > /etc/timezone
emerge --config sys-libs/timezone-data

echo -e "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

eselect locale list
eselect locale set 5

echo -e "WARNING!!!\ninstall sleep for 30 sec, check list"
sleep 30

env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
loadkeys ru
setfont cyr-sun16

echo -e "ACCEPT_LICENSE=\"-* @BINARY-REDISTRIBUTABLE\"" >> /etc/portage/make.conf

emerge sys-kernel/gentoo-sources
emerge --ask sys-kernel/linux-firmware
emerge sys-kernel/genkernel
emerge --verbose --update --deep --newuse @world

echo -e "/dev/sda2	/boot	vfat	defaults	0 2" >> /etc/fstab
genkernel all
