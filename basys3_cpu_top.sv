`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 06:25:47 PM
// Design Name: 
// Module Name: basys3_cpu_top
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


module basys3_cpu_top (
    input  logic        clk,
    input  logic        btnC,
    input  logic [1:0]  sw,
    output logic [14:0] led
);

    logic halted;
    logic illegal_instr;

    logic [3:0] pc;

    logic [7:0] r0;
    logic [7:0] r1;
    logic [7:0] r2;
    logic [7:0] r3;

    logic [7:0] selected_reg;

    // Instantiate the complete stored-program CPU
    stored_cpu #(
        .MEM_FILE("program_13.mem")
    ) u_cpu (
        .clk(clk),
        .rst(btnC),

        .halted(halted),
        .illegal_instr(illegal_instr),

        .pc(pc),
        .r0(r0),
        .r1(r1),
        .r2(r2),
        .r3(r3)
    );

    // Select one of the four CPU registers
    always_comb begin
        case (sw)
            2'b00: selected_reg = r0;
            2'b01: selected_reg = r1;
            2'b10: selected_reg = r2;
            2'b11: selected_reg = r3;
            default: selected_reg = 8'h00;
        endcase
    end

    // Display the selected register
    assign led[7:0] = selected_reg;

    // Display the program counter
    assign led[11:8] = pc;

    // Display CPU status
    assign led[12] = halted;
    assign led[13] = illegal_instr;
    assign led[14] = ~halted;

endmodule

