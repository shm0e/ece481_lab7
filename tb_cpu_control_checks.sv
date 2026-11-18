`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 05:54:13 PM
// Design Name: 
// Module Name: tb_cpu_control_checks
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

module tb_cpu_control_checks;

    logic clk = 0;
    logic rst = 1;

    logic halted;
    logic illegal_instr;
    logic [3:0] pc;
    logic [7:0] r0, r1, r2, r3;

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

    // Expected instruction bytes at each PC.
    logic [7:0] expected_rom [0:12];

    initial begin
        expected_rom[0]  = 8'hC2;
        expected_rom[1]  = 8'hCB;
        expected_rom[2]  = 8'hD5;
        expected_rom[3]  = 8'hD9;
        expected_rom[4]  = 8'h02;
        expected_rom[5]  = 8'h36;
        expected_rom[6]  = 8'h4C;
        expected_rom[7]  = 8'h78;
        expected_rom[8]  = 8'h24;
        expected_rom[9]  = 8'h6C;
        expected_rom[10] = 8'h16;
        expected_rom[11] = 8'h7C;
        expected_rom[12] = 8'hE0;
    end

    // Track previous register values to detect unintended writes.
    logic [7:0] old_r0, old_r1, old_r2, old_r3;
    logic [7:0] old_ir;
    logic [7:0] old_rom;

    // Run checks on every clock cycle after reset.
    initial begin
        repeat (2) @(negedge clk);
        rst = 0;

        // Check all instructions, including HALT.
        for (int instr = 0; instr < 13; instr++) begin

            // FETCH state
            wait (dut.rom_en === 1'b1);

            if (pc !== instr[3:0])
                $fatal(1, "Incorrect PC during FETCH");

            if (dut.reg_wr_en !== 0)
                $fatal(1, "Register write during FETCH");

            old_r0 = r0;
            old_r1 = r1;
            old_r2 = r2;
            old_r3 = r3;

            old_ir = dut.u_datapath.ir;

            // FETCH edge: synchronous ROM updates.
            @(posedge clk);
            #1;

            if (dut.u_datapath.u_rom.data !== expected_rom[instr])
                $fatal(1,
                    "ROM acquisition failed at PC=%0d",
                    instr);

            // IR must not capture the new instruction on FETCH edge.
            if (dut.u_datapath.ir !== old_ir)
                $fatal(1, "IR changed during FETCH");

            // IR state
            if (dut.ir_en !== 1)
                $fatal(1, "IR enable missing");

            if (dut.reg_wr_en !== 0)
                $fatal(1, "Register write during IR");

            // IR edge: instruction register captures ROM data.
            @(posedge clk);
            #1;

            if (dut.u_datapath.ir !== expected_rom[instr])
                $fatal(1,
                    "Instruction register incorrect at PC=%0d",
                    instr);

            // DECODE state
            if (dut.reg_wr_en !== 0)
                $fatal(1, "Register write during DECODE");

            if (r0 !== old_r0 ||
                r1 !== old_r1 ||
                r2 !== old_r2 ||
                r3 !== old_r3)
                $fatal(1,
                    "Registers changed during FETCH/IR/DECODE");

            // Wait until either EXEC or WB, or HALT.
            @(posedge clk);
            #1;

            if (instr == 12) begin
                // HALT instruction
                if (halted !== 1 ||
                    illegal_instr !== 0 ||
                    pc !== 4'd12)
                    $fatal(1, "Incorrect normal HALT");

                break;
            end

            // R-type instructions have EXEC before WB.
            if (expected_rom[instr][7:5] <= 3'b011) begin
                if (dut.alu_result_en !== 1)
                    $fatal(1, "ALU result enable missing");

                if (dut.reg_wr_en !== 0)
                    $fatal(1, "Write occurred during EXEC");

                @(posedge clk);
                #1;
            end

            // WB state
            if (dut.reg_wr_en !== 1)
                $fatal(1, "Register write enable missing in WB");

            if (dut.u_datapath.rd !== expected_rom[instr][4:3])
                $fatal(1,
                    "Wrong destination register at PC=%0d",
                    instr);

            // Writeback edge
            @(posedge clk);
            #1;

            // PC should not increment until INC.
            if (pc !== instr[3:0])
                $fatal(1, "PC changed before INC");

            // INC state
            if (dut.pc_en !== 1)
                $fatal(1, "PC enable missing during INC");

            if (dut.reg_wr_en !== 0)
                $fatal(1, "Register write during INC");

            @(posedge clk);
            #1;

            if (pc !== (instr + 1))
                $fatal(1,
                    "PC failed to increment at instruction %0d",
                    instr);

            $display("PASS: Instruction %0d timing and controls",
                     instr);
        end

        if (halted !== 1 || illegal_instr !== 0)
            $fatal(1, "Final HALT status incorrect");

        $display("----------------------------------------");
        $display("ALL CPU CONTROL CHECKS PASSED");
        $display("----------------------------------------");

        $finish;
    end

    initial begin
        #10000;
        $fatal(1, "Global timeout in control testbench");
    end

endmodule
