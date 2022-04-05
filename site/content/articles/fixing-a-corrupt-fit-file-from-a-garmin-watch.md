---
title: "Fixing a corrupt FIT file from a Garmin watch"
date: 2022-04-05T12:00:00-06:00
draft: false
description: Steps for fixing a corrupt FIT file from a Garmin watch.
---

After IRONMAN 70.3 Texas, I noticed the swim portion was not syncing to Garmin Connect. After some digging, I came to the conclusion that the data was most likely corrupted. Indeed, it seemed Garmin had fixed the issue in a recent [software update](https://www8.garmin.com/support/download_details.jsp?id=15159):

```
Changes made from version 19.20 to 20.30:
  • Fixed issue that would corrupt open water swim activity files.
```

After upgrading to version 20.50, which presumably fixes the issue, I still needed to get the corrupted file into Garmin Connect. The following details the steps I took to salvage the corrupt FIT file.

First, what is a FIT file?

>The Flexible and Interoperable Data Transfer (FIT) protocol is designed specifically for the storing and sharing of data that originates from sport, fitness and health devices.

The FIT file protocol provides interoperability of device data across various platforms. A FIT file enables data taken from an embedded device (Garmin watch) to be made available to software, applications, and third-party platforms.

An overview of the FIT file protocol can be found [here](https://developer.garmin.com/fit/overview).

## Step 1: Transferring the FIT file from my Garmin watch

In order to transfer the FIT file from my Garmin watch to my MacBook Pro, I needed to install [Android File Transfer](https://www.android.com/filetransfer). This utility allows you to browse and transfer files between your Mac computer and your Garmin device.

After connecting my Garmin watch to my MacBook Pro, I opened the Android File Transfer app and located the FIT file under `GARMIN/Activity`.

**NOTE**: Ensure your device is in MTP (Media Transfer) USB mode.

## Step 2: Fixing the corrupt file

Initially, I thought I could manually fix the corrupt data using Garmin's [FitCSVTool](https://developer.garmin.com/fit/fitcsvtool), however I received the following error when attempting to covert the file:

```
$ java -jar FitCSVTool.jar 2022-04-03-07-00-49.fit
FIT CSV Tool - Protocol 2.0 Profile 21.78 Release
Exception in thread "main" java.lang.RuntimeException: com.garmin.fit.FitRuntimeException: FIT decode error: Endian 243 not supported. Error at byte: 114276
  ...
```

Luckily, there is a web app that can attempt to fix corrupted files, [fitfiletools.com](https://www.fitfiletools.com). This web app provides a collection of useful tools for manipulating FIT files. I uploaded the FIT file to the **Corrupt Time Fixer** utility and downloaded the result. I was then able to convert the file to CSV:

```
$ java -jar FitCSVTool.jar -u fitfiletools.fit
FIT CSV Tool - Protocol 2.0 Profile 21.78 Release
FIT binary file fitfiletools.fit decoded to fitfiletools*.csv files.
```

**NOTE**: The `-u` option hides unknown data, which is necessary when converting the CSV file back to a FIT file.

```
$ java -jar FitCSVTool.jar -c fitfiletools.csv 2022-04-03-07-00-49.fit
FIT CSV Tool - Protocol 2.0 Profile 21.78 Release
CSVReader.read(): Error on line 6 - Unknown message "unknown".
Exception in thread "main" java.lang.RuntimeException: FIT encoding error.
  ...
```
*Example when converting the CSV file back to a FIT file without `-u` option.*

## Step 3: Editing the data

After opening the CSV, I noticed the following erroneous data at the end of the file:

```
Definition,3,gps_metadata,timestamp,1,,enhanced_altitude,1,,enhanced_speed,1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Data,3,gps_metadata,timestamp,"1017923721",s,enhanced_altitude,"2.988443896E8",m,enhanced_speed,"1113.864",m/s,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Data,0,record,timestamp,"1017944238",s,position_lat,"4976265",semicircles,position_long,"33588224",semicircles,distance,"1679052.86",m,enhanced_speed,"4984.076",m/s,unknown,"33792",,heart_rate,"0",bpm,cadence,"5",rpm,temperature,"-3",C,cycles,"4",cycles,fractional_cadence,"1.046875",rpm,unknown,"9",,unknown,"4",,total_cycles,"1284|1284",cycles,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
Data,0,record,timestamp,"1017944262",s,position_lat,"33227265",semicircles,position_long,"861801485",semicircles,distance,"155.32",m,enhanced_speed,"1117784.396",m/s,unknown,"118",,heart_rate,"11",bpm,cadence,"118",rpm,temperature,"117",C,cycles,"115",cycles,fractional_cadence,"0.890625",rpm,unknown,"114",,unknown,"112",,total_cycles,"1395|1395",cycles,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
```

I deleted these lines and converted the CSV file back to a FIT file.

```
$ java -jar FitCSVTool.jar -c fitfiletools.csv 2022-04-03-07-00-49.fit
FIT CSV Tool - Protocol 2.0 Profile 21.78 Release
fitfiletools.csv encoded into FIT binary file 2022-04-03-07-00-49.fit.
```

## Step 4: Manually uploading the file to Garmin Connect

I navigated to Garmin Connect, then clicked the cloud icon in the upper right-hand corner, then **Import Data**. I clicked **Browse**, then selected the edited FIT file, then clicked **Import Data**. My swim was then safely in [Garmin Connect](https://connect.garmin.com/modern/activity/8587222233).

**NOTE**: The activity synced with Training Peaks automatically, however I had to manually upload it to Strava.

I hope this helps. Happy training!
