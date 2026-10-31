module alu(A,B,ALUControl , Result ,Z ,N ,V,C);

input [31:0] A ,B; //32 bit
input [2:0] ALUControl;
// decalring output
output Z ,N,V,C;
output [31 : 0] Result ;

//logic
wire [31:0] a_and_b;
wire [31:0] a_or_b;
wire [31:0] not_b;
wire [31 :0] mux_1;
wire[31:0] sum ;
wire [31:0] mux_2;
wire cout ;
wire [31 :0 ]slt;

assign a_and_b = A& B;
assign a_or_b = A | B;

// not aperation
assign not_b = ~B;
assign mux_1 = (ALUControl[0] ==1'b0 ) ? B :~B;
assign {cout , sum } = A+ mux_1 + ALUControl[0];

assign slt = {31'b0, sum[31]^V};   // FIX: {31'b0 + ...} galat tha, comma chahiye

assign mux_2 = (ALUControl == 3'b000) ? sum :
               (ALUControl == 3'b001) ? sum :
               (ALUControl == 3'b010) ? a_and_b :
               (ALUControl == 3'b011) ? a_or_b :
               (ALUControl == 3'b101) ? slt :
                                        32'b0;

assign Result = mux_2;

assign Z = ~(|Result); // agar ek bhi 1 hue toh zero else 1
assign N = Result[31];
assign C= cout & ~ALUControl[1];
assign V =  ~(ALUControl[0] ^ A[31] ^ B[31]) & (A[31] ^ sum[31]) & ~ALUControl[1];

endmodule
