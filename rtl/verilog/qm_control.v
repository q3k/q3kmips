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
        input wire [5:0] i_Opcode,
        input wire [5:0] i_Function,

        /// Control lines to the pipeline stages
        // Mux selecting the destination register for the register writeback
        //  0 - RT
        //  1 - RD
        output wire co_RegDest,
        // Mux selecting the source of the ALU B operand
        //  0 - Value of RT register
        //  1 - instruction Imediate part
        output wire co_ALUSource,
        // ALU Control signal, select ALU operation
        output wire [3:0] co_ALUControl,
        // Memory write enable signal
        output wire co_MemWrite,
        // Mux selecting the source of the data for the register writeback
        //  0 - output of ALU
        //  1 - data read from memory
        output wire co_RegWSource,
        // Register writeback enable signal
        output wire co_RegWrite,
        // Unused...
        output wire co_Branch
    );

always @(opcode, funct) begin
    case (opcode)
        `OP_SPECIAL: begin
            co_RegDest <= 1;
            co_ALUSource <= 0;
            co_MemWrite <= 0;
            co_RegWSource <= 0;
            co_RegWrite <= 1;
            co_Branch <= 0;
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
            co_RegDest <= 0;
            co_ALUSource <= 1;
            co_ALUControl <= 0;
            co_MemWrite <= 0;
            co_RegWSource <= 1;
            co_RegWrite <= 1;
            co_Branch <= 0;
        end
        `OP_SW: begin
            co_RegDest <= 0;
            co_ALUSource <= 1;
            co_ALUControl <= 0;
            co_MemWrite <= 1;
            co_RegWSource <= 0;
            co_RegWrite <= 0;
            co_Branch <= 0;
        end
        6'b001???: // all immediate arith/logic
        default: begin
            co_RegDest <= 0;
            co_ALUSource <= 0;
            co_MemWrite <= 0;
            co_RegWSource <= 0;
            co_RegWrite <= 0;
            co_Branch <= 0;
            case (opcode)
                `OP_ADDI: co_ALUControl <= `ALU_ADD;
                `OP_ADDIU: co_ALUControl <= `ALU_ADD;
                `OP_ANDI: co_ALUControl <= `ALU_AND;
                `OP_ORI: co_ALUControl <= `ALU_OR;
                `OP_XORI: co_ALUControl <= `ALU_XOR;
                `OP_SLTI: co_ALUControl <= `ALU_SLT;
                `OP_SLTIU: co_ALUControl <= `ALU_SLTIU;
            endcase
        end
    endcase
end

endmodule
