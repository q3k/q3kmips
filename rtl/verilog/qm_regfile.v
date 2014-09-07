module qm_regfile(
    input wire we3,
    input wire [4:0] ra1,
    input wire [4:0] ra2,
    input wire [4:0] wa3,
    output wire [31:0] rd1,
    output wire [31:0] rd2,
    input wire [31:0] wd3
    );

	// three ported register file
	// two read ports, one write port
	
	// actual flops
	reg [31:0] rf [31:0];
	
	always @(wd3) begin
		if (we3) begin
			rf[wa3] = wd3;
		end
	end
	
	assign rd1 = rf[ra1];
	assign rd2 = rf[ra2];

endmodule
