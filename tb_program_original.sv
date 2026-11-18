`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 05:36:02 PM
// Design Name: 
// Module Name: tb_program_original
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

module tb_program_original;

    logic clk = 0;
    logic rst = 1;

    logic halted;
    logic illegal_instr;
    logic [3:0] pc;
    logic [7:0] r0, r1, r2, r3;

    always #5 clk = ~clk;

    stored_cpu #(
        .MEM_FILE("program_original.mem")
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

    // Check the architectural state after each instruction.
    task automatic check_state(
        input logic [3:0] exp_pc,
        input logic [7:0] exp_r0,
        input logic [7:0] exp_r1,
        input logic [7:0] exp_r2,
        input logic [7:0] exp_r3
    );
        bit reached;

        reached = 0;

        // Wait for the instruction to complete.
        for (int cycle = 0; cycle < 20; cycle++) begin
            @(negedge clk);

            if (pc === exp_pc) begin
                reached = 1;
                break;
            end
        end

        if (!reached)
            $fatal(1, "Timeout waiting for PC=%0d", exp_pc);

        if (r0 !== exp_r0 ||
            r1 !== exp_r1 ||
            r2 !== exp_r2 ||
            r3 !== exp_r3)
            $fatal(1,
                "FAIL PC=%0d: R0=%h R1=%h R2=%h R3=%h",
                pc, r0, r1, r2, r3);

        if (halted !== 0 || illegal_instr !== 0)
            $fatal(1, "Unexpected halt or illegal instruction");

        $display(
            "PASS PC=%0d: R0=%h R1=%h R2=%h R3=%h",
            pc, r0, r1, r2, r3
        );
    endtask

    initial begin

        // Synchronous reset
        repeat (2) @(negedge clk);

        if (pc !== 0 ||
            r0 !== 0 || r1 !== 0 ||
            r2 !== 0 || r3 !== 0 ||
            halted !== 0 ||
            illegal_instr !== 0)
            $fatal(1, "FAIL: Reset incorrect");

        $display("PASS: Synchronous reset");

        rst = 0;

        // Four LDI instructions
        check_state(4'd1, 8'h06, 8'h00, 8'h00, 8'h00);
        check_state(4'd2, 8'h06, 8'h03, 8'h00, 8'h00);
        check_state(4'd3, 8'h06, 8'h03, 8'h05, 8'h00);
        check_state(4'd4, 8'h06, 8'h03, 8'h05, 8'h02);

        // SUB R0, R1
        check_state(4'd5, 8'h03, 8'h03, 8'h05, 8'h02);

        // ADD R3, R2
        check_state(4'd6, 8'h03, 8'h03, 8'h05, 8'h07);

        // AND R2, R0
        check_state(4'd7, 8'h03, 8'h03, 8'h01, 8'h07);

        // IOR R1, R3
        check_state(4'd8, 8'h03, 8'h07, 8'h01, 8'h07);

        // ADD R0, R2
        check_state(4'd9, 8'h04, 8'h07, 8'h01, 8'h07);

        // SUB R3, R1
        check_state(4'd10, 8'h04, 8'h07, 8'h01, 8'h00);

        // Wait for HALT
        begin
            bit reached;
            reached = 0;

            for (int cycle = 0; cycle < 20; cycle++) begin
                @(negedge clk);

                if (halted === 1) begin
                    reached = 1;
                    break;
                end
            end

            if (!reached)
                $fatal(1, "FAIL: CPU did not halt");
        end

        // Final architectural state
        if (pc !== 4'hA ||
            r0 !== 8'h04 ||
            r1 !== 8'h07 ||
            r2 !== 8'h01 ||
            r3 !== 8'h00 ||
            halted !== 1 ||
            illegal_instr !== 0)
            $fatal(1, "FAIL: Incorrect final state");

        $display("PASS: Normal HALT at PC=10");

        // Check stability for 10 clock cycles after HALT
        repeat (10) begin
            @(negedge clk);

            if (pc !== 4'hA ||
                r0 !== 8'h04 ||
                r1 !== 8'h07 ||
                r2 !== 8'h01 ||
                r3 !== 8'h00 ||
                halted !== 1 ||
                illegal_instr !== 0)
                $fatal(1, "FAIL: State changed after HALT");
        end

        $display("PASS: HALT stability for 10 cycles");
        $display("-------------------------------------");
        $display("ALL ORIGINAL PROGRAM TESTS PASSED");
        $display("-------------------------------------");

        $finish;
    end

    // Global simulation timeout
    initial begin
        #10000;
        $fatal(1, "FAIL: Global simulation timeout");
    end

endmodule

