MEMORY {
    IMEM (rx)   : ORIGIN = 0x00000000, LENGTH = 32K  /* Instruction memory */
    DMEM (rw)   : ORIGIN = 0x00008000, LENGTH = 32K  /* Data memory */
    NV_REG (rw) : ORIGIN = 0x00010000, LENGTH = 64   /* Non-volatile memory */
    PERIMEM (rw): ORIGIN = 0x20000000, LENGTH = 12   /* Peripheral memory */
}

SECTIONS {
    .text : {
        . = 0x00000000;          /* Reset vector at 0x00 */
        KEEP(*(.text.init))      /* _start and main_entry */

        /* Place handler at 0x140 */
        . = 0x140;
        KEEP(*(.text.fast_irq_handler_nv_write))

        /* Other code (exclude handler section) */
        *(.text* .text.*)
        *(.rodata*)
        . = ALIGN(4);
    } > IMEM

    .data : {
        *(.data*)
        . = ALIGN(4);
    } > DMEM

    .bss : {
        _bss_start = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _bss_end = .;
    } > DMEM

    .stack : {
        _stack_bottom = .;
        . = . + 0x400;  /* 1 KB stack */
        _stack_top = .;
    } > DMEM

    .milestone 0x20000008 : {
        KEEP(*(.milestone))
    } > PERIMEM
}