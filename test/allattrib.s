.import usb_attrib_addr

.include "telestrat.inc"

.export _all_attrib

.proc _all_attrib
    BRK_TELEMON XMALLOC
    sta  myptr1
    sty  myptr1+1
    ldx  #$01
    jsr  usb_attrib_addr
    cmp  #$01
    beq  @error

    lda  myptr1
    ldx  myptr1+1
    rts
@error:
    lda  #$00
    tax
    rts
myptr1:
    .res 2
.endproc