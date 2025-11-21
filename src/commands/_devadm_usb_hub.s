.include "telestrat.inc"
.include "../../dependencies/orix-sdk/macros/SDK_memory.mac"

.export devadm_usb_hub
.export _devadm_usb_hub

libzp = $F0

.proc _devadm_usb_hub
    rts
.endproc


.proc devadm_usb_hub
    ptr1       := libzp
    port_count := libzp + 2
    token      := 0

    malloc  9
    sta     ptr1
    sty     ptr1+1


    ldy     #$00
    sty     port_count
@L1:
    lda     (data),y
    sta     (ptr1),y
    iny
    cpy     #$08
    bne     @L1

; Let's go to power on each usb port
@loop_port:
    inc     port_count
    lda     port_count
    cmp     #$04
    beq     scan_each_port

    ldy     #$05 ; Position of the port in data frame
    sta     (ptr1),y

    lda     ptr1
    ldx     ptr1+1
    jsr     ch376_wr_usb_data

    lda     token
    jsr     ch376_issue_token_x

    cmp     #CH376_INT_SUCCESS
    beq     @token_ok
    cmp     #$1D
    beq     @token_ok


token_ok:
    lda     token
    eor     #$80
    sta     token
    jmp     @@loop_port
    rts


scan_each_port:
    mfree(ptr1)
    rts

data:
 ; length, set port feature, set feature, port_power,0, Id port, 0, 0, 0
    .byte 8,$23,3,8,0,0,0,0

.endproc

