`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 02:24:25 PM
// Design Name: 
// Module Name: eq1
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

module eq1 (
  input  logic a,
  input  logic b,
  output logic eq
);

  assign eq = ~(a ^ b);

endmodule

