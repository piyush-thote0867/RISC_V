module Instr_memo (A , rst , RD);
input [31:0] A; // register in a memory
input  rst;
output [31:0] RD;
//memory
reg [31:0] Mem [0:1023];

initial $readmemh("program.hex", Mem);              // FIX: program load nahi ho raha tha

assign RD = (rst == 1'b1) ? Mem[A[11:2]] : 32'h0 ; // FIX: A[11:2]

endmodule
