struct libusb_device;

typedef struct libusb_device libusb_device;

//unsigned char libusb_init(libusb_context **ctx);
/*
struct usb_device {
  unsigned char devnum;
};
*/
struct libusb_device_descriptor {
  unsigned char  bLength;
  unsigned char  bDescriptorType;
  unsigned int   bcdUSB;
  unsigned char  bDeviceClass;
  unsigned char  bDeviceSubClass;
  unsigned char  bDeviceProtocol;
  unsigned char  bMaxPacketSize0;
  unsigned int   idVendor;
  unsigned int   idProduct;
  unsigned int   bcdDevice;
  unsigned char  iManufacturer;
  unsigned char  iProduct;
  unsigned char  iSerialNumber;
  unsigned char  bNumConfigurations;
};

struct libusb_version {
    unsigned char minor;
/*
    const uint16_t major;
    const uint16_t micro;
    const uint16_t nano;
    const char *rc;
    const char *describe;
*/
};

enum libusb_class_code {
    LIBUSB_CLASS_PER_INTERFACE = 0x00,
    LIBUSB_CLASS_AUDIO = 0x01,
    LIBUSB_CLASS_COMM = 0x02,
    LIBUSB_CLASS_HID = 0x03,
    LIBUSB_CLASS_PHYSICAL = 0x05,
    LIBUSB_CLASS_IMAGE = 0x06,
    LIBUSB_CLASS_PTP = 0x06, /* legacy name from libusb-0.1 usb.h */
    LIBUSB_CLASS_PRINTER = 0x07,
    LIBUSB_CLASS_MASS_STORAGE = 0x08,
    LIBUSB_CLASS_HUB = 0x09,
    LIBUSB_CLASS_DATA = 0x0a,
    LIBUSB_CLASS_SMART_CARD = 0x0b,
    LIBUSB_CLASS_CONTENT_SECURITY = 0x0d,
    LIBUSB_CLASS_VIDEO = 0x0e,
    LIBUSB_CLASS_PERSONAL_HEALTHCARE = 0x0f,
    LIBUSB_CLASS_DIAGNOSTIC_DEVICE = 0xdc,
    LIBUSB_CLASS_WIRELESS = 0xe0,
    LIBUSB_CLASS_MISCELLANEOUS = 0xef,
    LIBUSB_CLASS_APPLICATION = 0xfe,
    LIBUSB_CLASS_VENDOR_SPEC = 0xff
};

//  unsigned char libusb_get_device_list(libusb_context *ctx, libusb_device ***list);

struct usb_device *usb_get_device_no_address();
//unsigned char usb_control_msg (struct usb_device *dev, unsigned int pipe, unsigned char request, unsigned char requesttype, unsigned int value, unsigned int index, void *data, unsigned int size, unsigned char timeout);
//unsigned char usb_get_descriptor(struct usb_device *dev, unsigned char desctype, unsigned char descindex, void *buf, unsigned char size);


unsigned char libusb_get_device_list(void *ctx, libusb_device ***list);
unsigned char libusb_init(void *param);
void libusb_exit(void *param);
