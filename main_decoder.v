module main_decoder( RegWrite ,op,zero,MemWrite ,ResultSrc,ALUSrc,ImmSrc ,ALUOp,PCSrc);
//inputs
input zero;
input [6:0] op;
output RegWrite ,MemWrite , ResultSrc , ALUSrc,PCSrc;
output [1:0] ImmSrc ,ALUOp;

wire branch;

//assignment
assign RegWrite = (op == 7'b0000011 | op == 7'b0110011 | op == 7'b0010011) ? 1'b1 : 1'b0;  // FIX: addi (0010011) add kiya
assign MemWrite  = (op == 7'b0100011);                                       // sw
assign ResultSrc = (op == 7'b0000011);                                       // lw
assign ALUSrc    = (op == 7'b0000011 | op == 7'b0100011 | op == 7'b0010011); // lw, sw, addi
assign branch    = (op == 7'b1100011);                                       // beq

assign ImmSrc = (op == 7'b0100011) ? 2'b01 :       // sw  -> S-type
                (op == 7'b1100011) ? 2'b10 :       // beq -> B-type
                                     2'b00;        // lw, addi -> I-type

assign ALUOp  = (op == 7'b1100011) ? 2'b01 :                      // beq: sub
                (op == 7'b0110011 | op == 7'b0010011) ? 2'b10 :   // R-type, addi: funct3 dekho
                                     2'b00;                       // lw, sw: add

assign PCSrc  = branch & zero;

endmodule
