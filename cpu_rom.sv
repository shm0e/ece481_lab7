// 16 x 8 synchronous-read instruction ROM.
module cpu_rom #(
    parameter MEM_FILE = "program_5.mem"
)(
    input  logic       clk,
    input  logic       en,
    input  logic [3:0] addr,
    output logic [7:0] data
);
    (* rom_style = "distributed" *) logic [7:0] mem [0:15];

    initial begin
        $readmemh(MEM_FILE, mem);
    end

    always_ff @(posedge clk) begin
        if (en)
            data <= mem[addr];
    end
endmodule
