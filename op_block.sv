`timescale 1ns/1ps

module op_block #(parameter int WIDTH = 8) (
  input  logic [WIDTH-1:0] a,
  input  logic [WIDTH-1:0] b,
  input  logic       sel,
  output logic [WIDTH-1:0] y,
  output logic       eq,
  output logic       any
);

  assign y   = sel ? (a | b) : (a & b);
  assign any = |y;
  
  //assign eq  = (a == b);
  eqN #(.N(WIDTH)) u_eq (
    .a(a),
    .b(b),
    .eq(eq)
  );

endmodule

