@echo off
echo [BUILD] Assembling Bootloader....

@echo on
call fasm bootloader.asm

@echo off
if errorlevel 1 (
   echo [BUILD] Error: Assembler failed
   exit /b 1
)

echo [BUILD] Formatting foppy disk image...

@echo on
call dd if=bootloader.bin of=bootloader.flp

@echo off
if errorlevel 1 (
   echo [BUILD] Error: Floppy format failed
   exit /b 1
)

echo [BUILD] Success
