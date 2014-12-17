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

`include "qm_regfile.v"

/* verilator lint_off UNUSED */
module qm_decode(
    /// datapath
    // from Fetch
    input wire [31:0] di_IR,
    // backtraced from decode
    input wire [4:0] di_WA,
    input wire di_WE,
    input wire [31:0] di_WD,

    output wire [31:0] do_RSVal,
    output wire [31:0] do_RTVal,
    output wire [31:0] do_Imm,
    output wire [4:0] do_RS,
    output wire [4:0] do_RT,

    /// instruction to control unit
    output wire [5:0] o_Opcode,
    output wire [5:0] o_Function,

    /// controlpath
    input wire ci_RegWrite,
    input wire ci_RegWSource,
    input wire ci_MemWrite,
    input wire [3:0] ci_ALUControl,
    input wire ci_ALUSource,
    input wire ci_RegDest,
    input wire ci_Branch,

    output wire co_RegWrite,
    output wire co_RegWSource,
    output wire co_MemWrite,
    output wire [3:0] co_ALUControl,
    output wire co_ALUSource,
    output wire co_RegDest
);

// passthrough
assign co_RegWrite = ci_RegWrite;
assign co_RegWSource = ci_RegWSource;
assign co_MemWrite = ci_MemWrite;
assign co_ALUControl = ci_ALUControl;
assign co_ALUSource = ci_ALUSource;
assign co_RegDest = ci_RegDest;

// internal signals from the IR
wire [4:0] rs;
wire [4:0] rt;
wire [15:0] imm;

assign rs = di_IR[25:21];
assign rt = di_IR[20:16];
assign imm = di_IR[15:0];

qm_regfile regfile(
    .ra1(rs),
    .ra2(rt),
    .rd1(do_RSVal),
    .rd2(do_RTVal),
    .wa3(di_WA),
    .we3(di_WE),
    .wd3(di_WD)
);

// sign extend imm
assign do_Imm[31:0] = { {16{imm[15]}}, imm[15:0] };
assign do_RS = rs;
assign do_RT = rt;

assign o_Opcode = di_IR[31:26];
assign o_Function = di_IR[5:0];

endmodule
