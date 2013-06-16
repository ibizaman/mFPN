my Friend Private Network
=========================

This is a collection of bash scripts to install a bunch of stuff on the
Raspberry Pi.

All the scripts are more or less thoroughsly tested but some of them must be
run before others. Pay attention to what you're doing.

Installation
============
First, install archlinux on your SD card:

    # On Mac OS, user rdisk to speed up
    dd bs=1m if=archlinux-hf-2013-06-06.img of=/dev/rdisk1

Boot the RPi with the SD card.
If there is overscan, edit `/boot/config.txt` and reboot.
Watchout, you have a US mapping:

     :q! -> Ma1
     :wq -> Mza

Since you don't have ethernet or wifi access to the RPi, at least in my case,
you should copy the file in the repository on a USB key and mount it on your
RPi:

    rsync -avz mFPN usb/key

And on the RPi:

    mount /dev/sdXX /mnt
    cp -a /mnt/mFPN /usr/local

Scripts
=======
As a general rule, files with .conf.sample should be copied to .conf files and
you should edit the variables inside. Do not add those .conf files into the
git repository since they may contain your credentials!

To launch a script, simply do:
    
    cd /usr/local/mFPN
    sh <script.inst>

You can launch the scripts in verbose mode with:

    verbose=true sh <script.inst>

XBMC
----
To install XBMC from a scratch system, you should run these scripts
* Setup keyboard with `setup_kbdlayout.inst`
  And reboot.
* Setup wifi with `setup_wifi.inst`
  The conf file is `setup_wifi/setup_wifi.conf`
* Update pacman with `pacman -Syu`
* Install xbmc with `xbmc.inst`

Miscellaneous
-------------
* `update_pacman.inst` was needed when upgrading since binaries were moved to
  /usr/bin: (see this thread)[https://www.archlinux.org/news/binaries-move-to-usrbin-requiring-update-intervention/].
