# Instructions

**Note:** See [../asm/asm.py](asm.py) for a detailed list of instructions, their supported operands and instruction encodings.

## Legend

| Name | Description |
|---|---|
| dst | Destination register |
| src1 | Source operand 1 |
| src2 | Source operand 2 |
| src3 | Source operand 3 |
| i19 | 19-bit immediate value |
| V | Supports vector operation |

## Integer instructions

| Mnemonic | V | Operands | Operation | Description |
|---|---|---|---|---|
|NOP|   | - | - | No operation |
|OR| x | dst, src1, src2 | dst <= src1 \| src2 | Bitwise or |
|NOR| x | dst, src1, src2 | dst <= ~(src1 \| src2)  | Bitwise nor |
|AND| x | dst, src1, src2 | dst <= src1 & src2 | Bitwise and |
|XOR| x | dst, src1, src2 | dst <= src1 ^ src2 | Bitwise exclusive or |
|ADD| x | dst, src1, src2 | dst <= src1 + src2 | Addition |
|SUB| x | dst, src1, src2 | dst <= src2 - src1 | Subtraction (note: argument order) |
|SLT| x | dst, src1, src2 | dst <= (src1 < src2) ? 1 : 0 | Set if less than (signed) |
|SLTU| x | dst, src1, src2 | dst <= (src1 < src2) ? 1 : 0 | Set if less than (unsigned) |
|LSL| x | dst, src1, src2 | dst <= src1 << src2 | Logic shift left |
|ASR| x | dst, src1, src2 | dst <= src1 >> src2 (signed) | Arithmetic shift right |
|LSR| x | dst, src1, src2 | dst <= src1 >> src2 (unsigned) | Logic shift right |
|CLZ| x | dst, src1 | dst <= clz(src1) | Count leading zeros |
|REV| x | dst, src1 | dst <= rev(src1) | Reverse bit order |
|EXTB| x | dst, src1 | dst <= signextend(src1[7:0]) | Sign-extend byte to word |
|EXTH| x | dst, src1 | dst <= signextend(src1[15:0]) | Sign-extend halfword to word |
|LDB| (1) | dst, src1, src2 | dst <= [src1 + src2] (byte) | Load signed byte |
|LDUB| (1) | dst, src1, src2 | dst <= [src1 + src2] (byte) | Load unsigned byte |
|LDH| (1) | dst, src1, src2 | dst <= [src1 + src2] (halfword) | Load signed halfword |
|LDUH| (1) | dst, src1, src2 | dst <= [src1 + src2] (halfword) | Load unsigned halfword |
|LDW| (1) | dst, src1, src2 | dst <= [src1 + src2] (word) | Load word |
|STB| (1) | src1, src2, src3 | [src2 + src3] <= src1 (byte) | Store byte |
|STH| (1) | src1, src2, src3 | [src2 + src3] <= src1 (halfword) | Store halfowrd |
|STW| (1) | src1, src2, src3 | [src2 + src3] <= src1 (word) | Store word |
|MEQ| x | dst, src1, src2 | dst <= src2 if src1 == 0 | Conditionally move if equal to zero |
|MNE| x | dst, src1, src2 | dst <= src2 if src1 != 0 | Conditionally move if not equal to zero |
|MLT| x | dst, src1, src2 | dst <= src2 if src1 < 0 | Conditionally move if less than zero |
|MLE| x | dst, src1, src2 | dst <= src2 if src1 <= 0 | Conditionally move if less than or equal to zero |
|MGT| x | dst, src1, src2 | dst <= src2 if src1 > 0 | Conditionally move if greater than zero |
|MGE| x | dst, src1, src2 | dst <= src2 if src1 >= 0 | Conditionally move if greater than or equal to zero |
|LDI| x | dst, i19 | dst <= signextend(i19) | Load immediate (low 19 bits) |
|LDHI| x | dst, i19 | dst <= i19 << 13 | Load immediate (high 19 bits) |

**(1)**: The third operand in vector loads/stores is used as a stride parameter rather than an offset.

## Branch and jump instructions

| Mnemonic | V | Operands | Operation | Description |
|---|---|---|---|---|
|J|   | src1 | pc <= src1 | Jump to register address |
|JL|   | src1 | lr <= pc+4, pc <= src1 | Jump to register address and link |
|BEQ|   | src1, i19 | pc <= pc+signextend(i19)*4 if src1 == 0 | Conditionally branch if equal to zero |
|BNE|   | src1, i19 | pc <= pc+signextend(i19)*4 if src1 != 0 | Conditionally branch if not equal to zero |
|BGE|   | src1, i19 | pc <= pc+signextend(i19)*4 if src1 >= 0 | Conditionally branch if greater than or equal to zero |
|BGT|   | src1, i19 | pc <= pc+signextend(i19)*4 if src1 > 0 | Conditionally branch if greater than zero |
|BLE|   | src1, i19 | pc <= pc+signextend(i19)*4 if src1 <= 0 | Conditionally branch if less than or equal to zero |
|BLT|   | src1, i19 | pc <= pc+signextend(i19)*4 if src1 < 0 | Conditionally branch if less than zero |
|BLEQ|   | src1, i19 | lr <= pc+4, pc <= pc+signextend(i19)*4 if src1 == 0 | Conditionally branch and link if equal to zero |
|BLNE|   | src1, i19 | lr <= pc+4, pc <= pc+signextend(i19)*4 if src1 != 0 | Conditionally branch and link if not equal to zero |
|BLGE|   | src1, i19 | lr <= pc+4, pc <= pc+signextend(i19)*4 if src1 >= 0 | Conditionally branch and link if greater than or equal to zero |
|BLGT|   | src1, i19 | lr <= pc+4, pc <= pc+signextend(i19)*4 if src1 > 0 | Conditionally branch and link if greater than zero |
|BLLE|   | src1, i19 | lr <= pc+4, pc <= pc+signextend(i19)*4 if src1 <= 0 | Conditionally branch and link if less than or equal to zero |
|BLLT|   | src1, i19 | lr <= pc+4, pc <= pc+signextend(i19)*4 if src1 < 0 | Conditionally branch and link if less than zero |

## Floating point instructions

| Mnemonic | V | Operands | Operation | Description |
|---|---|---|---|---|
|ITOF| x | dst, src1 | dst <= (float)src1 | Cast integer to float |
|FTOI| x | dst, src1 | dst <= (int)src1 | Cast float to integer |
|FADD| x | dst, src1, src2 | dst <= src1 + src2 | Floating point addition |
|FSUB| x | dst, src1, src2 | dst <= src2 - src1 | Floating point subtraction (note: argument order) |
|FMUL| x | dst, src1, src2 | dst <= src1 * src2 | Floating point multiplication |
|FDIV| x | dst, src1, src2 | dst <= src1 / src2 | Floating point division |

## Vector instructions

Most instructions (excluding branch instructions) can be executed in both scalar and vector mode.

For instance the integer instruction `ADD` has the following operation modes:
* `ADD Sd,Sa,Sb` - scalar <= scalar + scalar
* `ADD Sd,Sa,IMM` - scalar <= scalar + scalar
* `ADD Vd,Va,Vb` - vector <= vector + vector
* `ADD Vd,Va,Sb` - vector <= vector + scalar
* `ADD Vd,Va,IMM` - vector <= vector + scalar

## Planned instructions

* Control instructions/registers (cache control, interrupt masks, status flags, ...).
* Load Linked (ll) and Store Conditional (sc) for atomic operations.
* Single-instruction load of common constants (mostly floating point: PI, sqrt(2), ...).
* More DSP-type operations (saturate, packed addition, swizzle, ...).
