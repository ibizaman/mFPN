Archlinux scripts
=================

These scripts are useful only if you installed Arch Linux on your Raspberry
Pi. If not, you should follow the [Raspbmc README][raspbmc_readme].

Installation
============

All the scripts were tested on [Arch Linux ARM built on
06/06/2013][archlinux]. So first, install archlinux on your SD card:

    # Instructions for Mac OS X
    # Let's say the SD card is the disk1 device
    diskutil unmountDisk /dev/disk1
    cd path/to/archlinux.img
    # On Mac OS X, use rdisk to speed up the copy
    dd bs=1m if=archlinux-hf-2013-06-06.img of=/dev/rdisk1

Boot the RPi with the SD card. If there is overscan, edit `/boot/config.txt`
and reboot. If you intend to install XBMC later on, note that XBMC will not
read it so you will still need to do a video calibration later on. Watchout,
you have a US mapping:

     # For be-latin1:
     :q! -> Ma1
     :wq -> Mza

Since you don't have ethernet or wifi access to the RPi, at least in my case,
you should copy the repository on a USB key that you will mount on your RPi:

    # On a mac:
    cp -a mFPN /Volumes/NAME_OF_USB_KEY

And on the RPi:

    mount /dev/sdXX /mnt
    cp -a /mnt/mFPN /usr/local

We have now installed our base system and can continue with the scripts.

[archlinux]: http://downloads.raspberrypi.org/images/archlinuxarm/archlinux-hf-2013-06-06/archlinux-hf-2013-06-06.zip.torrent
[raspbmc_readme]: ./README.md

XBMC
----
The scripts will install a bare XBMC on your system. They will thus add Xorg
and the video drivers for the RPi, if needed. No window manager is installed to
be as lightwheight as possible. They will also add an user named `xbmcuser`
which will autologin on start and automatically start XBMC. Finally, XBMC will
be automatically restarted a configurable number of times in case of crash.
After 5 crashes, it is assumed that a problem arised (e.g. crash loop) and it
will not restart anymore without issuing `startx` manually.

To install XBMC from a scratch system, you should run these scripts
* Setup keyboard with `setup_kbdlayout.inst`.
  And reboot.
* Setup wifi with `setup_wifi.inst`.
  The conf file is `setup_wifi/setup_wifi.conf`.
* Issue a sytem update with `pacman -Syu`.
* And install xbmc with `xbmc.inst`.

Miscellaneous
-------------
* `update_pacman.inst` was needed when upgrading since binaries were moved to
  /usr/bin: [see this thread][update_pacman]. If you use the same Arch Linux build
  as in the Installation section, you should be just fine and can simply issue a
  `pacman -Syu` to update your packages.

[update_pacman]: https://www.archlinux.org/news/binaries-move-to-usrbin-requiring-update-intervention/
