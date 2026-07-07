# Intermittent-Computing-Emulation-of-Ultra-Low-Power-Processors
A SystemVerilog implementation of the paper:

> *Intermittent Computing Emulation of Ultra-Low-Power Processors: Evaluation of Backup Strategies for RISC-V*

## Overview

This project implements an intermittent computing emulator for a RISC-V processor. The emulator models power failures and state backup/recovery mechanisms to evaluate different backup strategies for ultra-low-power systems.

## Features

- RV32I-compatible processor
- Intermittent power failure emulation
- Non-volatile memory state backup
- Interrupt-based checkpoint mechanism
- SystemVerilog implementation
- RISC-V software examples

## Repository Structure

```
.
├── rtl/                 # RTL source files
├── tb/                  # Testbench
├── software/            # RISC-V software
├── scripts/             # Utility scripts
├── output.mem           # Instruction memory image
└── README.md
```

## Building the Software

Compile the software using a RISC-V GCC toolchain:

```bash
riscv32-unknown-elf-gcc -march=rv32imc_zicsr -mabi=ilp32 -c main.c -o main.o

riscv32-unknown-elf-gcc -march=rv32imc_zicsr -mabi=ilp32 -c crt0.S -o crt0.o

riscv32-unknown-elf-gcc -nostartfiles -T link.ld crt0.o main.o -o program.elf

riscv32-unknown-elf-objcopy -O binary program.elf program.bin 
```

Convert the generated binary into a Verilog memory file:

```bash
python bin_to_mem.py program.bin program.mem
```

## Simulation

Load `program.mem` into the instruction memory and run the SystemVerilog simulation using your preferred simulator.

## Requirements

- RISC-V GCC Toolchain
- Python 3
- A SystemVerilog simulator

## Reference

If you use this project, please cite the original paper:

> *Intermittent Computing Emulation of Ultra-Low-Power Processors: Evaluation of Backup Strategies for RISC-V*
