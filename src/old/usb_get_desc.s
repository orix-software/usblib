.export usb_get_desc

.include "../libs/usr/arch/include/ch376.inc"
.include "telestrat.inc"
; A contains the address to get

CH376_SET_USB_ADDR    = $13

.proc usb_get_desc

 ; POKE(CH376_COMMAND,CH376_SET_USB_ADDR);
   ; POKE(CH376_DATA,0);
    ldx     #CH376_SET_USB_ADDR
    stx     CH376_COMMAND
    ldx     #$00
    stx     CH376_DATA


    ;devcount++;
   ; printf("Set usb address, devcount : %d\n",devcount);

    ;POKE(CH376_COMMAND,CH376_CMD_SET_ADDR); // 0x45
    ;POKE(CH376_DATA,devcount);
    ;val=PEEK(CH376_DATA);
    ;val=ch376_wait_response();
    ;if (val==0x0d || val==0x14) {
        ;// Set current address we talk with
        ;POKE(CH376_COMMAND,CH376_SET_USB_ADDR); // 13
        ;POKE(CH376_DATA,devcount);
        ;ch376_get_descr(devcount);
        ; Get descr
        ;POKE(CH376_COMMAND,CH376_CMD_RD_USB_DATA0);
        ;length=PEEK(CH376_DATA);
        ;for ( i = 0; i < length; i ++ ) descr_buf[i]=PEEK(CH376_DATA) ;

        ;if (length!=18) {
            ;printf("Invalid descv length : %d\n",length);
            ;return 0xff;
        ;}

        ;POKE(CH376_COMMAND,0x49);
        ;POKE(CH376_DATA,1);
        ;val=ch376_wait_response();
        ;return class;




    ;}
    ;else
    ;{
        ;printf("Error wait_response : %d\n",val);
 ;   }
;
.endproc