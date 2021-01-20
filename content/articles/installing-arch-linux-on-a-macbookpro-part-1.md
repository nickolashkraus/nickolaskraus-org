---
title: "Installing Arch Linux on a MacBookPro - Part 1"
date: 2021-01-01T12:00:00-06:00
draft: false
description: This is part one of a three part series on how to install macOS Big Sur and Arch Linux on a MacBookPro11,3.
---

**Warning**: This guide is for the MacBookPro11,3 and does not apply to more recent MacBooks. These are very poorly supported. See [here](https://github.com/Dunedan/mbp-2016-linux) for more information. To determine the *Model Identifier* of your MacBookPro, go to  > **About This Mac** > **System Report...**. The Model Identifier should be listed under **Hardware Overview**. You can also identify your MacBook Pro model [here](https://support.apple.com/en-us/HT201300).

## Overview
This is part one of a three part series on how to install macOS Big Sur and Arch Linux on a MacBookPro11,3.
* [Installing Arch Linux on a MacBook Pro - Part 1](articles/installing-arch-linux-on-a-macbookpro-part-1/)
* [Installing Arch Linux on a MacBook Pro - Part 2](articles/installing-arch-linux-on-a-macbookpro-part-2/)
* [Installing Arch Linux on a MacBook Pro - Part 3](articles/installing-arch-linux-on-a-macbookpro-part-3/)

## Requirements
* 1x - MacBookPro11,3
* 2x - +12GB USB Flash Drives

## Installing macOS Big Sur
### Create a Bootable Installer for macOS
You must use an external drive or secondary volume as a startup disk from which to install macOS Big Sur. Fortunately, Apple makes this relatively painless.

#### Step 1: Download macOS Big Sur
macOS Big Sur downloads directly to your Applications folder as an app named **Install macOS Big Sur**. If the installer opens after downloading, quit it without continuing installation.

To download macOS Big Sur, go to the Apple menu  > **App Store...** > search *macOS Big Sur* > click **View** > click **Get**. This will download macOS Big Sur.

#### Step 2: Use the `createinstallmedia` command in Terminal
1. Connect a USB flash drive. This will serve as the bootable installer. Make sure that it has at least 12GB of available storage and is formatted as Mac OS Extended.
2. Open the Terminal application.
3. Execute the following command:

```bash
sudo /Applications/Install\ macOS\ Big\ Sur.app/Contents/Resources/createinstallmedia \
  --volume /Volumes/<VolumeName>
```

This command assumes that the installer is still in your `Applications` folder. `VolumeName` is the name of the USB flash drive or other volume you’re using.

**Note**: This may take awhile (~30 minutes). Be patient.

#### Step 3: Install macOS Big Sur
1. Reboot your Mac.
2. Press and hold the Option (⌥) key.
3. Select the bootable installer for macOS.
4. Follow the prompts to install macOS.
5. Install any updates ( > **About This Mac** > **System Preferences...** > **Software Update**).

**Note**: To do a clean install, use Disk Utility within the installer to repartition or reformat the disk.

## Create a Partition for Arch Linux
Next, we will create a partition for Arch Linux along side your macOS installation.

1. Open Disk Utility.
2. Select the drive to be partitioned in the left-hand column. Click **Partition**, then **Partition** again.
3. Add a new partition by pressing **+** and choose how much space you wish to give the partition. The partition type does not matter, as it will be reformatted when installing Arch Linux, however it may be best to format the partition as APFS as not to confuse the partition with other partitions (i.e. a Windows 7 partition).

## Create an Arch Linux Installer
First, [download](https://www.archlinux.org/download/) the Arch Linux ISO image file using the torrent file.

1. Identify the USB device.

```bash
diskutil list
```

Your USB device will appear as something similar to `/dev/diskX (external, physical)`.

2. A USB device is normally auto-mounted in macOS. You have to unmount (not eject) it before block-writing to it with `dd`.

```bash
diskutil unmountDisk /dev/diskX
```

3. Copy the ISO image file to the device. The `dd` command is similar to its Linux counterpart, but notice the `r` before `disk`. This is for raw mode, which makes the transfer much faster:

```bash
dd if=path/to/arch.iso of=/dev/rdiskX bs=1m
```

After completion, macOS may complain that, *”The disk you inserted was not readable by this computer”*. Select **Ignore**. The USB device will now be bootable.

**Note**: You may need to give Terminal full disk access. Go to  > **System Preferences...** > **Security & Privacy**, then add Terminal to **Full Disk Access**.

**Note**: The image can be burned to a CD, mounted as an ISO file, or be directly written to a USB stick using a utility like `dd`. It is intended for new installations only; an existing Arch Linux system can always be updated with `pacman -Syu`.

**Note**: You will need a BitTorrent client in order to download the ISO image file from the torrent file. I use [Transmission](https://transmissionbt.com/).

## Installing Arch Linux
1. Reboot your Mac.
2. Press and hold the Option (⌥) key.
3. Select the bootable installer for Arch Linux.

Continue to [Installing Arch Linux on a MacBook Pro - Part 2](articles/installing-arch-linux-on-a-macbookpro-part-2/)
