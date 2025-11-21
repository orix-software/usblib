.export libusb_init

.export _libusb_init

.proc _libusb_init
    ;;@proto Blah
    ;;@brief blah
    lda     #$01
    ldx     #$00
    rts
.endproc

.proc libusb_init
    lda     #$01
    rts
.endproc
