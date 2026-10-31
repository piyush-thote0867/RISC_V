module data_memo(A , WD3 , clk , WE , rst ,RD);

input [31:0] A ,WD3;
input clk , rst , WE;

output  [31:0] RD;
reg [31:0] memo[0:1023];
assign RD = (WE == 1'b0) ? memo[A[11:2]] : 32'b0;   // FIX: word index = A[11:2]
integer i;
always @(posedge clk) begin
    if( (rst == 1'b0)) begin
        for( i = 0 ; i< 1024 ;i = i+1) memo[i] <= 32'b0;
    end
    else if(WE)
    memo[A[11:2]] <= WD3;                           // FIX: A[11:2]

end
endmodule
