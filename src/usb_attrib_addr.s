.export usb_attrib_addr

.include "../libs/usr/arch/include/ch376.inc"

CH376_SET_USB_ADDR    = $13

.include "telestrat.inc"
    ; Input : X the id address
    ;         AY buf 18 bytes for descr
    ; Output in A : 0 ok, 1 error
    ;           X : id of the set addr

.import    _ch376_wait_response
.import    _ch376_get_descr

.proc usb_attrib_addr

    sta     @store+1
    sty     @store+2
    stx     save_addr_usb

    lda     #CH376_SET_USB_ADDR
    sta     CH376_COMMAND
    lda     #$00                 ; Set current device : 0
    sta     CH376_DATA

    lda     #CH376_SET_ADRESS    ; Define the set address
    sta     CH376_COMMAND

    stx     CH376_DATA  ; Store the id address from arg

    lda     CH376_DATA

    jsr     _ch376_wait_response
    cmp     #CH376_USB_INT_SUCCESS
    beq     @success
    cmp     #CH376_USB_INT_DISK_READ
    beq     @success
    ; Error
@error:
    lda    #$01
    rts


@success:
    lda     #CH376_SET_USB_ADDR
    sta     CH376_COMMAND

    ldx     save_addr_usb
    stx     CH376_DATA

    txa
    jsr     _ch376_get_descr

    lda     #CH376_RD_USB_DATA0   ; Read header
    sta     CH376_COMMAND

    lda     CH376_DATA ; Length
    cmp     #18
    beq     @error

    ldx     #$00
@L1:
    lda     CH376_DATA
@store:
    sta     $dead,x
    inx
    bne     @L1

    ldx     save_addr_usb
    lda     #$00 ; OK
    rts

save_addr_usb:
    .res 1
.endproc
