    .include "telestrat.inc"
  ;  .include "../dependencies/orix-sdk/macros/SDK_memory.mac"

;.export libusb_get_device_list

.proc libusb_get_device_list
   ; lda    #$00
    rts
.endproc

