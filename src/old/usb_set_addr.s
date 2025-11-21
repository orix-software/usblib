.include "telestrat.inc"
.include "../libs/usr/arch/include/ch376.inc"

.proc usb_set_addr
  ;devcount++;
   ; printf("Set usb address, devcount : %d\n",devcount);

    ;POKE(CH376_COMMAND,CH376_CMD_SET_ADDR); // 0x45
    ;POKE(CH376_DATA,devcount);
    ;val=PEEK(CH376_DATA);
    ;val=ch376_wait_response();
    ;if (val==0x0d || val==0x14) {
     ;   // Set current address we talk with
        ;POKE(CH376_COMMAND,CH376_SET_USB_ADDR); // 13
        ;POKE(CH376_DATA,devcount);
.endproc
