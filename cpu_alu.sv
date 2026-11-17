`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 08:49:23 AM
// Design Name: 
// Module Name: cpu_alu
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


// 8-bit, modulo-256 ALU with the Day 13 opcode meanings:
// 00 ADD, 01 SUB, 10 AND, 11 IOR.
// Logical ops intentionally reuse the Day 6 op_block (AND/OR).
module cpu_alu (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [1:0] alu_op,
    output logic [7:0] result
);
    logic [7:0] logical_result;
    logic eq_unused, any_unused;

    op_block #(.WIDTH(8)) u_logic (
        .a(a), .b(b), .sel(alu_op[0]),
        .y(logical_result), .eq(eq_unused), .any(any_unused)
    );

    always_comb begin
        case (alu_op)
            2'b00:   result = a + b;
            2'b01:   result = a - b;
            2'b10:   result = logical_result; // AND
            2'b11:   result = logical_result; // IOR
            default: result = 8'h00;
        endcase
    end
endmodule

