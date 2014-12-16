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
