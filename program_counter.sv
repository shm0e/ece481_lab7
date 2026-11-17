`timescale 1ns/1ps

module regN #(
  parameter int WIDTH = 4
)(
  input  logic             clk,
  input  logic             rst,
  input  logic             en,
  input  logic [WIDTH-1:0] d,
  output logic [WIDTH-1:0] q
);
  
  always_ff @ (posedge clk) begin
    if (rst) begin
        q <= '0;
    end else if (en) begin
        q <= d;
    end
  end

endmodule
