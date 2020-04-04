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
  echo w;
) | fdisk /dev/sda

mkfs.vfat /dev/sda2
mkfs.ext4 /dev/sda3
mount /dev/sda3 /mnt/gentoo
ntpd -q -g
cd /mnt/gentoo
wget https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20200401T214502Z.tar.xz

tar xpf stage3-amd64-20200401T214502Z.tar.xz --xattrs-include='*.*' --numeric-owner
