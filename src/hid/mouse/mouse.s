; .import ptr1
; .import ptr2

.include "telestrat.inc"



.import _ch376_wait_response
.import _ch376_set_usb_speed

; .import popax

; 430 ' HID MOUSE TEST (for reference) ------------------------------------------
; 440 OUT cmd,&2C:OUT dat,&8 ' Write an 8 byte command to the device 
; 450 OUT dat, &21:OUT dat,&B ' SET PROTOCOL command   
; 460 OUT dat, &0 ' Use BOOT protocol
; 470 OUT dat,&0:OUT dat,&0:OUT dat,&0:OUT dat,&0:OUT dat,&0    
; 480 OUT cmd,&4E:OUT dat,&80:OUT dat,&D
; 490 GOSUB 140
; 500 token =0
; 510 OUT cmd, &4E:OUT dat,token:OUT dat,&19:token = token XOR &80 ' Get HID data
; 520 GOSUB 140
; 530 IF status = &23 THEN GOTO 660
; 540 IF STATUS<>&14 THEN PRINT HEX$(STATUS);:GOTO 510
; 550 OUT cmd,&27
; 560 Ln = INP(dat)
; 570 btn = INP(dat)
; 580 PLOT x,y,0
; 590 xd=INP(dat):yd=INP(dat):w=0'INP(dat)
; 600 IF xd>127 THEN xd=xd-256
; 610 IF yd>127 THEN yd=yd-256
; 620 IF w>127 THEN w=w-256
; 630 x=x+xd:y=y-yd:PLOT x,y,1
; 640 BORDER btn
; 650 GOTO 510
; 660 ' CLEAR STALL
; 670 PRINT "S";
; 680 OUT cmd,&41 ' CMD_CLEAR_STALL
; 690 OUT DAT,&81 ' Endpoint 1, IN
; 700 GOSUB 140:IF STATUS<>&14 THEN PRINT HEX$(STATUS);
; 710 GOTO 500

; Device enumeration
; Now that the CH376 is ready and awaiting orders, we can enable its USB port. Note that switching the mode will disconnect it from any USB or SD mass storage, if that is also used. Switching between the two dynamically may require some experimenting.

; Anyway, let's switch our USB device on!

; OUT CMD,&15:OUT DAT,7:v = INP(DAT)
; OUT CMD,&15;OUT DAT,7:v = INP(DAT)
; This sequence puts the CH376 in "HOST" mode. In this mode it acts just like a PC and you can connect USB devices to it.

; HID mouses are slow-speed devices. We must force the CH376 to use low speed.

; OUT CMD,&0B:OUT DAT,&17:OUT DAT,&D8
; This command acts like a "POKE" into the CH376 internal memory. It would be cleaner to use the SET_SPEED command, but the example I got from WCH forums uses this, and it works.

; The next step is to assign our USB device with its own address. When they are newly connected to a computer, all USB devices initially get an address of 0. It is up to the host to scan them and assign them other addresses. This should allow to use multiple devices at the same time, but I haven't tried that yet.

; OUT CMD,&45:OUT DAT,1:v = INP(DAT)
; So, we just tell our device to use address 1. And we must also tell the CH376 itself that it should now communicate with device 1, which is a separate command:

; OUT CMD,&13:OUT DAT,1
; The device may expose several "configurations", that is, several different ways to talk to it. In the case of our mouse, we will just try the first configuration.

; OUT CMD,&49:OUT DAT,1
; This command generates an interrupt. If you have interrupts enabled, you can wait for that, otherwise just busy loop on the status register:

; WAIT:

; v = INP(CMD)
; IF v > 127 THEN GOTO WAIT

; OUT CMD,&22
; STATUS = INP(DAT)
; RETURN

.export _get_hid_mouse_state


