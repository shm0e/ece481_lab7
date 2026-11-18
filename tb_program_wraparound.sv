`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 05:29:11 PM
// Design Name: 
// Module Name: tb_program_wraparound
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

module tb_program_wraparound;

    logic clk = 0;
    logic rst = 1;

    logic halted;
    logic illegal_instr;
    logic [3:0] pc;
    logic [7:0] r0, r1, r2, r3;

    always #5 clk = ~clk;

    stored_cpu #(
        .MEM_FILE("program_wraparound.mem")
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

    task automatic check_state(
        input logic [3:0] expected_pc,
        input logic [7:0] expected_r0,
        input logic [7:0] expected_r1
    );
        bit reached;

        reached = 0;

        for (int i = 0; i < 20; i++) begin
            @(negedge clk);

            if (pc === expected_pc) begin
                reached = 1;
                break;
            end
        end

        if (!reached)
            $fatal(1, "Timeout waiting for PC=%0d",
                   expected_pc);

        if (r0 !== expected_r0 ||
            r1 !== expected_r1 ||
            r2 !== 8'h00 ||
            r3 !== 8'h00)
            $fatal(1,
                "FAIL PC=%0d R0=%h R1=%h R2=%h R3=%h",
                pc, r0, r1, r2, r3);

        if (halted !== 0 || illegal_instr !== 0)
            $fatal(1, "Unexpected HALT or illegal instruction");

        $display("PASS PC=%0d R0=%h R1=%h",
                 pc, r0, r1);
    endtask

    initial begin

        // Synchronous reset
        repeat (2) @(negedge clk);

        if (pc !== 0 ||
            r0 !== 0 || r1 !== 0 ||
            r2 !== 0 || r3 !== 0 ||
            halted !== 0 ||
            illegal_instr !== 0)
            $fatal(1, "Reset failed");

        rst = 0;

        // LDI R0, #0
        check_state(4'd1, 8'h00, 8'h00);

        // LDI R1, #1
        check_state(4'd2, 8'h00, 8'h01);

        // SUB R0, R1: 0 - 1 = FF
        check_state(4'd3, 8'hFF, 8'h01);
        $display("PASS: Subtraction underflow");

        // ADD R0, R1: FF + 1 = 00
        check_state(4'd4, 8'h00, 8'h01);
        $display("PASS: Addition overflow");

        // Wait for HALT
        begin
            bit reached;
            reached = 0;

            for (int i = 0; i < 20; i++) begin
                @(negedge clk);

                if (halted === 1) begin
                    reached = 1;
                    break;
                end
            end

            if (!reached)
                $fatal(1, "CPU did not halt");
        end

        if (pc !== 4'd4 ||
            r0 !== 8'h00 ||
            r1 !== 8'h01 ||
            r2 !== 8'h00 ||
            r3 !== 8'h00 ||
            illegal_instr !== 0)
            $fatal(1, "Incorrect final state");

        // Verify stability after HALT
        repeat (10) begin
            @(negedge clk);

            if (pc !== 4'd4 ||
                r0 !== 8'h00 ||
                r1 !== 8'h01 ||
                r2 !== 8'h00 ||
                r3 !== 8'h00 ||
                halted !== 1 ||
                illegal_instr !== 0)
                $fatal(1, "HALT stability failed");
        end

        $display("PASS: HALT stability");
        $display("--------------------------------");
        $display("ALL WRAPAROUND TESTS PASSED");
        $display("--------------------------------");

        $finish;
    end

    initial begin
        #5000;
        $fatal(1, "Global simulation timeout");
    end

endmodule
