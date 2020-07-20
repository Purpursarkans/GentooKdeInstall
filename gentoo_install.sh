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

emerge --verbose --update --deep --newuse @world

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

emerge sys-kernel/gentoo-sources sys-kernel/linux-firmware sys-kernel/genkernel
emerge --verbose --update --deep --newuse @world

echo -e "/dev/sda2	/boot	vfat	defaults	0 2" >> /etc/fstab
genkernel all

echo -e "/dev/sda2   /boot        ext2    defaults,noatime     0 2\n/dev/sda3   /            ext4    noatime              0 1" >> /etc/fstab

rm -f /etc/conf.d/hostname
echo -d "hostname=\"potato-pc\"" >> /etc/conf.d/hostname

emerge --noreplace net-misc/netifrc

cd /etc/init.d
ln -s net.lo net.enp6s0 net.wlp7s0
rc-update add net.enp6s0 net.wlp7s0 default

echo -e "config_enp6s0=\"dhcp\"\nconfig_wlp7s0=\"dhcp\"" >> /etc/conf.d/net

rm -f /etc/conf.d/keymaps
echo -e "keymap=\"us\"\nwindowkeys=\"YES\"\nextended_keymaps=\"ru\"\ndumpkeys_charset=\"\"\nfix_euro=\"NO\"" >> /etc/conf.d/keymaps

rm -f /etc/conf.d/consolefont
echo -e "consolefont=\"cyr-sun16\"" >> /etc/conf.d/consolefont

emerge app-admin/sysklogd
rc-update add sysklogd default

emerge --noreplace sys-fs/e2fsprogs sys-fs/dosfstools net-misc/dhcpcd
emerge net-wireless/iw net-wireless/wpa_supplicant

emerge sys-boot/lilo

echo -e "#image=/boot/vmlinuz-4.9.16-gentoo\nlabel=gentoo\nread-only\nroot=/dev/sda3"
clear
echo -e "nano /etc/lilo.conf"
ls /boot
