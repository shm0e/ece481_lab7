`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 04:54:30 PM
// Design Name: 
// Module Name: tb_project_13
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


module tb_program_13;

    logic clk = 0;
    logic rst = 1;

    logic halted;
    logic illegal_instr;
    logic [3:0] pc;
    logic [7:0] r0, r1, r2, r3;

    // 100 MHz clock
    always #5 clk = ~clk;

    stored_cpu #(
        .MEM_FILE("program_13.mem")
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

    // Expected architectural state after each instruction
    logic [7:0] expected [0:11][0:3];

    initial begin
        expected[0]  = '{8'h02, 8'h00, 8'h00, 8'h00};
        expected[1]  = '{8'h02, 8'h03, 8'h00, 8'h00};
        expected[2]  = '{8'h02, 8'h03, 8'h05, 8'h00};
        expected[3]  = '{8'h02, 8'h03, 8'h05, 8'h01};
        expected[4]  = '{8'h05, 8'h03, 8'h05, 8'h01};
        expected[5]  = '{8'h05, 8'h03, 8'h04, 8'h01};
        expected[6]  = '{8'h05, 8'h00, 8'h04, 8'h01};
        expected[7]  = '{8'h05, 8'h00, 8'h04, 8'h05};
        expected[8]  = '{8'h01, 8'h00, 8'h04, 8'h05};
        expected[9]  = '{8'h01, 8'h04, 8'h04, 8'h05};
        expected[10] = '{8'h01, 8'h04, 8'h09, 8'h05};
        expected[11] = '{8'h01, 8'h04, 8'h09, 8'h0D};
    end

    task automatic check_registers(input int index);
        if (r0 !== expected[index][0] ||
            r1 !== expected[index][1] ||
            r2 !== expected[index][2] ||
            r3 !== expected[index][3])
        begin
            $fatal(1,
                "FAIL PC=%0d: R0=%h R1=%h R2=%h R3=%h",
                pc, r0, r1, r2, r3);
        end

        $display(
            "PASS PC=%0d: R0=%h R1=%h R2=%h R3=%h",
            pc, r0, r1, r2, r3);
    endtask

    initial begin
        // Apply synchronous reset
        repeat (2) @(negedge clk);

        if (pc !== 0 || r0 !== 0 || r1 !== 0 ||
            r2 !== 0 || r3 !== 0)
            $fatal(1, "Reset failed");

        if (halted !== 0 || illegal_instr !== 0)
            $fatal(1, "Reset status incorrect");

        rst = 0;

        // Verify each completed instruction
        for (int i = 0; i < 12; i++) begin
            bit reached;
            reached = 0;

            for (int cycle = 0; cycle < 20; cycle++) begin
                @(negedge clk);

                if (pc === (i + 1)) begin
                    reached = 1;
                    break;
                end
            end

            if (!reached)
                $fatal(1, "Timeout waiting for PC=%0d", i+1);

            check_registers(i);

            if (halted !== 0 || illegal_instr !== 0)
                $fatal(1, "Unexpected halt or illegal instruction");
        end

        // Wait for HALT
        begin
            bit halt_reached;
            halt_reached = 0;

            for (int i = 0; i < 20; i++) begin
                @(negedge clk);
                if (halted === 1) begin
                    halt_reached = 1;
                    break;
                end
            end

            if (!halt_reached)
                $fatal(1, "CPU failed to halt");
        end

        if (pc !== 4'hC || illegal_instr !== 0)
            $fatal(1, "Incorrect final PC or status");

        check_registers(11);

        // Verify architectural state remains frozen
        repeat (10) begin
            @(negedge clk);

            if (pc !== 4'hC ||
                r0 !== 8'h01 ||
                r1 !== 8'h04 ||
                r2 !== 8'h09 ||
                r3 !== 8'h0D ||
                halted !== 1 ||
                illegal_instr !== 0)
                $fatal(1, "HALT stability failed");
        end

        $display("------------------------------------");
        $display("ALL 13-INSTRUCTION TESTS PASSED");
        $display("------------------------------------");

        $finish;
    end

    // Global timeout
    initial begin
        #10000;
        $fatal(1, "GLOBAL SIMULATION TIMEOUT");
    end

endmodule

