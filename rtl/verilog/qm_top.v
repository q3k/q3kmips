module qm_top(
    
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
reg cdecode_RegWrite;
reg cdecode_RegWSource;
reg cdecode_MemWrite;
reg [3:0] cdecode_ALUControl;
reg cdecode_ALUSource;
reg cdecode_RegDest;

/// Datapath signal inputs
// Fetch / Decode
reg [31:0] FD_IR;
reg [31:0] FD_NextPC;
// Decode / Execute
reg [31:0] DE_RSVal;
reg [31:0] DE_RTVal;
reg [31:0] DE_Imm;
reg [31:0] DE_RS;
reg [31:0] DE_RT;

/// Datapath signal outputs
// Fetch
wire [31:0] fetch_IR;
wire [31:0] fetch_NextPC;
// Decode
wire [31:0] decode_RSVal;
wire [31:0] decode_RTVal;
wire [31:0] decode_Imm;
wire [4:0] decode_RS;
wire [4:0] decode_RT;
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
    DE_RS <= decode_RS;
    DE_RT <= decode_RT;

    DEC_RegWrite <= cdecode_RegWrite;
    DEC_REGWSource <= cdecode_RegWSource;
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
    i_Opcode(decode_Opcode),
    i_Function(decode_Function),
    
    co_RegDest(control_RegDest),
    co_ALUSource(control_ALUSource),
    co_ALUControl(control_ALUControl),
    co_MemWrite(control_MemWrite),
    co_RegWSource(control_RegWSource),
    co_RegWrite(control_RegWrite),
    co_Branch(control_Branch)
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
    .do_RS(decode_RS),
    .do_RT(decode_RT),

    di_WA(0),
    di_WE(0),
    di_WD(0),

    o_Opcode(decode_Opcode),
    o_Function(decode_Function),

    ci_RegWrite(control_RegWrite),
    ci_RegWSource(control_RegWSource),
    ci_MemWrite(control_MemWrite),
    ci_ALUControl(control_ALUControl),
    ci_ALUSource(control_ALUSource),
    ci_RegDest(control_RegDest),

    co_RegDest(cdecode_RegDest),
    co_ALUSource(cdecode_ALUSource),
    co_ALUControl(cdecode_ALUControl),
    co_MemWrite(cdecode_MemWrite),
    co_RegWSource(cdecode_RegWSource),
    co_RegWrite(cdecode_RegWrite),
   
);

endmodule
