; Good documentation on an x86 bootloader found here:
;     https://en.wikibooks.org/wiki/X86_Assembly/Bootloaders

; The Bootsector
; ------------------------------------------------------------------------------
; The first 512 bytes of a disk are known as the bootsector or Master Boot Record.
; The boot sector is an area of the disk reserved for booting purposes.
; If the bootsector of a disk contains a valid boot sector (the last word of the
; sector must contain the signature 0xAA55), then the disk is treated by the BIOS
; as bootable.


; The code must be in sector 0 (master boot record) of the drive
; The dl register will contain the drive number the bootloader code was loaded from
; This code will be loaded at 7C00h
; 
; BIOS interrupts
;  int 10h (displaying text/graphics)
;  int 13h (disk)
;  int 16h (keyboard)
	
use16 				; x86 starts in 16 bit mode

start:
	; Set up 4K stack space after this bootloader
	; (4096 + 512) / 16 bytes per paragraph
	mov ax, 08E0h
	mov ss, ax
	mov sp, 1000h

	mov ax, 07C0h		; Set data segment to where we're loaded
	mov ds, ax

	mov si, start_message   ; Print start message
	call bootloader_log

	; Print the drive it was loaded from
	add dl,'0'
	mov [drive_message_end-2], dl
	mov si, drive_message   ; Print start message
	call bootloader_log
	

	; Not Implemented
	mov si, not_implemented_message
	call bootloader_log

	jmp $			; Jump here - infinite loop!

start_message:           db "start", 0
drive_message:           db "loaded from drive ?", 0
drive_message_end:
not_implemented_message: db "finished (not implemented)", 0
bootloader_prefix:       db "bootloader: ",0	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bootloader_log:
	; output string to screen using bios interrupt
	; input: si points to address of null-terminated string
	push si	
	mov si, bootloader_prefix
	call print
	pop si
	call println	
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
println:
	call print
	mov al, 0Dh             ; print '\r'
	int 10h
	mov al, 0Ah             ; print '\n'
	int 10h
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print:
	; output string to screen using bios interrupt
	; input: si points to address of null-terminated string
	mov ah, 0Eh		; Argument for interrupt 10 which says to
	                        ; print the character in al to the screen
.while_not_null:
	lodsb			; load next byte from memory pointed to by si
	                        ; into al and increment si
	cmp al, 0
	je .no_more_chars	; If char is zero, end of string
	int 10h			; Otherwise, print it
	jmp .while_not_null
.no_more_chars:
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; Boot Sector Signature
	
