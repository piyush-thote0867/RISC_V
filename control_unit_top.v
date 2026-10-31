`include "main_decoder.v"
`include "alu_decoder.v"

module Control_Unit_Top (op, func3, func7, zero,
                         RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, PCSrc, ALUControl);
input  [6:0] op;
input  [2:0] func3;
input        func7, zero;            // func7 = instr[30]
output       RegWrite, ALUSrc, MemWrite, ResultSrc, PCSrc;
output [1:0] ImmSrc;
output [2:0] ALUControl;

wire [1:0] ALUOp;

main_decoder md (.RegWrite(RegWrite), .op(op), .zero(zero), .MemWrite(MemWrite),
                 .ResultSrc(ResultSrc), .ALUSrc(ALUSrc), .ImmSrc(ImmSrc),
                 .ALUOp(ALUOp), .PCSrc(PCSrc));

alu_decoder  ad (.ALUOp(ALUOp), .func3(func3), .func7(func7),
                 .op5(op[5]), .ALUControl(ALUControl));
endmodule
