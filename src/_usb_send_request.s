.include "telestrat.inc"
.include "../libs/usr/arch/include/ch376.inc"
.import _ch376_wait_response

.export _usb_send_request

.import usblib_token

.proc _usb_send_request
        ; X : port id
        lda     #CH376_WR_USB_DATA
        sta     CH376_COMMAND
        lda     #$08
        sta     CH376_DATA
        lda     #$23          ;  bmRequesType = SET PORT FEATURE
        sta     CH376_DATA
        lda     #$03          ;  // ' bRequest = SET FEATURE
        sta     CH376_DATA
        lda     #$08          ;  // 'wValue = PORT_POWER
        sta     CH376_DATA
        lda     #$00
        sta     CH376_DATA

        stx     CH376_DATA   ; port

        sta     CH376_DATA   ; Equal to 0

        sta     CH376_DATA   ; length 0
        sta     CH376_DATA   ; length 0

        lda     #$4A            ; Do a control transfer
        sta     CH376_COMMAND
        ; Token
        lda     usblib_token
        sta     CH376_DATA   ; length 0

        lda     #$0D
        sta     CH376_DATA   ; length 0
        eor     #$80
        sta     usblib_token

       ; val=ch376_wait_response();
        rts
.endproc
