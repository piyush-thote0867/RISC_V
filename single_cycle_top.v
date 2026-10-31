
`include "Program_counter.v"
`include "instruction_memory.v"
`include "Register_file.v"
`include "sign_extend.v"
`include "alu.v"
`include "control_unit_top.v"

`include "data_memo.v"
`include "PC_Adder.v"

module single_cycle_top(clk ,rst );

input clk , rst ;

wire [31:0] PC_Top ,PCPlus4, PCTarget, PC_Next, RD_Instr , RD1_Top , RD2_Top, Imm_Ext_Top, SrcB, ALUResult , ReadData, Result;
wire [2:0] ALUControl_Top;      // FIX: 32-bit tha, 3-bit chahiye
wire [1:0] ImmSrc;
wire RegWrite, ALUSrc, MemWrite, ResultSrc, PCSrc, Zero;

// PC
p_c PC(
    .rst(rst) ,
    .clk(clk) ,
    .PC(PC_Top) ,               // FIX: PC_TOP / PC_Top naam mismatch
    .PC_NEXT(PC_Next)
);

PC_Adder PC_Plus4(              // PC + 4
    .a(PC_Top),                 // FIX: ';' ki jagah ','
    .b(32'd4),
    .c(PCPlus4)
);

PC_Adder PC_Branch(             // PC + imm (beq target)
    .a(PC_Top),
    .b(Imm_Ext_Top),
    .c(PCTarget)
);

assign PC_Next = PCSrc ? PCTarget : PCPlus4;    // branch taken -> target

// Instruction memory
Instr_memo Instr_memo(
    .rst(rst),
    .A(PC_Top),
    .RD(RD_Instr)
);

// Register file
r_f rf(
    .A1(RD_Instr[19:15]) ,
    .A2(RD_Instr[24:20]) ,      // FIX: rs2 connect kiya
    .A3(RD_Instr[11:7]) ,
    .clk(clk) ,
    .WD3(Result) ,              // FIX: ReadData ki jagah Result (mux ke baad)
    .WE3(RegWrite) ,
    .rst(rst) ,
    .RD1(RD1_Top),
    .RD2(RD2_Top)
);                              // FIX: ';' missing tha

// Immediate generator
imm_gen Sign(
    .instr(RD_Instr),
    .ImmSrc(ImmSrc),
    .ImmExt(Imm_Ext_Top)
);

// ALU
assign SrcB = ALUSrc ? Imm_Ext_Top : RD2_Top;   // FIX: SrcB mux

alu alu(
    .A(RD1_Top),
    .B(SrcB),
    .ALUControl(ALUControl_Top) ,
    .Result(ALUResult) ,
    .Z(Zero) ,
    .N() ,
    .V(),
    .C()
);

// Control unit
Control_Unit_Top Control_Unit(  // FIX: instance name missing tha
    .op(RD_Instr[6:0]),
    .func3(RD_Instr[14:12]),
    .func7(RD_Instr[30]),
    .zero(Zero),
    .RegWrite(RegWrite),
    .ImmSrc(ImmSrc),
    .ALUSrc(ALUSrc),
    .MemWrite(MemWrite),
    .ResultSrc(ResultSrc),
    .PCSrc(PCSrc),
    .ALUControl(ALUControl_Top)
);

// Data memory
data_memo dm(
    .A(ALUResult) ,
    .WD3(RD2_Top) ,
    .clk(clk) ,
    .WE(MemWrite) ,
    .rst(rst) ,
    .RD(ReadData)
);

assign Result = ResultSrc ? ReadData : ALUResult;   // write-back mux

endmodule
