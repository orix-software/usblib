.include "telestrat.inc"
.include "libs/usr/arch/include/ch376.inc"


.proc _udevadm_detect_usb
    ;;@modifyMEM_TR7
    lda     #CH376_ARG_SET_USB_HOST_RESET_USB_BUS
    jsr     ch376_set_usb_mode

@L1:
    lda     CH376_DATA
    cmp     #CH376_RET_SUCCESS
    bne     @L1

    lda     #CH376_ARG_SET_USB_MODE_USB_HOST
    jsr     ch376_set_usb_mode

@L2:
    lda     CH376_DATA
    cmp     #CH376_RET_SUCCESS
    bne     @L2

    ;; Set speed
    lda     #$02
    jsr     ch376_set_usb_speed


    ; TR7 is used for devcount
    lda     #$01
    sta     TR7

@search_device:
    ; Get the device
    lda     #$00
    jsr     ch376_set_usb_addr

    lda     TR7
    jsr     ch376_set_address
    cmp     #CH376_INT_SUCCESS
    beq     @set_address_set
    cmp     #$1D
    beq     @set_address_set
    ; Store into memcache NBUSB
    ; Error
    lda     #$01 ; No device
    rts

@set_address_set:
    inc     TR7
    ; Store into memcache
    jmp     @search_device


    rts
.endproc
