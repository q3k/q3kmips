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

/* verilator lint_off UNUSED */
module qm_dcache(
    input wire reset,
    input wire clk,

    // to the consumer (CPU execute stage)
    output reg stall,
    input wire [31:0] address,
    output reg [31:0] read_data,
    input wire [31:0] write_data,
    input wire write_enable,
    input wire enable,

    // to the memory controller (no wishbone yet...)
    // the cache is currently only backed in 1GBit RAM via this controller
    // this RAM is mapped 0x80000000 - 0x90000000
    output wire mem_cmd_clk, // we will keep this synchronous to the input clock
    output reg mem_cmd_en,
    output reg [2:0] mem_cmd_instr,
    output reg [5:0] mem_cmd_bl,
    output reg [29:0] mem_cmd_addr,
    input wire mem_cmd_full,
    input wire mem_cmd_empty,

    output wire mem_rd_clk,
    output reg mem_rd_en,
    input wire [6:0] mem_rd_count,
    input wire mem_rd_full,
    input wire [31:0] mem_rd_data,
    input wire mem_rd_empty,

    output wire mem_wr_clk,
    output wire mem_wr_en,
    output wire mem_wr_mask,
    output wire [31:0] mem_wr_data,

    input wire mem_wr_empty,
    input wire mem_wr_full,
    input wire mem_wr_underrun,
    input wire [6:0] mem_wr_count,
    input wire mem_wr_data
);


// 4k cache lines -> 16kword cache
reg [145:0] lines [4095:0];

/// internal signals
// the bit used to mark valid lines (flips when we flush the cache)
reg valid_bit;
wire [11:0] index;
wire index_valid;
wire [15:0] index_tag;
wire [15:0] address_tag;
wire [1:0] address_word;

//        145                                                         0
// -       +----------------------------------------------------------+
// ^ 4k    | s | v | tag  |  word 3  |  word 2  |  word 1  |  word 0  |
// | lines | s | v | tag  |  word 3  |  word 2  |  word 1  |  word 0  |
// |       | s | v | tag  |  word 3  |  word 2  |  word 1  |  word 0  | <--
// |       | s | v | tag  |  word 3  |  word 2  |  word 1  |  word 0  |  index
// |       | s | v | tag  |  word 3  |  word 2  |  word 1  |  word 0  |
// |       | s | v | tag  |  word 3  |  word 2  |  word 1  |  word 0  |
// v       | s | v | tag  |  word 3  |  word 2  |  word 1  |  word 0  |
// -       +----------------------------------------------------------+
//
// index - lower 16 bits of address, used to select a line
//  s - synced (written back to memory, can be evicted)
//  v - valid (has been read from memory, can be output to consumer)
//  tag - upper 16 bits of address, to check against requested address
//

assign index = address[15:4];
assign index_synced = lines[index]145];
assign index_valid = lines[index][144];
assign index_tag = lines[index][143:128];

assign address_tag = address[31:16];
assign address_word = address[3:2];

// Be pi degrees out of phase with DRAM controller
assign mem_rd_clk = ~clk;
assign mem_wr_clk = ~clk;
assign mem_cmd_clk = ~clk;
assign mem_wr_mask = 32'b0;

// reset condition
generate
    genvar i;
    for (i = 0; i < 4096; i = i + 1) begin: ruchanie
        always @(posedge clk) begin
            if (reset) begin
                lines[0] <= {146'b0};
            end
        end
    end
endgenerate
always @(posedge clk) begin
    if (reset) begin
        valid_bit <= 1;
        memory_read_state <= 0;
        memory_write_state <= 0;
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

reg [2:0] memory_read_state;
reg [2:0] memory_write_state;
always @(posedge clk) begin
    // Should we be running the read state machine?
    if ((stall && !reset && enable && index_sync == 1) ||
        (memory_read_state != 0 && !reset && enable)) begin
        case (memory_read_state)
            0: begin // assert command
                mem_cmd_instr <= 1; // read
                mem_cmd_bl <= 3; // four words
                mem_cmd_addr <= {1'b0, address[28:0]};
                mem_cmd_en <= 1;
                mem_rd_en <= 1;
                memory_read_state <= 1;
            end
            1: begin // wait for first word
                mem_cmd_en <= 0;
                if (!mem_rd_empty) begin
                    lines[index][31:0] <= mem_rd_data;
                    memory_read_state <= 2;
                end
            end
            2: begin // wait for second word
                if (!mem_rd_empty) begin
                    lines[index][63:32] <= mem_rd_data;
                    memory_read_state <= 3;
                end
            end
            3: begin // wait for third word
                if (!mem_rd_empty) begin
                    lines[index][95:64] <= mem_rd_data;
                    memory_read_state <= 4;
                end
            end
            4: begin // wait for fourth word
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
    // Should we be running the writeback state machine?
    if ((stall && !reset && enable && index_sync == 0) ||
        (memory_write_state != 0 && !reset && enable)) begin
        case (memory_write_state)
            0: begin
                // first word to fifo
                if (!mem_wr_full) begin
                    mem_wr_en <= 1;
                    mem_wr_data <= lines[index][31:0];
                    memory_write_state <= 1;
                end
            end
            1: begin
                // second word to fifo
                if (!mem_wr_full) begin
                    mem_wr_data <= lines[index][63:32];
                    memory_write_state <= 2;
                end
            end
            2: begin
                // third word to fifo
                if (!mem_wr_full) begin
                    mem_wr_data <= lines[index][95:64];
                    memory_write_state <= 3;
                end
            end
            3: begin
                // fourth word to fifo
                if (!mem_wr_full) begin
                    mem_wr_data <= lines[index][127:96];

                    // also send write command
                    mem_cmd_en <= 1;
                    mem_cmd_instr <= 0; // write
                    mem_cmd_bl <= 3; // four words
                    mem_cmd_addr <= {1'b0, address[28:0]};

                    memory_write_state <= 4;
                end
            end
            4: begin
                mem_wr_en <= 0;
                mem_cmd_en <= 0;
                memory_write_state <= 0;
            end
        endcase
    end
end

endmodule
