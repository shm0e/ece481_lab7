`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2026 06:42:03 PM
// Design Name: 
// Module Name: stored_cpu_controller
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


module stored_cpu_controller (
    input  logic clk,
    input  logic rst,

    input  logic is_rtype,
    input  logic is_ldi,
    input  logic is_halt,
    input  logic is_valid,

    output logic rom_en,
    output logic ir_en,
    output logic alu_result_en,
    output logic reg_wr_en,
    output logic pc_en,
    output logic wb_sel_imm,

    output logic halted,
    output logic illegal_instr
);

    typedef enum logic [2:0] {
        FETCH,
        IR,
        DECODE,
        EXEC,
        WB,
        INC,
        HALT
    } state_t;

    state_t state, next_state;

    logic illegal_next;

    // State and illegal flag registers
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= FETCH;
            illegal_instr <= 1'b0;
        end else begin
            state <= next_state;

            if (illegal_next)
                illegal_instr <= 1'b1;
        end
    end

    // Next-state logic
    always_comb begin
        next_state = state;
        illegal_next = 1'b0;

        case (state)

            FETCH: begin
                next_state = IR;
            end

            IR: begin
                next_state = DECODE;
            end

            DECODE: begin
                if (!is_valid) begin
                    illegal_next = 1'b1;
                    next_state = HALT;
                end
                else if (is_halt) begin
                    next_state = HALT;
                end
                else if (is_ldi) begin
                    next_state = WB;
                end
                else if (is_rtype) begin
                    next_state = EXEC;
                end
            end

            EXEC: begin
                next_state = WB;
            end

            WB: begin
                next_state = INC;
            end

            INC: begin
                next_state = FETCH;
            end

            HALT: begin
                next_state = HALT;
            end

            default: begin
                next_state = FETCH;
            end
        endcase
    end

    // Datapath control signals
    always_comb begin
        rom_en       = 1'b0;
        ir_en        = 1'b0;
        alu_result_en = 1'b0;
        reg_wr_en    = 1'b0;
        pc_en        = 1'b0;
        wb_sel_imm   = 1'b0;
        halted       = 1'b0;

        case (state)

            FETCH: begin
                rom_en = 1'b1;
            end

            IR: begin
                ir_en = 1'b1;
            end

            EXEC: begin
                alu_result_en = 1'b1;
            end

            WB: begin
                reg_wr_en = 1'b1;
                wb_sel_imm = is_ldi;
            end

            INC: begin
                pc_en = 1'b1;
            end

            HALT: begin
                halted = 1'b1;
            end

            default: begin
            end
        endcase
    end

endmodule
