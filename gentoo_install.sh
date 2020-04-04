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