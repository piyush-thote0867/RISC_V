module r_f(A1 , A2 ,A3 , clk , WD3 , WE3 , rst ,RD1,RD2);
input [4:0] A1 , A2 ,A3 ; // address line
input clk , rst  ,WE3;
input  [31:0] WD3;                // likhne wala data
output [31:0] RD1, RD2;

reg [31:0] Register [31:0];
integer i;                         // FIX: i declare nahi tha

//x0 @ 0
assign RD1 = (rst == 1'b0) ? 32'h0 : (A1 == 5'b0) ? 32'h0 : Register[A1];
assign RD2 = (rst == 1'b0) ? 32'h0 : (A2 == 5'b0) ? 32'h0 : Register[A2];

//now clock
always @(posedge clk) begin
    if  (rst ==1'b0)begin
        for (i=0 ; i<32 ;i = i+1) Register[i] <= 32'h0;   // FIX: i==0 -> i=0
    end
    else if ( WE3 && (A3 != 5'b0)) Register[A3] <= WD3;
end

endmodule
