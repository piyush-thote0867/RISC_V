# Single-Cycle RISC-V CPU (RV32I subset) in Verilog

Course project: *Datapath and decoder for RISC-V 16-bit (compressed) instructions*.
This repo has the 32-bit single-cycle CPU. The 16-bit RVC part is the next step.

## Supported instructions
`add`, `sub`, `and`, `or`, `slt`, `addi`, `lw`, `sw`, `beq`

## Files
| File | Module | Job |
|---|---|---|
| `single_cycle_top.v` | `single_cycle_top` | connects everything |
| `Program_counter.v` | `p_c` | PC register (active-low reset) |
| `PC_Adder.v` | `PC_Adder` | PC+4 and branch target |
| `instruction_memory.v` | `Instr_memo` | 1024 words, loads `program.hex` |
| `Register_file.v` | `r_f` | 32 registers, x0 = 0 |
| `sign_extend.v` | `imm_gen` | I, S, B immediates |
| `alu.v` | `alu` | add, sub, and, or, slt + flags |
| `main_decoder.v` | `main_decoder` | control signals from opcode |
| `alu_decoder.v` | `alu_decoder` | ALUControl from funct3/funct7 |
| `control_unit_top.v` | `Control_Unit_Top` | main decoder + ALU decoder |
| `data_memo.v` | `data_memo` | 1024 words data memory |
| `single_cycle_tb.v` | `single_cycle_tb` | self-checking testbench |
| `program.hex`, `program2.hex` | | test programs |

## Conventions
- Reset is **active-low** (`rst = 0` resets, `rst = 1` runs).
- Memories are indexed by `A[11:2]` (byte address / 4).

## Run (Icarus Verilog)
Keep all files and both `.hex` files in one folder:
```
iverilog -o cpu_sim single_cycle_tb.v
vvp cpu_sim
gtkwave cpu.vcd
```
The last line should say `ALL PASS`.
(The `$readmemh ... Not enough words` warning is harmless.)

## Tests
- **Test 1** (`program.hex`): add, sub, and, or, slt, sw, lw, beq taken.
- **Test 2** (`program2.hex`): negative immediate, slt both ways, write to x0 ignored, sw/lw with offset, beq not taken.

The testbench checks registers, data memory and final PC.

## Next
RVC (16-bit compressed) expander and PC +2/+4 fetch logic.