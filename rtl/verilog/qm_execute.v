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
// POSSIBILITY OF SUCH DAMAGE.

`include "qm_alu.v"

module qm_execute(
    /// datapath
    // from Decode
    input wire [31:0] di_RSVal,
    input wire [31:0] di_RTVal,
    input wire [31:0] di_Imm,
    input wire [4:0] di_RT,
    input wire [4:0] di_RD,
    // to Memory
    output wire [31:0] do_ALUOut,
    output wire [31:0] do_WriteData,
    output wire [31:0] do_WriteReg,

    /// controlpath
    // from Decode
    input wire ci_RegWrite,
    input wire ci_RegWSource,
    input wire ci_MemWrite,
    input wire [3:0] ci_ALUControl,
    input wire ci_ALUSource,
    input wire ci_RegDest
    // to Memory
    output wire co_RegWrite,
    output wire co_RegWSource,
    output wire co_MemWrite
);

// passthrough
assign co_RegWrite = ci_RegWrite;
assign co_RegWSource = ci_RegWSource;
assign co_MemWrite = ci_MemWrite;

assign do_WriteData = di_RTVal;

// Mux to ALU B
wire ALUB = ci_ALUSource ? di_RTVal : di_Imm;

// Mux to register write index
assign do_WriteReg = ci_RegDest ? di_RT : di_RD;

qm_alu alu(
    .i_ALUControl(ci_ALUControl),
    .i_A(di_RSVal),
    .i_B(ALUB),

    .o_Result(do_ALUOut)
);

endmodule
