.export usb_discover_device

CH376_SET_USB_ADDR    = $13

.include "telestrat.inc"

.proc usb_discover_device

    ldx     #CH376_SET_USB_ADDR
    stx     CH376_COMMAND
    ldx     #$00
    stx     CH376_DATA

    rts
.endproc
