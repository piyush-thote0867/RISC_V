module p_c(rst , clk , PC , PC_NEXT);
input [31:0] PC_NEXT;
input clk , rst;

output reg [31:0] PC;

always @(posedge clk)
begin
    if(rst == 1'b0)         // active-low reset
        PC <= 32'h0;
    else
        PC <= PC_NEXT;      // FIX: syntax error tha (PC_NEXT = PC <= PC_NEXT:)
end
endmodule
