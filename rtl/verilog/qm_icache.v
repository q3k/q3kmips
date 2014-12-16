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
//
/* verilator lint_off UNUSED */
module qm_icache(
    input wire [31:0] address,
    input wire reset,
    input wire clk,

    // to the consumer (CPU fetch stage)
    output wire hit,
    output wire stall,
    output wire [31:0] data,
    input wire enable,

    // to the memory controller (no wishbone yet...)
    // the cache is currently only backed in 1GBit RAM via this controller
    // this RAM is mapped 0x80000000 - 0x90000000
    output wire mem_cmd_clk, // we will keep this synchronous to the input clock
    output wire mem_cmd_en,
    output wire [2:0] mem_cmd_instr,
    output wire [5:0] mem_cmd_bl,
    output wire [29:0] mem_cmd_addr,
    input wire mem_cmd_full,
    input wire mem_cmd_empty,

    output wire mem_rd_clk,
    output wire mem_rd_en,
    input wire [6:0] mem_rd_count,
    input wire mem_rd_full,
    input wire [31:0] mem_rd_data,
    input wire mem_rd_empty
);


// 4k cache lines -> 16kword cache
reg [144:0] lines [4095:0];

/// internal signals
// the bit used to mark valid lines (flips when we flush the cache)
reg valid_bit;
wire [11:0] index;
wire index_valid;
wire [15:0] index_tag;
wire [15:0] address_tag;
wire [1:0] address_word;

assign index = address[15:4];
assign index_valid = lines[index][144];
assign index_tag = lines[index][143:128];

assign address_tag = address[31:16];
assign address_word = address[3:2];

assign mem_rd_clk = clk;
assign mem_cmd_clk = clk;

// reset condition
generate
    genvar i;
    for (i = 0; i < 4096; i = i + 1) begin: ruchanie
        always @(posedge clk) begin
            if (reset) begin
                lines[0] <= {145'b0};
            end
        end
    end
endgenerate
always @(posedge clk) begin
    if (reset) begin
        valid_bit <= 1;
        memory_read_state <= 0;
        mem_cmd_en <= 0;
        mem_cmd_bl <= 0;
        mem_cmd_instr <= 0;
        mem_cmd_addr <= 0;
        mem_rd_en <= 0;
    end
end

// read condition
always @(*) begin
    if (enable) begin
        // is this in the RAM region?
        if (32'h80000000 <= address && address < 32'h90000000) begin
            // do we have a hit?
            if (index_valid == valid_bit && index_tag == address_tag) begin
                if (address_word == 2'b00)
                    data = lines[index][31:0];
                else if (address_word == 2'b01)
                    data = lines[index][63:32];
                else if (address_word == 2'b10)
                    data = lines[index][95:64];
                else
                    data = lines[index][127:96];
                hit = 1;
                stall = 0;
            end else begin
                hit = 0;
                stall = 1;
            end
        end else begin
            hit = 1;
            stall = 0;
            data = 32'h00000000;
        end
    end else begin
        hit = 0;
        stall = 0;
    end
end

// if we are stalling, it means that our consumer is waiting for us to
// read memory and provide it data
reg [2:0] memory_read_state;
always @(posedge clk) begin
    if (stall && !reset && enable) begin
        case (memory_read_state)
            0: begin // assert command
                mem_cmd_instr <= 1; // read
                mem_cmd_bl <= 3; // four words
                mem_cmd_addr <= {1'b0, address[28:0]};
                mem_cmd_en <= 0;
                memory_read_state <= 1;
            end
            1: begin // assert enable
                mem_cmd_en <= 1;
                memory_read_state <= 2;
                mem_rd_en <= 1;
            end
            2: begin // wait for first word
                mem_cmd_en <= 0;
                if (!mem_rd_empty) begin
                    lines[index][31:0] <= mem_rd_data;
                    memory_read_state <= 3;
                end
            end
            3: begin // wait for second word
                if (!mem_rd_empty) begin
                    lines[index][63:32] <= mem_rd_data;
                    memory_read_state <= 4;
                end
            end
            4: begin // wait for third word
                if (!mem_rd_empty) begin
                    lines[index][95:64] <= mem_rd_data;
                    memory_read_state <= 5;
                end
            end
            5: begin // wait for fourth word
                if (!mem_rd_empty) begin
                    lines[index][127:96] <= mem_rd_data;
                    memory_read_state <= 0;
                    mem_rd_en <= 0;
                    // write tag
                    lines[index][143:128] <= address_tag;
                    // and valid bit - our cominatorial logic will now turn
                    // off stalling and indicate a hit to the consumer
                    lines[index][144] <= valid_bit;
                end
            end
        endcase
    end
end

endmodule
