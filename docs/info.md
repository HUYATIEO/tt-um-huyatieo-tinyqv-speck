TinyQV SoC - Speck Hardware Accelerated EditionProject: tt_um_huyatieo_tinyqv_speckThis design is based on the TinyQV RISC-V (RV32EC) soft-core microcontroller, featuring Custom Hardware Instructions specifically designed to accelerate the Speck64/128 lightweight block cipher algorithm. Despite the addition of custom cryptographic instructions, the entire design fits seamlessly into a 2x2 tile without increasing the overall silicon area.1. Custom ISA Extensions (Hardware Acceleration)To drastically reduce clock cycles and optimize cryptographic throughput, the TinyQV ALU and Decoder have been modified to support custom RISC-V instructions. These instructions fuse multiple standard operations into single-cycle hardware execution.InstructionHardware OperationBenefitspeck_sumrd = (rs1 ROR 8) + rs2Replaces 4 standard instructions (srli, slli, or, add).speck_xorrd = (rs1 ROL 3) ^ rs2Replaces 4 standard instructions (slli, srli, or, xor).Assembly ImplementationBoth instructions use the Standard R-Type Format mapped to the Custom-0 opcode space (0x0B). You can invoke them using the .insn R directive:Đoạn mã/* speck_sum: Opcode 0x0B, Funct3 0b000 */
.macro speck_sum rd, rs1, rs2
    .insn R 0x0B, 0, 0, \rd, \rs1, \rs2
.endm

/* speck_xor: Opcode 0x0B, Funct3 0b001 */
.macro speck_xor rd, rs1, rs2
    .insn R 0x0B, 1, 0, \rd, \rs1, \rs2
.endm
2. Register Map & Usage GuidelinesTinyQV implements the RV32EC (Embedded) instruction set, providing 16 general-purpose registers (x0 to x15).[!CAUTION]Critical Hardware ConstraintYou MUST STRICTLY AVOID using the following registers for general calculations, as they are hardwired in this SoC:x3 (gp): Hardcoded to 0x1000400.x4 (tp): Hardcoded to 0x8000000 (Base address for MMIO: UART & SPI).Safe Registers: x1, x2, and x5 through x15 are fully available for standard RISC-V calling conventions.NSA Standard Test Vector (Reference)Verify your implementation against the official Speck64/128 Test Vector:Key: 1b1a1918 13121110 0b0a0908 03020100Plaintext: 3b726574 7475432dExpected Ciphertext: 8c6fa548 454e028b (After 27 rounds).3. Simulation Guide (Cocotb)This project utilizes Cocotb and Icarus Verilog for RTL-level simulation.Environment RequirementsOS: Ubuntu (24.04 recommended)Toolchain: gcc-riscv64-unknown-elfPython: Cocotb library installedPractical Simulation StepsStep 1: Compile the FirmwareConvert Assembly source code into 1-byte aligned Hex format.Bash# Compile and Link
riscv64-unknown-elf-gcc -march=rv32ec -mabi=ilp32e -nostdlib -T link.ld firmware.S -o firmware.elf

# Convert to Verilog Hex
riscv64-unknown-elf-objcopy -O verilog --verilog-data-width=1 firmware.elf firmware_raw.hex

# Format adjustment for simulation
python3 fix_hex.py firmware_raw.hex asm/firmware.hex
Step 2: Clear Simulation CacheBashrm -rf sim_build/
Step 3: Run SimulationExecute the Cocotb testbench while pointing to the compiled firmware:Bashmake COCOTB_TESTCASE=test_dump COMPILE_ARGS="-DPROG_FILE=\\\"`pwd`/asm/firmware.hex\\\""
Step 4: Waveform AnalysisView the instruction fetch process and hardware signals using GTKWave:Bashgtkwave wave_fpga_top.vcd
