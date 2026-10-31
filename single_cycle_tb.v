`include "single_cycle_top.v"

module single_cycle_tb;
reg clk = 0, rst = 0;
integer errors = 0;

single_cycle_top dut(.clk(clk), .rst(rst));

always #5 clk = ~clk;

// register check
task check_reg;
input [31:0] n;
input [31:0] expected;
begin
    if (dut.rf.Register[n] !== expected) begin
        $display("FAIL x%0d = %h (expected %h)", n, dut.rf.Register[n], expected);
        errors = errors + 1;
    end else
        $display("ok   x%0d = %h", n, dut.rf.Register[n]);
end
endtask

// data memory word check
task check_mem;
input [31:0] w;
input [31:0] expected;
begin
    if (dut.dm.memo[w] !== expected) begin
        $display("FAIL mem[%0d] = %h (expected %h)", w, dut.dm.memo[w], expected);
        errors = errors + 1;
    end else
        $display("ok   mem[%0d] = %h", w, dut.dm.memo[w]);
end
endtask

// PC check (end of program loop)
task check_pc;
input [31:0] expected;
begin
    if (dut.PC_Top !== expected) begin
        $display("FAIL PC = %h (expected %h)", dut.PC_Top, expected);
        errors = errors + 1;
    end else
        $display("ok   PC = %h", dut.PC_Top);
end
endtask

initial begin
    $dumpfile("cpu.vcd");
    $dumpvars(0, single_cycle_tb);

    // ---------- TEST 1: program.hex (add sub and or slt sw lw beq-taken) ----------
    $display("--- TEST 1 ---");
    #12 rst = 1;
    #200;
    check_reg(0, 0);
    check_reg(1, 5);   check_reg(2, 10);  check_reg(3, 15);  check_reg(4, 5);
    check_reg(5, 0);   check_reg(6, 15);  check_reg(7, 1);   check_reg(8, 15);
    check_reg(9, 0);   check_reg(10, 1);
    check_mem(0, 15);
    check_pc(32'h30);                  // last instr (beq x0,x0,0) par atka hai

    // ---------- TEST 2: program2.hex (negative imm, slt both ways, x0, sw/lw offset, beq-not-taken) ----------
    $display("--- TEST 2 ---");
    rst = 0;                           // reset
    #20;
    $readmemh("program2.hex", dut.Instr_memo.Mem);
    rst = 1;
    #200;
    check_reg(0, 0);                   // addi x0 ignore hona chahiye
    check_reg(1, 32'hFFFFFFFB);        // -5
    check_reg(2, 3);
    check_reg(3, 32'hFFFFFFFE);        // -2
    check_reg(4, 1);                   // -5 < 3
    check_reg(5, 0);                   // 3 < -5 false
    check_reg(6, 8);                   // 3 - (-5)
    check_reg(7, 7);                   // beq not taken -> ye chala
    check_reg(8, 8);
    check_reg(9, 32'hFFFFFFFE);        // sw/lw offset 4
    check_mem(1, 32'hFFFFFFFE);
    check_pc(32'h30);

    if (errors == 0) $display("ALL PASS"); else $display("%0d FAIL", errors);
    $finish;
end

initial begin #5000; $display("TIMEOUT"); $finish; end   // atak jaye toh
endmodule