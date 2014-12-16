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

module qm_fetch(
    /// datapath
    // input PC to assume
    input wire [31:0] di_PC,
    // output instruction register
    output wire [31:0] do_IR,
    // output to next PC
    output wire [31:0] do_NextPC,

    // icache connectivity
    output wire [31:0] icache_address,
    input wire icache_hit,
    input wire icache_should_stall,
    input wire [31:0] icache_data
 );

assign icache_address = di_PC;

always @(*) begin
    if (icache_should_stall && !icache_hit) begin
        do_NextPC = di_PC;
        do_IR = 0;
    end else begin
        do_NextPC = di_PC + 4;
        do_IR = icache_data;
    end
end

endmodule
