config
======

Personal Configuration Files

# Linux Laptop Configuration

## Hard Disk Configurations
Unfortunately some hard disks have buggy firmware that affect the power
management features of the hard disk.  The result is a constant
loading/unloading of the heads, ultimately causing disk failure if left
unchecked.  The commands below verify and fix the issue if it is present.

- Check the hard disk spin-down using `smartctl -a`.
- Check the hard disk APM level using `hdparm -B`.
- Create under `/etc/pm/` a `99-hdparm.sh` file under `power.d` and `sleep.d`
  with contents

  ```shell
  #!/bin/sh
  hdparm -B 255 /dev/sdX
  ```

## Fixing Suspend
In my experience, suspend seems to be a perpetually broken feature within
Linux.  Attempting to resume from suspend results in a frozen kernel.  The
issue appears to be a bug with open-source video drivers (e.g., xf86-video-ati
and xf86-video-nouveau).  While suboptimal in my opinion, the only fix I have
found is to install the proprietary video drivers.

## HiDPI Scaling

* **QT 5.6+:**
  ```shell
  export QT_AUTO_SCREEN_SCALE_FACTOR=1
  ```

## Adding sounds to Gnome

* Add sound to `/usr/share/sounds`
* Add entry to `/usr/share/gnome-control-center/sounds/gnome-sounds-default.xml`

## Touchpad right-click in Ubuntu 18.04+

For whatever reason, Ubuntu configures the touchpad as multi-touch by default. To restore area-touch middle/right-click, install the `gnome-tweak-tools` package and change the "Mouse Click Emulation" setting to "Area".
