#!/bin/bash

# Detect the block device dynamically
block_device=$(lsblk -dpno NAME,TYPE | awk '$2=="disk" && $1!~/nvme[0-9]n1$/ {print $1}')

# Partition disk
/usr/sbin/parted --script -a optimal -- ${block_device} mklabel gpt mkpart primary 1MiB -1
sleep 2

# Create Filesystem
mkfs.xfs -i size=512 "${block_device}p1"

# Add to /etc/fstab, mount filesystem, and create brick subdirectory
UUID=$(blkid "${block_device}p1" | cut -d \" -f 2)
echo "UUID=$UUID /gfs xfs rw,inode64,noatime,nouuid 1 2" >> /etc/fstab
mkdir /gfs
mount /gfs
mkdir /gfs/brick-1
touch /tmp/brick_done
