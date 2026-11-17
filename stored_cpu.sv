`timescale 1ns/1ps

module stored_cpu #(
    parameter MEM_FILE = "program_5.mem"
)(
    input  logic clk,
    input  logic rst,

    output logic halted,
    output logic illegal_instr,
    output logic [3:0] pc,
    output logic [7:0] r0,
    output logic [7:0] r1,
    output logic [7:0] r2,
    output logic [7:0] r3
);

    // Controller-to-datapath signals
    logic rom_en;
    logic ir_en;
    logic alu_result_en;
    logic reg_wr_en;
    logic pc_en;
    logic wb_sel_imm;

    // Instruction classification signals
    logic is_rtype;
    logic is_ldi;
    logic is_halt;
    logic is_valid;

    // Internal datapath signals
    logic [7:0] rom_data;
    logic [7:0] ir;
    logic [2:0] opcode;
    logic [1:0] rd, rs;
    logic [2:0] imm3;
    logic [1:0] alu_op;
    logic [7:0] operand_a, operand_b;
    logic [7:0] alu_y, alu_q, wb_data;

    // Datapath
    cpu_datapath #(
        .MEM_FILE(MEM_FILE)
    ) u_datapath (
        .clk(clk),
        .rst(rst),

        .rom_en(rom_en),
        .ir_en(ir_en),
        .alu_result_en(alu_result_en),
        .reg_wr_en(reg_wr_en),
        .pc_en(pc_en),
        .wb_sel_imm(wb_sel_imm),

        .pc(pc),
        .rom_data(rom_data),
        .ir(ir),
        .opcode(opcode),
        .rd(rd),
        .rs(rs),
        .imm3(imm3),
        .is_rtype(is_rtype),
        .is_ldi(is_ldi),
        .is_halt(is_halt),
        .is_valid(is_valid),
        .alu_op(alu_op),

        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_y(alu_y),
        .alu_q(alu_q),
        .wb_data(wb_data),

        .r0(r0),
        .r1(r1),
        .r2(r2),
        .r3(r3)
    );

    // Multi-cycle controller
    stored_cpu_controller u_controller (
        .clk(clk),
        .rst(rst),

        .is_rtype(is_rtype),
        .is_ldi(is_ldi),
        .is_halt(is_halt),
        .is_valid(is_valid),

        .rom_en(rom_en),
        .ir_en(ir_en),
        .alu_result_en(alu_result_en),
        .reg_wr_en(reg_wr_en),
        .pc_en(pc_en),
        .wb_sel_imm(wb_sel_imm),

        .halted(halted),
        .illegal_instr(illegal_instr)
    );

endmodule
