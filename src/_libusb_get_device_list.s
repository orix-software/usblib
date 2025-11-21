    .include "telestrat.inc"

;ssize_t LIBUSB_CALL libusb_get_device_list(libusb_context *ctx,
;    libusb_device ***list);

.import popax

.export _libusb_get_device_list

;.import libusb_get_device_list

.proc _libusb_get_device_list
    ;;@proto unsigned char libusb_get_device_list(libusb_context *ctx, libusb_device ***list);
    sta    RES
    stx    RES + 1

    jsr    popax
    sta    RESB
    stx    RESB + 1

   ; jsr    libusb_get_device_list

    ldx    #$00
    rts
.endproc
