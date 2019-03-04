#!/bin/bash

# TODO
# Kubernetes, /tmp, SELinux

IMAGE_DIR=/images
mkdir -p ${IMAGE_DIR}

IMAGE="${IMAGE_DIR}/centos7-test.img"
ROOT_FS_TAR="${IMAGE_DIR}/centos7.tar.gz"
BOOTDEVICE=/dev/xvdf
BINDMNTS="dev sys etc/hosts etc/resolv.conf dev/disk"
ROOTFS=/newroot

# If running on EC2, minimally install these packages to be able to do the
# rest
apt-get update
apt-get install -y \
  dosfstools \
  curl \
  parted \
  udev \
  xfsprogs

mkdir -p /images

# This was being used when this script was writing an image file instead of
# to a host attached volume
# BOOTDEVICE=$(losetup -f)
#rm -f ${IMAGE}
#truncate -s 10G ${IMAGE}
#losetup ${BOOTDEVICE} ${IMAGE}

echo Creating GPT
parted ${BOOTDEVICE} --script mklabel gpt
parted ${BOOTDEVICE} disk_toggle pmbr_boot

echo Creating BIOS boot partion
parted ${BOOTDEVICE} --script mkpart primary 1MiB 2MiB
parted ${BOOTDEVICE} --script set 1 bios_grub on

echo Creating EFI System Partition
parted ${BOOTDEVICE} --script mkpart primary fat32 2MiB 200MiB
parted ${BOOTDEVICE} --script set 2 esp on
parted ${BOOTDEVICE} --script set 2 boot on
parted ${BOOTDEVICE} --script name 2 efi

echo Creating boot partition
parted ${BOOTDEVICE} --script mkpart primary ext4 200MiB 1200MiB
parted ${BOOTDEVICE} --script name 3 boot
parted ${BOOTDEVICE} --script set 3 legacy_boot on


echo Creating root partition
parted ${BOOTDEVICE} --script mkpart primary xfs 1200MiB 3200MiB
parted ${BOOTDEVICE} --script name 4 root

echo Creating home partition
parted ${BOOTDEVICE} --script mkpart primary xfs 3200Mib 4200MiB
parted ${BOOTDEVICE} --script name 5 home


echo Creating log partition
parted ${BOOTDEVICE} --script mkpart primary xfs 4200Mib 5200MiB
parted ${BOOTDEVICE} --script name 6 log

echo Creating Audit partition
parted ${BOOTDEVICE} --script mkpart primary xfs 5200MiB 6200MiB
parted ${BOOTDEVICE} --script name 7 audit

echo Creating var partition
parted ${BOOTDEVICE} --script mkpart primary xfs 6200MiB 100%
parted ${BOOTDEVICE} --script name 8 var

lsblk
parted ${BOOTDEVICE} print

echo Formatting partitions

# This is racy, leading to the sleep.
# Replace with retries. Probably rewrite in Golang to avoid Bash loop hell
partprobe ${BOOTDEVICE}
sleep 5
ls /dev

# ${PARTITION_PREFIX} varies across distros due to udev rules. Even affects
# running inside a Docker instance as udev rules are external.
# When running on an Ubuntu host, PARTITION_PREFIX should be "", for Fedora,
# it should be "p"
mkfs.vfat ${BOOTDEVICE}${PARTITION_PREFIX}2
mkfs.ext4 ${BOOTDEVICE}${PARTITION_PREFIX}3
mkfs.xfs -f ${BOOTDEVICE}${PARTITION_PREFIX}4
mkfs.xfs -f ${BOOTDEVICE}${PARTITION_PREFIX}5
mkfs.xfs -f ${BOOTDEVICE}${PARTITION_PREFIX}6
mkfs.xfs -f ${BOOTDEVICE}${PARTITION_PREFIX}7
mkfs.xfs -f ${BOOTDEVICE}${PARTITION_PREFIX}8

mkdir ${ROOTFS}
mount ${BOOTDEVICE}${PARTITION_PREFIX}4 /${ROOTFS}
mkdir /${ROOTFS}/boot
mount ${BOOTDEVICE}${PARTITION_PREFIX}3 /${ROOTFS}/boot
mkdir ${ROOTFS}/boot/efi
mount ${BOOTDEVICE}${PARTITION_PREFIX}2 ${ROOTFS}/boot/efi
mkdir /${ROOTFS}/home
mount ${BOOTDEVICE}${PARTITION_PREFIX}5 /${ROOTFS}/home
mkdir /${ROOTFS}/var
mount ${BOOTDEVICE}${PARTITION_PREFIX}8 /${ROOTFS}/var
mkdir /${ROOTFS}/var/log
mount ${BOOTDEVICE}${PARTITION_PREFIX}6 /${ROOTFS}/var/log
mkdir /${ROOTFS}/var/log/audit
mount ${BOOTDEVICE}${PARTITION_PREFIX}7 /${ROOTFS}/var/log/audit

curl "https://s3.amazonaws.com/test.boot-image.vmware.dev/centos7.tar.gz" -o "${ROOT_FS_TAR}"
tar -C ${ROOTFS} -xzf ${ROOT_FS_TAR}
echo "Root FS Untarred"

for d in $BINDMNTS ; do
  mount --bind /${d} ${ROOTFS}/${d}
done

mount -t proc none ${ROOTFS}/proc

# TODO: Fix this, there are other file contexts to be written.
echo "Relabelling filesystem"
chroot ${ROOTFS} /sbin/setfiles -F /etc/selinux/targeted/contexts/files/file_contexts /

echo "Installing boot manager"
chroot ${ROOTFS} grub2-install --target=i386-pc ${BOOTDEVICE}
chroot ${ROOTFS} grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
chroot ${ROOTFS} grub2-mkconfig -o /boot/grub2/grub.cfg
# Grub will create an EFI config if it is running on an EFI booted host due
# to EFI detection in /proc. A sed switches this to the correct type for BIOS
# boot.
chroot ${ROOTFS} sed -i 's/linuxefi/linux/' /boot/grub2/grub.cfg
chroot ${ROOTFS} sed -i 's/initrdefi/initrd/' /boot/grub2/grub.cfg

# Disable SELinux as labels are still incorrect
chroot ${ROOTFS} sed -i -e 's/^\(SELINUX=\).*/\1disabled/' /etc/selinux/config

# A debug shell to check everything's ok
# chroot ${ROOTFS} /bin/bash

echo "Unmounting filesystems"
umount ${ROOTFS}/var/log/audit
umount ${ROOTFS}/var/log
umount ${ROOTFS}/var
umount ${ROOTFS}/home
umount ${ROOTFS}/boot/efi
umount ${ROOTFS}/boot
umount ${ROOTFS}/sys
umount ${ROOTFS}/dev/disk
umount ${ROOTFS}/dev
umount ${ROOTFS}/proc
umount ${ROOTFS}/etc/hosts
umount ${ROOTFS}/etc/resolv.conf
umount ${ROOTFS}

# Remove the loop device if writing an image file
#losetup -d ${BOOTDEVICE}
