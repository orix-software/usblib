.struct libusb_device_descriptor
  bLength .byte
  bDescriptorType .byte
  bcdUSB .word
  bDeviceClass .byte
  bDeviceSubClass .byte
  bDeviceProtocol .byte
  bMaxPacketSize0 .byte
  idVendor .word
  idProduct .word
  bcdDevice .word
  iManufacturer .byte
  iProduct .byte
  iSerialNumber .byte
  bNumConfigurations .byte
  ; Does not exist
  devnum .byte
.endstruct
