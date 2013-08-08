my Friend Private Network
=========================

This is a collection of sh scripts to install a bunch of stuff on the
Raspberry Pi.

All the scripts are more or less thoroughsly tested but bugs are certainly
hidden. Furthermore, the execution order is important. Pay attention to what
you're doing.

The goal of this project is to link multiple RPi into one private network where
you can share movies, pictures and music with friends. More on this later :)

Disclaimer
==========
First, this projet is **work in progress**. Second, it was designed to be used on
a bare RPi where you have nothing installed on it. So be careful if you
use the scripts on your actual RPi.

Installation
============
First you need to install an OS on an SD card. This README file suppose you
will install [Raspbmc][raspbmc]. If you rather want to install Arch Linux, see [this
file][archlinux_readme].

[raspbmc]: http://www.raspbmc.com/
[archlinux_readme]: ./archlinux/README.md

Scripts
=======
Scripts are sh files ending with `.inst`. I tried to write them as error-aware
as possible:
* they exit gracefully and with a meaningful message when having an
  error;
* you can relaunch them multiple times without fear since they will detect it
  and won't re-apply the changes already done.
E.g. if a user already exist, he won't be added a second time; if a file
already exist, it will be backed up first.

To launch a script, simply do:
    
    cd /usr/local/mFPN     # Necessary (for now)
    sh <script.inst>

You can launch the scripts in verbose mode with:

    verbose=true sh <script.inst>

Certain scripts use `<file>.conf` files, located in a directory of the same name
(without `.inst`), that contains variables relative to your own configuration.
These files are obviously not provided since it is not possible know the
specifics of your installation in advance. However, a `<file>.conf.sample` file is
provided that you can simply copy to `<file>.conf` which you can then edit.
**Do not add those .conf files into the git repository since they may contain your
credentials!**

Certain scripts also use `.template` files which are simple files but with
variables inside that will be overwritten when the file is copied in its
installation directory.

XBMC
----
You've got nothing to do. That's what's great with Raspbmc, it comes out of
the box with neat features !

License
=======
Not much to say about this else that all these scripts are released under
GPLv2.
