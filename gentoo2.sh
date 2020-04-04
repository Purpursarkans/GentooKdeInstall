cd /mnt/gentoo
rm stage3-amd64-20200401T214502Z.tar.xz
wget https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20200401T214502Z.tar.xz
tar xpf stage3-amd64-20200401T214502Z.tar.xz --xattrs-include='*.*' --numeric-owner
