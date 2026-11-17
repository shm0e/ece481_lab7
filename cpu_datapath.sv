`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 09:52:54 AM
// Design Name: 
// Module Name: cpu_datapath
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


// Day 14: CPU datapath
module cpu_datapath #(
    parameter MEM_FILE = "program_5.mem"
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       rom_en,
    input  logic       ir_en,
    input  logic       alu_result_en,
    input  logic       reg_wr_en,
    input  logic       pc_en,
    input  logic       wb_sel_imm,
    output logic [3:0] pc,
    output logic [7:0] rom_data,
    output logic [7:0] ir,
    output logic [2:0] opcode,
    output logic [1:0] rd,
    output logic [1:0] rs,
    output logic [2:0] imm3,
    output logic       is_rtype,
    output logic       is_ldi,
    output logic       is_halt,
    output logic       is_valid,
    output logic [1:0] alu_op,
    output logic [7:0] operand_a,
    output logic [7:0] operand_b,
    output logic [7:0] alu_y,
    output logic [7:0] alu_q,
    output logic [7:0] wb_data,
    output logic [7:0] r0,
    output logic [7:0] r1,
    output logic [7:0] r2,
    output logic [7:0] r3
);

    // Reuse the Day 6 program counter. No branch instruction in this ISA.
    program_counter #(.WIDTH(4)) u_pc (
        .clk(clk), .rst(rst), .en(pc_en),
        .take_branch(1'b0), .branch_target(4'b0000), .pc(pc)
    );

    // The ROM output is registered.
    cpu_rom #(.MEM_FILE(MEM_FILE)) u_rom (
        .clk(clk), .en(rom_en), .addr(pc), .data(rom_data)
    );

    regN #(.WIDTH(8)) u_ir (
        .clk(clk), .rst(rst), .en(ir_en), .d(rom_data), .q(ir)
    );

    // Reuse the exact decoder completed on Day 13.
    cpu_decode u_decode (
        .instr(ir), .opcode(opcode), .rd(rd), .rs(rs), .imm3(imm3),
        .is_rtype(is_rtype), .is_ldi(is_ldi),
        .is_halt(is_halt), .is_valid(is_valid), .alu_op(alu_op)
    );

    // One synchronous write port and two asynchronous operand read ports.
    cpu_register_file u_rf (
        .clk(clk), .rst(rst),
        .wr_en(reg_wr_en), .wr_addr(rd), .wr_data(wb_data),
        .rd_addr_a(rd), .rd_addr_b(rs),
        .rd_data_a(operand_a), .rd_data_b(operand_b),
        .r0(r0), .r1(r1), .r2(r2), .r3(r3)
    );

    // Combinational ALU followed by a clock-enabled result register.
    cpu_alu u_alu (
        .a(operand_a), .b(operand_b),
        .alu_op(alu_op), .result(alu_y)
    );

    regN #(.WIDTH(8)) u_alu_result (
        .clk(clk), .rst(rst), .en(alu_result_en),
        .d(alu_y), .q(alu_q)
    );

    // LDI bypasses the ALU result register at writeback.
    assign wb_data = (wb_sel_imm) ? ({5'b0_0000,imm3}) : (alu_q);

endmodule

