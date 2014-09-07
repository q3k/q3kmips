module qm_decode(
    /// datapath
    // input instruction register
    input wire [31:0] di_IR,
    // output instruction register
    output wire [31:0] do_IR,
    // output first operand
    output wire [31:0] do_A,
    // output second operand
    output wire [31:0] do_B,
    // output immediate
    output wire [31:0] do_Imm,

    // control signals
    
    // debug signals
    input wire [4:0] dbg_wa,
    input wire dbg_we,
    input wire [31:0] dbg_wd
);

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
    .rd1(do_A),
    .rd2(do_B),

    // unused
    .wa3(dbg_wa),
    .we3(dbg_we),
    .wd3(dbg_wd)
);

// sign extend imm
assign do_Imm[31:0] = { {16{imm[15]}}, imm[15:0] };

assign do_IR = di_IR;

endmodule
