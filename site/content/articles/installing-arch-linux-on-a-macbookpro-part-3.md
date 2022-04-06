---
title: "Installing Arch Linux on a MacBookPro - Part 3"
date: 2021-01-15T00:00:00-06:00
draft: false
description: This is part three of a three part series on how to install macOS Big Sur and Arch Linux on a MacBookPro11,3.
---

## Overview
This is part three of a three part series on how to install macOS Big Sur and Arch Linux on a MacBookPro11,3:

* [Installing Arch Linux on a MacBook Pro - Part 1](https://nickolaskraus.org/articles/installing-arch-linux-on-a-macbookpro-part-1/)
* [Installing Arch Linux on a MacBook Pro - Part 2](https://nickolaskraus.org/articles/installing-arch-linux-on-a-macbookpro-part-2/)
* [Installing Arch Linux on a MacBook Pro - Part 3](https://nickolaskraus.org/articles/installing-arch-linux-on-a-macbookpro-part-3/)

## Configuring Arch Linux
### Step 1: Generate an `fstab` file
Make a backup of `fstab`:

```bash
cp /mnt/etc/fstab /mnt/etc/fstab.bak
```

Generate output for the `fstab` file (use `-U` or `-L` to use [UUIDs](https://wiki.archlinux.org/index.php/UUID) or labels for source identifiers, respectively):

```bash
genfstab -L /mnt >> /mnt/etc/fstab
```

### Step 2: Chroot into the new system
Change root (`chroot`) into the new system:

```bash
arch-chroot /mnt
```

### Step 3: Install necessary packages
Download a fresh copy of the master package database from the server(s) defined in `pacman.conf`:

```bash
pacman -Sy
```

Install necessary packages:

```bash
pacman -S man-db man-pages vim
```

**Note**: Packages included in the live installation are **not** included on the new system.

### Step 4: Set the time zone
Set the time zone:

```bash
timedatectl set-timezone <region>/<city>
```

For a list of available time zones, run:

```bash
timedatectl list-timezones
```

Set the RTC ([real-time clock](https://man7.org/linux/man-pages/man4/rtc.4.html)) from the system time:

```bash
hwclock --systohc
```

### Step 5: Configure localization
Make a backup of `locale.gen`:

```bash
cp /etc/locale.gen /etc/locale.gen.bak
```

Edit `/etc/locale.gen` and uncomment `en_US.UTF-8 UTF-8` and any other needed locales.

Run the `locale-gen` command to generate the locales, placing them in `/usr/lib/locale`:

```bash
locale-gen
```

Set the system locale by creating a `/etc/locale.conf` and adding the following line:

`/etc/locale.conf`

```
LANG=<locale>
```

**Note**: A list of valid locales can be found in `/etc/locale.gen`.

If you set the keyboard layout, make the changes persistent in `vconsole.conf`:

`/etc/vconsole.conf`

```
KEYMAP=<keymap>
```

**Note**: A list of valid keymaps can be found by running `localectl list-keymaps`.

**Note**: Locales are used by [glibc](https://archlinux.org/packages/?name=glibc) and other locale-aware programs or libraries for rendering text, correctly displaying regional monetary values, time and date formats, alphabetic idiosyncrasies, and other locale-specific standards.

### Step 6: Configure network
Create the `hostname` file:

`/etc/hostname`

```
<hostname>
```

Create the `hosts` file:

`/etc/hosts`

```
127.0.0.1    localhost
::1          localhost
127.0.1.1    <hostname>.localdomain    <hostname>
```

**Note:** The installation image uses [systemd-networkd](https://wiki.archlinux.org/index.php/Systemd-networkd) and [systemd-resolved](https://wiki.archlinux.org/index.php/Systemd-resolved). systemd-networkd configures a DHCP client for [wired](https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/configs/releng/airootfs/etc/systemd/network/20-ethernet.network) and [wireless](https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/configs/releng/airootfs/etc/systemd/network/20-wireless.network) network interfaces. These must be enabled and configured on the new system.

Install [iwd](https://wiki.archlinux.org/index.php/Iwd):

```bash
pacman -S iwd
```

Install [broadcom-wl](https://wiki.archlinux.org/index.php/Broadcom_wireless):

```bash
pacman -S broadcom-wl
```

Configure [systemd-networkd](https://wiki.archlinux.org/index.php/Systemd-networkd):

`/etc/systemd/network/20-ethernet.network`

```ini
[Match]
Name=en*
Name=eth*

[Network]
DHCP=yes
IPv6PrivacyExtensions=yes

[DHCP]
RouteMetric=512
```

`/etc/systemd/network/20-wireless.network`

```ini
[Match]
Name=wlp*
Name=wlan*

[Network]
DHCP=yes
IPv6PrivacyExtensions=yes

[DHCP]
RouteMetric=1024
```

Configure [systemd-resolved](https://wiki.archlinux.org/index.php/Systemd-resolved):

```bash
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

Ensure systemd-networkd, systemd-resolved, and iwd start on boot:

```bash
systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service
systemctl enable iwd
```

### Step 7: Set the root password
Set the root password:

```bash
passwd
```

### Step 8: Install and configure a boot loader
Apple's native EFI boot loader reads `.efi` files located within the EFI system partition (`/mnt/boot`) at `$ESP/EFI/BOOT/BOOTX64.EFI`. Fortunately, this is also the default install location for the systemd-boot binary. This means that booting Arch Linux using systemd-boot is very simple.

**Note**: The EFI system partition should be mounted to `/mnt/boot` (`/boot` within the new system).

**Note**: systemd-boot is the recommended boot loader for systems that support UEFI.

1. Ensure the EFI system partition is mounted:

    ```bash
    ls /boot
    ```

2. Install systemd-boot into the EFI system partition:

    ```bash
    bootctl install
    ```

This command installs systemd-boot into the EFI system partition. A copy of systemd-boot will be stored as the EFI default/fallback loader at `$ESP/EFI/BOOT/BOOT*.EFI`. The loader is then added to the top of the firmware's boot loader list.

#### Configure systemd-boot
systemd-boot is a simple UEFI boot manager, which executes configured EFI images. The default entry is selected by a configured pattern (glob) or an on-screen menu navigated via arrow-keys. It is included with systemd, which is installed on Arch Linux systems by default.

The loader configuration is stored in the file `$ESP/loader/loader.conf`.

`$ESP/loader/loader.conf`

```
default arch.conf
timeout 3
```

systemd-boot will search for boot menu items in `$ESP/loader/entries/*.conf`.

`$ESP/loader/entries/arch.conf`

```
title      Arch Linux
linux      /vmlinuz-linux
initrd     /intel-ucode.img
initrd     /initramfs-linux.img
options    root="LABEL=Arch"
```

**Note**: An example entry file is located at `/usr/share/systemd/bootctl/arch.conf`.

### Step 9: Reboot
Exit the chrooted environment by typing `exit`.

Optionally, you can manually unmount all the partitions with `umount -R /mnt`.

Restart the machine with `reboot`.
