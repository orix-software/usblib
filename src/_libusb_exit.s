.export _libusb_exit
.export libusb_exit

.proc _libusb_exit
    ;;@proto void 	libusb_exit (libusb_context *ctx)
    ;;@brief Exit lib usb
.endproc

.proc libusb_exit
    ;;@brief exit lib usb
    ;;@inputA Low ptr ctx
    ;;@inputY High ptr ctx
    rts
.endproc