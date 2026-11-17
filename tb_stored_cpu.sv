`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 02:12:06 PM
// Design Name: 
// Module Name: tb_stored_cpu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_stored_cpu;

    logic clk = 0;
    logic rst;

    logic halted;
    logic illegal_instr;
    logic [3:0] pc;
    logic [7:0] r0, r1, r2, r3;

// 100 MHz clock
    always #5 clk = ~clk;

stored_cpu #(
        .MEM_FILE("program_5.mem")
    ) dut (
        .clk(clk),
        .rst(rst),
        .halted(halted),
        .illegal_instr(illegal_instr),
        .pc(pc),
        .r0(r0),
        .r1(r1),
        .r2(r2),
        .r3(r3)
    );

// Check architectural state
    task automatic check_state(
        input logic [3:0] exp_pc,
        input logic [7:0] exp_r0,
        input logic [7:0] exp_r1,
        input logic [7:0] exp_r2,
        input logic [7:0] exp_r3
    );
        if (pc !== exp_pc ||
            r0 !== exp_r0 ||
            r1 !== exp_r1 ||
            r2 !== exp_r2 ||
            r3 !== exp_r3)
        begin
            $fatal(1,
                "FAIL: PC=%h R0=%h R1=%h R2=%h R3=%h",
                pc, r0, r1, r2, r3);
        end
        $display("PASS: PC=%h R0=%h R1=%h R2=%h R3=%h",
                 pc, r0, r1, r2, r3);
    endtask

// Wait for a completed instruction (PC increment)
    task automatic wait_for_pc(input logic [3:0] target);
        for (int i = 0; i<20; i++) begin
            @(negedge clk);
            if (pc === target)
                return;
        end
        $fatal(1, "TIMEOUT waiting for PC=%h", target);
    endtask

initial begin
        rst = 1;

repeat (2) @(negedge clk);
        check_state(0, 0, 0, 0, 0);

if (halted !== 0 || illegal_instr !== 0)
            $fatal(1, "Reset status flags incorrect");

        rst = 0;

// Verify each completed instruction
        wait_for_pc(1);
        check_state(1, 2, 0, 0, 0);

wait_for_pc(2);
        check_state(2, 2, 3, 0, 0);

wait_for_pc(3);
        check_state(3, 5, 3, 0, 0);

wait_for_pc(4);
        check_state(4, 1, 3, 0, 0);

// Wait for HALT
        for (int i = 0; i<20; i++) begin
            @(negedge clk);
            if (halted === 1)
                break;
        end

if (halted !== 1)
            $fatal(1, "CPU did not HALT");

if (illegal_instr !== 0)
            $fatal(1, "Unexpected illegal instruction");

        check_state(4, 1, 3, 0, 0);

// Check that HALT preserves architectural state
        repeat (10) begin
            @(negedge clk);
            check_state(4, 1, 3, 0, 0);

if (halted !== 1 || illegal_instr !== 0)
                $fatal(1, "HALT status changed");
        end

$display("ALL CLASSROOM PROGRAM TESTS PASSED");
        $finish;
    end

// Independent finite timeout
    initial begin
        #5000;
        $fatal(1, "GLOBAL SIMULATION TIMEOUT");
    end

endmodule