; 120 OUT CMD,&B:OUT DAT,&17:OUT DAT,&D8 :' Set USB device speed?
; 130 OUT CMD,&45:OUT DAT,&1:v =INP(dat) :' Set device address
; 140 GOSUB 510
; 150 OUT CMD,&13:OUT DAT,&1 :' Set CH376 address
; 160 :' We can now select configuration 1. In a mouse, this is (usually?) the only available configuration.
; 170 OUT CMD,&49:OUT DAT,&1 :' Select configuration 1
; 180 GOSUB 510
; 190 :' And here is our main loop.
; 200 :' We will poll the mouse for data.
; 210 :' We use command &4E which is the lowest level command available.
; 220 TOKEN = &0 :' TOKEN selects DATA0 or DATA1 packet. They must alternate!
; 230 OUT CMD,&4E
; 240 :' First parameter is the "sync token", bit 7 means "host endpoint synchronous trigger" (whatever...)
; 250 OUT DAT,TOKEN
; 260 :' Second byte is the operation descriptor.
; 270 :' High 4 bits define the endpoint
; 280 :' (here we use endpoint 1, which is the interrpt endpoint of the mouse)
; 290 :' low 4 bits define the operation (9 is a READ).
; 300 OUT DAT,&19 :' Read from endpoint 0
; 310 :' The mouse only sends reports when something actually changes (move or button state). If you want periodic reports, the HID "set idle" command can be used to configure it so.
; 320 TOKEN = TOKEN XOR &80 :'Alternate DATA0 - DATA1 packets
; 330 GOSUB 510
; 340 OUT CMD,&27 :' Get data from command RD_USB_DATA0
; 350 :' We use command &27 as usual to get the data
; 360 :' The first byte is the length of the report.
; 370 Ln = INP(dat)
; 380 IF Ln = 0 THEN GOTO 230 :' No data, try again?
; 390 :' First byte of report has button states (lowest bit is button 1)
; 400 BTN=INP(dat)
; 410 xd=INP(dat):yd=INP(dat):w=INP(dat) :' Next are X-delta, Y-delta, and wheel-delta
; 420 LOCATE 1,3:PRINT"dX: &";HEX$(xd,2);"   dY: &";HEX$(yd,2);"   Wheel: &";HEX$(w,2);"   Buttons: &";HEX$(BTN,2);
; 430 :' Now perform some fixes for BASIC compatibility
; 440 IF xd > 127 THEN xd = xd - 256 :' Convert to signed
; 450 yd = yd XOR &FF:IF yd > 127 THEN yd = yd - 256
; 460 IF w > 127 THEN w = w - 256
; 470 :' And just plot a pixel at the current mouse position
; 480 x=x+xd:y=y+yd:DRAW x,y :' Move and draw cursor
; 490 GOTO 230
; 500 :' Wait for command to complete and read error code
; 510 LOCATE 1,24:sta = INP(CMD):PRINT"Status: &";HEX$(sta,2);:IF sta > 127 THEN GOTO 510
; 520 :' GET_STATUS
; 530 OUT CMD,&22
; 540 STATUS=INP(DAT):LOCATE 1,1:PRINT"Interrupt status (&14,&1D=OK) = ";HEX$(STATUS,2);
; 550 RETURN

.proc _get_hid_mouse_state
    ; sta     ptr1
    ; stx     ptr1+1
    ; jsr     popax
    ; sta     ptr2
    ; stx     ptr2+1

;100 OUT CMD,&15:OUT DAT,&7 :' Initialize device in usb HOST mode, reset USB bus
    ; lda     #$15
    ; sta     CH376_COMMAND

    ; lda     #$07
    ; sta     CH376_DATA

;110 OUT CMD,&15:OUT DAT,&6 :' Initialize device in usb HOST mode, produce SOF

    ; lda     #$15
    ; sta     CH376_COMMAND

    ; lda     #$06
    ; sta     CH376_DATA
;120 OUT CMD,&B:OUT DAT,&17:OUT DAT,&D8 :' Set USB device speed?

    lda     #$02
    jsr     _ch376_set_usb_speed

    lda     #$0B
    sta     CH376_COMMAND

    lda     #$17
    sta     CH376_DATA

    lda     #$D8
    sta     CH376_DATA

;130 OUT CMD,&45:OUT DAT,&1:v =INP(dat) :' Set device address
;     lda     #$45
;     sta     CH376_COMMAND

;     lda     #$01
;     sta     CH376_DATA

