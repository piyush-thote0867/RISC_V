module alu_decoder(ALUOp , func3, func7 , op5 ,ALUControl);   // FIX: port list mein op tha, op5 hona chahiye

input  op5 , func7;
input [2:0] func3;      // FIX: [1:0] tha, func3 3-bit hai
input [1:0] ALUOp;      // FIX: [2:0] tha, ALUOp 2-bit hai
output [2:0] ALUControl;

wire [1:0] concatenation;
assign concatenation = {op5, func7};   // 11 ho toh sub, baaki sab add

assign ALUControl = (ALUOp == 2'b00) ? 3'b000 :                                 // lw/sw: add
                    (ALUOp == 2'b01) ? 3'b001 :                                 // beq: sub
                    (func3 == 3'b000) ? ((concatenation == 2'b11) ? 3'b001      // sub
                                                                  : 3'b000) :   // add, addi
                    (func3 == 3'b010) ? 3'b101 :                                // slt
                    (func3 == 3'b110) ? 3'b011 :                                // or
                    (func3 == 3'b111) ? 3'b010 : 3'b000; //and
endmodule
