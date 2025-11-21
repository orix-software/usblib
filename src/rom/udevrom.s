.include   "telestrat.inc"
.include   "fcntl.inc"
;.include   "build.inc"

userzp := $80 ; FIXME

.import _udevadm

.org $c000

.code
rom_start:
        rts

;.include "../commands/_udevadm.s"

rom_signature:
	.asciiz   "Udev v2024.1"


udevadm_str:
        .asciiz "udevadm"

commands_text:
        .addr udevadm_str

commands_address:
        .addr _udevadm

commands_version:
        .asciiz "0.0.1"

; ----------------------------------------------------------------------------
; Copyrights address

        .res $FFF0-*
        .org $FFF0
; $fff0
; $00 : empty ROM
; $01 : command ROM
; $02 : TMPFS
; $03 : Drivers
; $04 : filesystem drivers
type_of_rom:
    .byt $01
; $fff1
parse_vector:
        .byt $00,$00
; fff3
adress_commands:
        .addr commands_address
; fff5
list_commands:
        .addr udevadm_str
; $fff7
number_of_commands:
        .byt 1
signature_address:
        .word   rom_signature

; ----------------------------------------------------------------------------
; Version + ROM Type
ROMDEF:
        .addr rom_start

; ----------------------------------------------------------------------------
; RESET
rom_reset:
        .addr   rom_start
; ----------------------------------------------------------------------------
; IRQ Vector
empty_rom_irq_vector:
        .addr   IRQVECTOR ; from telestrat.inc (cc65)
end: