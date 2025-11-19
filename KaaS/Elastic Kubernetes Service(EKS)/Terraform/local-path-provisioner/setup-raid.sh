#!/bin/bash
set -ex

# Install NVMe CLI
yum install nvme-cli -y

# Get list of NVMe Drives
nvme_drives=$(nvme list | grep "Amazon EC2 NVMe Instance Storage" | cut -d " " -f 1 || true)
readarray -t nvme_drives <<< "$nvme_drives"
num_drives=${#nvme_drives[@]}

# Install software RAID utility
yum install mdadm -y

# Create RAID-0 array across the instance store NVMe SSDs
mdadm --create /dev/md0 --level=0 --name=md0 --raid-devices=$num_drives "${nvme_drives[@]}" --force

# Format drive with Ext4
mkfs.ext4 /dev/md0

# Get RAID array's UUID
uuid=$(blkid -o value -s UUID /dev/md0)

# Create a filesystem path to mount the disk
mount_location="/mnt/fast-disks/$uuid"
mkdir -p $mount_location

# Mount RAID device
mount /dev/md0 $mount_location

# Have disk be mounted on reboot
mdadm --detail --scan >> /etc/mdadm.conf 
echo /dev/md0 $mount_location ext4 defaults,noatime 0 2 >> /etc/fstab
