#!/bin/bash

url=https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds
version=latest-stage3-amd64.txt
archive=$(curl -s $url/$version | grep -v "^#" | cut -d" " -f1)

read -p "write part of install(1 or 2): " rd

label1(){

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

mkfs.fat -F 32 /dev/sda5
mkfs.ext4 /dev/sda6
mount /dev/sda6 /mnt/gentoo

ntpd -q -g

cp JvbMD /mnt/gentoo/JvbMD

cd /mnt/gentoo

wget $url/$archive
tar xpf $(basename $archive) --xattrs-include='*.*' --numeric-owner
rm -f $(basename $archive)


echo -e "MAKEOPTS=\"-j4\"\n\nGENTOO_MIRRORS=\"https://mirror.yandex.ru/gentoo-distfiles/\"" >> /mnt/gentoo/etc/portage/make.conf

mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/


mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev 
}


label2(){

source /etc/profile
#export PS1="(chroot) ${PS1}"

mount /dev/sda5 /boot
emerge-webrsync
emerge --sync --quiet

eselect profile set 20
eselect profile list



echo "Europe/Saratov" > /etc/timezone
emerge --config sys-libs/timezone-data

echo -e "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

eselect locale set 5
eselect locale list



emerge --verbose --update --deep --newuse @world


env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
loadkeys ru
setfont cyr-sun16

echo -e "ACCEPT_LICENSE=\"-* @BINARY-REDISTRIBUTABLE\"" >> /etc/portage/make.conf

emerge sys-kernel/gentoo-sources sys-kernel/linux-firmware sys-kernel/genkernel

echo -e "/dev/sda5	/boot	vfat	defaults,noatime	0 2\n" >> /etc/fstab
genkernel all

echo -e "/dev/sda6   /            ext4    noatime              0 1" >> /etc/fstab

rm -f /etc/conf.d/hostname
echo -e "hostname=\"potato-pc\"" >> /etc/conf.d/hostname

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

echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
emerge sys-boot/grub:2
}

if [ "$rd" == "1" ]; then label1; fi
if [ "$rd" == "2" ]; then label2; fi
