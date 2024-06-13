#!/bin/bash

# Detect the block device dynamically
busy=$(lsblk | grep part | awk '{ print $1 }' | head -1 | cut -b 7-13)
free=$(lsblk | grep -v ${busy} | grep -v NAME | awk '{ print $1 }')

# Partition disk
/usr/sbin/parted --script -a optimal -- ${free} mklabel gpt mkpart primary 1MiB -1
sleep 2

# Create Filesystem
mkfs.xfs -i size=512 "${free}p1"

# Add to /etc/fstab, mount filesystem, and create brick subdirectory
UUID=$(blkid "${free}p1" | cut -d \" -f 2)
echo "UUID=$UUID /gfs xfs rw,inode64,noatime,nouuid 1 2" >> /etc/fstab
mkdir /gfs
mount /gfs
mkdir /gfs/brick-1
touch /tmp/brick_done
