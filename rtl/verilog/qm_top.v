module qm_top(
    
);


// Fetch / Decode
reg [31:0] FD_IR;
reg [31:0] FD_NextPC;

// Decode / Execute
reg [31:0] DE_A;
reg [31:0] DE_B;
reg [31:0] DE_Imm;
reg [31:0] DE_IR;

wire [31:0] ICache_Address;
wire [31:0] ICache_Data;
wire ICache_Hit;
wire ICache_ShouldStall;
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

// Fetch
wire [31:0] fetch_IR;
wire [31:0] fetch_NextPC;
qm_fetch fetch(
    .di_PC(FD_NextPC),
    .do_IR(fetch_IR),
    .do_NextPC(fetch_NextPC),

    .icache_address(ICache_Address),
    .icache_hit(ICache_Hit),
    .icache_should_stall(ICache_ShouldStall),
    .icache_data(ICache_Data)
);
always @(posedge clk) begin
    FD_IR <= fetch_IR;
    FD_NextPC <= fetch_NextPC;
end


endmodule
