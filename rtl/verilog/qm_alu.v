// Copyright (c) 2014, Segiusz 'q3k' Bazanski <sergiusz@bazanski.pl>
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE

`include "defines.v"

// Right now this ALU doesn't do any sort of overflow traps - mathematicians
// beware!
module qm_alu(
    input wire [3:0] i_ALUControl,
    input wire [31:0] i_A,
    input wire [31:0] i_B,

    output reg [31:0] o_Result,

    always @(i_ALUControl, i_A, i_B) begin
        case (i_ALUControl)
            `ALU_ADD: o_Result = i_A + i_B;
            `ALU_AND: o_Result = i_A & i_B;
            `ALU_OR:  o_Result = i_A | i_B;
            `ALU_XOR: o_Result = i_A ^ i_B;
            `ALU_SLT: o_Result = i_A << i_B;
            `ALU_SUB: o_Result = i_A - i_B;
            `ALU_DIV: o_Result = i_A / i_B;
            `ALU_MUL: o_Result = i_A * i_B;
            `ALU_NOR: o_Result = ~(i_A | i_B);
        endcase
    end
);

endmodule
