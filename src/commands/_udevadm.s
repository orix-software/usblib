.include "telestrat.inc"
.include "../../dependencies/orix-sdk/macros/SDK_mainargs.mac"
.include "../../dependencies/orix-sdk/macros/SDK_memory.mac"

; Restart : udevadm control --reload-rules

.export _udevadm

userzp := $80

.proc _udevadm
    argv            := userzp   ; 2 bytes -> ptr
    argc            := userzp+2 ; 1 byte -> value
    ptr1            := userzp+3
    ptr2            := userzp+5

    initmainargs argv, argc, 0

    getmainarg #1, (argv)

    ; Save the ptr of the first parameter in first_arg_ptr
    sta     ptr1
    sty     ptr1+1

    lda     #<option_start
    ldy     #>option_start

    jsr     @check_option
    cmp     #$00
    beq     @udevadm_start

    mfree(argv) ; Free argv copy
    rts


;@found:
@not_found:


@udevadm_start:

    rts

@found:
    lda     #$00
    rts



@check_option:
    sta    ptr2
    sty    ptr2+1

    ldy     #$00
    lda     (ptr2),y
    beq     @found
    cmp     (ptr1),y
    bne     @not_found
    ldy     #$01
    rts

option_start:
    .asciiz "start"

option_info:
    .asciiz "info"

option_control:
    .asciiz "control"
.endproc

