my Friend Private Network
=========================

This is a collection of bash scripts to install a bunch of stuff on the
Raspberry Pi.

All the scripts are more or less thoroughsly tested but bugs are certainly
hidden. Furthermore, the execution order is important. Pay attention to what
you're doing.

The goal of this project is to link multiple RPi into one private network where
you can share movies, pictures and music with friends. More on this later :)

Disclaimer
==========
First, this projet is *work in progress*. Second, it was designed to be used on
a bare system where you have nothing installed on it. So be careful if you
use the scripts on your actual RPi.

Installation
============
All the scripts were tested on [Arch Linux ARM built on 06/06/2013][archlinux].
So first, install archlinux on your SD card:

    # On Mac OS, use rdisk to speed up
    dd bs=1m if=archlinux-hf-2013-06-06.img of=/dev/rdisk1

Boot the RPi with the SD card. If there is overscan, edit `/boot/config.txt`
and reboot. Watchout, you have a US mapping:

     # For be-latin1:
     :q! -> Ma1
     :wq -> Mza

Since you don't have ethernet or wifi access to the RPi, at least in my case,
you should copy the repository on a USB key that you will mount it on your RPi:

    # On a mac:
    cp -a mFPN /Volumes/NAME_OF_USB_KEY

And on the RPi:

    mount /dev/sdXX /mnt
    cp -a /mnt/mFPN /usr/local

We have now installed our base system and can continue with the scripts.

[archlinux]: http://downloads.raspberrypi.org/images/archlinuxarm/archlinux-hf-2013-06-06/archlinux-hf-2013-06-06.zip.torrent

Scripts
=======
Scripts are sh files ending with `.inst`. I tried to write them as error-aware
as possible: They exit gracefully and with a meaningful message when having an
error and when exited mid-script, you can relaunch them without fear since they
will detect it and continue from their exit point. E.g. if a user was added,
they won't add it a second time; if a file or directory was created, it won't
be overwritten.

To launch a script, simply do:
    
    cd /usr/local/mFPN     # Necessary (for now)
    sh <script.inst>

You can launch the scripts in verbose mode with:

    verbose=true sh <script.inst>

Certain scripts use `.conf` files, located in a directory of the same name
(without `.inst`), that contains variables relative to your own configuration.
You can simply create them by copying their .conf.sample counterpart and by
editing the variables inside. Do not add those .conf files into the git
repository since they may contain your credentials!

Certain scripts also can `.template` files which are simple files but with
variables inside that will be overwritten when the file is copied in its
installation directory.

XBMC
----
The scripts will install a bare XBMC on your system. They will thus add Xorg
and the video drivers for the RPi if needed. No window manager is installed to
be as lightwheight as possible. They will also add an user named `xbmcuser`
which will autologin on start and automatically start XBMC. Finally, XBMC will
be automatically restarted 5 times in case of crash. After 5 crashes, it is
assumed that a problem arised (e.g. crash loop) and it will not restart anymore
without issuing `startx` manually.

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
  /usr/bin: [see this thread][update_pacman].

[update_pacman]: https://www.archlinux.org/news/binaries-move-to-usrbin-requiring-update-intervention/

