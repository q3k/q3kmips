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

`include "qm_control.v"
`include "qm_icache.v"
`include "qm_fetch.v"
`include "qm_decode.v"

module qm_top(
    input wire clk    
);

/// Controlpath signal inputs
// Decode/Execute
reg DEC_RegWrite;
reg DEC_RegWSource;
reg DEC_MemWrite;
reg [3:0] DEC_ALUControl;
reg DEC_ALUSource;
reg DEC_RegDest;

/// Controlpath signal outputs
wire cdecode_RegWrite;
wire cdecode_RegWSource;
wire cdecode_MemWrite;
wire [3:0] cdecode_ALUControl;
wire cdecode_ALUSource;
wire cdecode_RegDest;

/// Datapath signal inputs
// Fetch / Decode
reg [31:0] FD_IR;
reg [31:0] FD_NextPC;
// Decode / Execute
reg [31:0] DE_RSVal;
reg [31:0] DE_RTVal;
reg [31:0] DE_Imm;
reg [31:0] DE_RT;
reg [31:0] DE_RD;

/// Datapath signal outputs
// Fetch
wire [31:0] fetch_IR;
wire [31:0] fetch_NextPC;
// Decode
wire [31:0] decode_RSVal;
wire [31:0] decode_RTVal;
wire [31:0] decode_Imm;
wire [4:0] decode_RT;
wire [4:0] decode_RD;
wire [5:0] decode_Opcode;
wire [5:0] decode_Function;
// ICache
wire [31:0] ICache_Address;
wire [31:0] ICache_Data;
wire ICache_Hit;
wire ICache_ShouldStall;

/// Pipeline step
always @(posedge clk) begin
    // Fetch -> Decode
    FD_IR <= fetch_IR;
    FD_NextPC <= fetch_NextPC;

    // Decode -> Execute
    DE_RSVal <= decode_RSVal;
    DE_RTVal <= decode_RTVal;
    DE_Imm <= decode_Imm;
    DE_RT <= decode_RT;
    DE_RD <= decode_RD;

    DEC_RegWrite <= cdecode_RegWrite;
    DEC_RegWSource <= cdecode_RegWSource;
    DEC_MemWrite <= cdecode_MemWrite;
    DEC_ALUControl <= cdecode_ALUControl;
    DEC_ALUSource <= cdecode_ALUSource;
    DEC_RegDest <= cdecode_RegDest;
end

/// Impelementations
// Control unit
// Extra internal signals, to Decode...
wire control_RegDest;
wire control_ALUSource;
wire [3:0] control_ALUControl;
wire control_MemWrite;
wire control_RegWSource;
wire control_RegWrite;
wire control_Branch;
qm_control control(
    .i_Opcode(decode_Opcode),
    .i_Function(decode_Function),
    
    .co_RegDest(control_RegDest),
    .co_ALUSource(control_ALUSource),
    .co_ALUControl(control_ALUControl),
    .co_MemWrite(control_MemWrite),
    .co_RegWSource(control_RegWSource),
    .co_RegWrite(control_RegWrite),
    .co_Branch(control_Branch)
);
// ICache
qm_icache icache(
    .reset(reset),
    .clk(sys_clk),

    .address(ICache_Address),
    .data(ICache_Data),
    .hit(ICache_Hit),
    .stall(ICache_ShouldStall),
    .enable(ICache_Enable)
);
//Fetch
qm_fetch fetch(
    .di_PC(FD_NextPC),
    .do_IR(fetch_IR),
    .do_NextPC(fetch_NextPC),

    .icache_address(ICache_Address),
    .icache_hit(ICache_Hit),
    .icache_should_stall(ICache_ShouldStall),
    .icache_data(ICache_Data)
);
// Decode
qm_decode decode(
    .di_IR(fetch_IR),
    
    .do_RSVal(decode_RSVal),
    .do_RTVal(decode_RTVal),
    .do_Imm(decode_Imm),
    .do_RT(decode_RT),
    .do_RD(decode_RD),

    .di_WA(0),
    .di_WE(0),
    .di_WD(0),

    .o_Opcode(decode_Opcode),
    .o_Function(decode_Function),

    .ci_RegWrite(control_RegWrite),
    .ci_RegWSource(control_RegWSource),
    .ci_MemWrite(control_MemWrite),
    .ci_ALUControl(control_ALUControl),
    .ci_ALUSource(control_ALUSource),
    .ci_RegDest(control_RegDest),

    .co_RegDest(cdecode_RegDest),
    .co_ALUSource(cdecode_ALUSource),
    .co_ALUControl(cdecode_ALUControl),
    .co_MemWrite(cdecode_MemWrite),
    .co_RegWSource(cdecode_RegWSource),
    .co_RegWrite(cdecode_RegWrite)
);

endmodule
