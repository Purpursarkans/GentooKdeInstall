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
