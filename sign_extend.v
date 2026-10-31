// FIX: pura rewrite - sirf I-type tha, ImmSrc input nahi tha, syntax errors the
module imm_gen(instr, ImmSrc, ImmExt);
input  [31:0] instr;
input  [1:0]  ImmSrc;
output [31:0] ImmExt;

assign ImmExt = (ImmSrc == 2'b00) ? {{20{instr[31]}}, instr[31:20]} :                                   // I-type
                (ImmSrc == 2'b01) ? {{20{instr[31]}}, instr[31:25], instr[11:7]} :                      // S-type
                (ImmSrc == 2'b10) ? {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0} :      // B-type
                                    32'h0;
endmodule
