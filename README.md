# Single-Cycle RISC-V CPU (RV32I subset) in Verilog

A single-cycle RISC-V processor written in Verilog, built as the base for a
"Datapath and decoder for RISC-V 16-bit (compressed) instructions" project.

## Status

| Part | Status |
|---|---|
| Single-cycle RV32I subset (9 instructions) | Done, simulation tests pass |
| 16-bit compressed (RVC) decoder / expander | Not started |
| ModelSim run | Not done yet (simulated with Icarus Verilog 12) |

## Supported instructions

| Type | Instructions |
|---|---|
| R-type | `add`, `sub`, `and`, `or`, `slt` |
| I-type | `addi`, `lw` |
| S-type | `sw` |
| B-type | `beq` |

Not supported: `jal`, `jalr`, `lui`, `auipc`, shifts, `xor`, other branches,
byte/half-word loads and stores.

## Architecture

Standard single-cycle datapath: one instruction completes per clock cycle.

```
PC -> Instruction Memory -> instr
instr -> Control Unit (main decoder + ALU decoder) -> control signals
instr -> Register File -> RD1, RD2
instr -> Sign Extend -> immediate
RD1, (RD2 or immediate) -> ALU -> ALUResult
ALUResult -> Data Memory -> ReadData
(ALUResult or ReadData) -> write back to Register File
PC -> PC + 4, or PC + immediate when beq is taken
```

Three muxes: `ALUSrc` (register or immediate), `ResultSrc` (ALU result or memory
data), `PCSrc` (PC + 4 or branch target, `PCSrc = Branch & Zero`).

### Modules

| File | Module | Purpose |
|---|---|---|
| `single_cycle_top.v` | `single_cycle_top` | Connects everything |
| `program_counter.v` | `p_c` | Program counter |
| `instruction_memory.v` | `Instr_memo` | Instruction memory, loaded from `program.hex` |
| `Register_file.v` | `r_f` | 32 x 32-bit registers, x0 hardwired to 0 |
| `sign_extend.v` | `Sign` | Immediate generation with sign extension |
| `alu.v` | `alu` | add, sub, and, or, slt, plus Z/N/V/C flags |
| `control_unit_top.v` | `Control_Unit_Top` | Wraps `main_decoder` and `alu_decoder` |
| `main_decoder.v` | `main_decoder` | Opcode to control signals |
| `alu_decoder.v` | `alu_decoder` | ALUOp/funct3/funct7 to ALU control |
| `data_memo.v` | `data_memo` | Data memory |

### ALU control codes

| Code | Operation |
|---|---|
| `000` | ADD |
| `001` | SUB |
| `010` | AND |
| `011` | OR |
| `101` | SLT |

## Design notes

- Reset (`rst`) is active-low: `0` = reset, `1` = run.
- Instruction and data memories are 1024 words, indexed by `address[11:2]`
  (byte address divided by 4). Higher address bits are ignored, so addresses wrap.
- Register file: synchronous write, combinational read.
- `sub` is selected only when `{op[5], funct7[5]} == 2'b11`, so `addi` with a
  negative immediate is never decoded as `sub`.

## How to run

Requires [Icarus Verilog](https://bleyer.org/icarus/). Run from the project folder
(`program.hex` and `program2.hex` must be in the same folder):

```
iverilog -o cpu_sim single_cycle_tb.v
vvp cpu_sim
```

The testbench includes the top module, which includes all other files, so only the
testbench is passed to `iverilog`. It writes `cpu.vcd` for waveform viewing.

The `$readmemh ... Not enough words in the file` warning is expected: the hex files
have fewer lines than the 1024-word memory.

## Test results

The testbench loads a program, runs it, and compares registers and memory against
expected values.

**Test 1** (`program.hex`): add, sub, and, or, slt, addi, sw, lw, beq

| Check | Value |
|---|---|
| x1, x2 | 5, 10 |
| x3 (add) | 15 |
| x4 (sub) | 5 |
| x5 (and) | 0 |
| x6 (or) | 15 |
| x7 (slt) | 1 |
| x8 (lw from mem[0]) | 15 |
| x9 (skipped by beq) | 0 |
| x10 | 1 |
| mem[0] (sw) | 15 |
| Final PC | 0x30 |

**Test 2** (`program2.hex`): includes negative values

| Check | Value |
|---|---|
| x1 | 0xfffffffb (-5) |
| x2 | 3 |
| x3 | 0xfffffffe (-2) |
| x4 | 1 |
| x5 | 0 |
| x6 | 8 |
| x7 | 7 |
| x8 | 8 |
| x9 | 0xfffffffe (-2) |
| mem[1] | 0xfffffffe (-2) |
| Final PC | 0x30 |

Result: **ALL PASS** (Icarus Verilog 12).

## Next steps

1. 16-bit RVC expander (compressed instruction to its 32-bit equivalent), reusing
   the existing decoder.
2. Fetch logic for 2-byte aligned PC (PC advances by 2 or 4).
3. Verify in ModelSim.