`define OP_SPECIAL       6'b000000
`define OP_SPECIAL2      6'b011100

`define OP_ADDI          6'b001000 // addi rt, rs, imm  ; rt = rs + imm
`define OP_ADDIU         6'b001001 // addiu rt, rs, imm ; rt = rs + imm
`define OP_ANDI          6'b001100 // andi rt, rs, imm  ; rt = rs & imm
`define OP_ORI           6'b001101
`define OP_XORI          6'b001110
`define OP_SLTI          6'b001010
`define OP_SLTIU         6'b001011

`define OP_LB            6'b100000
`define OP_LH            6'b100001
`define OP_LBU           6'b100100
`define OP_LHU           6'b100101
`define OP_LW            6'b100011 // lw rt, imm(rs)    ; rt = [rs+imm]
`define OP_SW            6'b101011 // sw rt, imm(rs)    ; [rs + imm] = rt

// Special 0
`define FUNCT_ADD        6'b100000
`define FUNCT_ADDU       6'b100001
`define FUNCT_AND        6'b100100
`define FUNCT_DIV        6'b011010
`define FUNCT_DIVU       6'b011011
`define FUNCT_MULT       6'b011000
`define FUNCT_MULTU      6'b011001
`define FUNCT_NOR        6'b100111
`define FUNCT_OR         6'b100101
`define FUNCT_SLT        6'b101010
`define FUNCT_SUB        6'b100010
`define FUNCT_SUBU       6'b100011
`define FUNCT_XOR        6'b100110

// Special 2
//`define FUNCT_CLO        6'b100001
//`define FUNCT_CLZ        6'b100000
//`define FUNCT_MADD       6'b000000
//`define FUNCT_MADDU      6'b000001
//`define FUNCT_MSUB       6'b000100
//`define FUNCT_MSUBU      6'b000101
//`define FUNCT_MUL        6'b000010

`include "defines.v"

module qm_control(
        /// Instruction from the decode stage
        input wire [5:0] opcode,
        input wire [5:0] funct,

        /// Control lines to the pipeline stages
        // Mux selecting the destination register for the register writeback
        //  0 - RT
        //  1 - RD
        output wire reg_destination,
        // Mux selecting the source of the ALU B operand
        //  0 - Value of RT register
        //  1 - instruction Imediate part
        output wire alu_source,
        // ALU Control signal, select ALU operation
        output wire [3:0] alu_control,
        // Memory write enable signal
        output wire mem_write,
        // Mux selecting the source of the data for the register writeback
        //  0 - output of ALU
        //  1 - data read from memory
        output wire reg_wsource,
        // Register writeback enable signal
        output wire reg_write
    );

always @(opcode, funct) begin
    case (opcode)
        `OP_SPECIAL: begin
            reg_destination <= 1;
            alu_source <= 0;
            mem_write <= 0;
            reg_wsource <= 0;
            reg_write <= 1;
            case (funct)
                `FUNCT_ADD: <= `ALU_ADD;
                `FUNCT_ADDU: <= `ALU_ADD;
                `FUNCT_AND: <= `ALU_AND;
                `FUNCT_DIV: <= `ALU_DIV;
                `FUNCT_DIVU: <= `ALU_DIV;
                `FUNCT_MULT: <= `ALU_MUL;
                `FUNCT_MULTU: <= `ALU_MUL;
                `FUNCT_NOR: <= `ALU_NOR
                `FUNCT_OR: <= `ALU_OR;
                `FUNCT_SLT: <= `ALU_SLT;
                `FUNCT_SUB: <= `ALU_SUB;
                `FUNCT_SUBU: <= `ALU_SUB;
                `FUNCT_XOR: <= `ALU_XOR;
            endcase
        end
        `OP_LW: begin
            reg_destination <= 0;
            alu_source <= 1;
            alu_control <= 0;
            mem_write <= 0;
            reg_wsource <= 1;
            reg_write <= 1;
        end
        `OP_SW: begin
            reg_destination <= 0;
            alu_source <= 1;
            alu_control <= 0;
            mem_write <= 1;
            reg_wsource <= 0;
            reg_write <= 0;
        end
        6'b001???: // all immediate arith/logic
        default: begin
            reg_destination <= 0;
            alu_source <= 0;
            mem_write <= 0;
            reg_wsource <= 0;
            reg_write <= 0;
            case (opcode)
                `OP_ADDI: alu_control <= `ALU_ADD;
                `OP_ADDIU: alu_control <= `ALU_ADD;
                `OP_ANDI: alu_control <= `ALU_AND;
                `OP_ORI: alu_control <= `ALU_OR;
                `OP_XORI: alu_control <= `ALU_XOR;
                `OP_SLTI: alu_control <= `ALU_SLT;
                `OP_SLTIU: alu_control <= `ALU_SLTIU;
            endcase
        end
    endcase
end

endmodule
