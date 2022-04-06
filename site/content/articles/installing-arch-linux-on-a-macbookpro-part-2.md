---
title: "Installing Arch Linux on a MacBookPro - Part 2"
date: 2021-01-08T00:00:00-06:00
draft: false
description: This is part two of a three part series on how to install macOS Big Sur and Arch Linux on a MacBookPro11,3.
---

## Overview
This is part two of a three part series on how to install macOS Big Sur and Arch Linux on a MacBookPro11,3:

* [Installing Arch Linux on a MacBook Pro - Part 1](https://nickolaskraus.org/articles/installing-arch-linux-on-a-macbookpro-part-1/)
* [Installing Arch Linux on a MacBook Pro - Part 2](https://nickolaskraus.org/articles/installing-arch-linux-on-a-macbookpro-part-2/)
* [Installing Arch Linux on a MacBook Pro - Part 3](https://nickolaskraus.org/articles/installing-arch-linux-on-a-macbookpro-part-3/)

## Installing Arch Linux
### Step 1: Set the keyboard layout
Available keymap files can be listed with:

```bash
ls /usr/share/kbd/keymaps/**/*.map.gz
```

Or with the following command:

```bash
localectl list-keymaps
```

To modify the keyboard layout, append a corresponding file name to `loadkeys`, omitting the path and file extension or use `localectl set-keymap`.

### Step 2: Verify the boot mode
To verify the boot mode, list the `efivars`:

```bash
ls /sys/firmware/efi/efivars
```

If this directory exists, you have a UEFI-enabled system and the system is booted in UEFI mode.

**Note**: You can also list UEFI variables using the following:

```bash
efivars --list
```

### Step 3: Connect to the internet
#### Wired
The easiest way to establish an internet connect is via a [Thunderbolt Ethernet adapter](https://www.amazon.com/gp/product/B011K4RKFW) or [USB-to-Ethernet adapter](https://www.amazon.com/dp/B00W7W9FK0/). These adapters are usually picked up automatically. If you are using a Thunderbolt Ethernet adapter, you may need to power on the machine with the adapter plugged in for it to be picked up by the system.

#### Wireless
Depending on your model of MacBookPro, you may have the Broadcom BCM43602 single-chip dual-band transceiver, which is supported by the open source [brcm80211](https://wiki.archlinux.org/index.php/Broadcom_wireless#brcm80211) module that is built-in to the Linux kernel and typically enabled by default.

Other BCM43XX chipsets may only be supported by a proprietary driver such as [b43](https://wiki.archlinux.org/index.php/Broadcom_wireless#b43) or [broadcom-wl](https://wiki.archlinux.org/index.php/Broadcom_wireless#broadcom-wl).

The [broadcom-wl](https://www.archlinux.org/packages/?name=broadcom-wl) package is included in the Arch Linux installer, but may need to be manually enabled before the chipset will function correctly. The b43 driver is also built-in to the kernel and included in the installation media, but it requires external proprietary firmware from the [b43-firmware](https://aur.archlinux.org/packages/b43-firmware/) AUR package which will need to be downloaded from another machine connected to the internet.

You can list the network interfaces available from the installer environment by running `ip link show`. If you can see your wireless interface in the list (ex `wlan0`), you should now be able to use [`iwctl`](https://wiki.archlinux.org/index.php/Iwd#iwctl) to select and connect to a wireless network.

If the virtual loopback interface is the only listed interface, you may need to load an alternative Broadcom driver. To do this, begin by ensuring that all Broadcom drivers have been unloaded.

```bash
rmmod b43
rmmod bcma
rmmod ssb
rmmod wl
```

Add the `bcma` module:

```bash
modprobe bcma
```

If you still cannot see your wireless interface, remove the `bcma` module and add the `wl` module:

```bash
rmmod bcma && modprobe wl
```

Use `iwctl` to connect to Wi-Fi.

The connection may be verified with `ping`:

```bash
ping -c 1 archlinux.org
```

**Note:** If you used the `wl` or `b43` drivers, they will need to be manually installed to your new Arch system, this can be done by synchronizing the [broadcom-wl](https://www.archlinux.org/packages/?name=broadcom-wl)/[broadcom-wl-dkms](https://www.archlinux.org/packages/?name=broadcom-wl-dkms) or [b43-firmware](https://aur.archlinux.org/packages/b43-firmware/) AUR packages as necessary, either during setup or after booting into your new Arch system.
We will install the [broadcom-wl](https://archlinux.org/packages/?name=broadcom-wl) package when configuring the network.

**Note**: I was only able to get the onboard wireless adapter to work using the broadcom-wl module.

**Note**: To determine the Broadcom chipset on your MacBookPro, go to  > **About This Mac** > **System Report…** > **Network** > **Wi-Fi**. Obviously, this must be done while booted into macOS.

**Note**: In the installation image, [systemd-networkd](https://wiki.archlinux.org/index.php/Systemd-networkd), [systemd-resolved](https://wiki.archlinux.org/index.php/Systemd-resolved) and [iwd](https://wiki.archlinux.org/index.php/Iwd) are preconfigured and enabled by default. That will not be the case for the installed system. The configuration files for these packages can be found at the following locations:

* `/etc/systemd/network/20-ethernet.network`
* `/etc/systemd/network/20-wireless.network`
* `/etc/resolv.conf`

### Step 4: Update the system clock
Use `timedatectl` to ensure the system clock is accurate:

```bash
timedatectl set-ntp true
```

To check the service status, run `timedatectl status`.

### Step 5: Partition the disk
Since we have already partitioned the disk using Disk Utility, it is not necessary to repartition the disk.

If you *were* to partition or modify the disk partition table, you would run the following:

```bash
fdisk /dev/sda
```

`fdisk` is a dialog-driven program for creation and manipulation of partition tables.

To show the disk partition table, use `fdisk`:

```bash
fdisk -l
```

To list block devices, use `lsblk`:

```bash
lsblk
```

To install Arch Linux, the following partitions are required:

* One partition for the EFI system partition.
* One partition for the root directory `/`.

Having already partitioned the disk, the following partitions should exist:

* EFI System (EFI system partition)
* Apple APFS (macOS)
* Apple APFS (Arch Linux)

When installing Arch Linux on a UEFI-enabled system, the partition, mount point, partition type, and size requirements are as follows:

* EFI System (EFI system partition)
	* **Mount Point**: `/mnt/boot` or `/mnt/efi`
	* **Partition Type**: EFI System
	* **Suggested Size**: At least 260 MiB
* Root Partition (Arch Linux)
	* **Mount Point**: `/mnt`
	* **Partition Type**: Linux root (x86-64)
	* **Suggested Size**: Remainder of the device

Currently, our Root Partition is of type Apple APFS. To change the partition type to Linux root (x86-64), run `fdisk /dev/sda`:

1. Print the `fdisk` menu (`m`).
2. Print the partition table (`p`).
3. Select `t` to change a partition type.
4. Select the partition.
5. Determine the partition type or alias (select `L`, then locate Linux root (x86-64)).
6. Write table to disk and exit (`w`).

**Note**: The partition type of the *Arch Linux* partition does not matter, as it will be reformatted.

**Note**: The **Arch Linux** partition will be used for the root directory.

### Step 6: Format the partition
Once the partitions have been created, each newly created partition must be formatted with an appropriate file system. To create an Ext4 file system on `/dev/<root_partition>`, run:

```bash
mkfs.ext4 /dev/<root_partition> -L "Arch"
```

**Note**: `root_partition` should be the *Arch Linux* partition. Use `fdisk -l` to show the disk partition table.

**Note**: The `-L` option is given to set the volume label. This is useful when creating the `fstab` file and boot loader entry.

### Step 7: Mount the root partition and EFI system partition
Mount the root partition to `/mnt`:

```bash
mount /dev/<root_partition> /mnt
```

Mount the EFI system partition to `/mnt/boot`:

```bash
mkdir -p /mnt/boot
mount /dev/<efi_partition> /mnt/boot
```

**Note**: The EFI system partition will contain the systemd-boot boot loader that is launched by the UEFI firmware.

**Note**: It is *very* important that you mount the EFI system partition correctly. If the EFI system partition is not mounted to `/boot`, the installation will not create the initial ramdisk environment for booting the Linux kernel in the correct location.

### Step 8: Select mirrors
In order to installed packages quickly, you will need to update the mirror servers located in `/etc/pacman.d/mirrorlist`. This can be done using [reflector](https://xyne.archlinux.ca/projects/reflector/).

**Note**: `reflector` should already be installed on the live installation.

Retrieve a list of the latest Arch Linux mirrors:

```bash
reflector -c "US" -f 10 -l 10 -n 10 --save /etc/pacman.d/mirrorlist
```

**Note**: Run `reflector --help` for documentation on the arguments given above.

**Note**: `/etc/pacman.d/mirrorlist` will be copied to the new system using `pacstrap`, so it is worth getting right..

### Step 9: Install the Linux kernel
Use the `pacstrap` script to install the following packages:

* **base**: Minimal package set to define a basic Arch Linux installation
* **linux**: The Linux kernel and modules
* **linux-firmware**: Firmware files for Linux

```bash
pacstrap /mnt base linux linux-firmware
```

**Note**: `pacstrap` is used to install packages to a specified root directory (ex. `/mnt`).

**Note**: `pacman` can be used to gather information about packages using the `-Q` option:

```bash
pacman -Q --info <package>
```

The [base](https://archlinux.org/packages/?name=base) package does not install the packages included in the live installation. Therefore, installing other packages may be necessary for a fully functional base system.

These packages can be installed via `pacstrap`:

```bash
pacstrap /mnt <package>
```

Or via `pacman` while [chrooted](https://en.wikipedia.org/wiki/Chroot) into the new system.

For comparison, packages available in the live installation can be found here ([packages.x86_64](https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/configs/releng/packages.x86_64)). We will install necessary packages in part three.

Continue to [Installing Arch Linux on a MacBook Pro - Part 3](https://nickolaskraus.org/articles/installing-arch-linux-on-a-macbookpro-part-3/)
