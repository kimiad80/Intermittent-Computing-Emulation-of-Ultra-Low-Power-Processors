.option norvc
.section .text.init
.global _start
.global main_entry

.equ NV_DIRTY_BIT_ADDR, 0x00010000
.equ NV_PC_ADDR, 0x00010004
.equ NV_REG_FILE_ADDR, 0x00010008
.equ NV_MSTATUS_ADDR, 0x0001002c
.equ NV_MIE_ADDR, 0x00010028
.equ STACK_START, 0x0000FF00
.equ BSS_START, 0x0000C000
.equ BSS_END, 0x0000C400

.section .text.init
.global _start
_start:
    j main_entry
    .align 2

main_entry:
    li sp, STACK_START
	mv s0, sp
	addi x10, x0, 0
	addi x11, x0, 0
    
    li t0, 0x140
    csrw mtvec, t0

    li x1, NV_DIRTY_BIT_ADDR
    lw x1, 0(x1)
    bnez x1, dummy_main

    la x26, BSS_START
    la x27, BSS_END
    bge x26, x27, zero_loop_end
	
zero_loop:
    sw x0, 0(x26)
    addi x26, x26, 4
    ble x26, x27, zero_loop
zero_loop_end:
    jal x1, main
	jal x0, both

dummy_main:
    li x1, NV_REG_FILE_ADDR
    lw x28, 0(x1); mv a0, x28
    lw x28, 4(x1); mv a1, x28
    lw x28, 8(x1); mv a2, x28
    lw x28, 12(x1); mv a3, x28
    lw x28, 16(x1); mv a4, x28
    lw x28, 20(x1); mv a5, x28
    lw x28, 24(x1); mv a6, x28
    lw x28, 28(x1); mv a7, x28
    lw x28, 32(x1); csrw mie, x28
    lw x28, 36(x1); csrw mstatus, x28
    sw x0, -8(x1)         // Clear dirty bit
    lw x28, -4(x1)        // Load saved PC
    jalr x1, 0(x28)       // Jump to saved PC

both:
    j both
	