;     lda     CH376_DATA
; ;140 GOSUB 510
;     jsr     _ch376_wait_response

;150 OUT CMD,&13:OUT DAT,&1 :' Set CH376 address
    lda     #$13
    sta     CH376_COMMAND

    lda     #$01
    sta     CH376_DATA


;160 :' We can now select configuration 1. In a mouse, this is (usually?) the only available configuration.
;170 OUT CMD,&49:OUT DAT,&1 :' Select configuration 1
    lda     #$49
    sta     CH376_COMMAND

    lda     #$01
    sta     CH376_DATA

;180 GOSUB 510

    jsr     _ch376_wait_response

@L1:
; 220 TOKEN = &0 :' TOKEN selects DATA0 or DATA1 packet. They must alternate!
; 230 OUT CMD,&4E
; 240 :' First parameter is the "sync token", bit 7 means "host endpoint synchronous trigger" (whatever...)


    lda     #$4E
    sta     CH376_COMMAND
; 250 OUT DAT,TOKEN

    lda     token
    sta     CH376_DATA

; 260 :' Second byte is the operation descriptor.
; 270 :' High 4 bits define the endpoint
; 280 :' (here we use endpoint 1, which is the interrpt endpoint of the mouse)
; 290 :' low 4 bits define the operation (9 is a READ).
; 300 OUT DAT,&19 :' Read from endpoint 0
; 310 :' The mouse only sends reports when something actually changes (move or button state). If you want periodic reports, the HID "set idle" command can be used to configure it so.


    lda     #$19
    sta     CH376_DATA


; 320 TOKEN = TOKEN XOR &80 :'Alternate DATA0 - DATA1 packets
    lda     token
    eor     #$80
    sta     token

; 330 GOSUB 510


    jsr     _ch376_wait_response

; 340 OUT CMD,&27 :' Get data from command RD_USB_DATA0
; 350 :' We use command &27 as usual to get the data
; 360 :' The first byte is the length of the report.


    lda     #$27
    sta     CH376_COMMAND

; 370 Ln = INP(dat)


    lda     CH376_DATA

; 380 IF Ln = 0 THEN GOTO 230 :' No data, try again?


    beq     @out

; 390 :' First byte of report has button states (lowest bit is button 1)
; 400 BTN=INP(dat)
; 410 xd=INP(dat):yd=INP(dat):w=INP(dat) :' Next are X-delta, Y-delta, and wheel-delta
; 420 LOCATE 1,3:PRINT"dX: &";HEX$(xd,2);"   dY: &";HEX$(yd,2);"   Wheel: &";HEX$(w,2);"   Buttons: &";HEX$(BTN,2);
; 430 :' Now perform some fixes for BASIC compatibility
; 440 IF xd > 127 THEN xd = xd - 256 :' Convert to signed
; 450 yd = yd XOR &FF:IF yd > 127 THEN yd = yd - 256
; 460 IF w > 127 THEN w = w - 256
; 470 :' And just plot a pixel at the current mouse position
; 480 x=x+xd:y=y+yd:DRAW x,y :' Move and draw cursor
; 490 GOTO 230

    lda     CH376_DATA ; get bouton
    lda     CH376_DATA ; get X
    tax
    lda     CH376_DATA ; get Y
    pha
    lda     CH376_DATA ; get wheel
    pla
    rts

@out:
    ldx     #$00
    rts


   rts
token:
    .byt $00


wait_response:
@L1:
    lda     CH376_COMMAND
    and     #%10000000
    cmp     #128
    bne     @L1

@out:
    lda     #$22
    sta     CH376_COMMAND
    lda     CH376_DATA
    ; status
    rts
;500 :' Wait for command to complete and read error code
;510 LOCATE 1,24:sta = INP(CMD):PRINT"Status: &";HEX$(sta,2);:IF sta > 127 THEN GOTO 510
;520 :' GET_STATUS
;530 OUT CMD,&22
;540 STATUS=INP(DAT):LOCATE 1,1:PRINT"Interrupt status (&14,&1D=OK) = ";HEX$(STATUS,2);
;550 RETURN

.endproc