; unsigned char usb_hub() {
;     unsigned char portcount = 4;
;     unsigned char val, token=0;
;     static unsigned char i=0;
;     unsigned char length=0;
;     unsigned char hubstatus=0;
;     unsigned char port = 0;
;     unsigned char mask;
;     int wait;
;     for (i=1; i <= portcount; i++) {
;         //printf("Power on port %d\n",i);
;         // Send data to the CH376 for the request, requests are always 8 bytes
;         POKE(CH376_COMMAND, CH376_WR_USB_DATA);
;         POKE(CH376_DATA,8);
;         POKE(CH376_DATA,0x23); // bmRequesType = SET PORT FEATURE
;         POKE(CH376_DATA,3); // ' bRequest = SET FEATURE
;         // 810 OUT dat,8:OUT dat,0 ' wValue = PORT_POWER
;         POKE(CH376_DATA,8); // 'wValue = PORT_POWER
;         POKE(CH376_DATA,0);
;         //  wIndex = port index (1 to 4 for a 4 port hub)
;         POKE(CH376_DATA,i);
;         POKE(CH376_DATA,0);
;         // wLength = 0 (no data)
;         POKE(CH376_DATA,0);
;         POKE(CH376_DATA,0);
;         //  Do a control transfer
;         POKE(CH376_COMMAND,CH376_CMD_ISSUE_TKN_X);
;         POKE(CH376_DATA,token);
;         POKE(CH376_DATA,0x0D); // Control transfert
;         //token = token XOR &80 ' prepare for next transaction
;         token = token ^ 0x80; // prepare for next transaction
;         val = ch376_wait_response();
;         if (val!=0x14 && val!=0x1D)
;             printf("Error val %d\n",val);
;     }

;         /*
;         880 ' Ok, now all port are powered up and we should start getting notifications for new connected devices
;         890 OUT cmd,&4E:OUT dat,token:OUT dat,&19 ' Read transaction on endpoint 1 (interrupt endpoint)
;         900 GOSUB 140
;         */
;         POKE(CH376_COMMAND, CH376_CMD_ISSUE_TKN_X);
;         POKE(CH376_DATA,token);
;         token = token ^ 0x80; // prepare for next transaction
;         POKE(CH376_DATA,0x19);
;         val = ch376_wait_response();
;         if (val!=0x14 && val!=0x1D) {
;   g          printf("Error val %d\n",val);
;         }
;         // 910 OUT cmd,&27 ' Read the result
;         POKE(CH376_COMMAND, CH376_CMD_RD_USB_DATA0);// CH376_CMD_RD_USB_DATA0
;         length = PEEK(CH376_DATA);
;         // 930 ' The reply is a bitfield where bit 0 is the global status and bits 1 to N are the status for each port. Each set bit is a port with a device connected
;         printf("Received %d bytes\n",length);
;         // ' The reply is a bitfield where bit 0 is the global status and bits 1 to N are the status for each port. Each set bit is a port with a device connected
;         /*
;         940 hubstatus=INP(dat):port = 0
;         950 PRINT "Initial value: ";HEX$(hubstatus, 2)
;         960 hubstatus = hubstatus AND &FE
;         970 hubstatus=UNT(hubstatus/2):port = port + 1
;         980 PRINT "Scanning port ";port;" hubstatus ";HEX$(hubstatus,2)
;         990 IF hubstatus AND 1 THEN PRINT "Device found on port ";port:GOSUB 1030
;         1000 hubstatus = hubstatus AND &FE
;         1010 IF hubstatus <> 0 THEN GOTO 970
;         1020 END
;         */

;         hubstatus = PEEK(CH376_DATA);
;         port = 0;
;         //printf("Hubstatus Initial value %d\n", hubstatus);
;         hubstatus = hubstatus&0xfe;
;         //printf("Hubstatus with 0xfe %d\n", hubstatus);
;         /*
;             > Rien sur le hub | 00000010 (2)
;             > port 1 | 00010010 (18)
;             > Port 2 | 00001010 (10)
;             > Port 3 | 00000110 (6)
;             > A partir du port4| tout le temps 2 (Pb d'init d'allumage des ports, apparemment non
;             > port 1&2 | 00011010 (26)
;             > port 1&3 | 00010110 (22)
;             > port 2&3 | 00001110 (14)
;         */


;         port = 0;
;         mask = 16;
;         while (port!=4) {
;             //hubstatus = hubstatus/2;
;             printf("Hubstatus with %d\n", hubstatus);
;             port++;
;             //printf("Scanning port %d hubstatus %d mask %d conv = %d\n",port, hubstatus, mask, hubstatus&mask);
;             if (hubstatus&mask) {
;                 printf("**************************************\n");
;                 printf("*Device found on port %d*\n", port);
;                 printf("**************************************\n");
;                 // 1040 OUT cmd,&2C:OUT dat,&8 ' Prepare a control transfer
;                 POKE(CH376_COMMAND, CH376_WR_USB_DATA);
;                 POKE(CH376_DATA,0x08);// ? Length ?
;                 // 1050 OUT dat,&23 ' bmRequestType = Set Port Feature
;                 POKE(CH376_DATA,0x23);
;                 // 1060 OUT dat,&3 ' Set feature
;                 POKE(CH376_DATA,0x03); // Set feature
;                 // 1070 OUT dat,&4:OUT dat,&0 ' Port reset
;                 POKE(CH376_DATA,0x04);
;                 POKE(CH376_DATA,0x00); // port reset
;                 // 1080 OUT dat,port:OUT dat,0 ' Port index
;                 POKE(CH376_DATA, port);
;                 POKE(CH376_DATA,0);
;                 // 1090 OUT dat,0: OUT dat, 0 ' No data
;                 POKE(CH376_DATA,0);
;                 POKE(CH376_DATA,0);
;                 // 1091 OUT cmd,&4E:OUT dat,token:OUT dat,&D

;                 POKE(CH376_COMMAND, CH376_CMD_ISSUE_TKN_X);
;                 POKE(CH376_DATA,token);
;                 POKE(CH376_DATA,0x0D);

;                 printf("Token = %d\n",token);
;                 token = token ^ 0x80; // prepare for next transaction
;                 // 1100 token=token XOR &80:GOSUB 140
;                 val = ch376_wait_response();
;                 if (val == CH376_INT_SUCCESS || val==0x1D) {
;                     //cgetc();
;                     // 1110 FRAME:FRAME:FRAME:FRAME:FRAME ' Wait a bit for port reset
;                     for (wait=0;wait<10000;wait++); // Wait
;                         //for (i=0;i<255;i++); // Wait
;                         //for (i=0;i<255;i++); // Wait
;                     val = discover_and_attrib_device();
;                     if (val == 0xFE) {
;                         printf("Error of usb detection");
;                         return val;
;                     }
;                     if (val == 0xFF) {
;                         printf("Error length desc");
;                         return val;
;                     }
;                     build_descr();
;                     display_descr();
;                 }
;                 else {
;                     printf("Reset error val 0x4E (ISSUE_TKN_X) %d\n",val);
;                 }
;             }
;                 mask = mask/2;
;                 // hubstatus = hubstatus&0xfe;
;                 // if (hubstatus == 0) break;
;                 // if (port == portcount) break;
;         }
; }
