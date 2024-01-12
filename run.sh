ORICUTRON="/mnt/c/Users/plifp/OneDrive/oric/oricutron_wsl/oricutron"


# cl65 -ttelestrat -I include/ test/main.c build/lib8/usb.lib  libs/lib8/ch376.lib -o 1000 --start-addr 2048
# cl65 -ttelestrat -I include/ test/main.c build/lib8/usb.lib  libs/lib8/ch376.lib -o 1256 --start-addr 2304

# ./dependencies/orix-sdk/bin/relocbin.py3 -o e -2 1000 1256

ca65 -ttelestrat src/usbrom.s  -o usbrom.ld65
ld65 -tnone usbrom.ld65 libs/lib8/ch376.lib -o usb.rom
# cp h $ORICUTRON/sdcard/bin

cl65 -I include/ -ttelestrat test/lsusb.c

# cp autoboot $ORICUTRON/sdcard/etc/

cd $ORICUTRON
#./oricutron

cd -
