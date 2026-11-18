`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 05:24:26 PM
// Design Name: 
// Module Name: tb_program_illegal
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

module tb_program_illegal;

    logic clk = 0;
    logic rst = 1;

    logic halted;
    logic illegal_instr;
    logic [3:0] pc;
    logic [7:0] r0, r1, r2, r3;

    always #5 clk = ~clk;

    stored_cpu #(
        .MEM_FILE("program_illegal.mem")
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

    initial begin
        // Apply synchronous reset
        repeat (2) @(negedge clk);

        if (pc !== 4'd0 ||
            r0 !== 8'd0 ||
            r1 !== 8'd0 ||
            r2 !== 8'd0 ||
            r3 !== 8'd0)
            $fatal(1, "FAIL: Reset values incorrect");

        if (halted !== 0 || illegal_instr !== 0)
            $fatal(1, "FAIL: Reset status incorrect");

        rst = 0;

        // Wait for first instruction to complete
        begin
            bit reached;
            reached = 0;

            for (int i = 0; i < 20; i++) begin
                @(negedge clk);

                if (pc === 4'd1) begin
                    reached = 1;
                    break;
                end
            end

            if (!reached)
                $fatal(1, "FAIL: PC never reached 1");
        end

        // Verify LDI R0, #5
        if (r0 !== 8'd5 ||
            r1 !== 8'd0 ||
            r2 !== 8'd0 ||
            r3 !== 8'd0)
            $fatal(1, "FAIL: Initial LDI incorrect");

        $display("PASS: LDI R0, #5 executed correctly");

        // Wait for illegal instruction detection
        begin
            bit reached;
            reached = 0;

            for (int i = 0; i < 20; i++) begin
                @(negedge clk);

                if (halted === 1 && illegal_instr === 1) begin
                    reached = 1;
                    break;
                end
            end

            if (!reached)
                $fatal(1, "FAIL: Illegal instruction not detected");
        end

        // Verify illegal instruction stopped the CPU
        if (pc !== 4'd1)
            $fatal(1, "FAIL: PC advanced past illegal instruction");

        if (r0 !== 8'd5 ||
            r1 !== 8'd0 ||
            r2 !== 8'd0 ||
            r3 !== 8'd0)
            $fatal(1, "FAIL: Registers changed after illegal instruction");

        $display("PASS: Illegal instruction detected at PC=1");
        $display("PASS: illegal_instr=1 and halted=1");

        // Verify no additional instructions execute
        repeat (10) begin
            @(negedge clk);

            if (pc !== 4'd1 ||
                r0 !== 8'd5 ||
                r1 !== 8'd0 ||
                r2 !== 8'd0 ||
                r3 !== 8'd0 ||
                halted !== 1 ||
                illegal_instr !== 1)
                $fatal(1, "FAIL: CPU changed state after illegal halt");
        end

        $display("PASS: CPU stable for 10 cycles");
        $display("PASS: Instruction at PC=2 was not executed");

        $display("------------------------------------");
        $display("ALL ILLEGAL-INSTRUCTION TESTS PASSED");
        $display("------------------------------------");

        $finish;
    end

    initial begin
        #5000;
        $fatal(1, "FAIL: Global simulation timeout");
    end

endmodule

