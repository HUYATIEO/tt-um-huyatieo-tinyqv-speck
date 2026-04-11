# TinyQV SoC - Speck Hardware Accelerated Edition
**Project:** `tt_um_huyatieo_tinyqv_speck`

This design is based on the TinyQV RISC-V (RV32EC) soft-core microcontroller, featuring **Custom Hardware Instructions** specifically designed to accelerate the **Speck64/128** lightweight block cipher algorithm at the bare-metal level. It also integrates direct simulation testing tools via Cocotb.

## 1. Custom ISA Extensions (Hardware Acceleration)
To drastically reduce clock cycles and optimize cryptographic throughput, the TinyQV ALU and Decoder have been modified to support custom RISC-V instructions. These instructions fuse multiple standard operations (bitwise rotations, additions, and XORs) into single-cycle hardware execution, bypassing the limitations of the standard RV32EC instruction set.

* **`speck_sum` (Custom Add & Rotate Right):**
  * **Hardware Operation:** `rd = (rs1 ROR 8) + rs2`
  * **Benefit:** Replaces the standard 4-instruction sequence (`srli`, `slli`, `or`, `add`) with a single hardware instruction.
* **`speck_xor` (Custom XOR & Rotate Left):**
  * **Hardware Operation:** `rd = (rs1 ROL 3) ^ rs2`
  * **Benefit:** Replaces the standard 4-instruction sequence (`slli`, `srli`, `or`, `xor`) with a single hardware instruction.

By utilizing these custom instructions, the execution time for the Speck round function and Key Schedule is significantly reduced, maximizing the efficiency of the SoC.

## 2. Speck64/128 Execution Flow

Due to the hardware architectural limits of TinyQV (only 16 registers, with `x3` and `x4` hardcoded), the Speck64/128 execution flow is strictly managed to avoid system conflicts.

**Register Map & Resource Allocation:**
* **Plaintext / Ciphertext (64-bit):** Uses `x10` (High block - x) and `x11` (Low block - y).
* **Key (128-bit):** Uses registers `x12` through `x15`.
* **System Registers (Strictly Reserved):** `x1` (ra), `x2` (sp), `x3` (gp - hardwired to `0x1000400`), `x4` (tp - hardwired to `0x8000000`).

**NSA Standard Test Vector:**
The Speck hardware flow is verified for absolute accuracy using the official NSA Test Vector:
* **Key:** `1b1a1918 13121110 0b0a0908 03020100`
* **Plaintext:** `3b726574 7475432d`
* **Expected Ciphertext:** `8c6fa548 454e028b` (Extracted from `x10` and `x11` after 27 rounds).

---

## 3. Simulation Guide (Testing with Cocotb)

This project utilizes **Cocotb** and **Icarus Verilog** for RTL-level simulation. The test environment simulates the QSPI ROM structure, UART, and the CPU's instruction fetch process.

### Environment Requirements
* OS: Ubuntu (24.04 recommended).
* Toolchain: `gcc-riscv64-unknown-elf` (for Assembly compilation) and Cocotb Python.

### Practical Simulation Steps

**Step 1: Compile the Firmware (Assembly to Hex)**
The Speck (or UART) source code written in `.S` must be compiled and converted into a 1-byte aligned Hex format to be loaded into the `fpga_qspi_rom.v` simulation block.
```bash
riscv64-unknown-elf-gcc -march=rv32ec -mabi=ilp32e -nostdlib -T link.ld firmware.S -o firmware.elf
riscv64-unknown-elf-objcopy -O verilog --verilog-data-width=1 firmware.elf firmware_raw.hex
python3 fix_hex.py firmware_raw.hex asm/firmware.hex
