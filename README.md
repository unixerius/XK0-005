# XK0-004 and XK0-005
Course files for CompTIA Linux+ XK0-004 and XK0-005.

# What is this?
Tess Sluijter-Stek teaches the Linux+ curriculum, on Unixerius' behalf.

The classes in this Linux+ track include a large number of labs and exercises. We thought it could be beneficial to students world-wide, if we shared these exercises publicly.

The lab instructions are updated for the latest version of the Linux+ exam.

# Working environment

For this class, we assume everybody uses VirtualBox because it's the lowest common denominator. VirtualBox is available for MacOS, Windows and Linux. The only exception, for now, is MacOS systems on ARM (aarch64). On those, we use UTM.

## Ensure high performance for VirtualBox with Windows

Windows 10 and Windows 11 have very good power management features, to save your laptop's battery. Modern processors distinguish between "performance" and "efficiency" cores, where tasks will run on a slower and more power efficient part of the CPU in many circumstances.

For our labs we need to make sure that VirtualBox does not get restricted on CPU resources. We need to make sure that VirtualBox always runs on powerful "high performance" settings. To do so:

1. In your Start-menu search for "Powershell" and choose _run as administrator_.
2. In this administrator Powershell, run the following commands:

```
powercfg /powerthrottling disable /path "C:\Program Files\Oracle\VirtualBox\VBoxHeadless.exe"
powercfg /powerthrottling disable /path "C:\Program Files\Oracle\VirtualBox\VirtualBoxVM.exe"
powercfg /powerthrottling list
```

The third command should include the "VBoxHeadless" and "VirtualBoxVM" processes. [Source](https://forums.virtualbox.org/viewtopic.php?t=108745)

Also, you may want to change your overall power management settings for the duration of this class. You can change these by opening the **Settings** app, then going into _Power & Battery > Power mode_ and setting it to "_Best Performance_".

# License
We've decided to offer these files under the Creative Commons, BY-NC-SA license: Non-Commercial, Attribution and Share Alike. You can read all about it in the LICENSE.txt file. Basically: you can re-use these files as you see fit but not for commercial purposes, as long as you attribute us as the original source and you re-share your own modifications. 
