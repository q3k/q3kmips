module qm_icache(
    input wire [31:0] address,
    input wire reset,
    input wire clk,

    output wire hit,
    output wire stall,
    output wire [31:0] data
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
always @(posedge clk)
    if (reset)
        valid_bit <= 1;

// read condition
always @(address) begin
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
end

endmodule
