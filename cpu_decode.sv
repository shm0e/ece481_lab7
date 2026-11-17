// Day 13 mini-lab: instruction decoder
module cpu_decode (
    input  logic [7:0] instr,
    output logic [2:0] opcode,
    output logic [1:0] rd,
    output logic [1:0] rs,
    output logic [2:0] imm3,
    output logic       is_rtype,
    output logic       is_ldi,
    output logic       is_halt,
    output logic       is_valid,
    output logic [1:0] alu_op
);

    // TODO 1: Decode the bit fields [7:5], [4:3], [2:1], [2:0].
    // Replace these placeholder values.
    assign opcode = instr[7:5];
    assign rd     = instr[4:3];
    assign rs     = instr[2:1];
    assign imm3   = instr[2:0];

    always_comb begin
        // TODO 2: Classify R-type (000--011), LDI (110), HALT (111).
        // TODO 3: Leave 100 and 101 unclassified.
        is_rtype = 1'b0;
        is_ldi   = 1'b0;
        is_halt  = 1'b0;

        case (opcode)
            3'b000,
            3'b001,
            3'b010,
            3'b011: is_rtype = 1'b1;
            
            3'b110: is_ldi = 1'b1;
            
            3'b111: is_halt = 1'b1;
            
            default: ;
        endcase
    end

    // TODO 4: Valid if and only if one supported class is identified.
    assign is_valid = is_rtype | is_ldi | is_halt;

    // TODO 5: Select ALU op (00/01/10/11) for R-type only.
    // For all other classes, alu_op must be 00.
    assign alu_op = is_rtype ? opcode[1:0] : 2'b00;
endmodule
