; struct usb_device *usb_get_device_no_address();
.include "../../include/libusb.inc"
.include "../../libs/usr/arch/include/ch376.inc"



.include "telestrat.inc"
.include "errno.inc"


.import _ch376_wait_response

;unsigned char	mCH375Init( )
;{
;	unsigned char	c, i;

 ;   POKE(CH376_COMMAND,CH376_CMD_SET_USB_MODE);
  ;  POKE(CH376_DATA,6);

	;for ( i = 0xff; i != 0; i -- ) {
	;	c=PEEK(CH376_COMMAND);
	;	if ( c == CH376_RET_SUCCESS ) break;
	;}
	;if ( i != 0 ) return( CH376_INT_SUCCESS );
	;else return( 0xff );
;}

.export _usb_get_device_no_address

.proc _usb_get_device_no_address

    lda     #<.sizeof(libusb_device_descriptor)
    ldy     #>.sizeof(libusb_device_descriptor)
    BRK_TELEMON XMALLOC
    cmp     #$00
    bne     @not_null
    cpy     #$00
    bne     @not_null
    ; Error oom
    rts

@not_null:
    sta     tmp_ptr
    sty     tmp_ptr+1

    lda     #CH376_SET_USB_MODE
    sta     CH376_COMMAND
    lda     #CH376_USB_MODE_HOST_RESET
    sta     CH376_DATA

    jsr     mCH376Init

    lda     #CH376_SET_USB_MODE
    sta     CH376_COMMAND
    lda     #CH376_USB_MODE_HOST_RESET
    sta     CH376_DATA

    jsr     mCH376Init

    ; Get device with no address
    lda     #CH376_SET_USB_ADDR
    sta     CH376_COMMAND
    lda     #$00
    sta     CH376_DATA

    ; set now first adress available

    lda     #CH376_SET_USB_ADDR
    sta     CH376_COMMAND
    lda     current_device_address
    sta     CH376_DATA

    ; get data
    lda     CH376_DATA
    jsr     _ch376_wait_response
    cmp     #CH376_USB_INT_SUCCESS
    beq     @continue
    cmp     #$0D
    beq     @continue
    ; Error destroy struct and return 0
    lda     tmp_ptr
    ldy     tmp_ptr+1
    BRK_TELEMON XFREE
    ; return $00
    lda     #$00
    tax
    rts

@continue:

    lda     tmp_ptr
    ldy     tmp_ptr+1
    sta     __store_struct+1
    sty     __store_struct+2

    ldx     #libusb_device_descriptor::devnum
    lda     current_device_address

__store_struct:
    sta     $dead,x

    inc     current_device_address
    ; Return struct
    lda     tmp_ptr
    ldx     tmp_ptr+1
    rts

current_device_address:
    .byte 1

tmp_ptr:
    .res 2
.endproc


.proc mCH376Init

    lda     #CH376_SET_USB_MODE
    sta     CH376_COMMAND
    lda     #$06
    sta     CH376_DATA

    ldy     #$FF
loop3:
    ldx     #$FF ; merci de laisser une valeur importante car parfois en mode non debug, le controleur ne répond pas tout de suite
@loop:
    lda     CH376_COMMAND
    and     #%10000000
    cmp     #128
    bne     @no_error
    dex
    bne     @loop
    dey
    bne     loop3
	; error is here
    lda     #$01
    rts
@no_error:

@exit:
    rts
.endproc
