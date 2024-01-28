
struct device {
   const char * init_name;
};

#include <stdint.h>
#include <stdio.h>
#include "usb.h"

struct usb_device *dev;

main() {
    dev = usb_get_device_no_address();

    return 0;
}
