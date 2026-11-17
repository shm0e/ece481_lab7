// Four 8-bit registers, two asynchronous read ports, one synchronous
// write port. Uses unchanged Day 6 regN blocks for state storage.
// All registers reset to zero synchronously.
module cpu_register_file (
    input  logic       clk,
    input  logic       rst,
    input  logic       wr_en,
    input  logic [1:0] wr_addr,
    input  logic [7:0] wr_data,
    input  logic [1:0] rd_addr_a,
    input  logic [1:0] rd_addr_b,
    output logic [7:0] rd_data_a,
    output logic [7:0] rd_data_b,
    output logic [7:0] r0,
    output logic [7:0] r1,
    output logic [7:0] r2,
    output logic [7:0] r3
);
    logic [7:0] regs [0:3];

    for (genvar i = 0; i < 4; i++) begin : g_regs
        localparam logic [1:0] ADDR = i;
        regN #(.WIDTH(8)) u_reg (
            .clk(clk), .rst(rst),
            .en(wr_en && (wr_addr == ADDR)),
            .d(wr_data), .q(regs[i])
        );
    end

    assign rd_data_a = regs[rd_addr_a];
    assign rd_data_b = regs[rd_addr_b];
    assign r0 = regs[0];
    assign r1 = regs[1];
    assign r2 = regs[2];
    assign r3 = regs[3];
endmodule
