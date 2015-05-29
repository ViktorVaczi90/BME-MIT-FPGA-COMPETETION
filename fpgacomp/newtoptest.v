`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:17:20 05/26/2015
// Design Name:   top_level
// Module Name:   F:/Users/Viktor/XILINX_PROJECTS/FPGACOMP2/fpgacomp/toptest.v
// Project Name:  fpgacomp
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top_level
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module toptest;

	// Inputs
	reg clk16M;
	reg rst;
	reg [3:0] bt;
	reg [7:0] sw;

	// Outputs
	wire [5:0] rgb;
	wire hs;
	wire vs;
	wire [7:0] ld;

	// Instantiate the Unit Under Test (UUT)
	top_level uut (
		.clk16M(clk16M), 
		.rst(rst), 
		.rgb(rgb), 
		.hs(hs), 
		.vs(vs), 
		.ld(ld), 
		.bt(bt), 
		.sw(sw)
	);

		always #1
		clk16M = ~clk16M;
	initial begin
		// Initialize Inputs
		clk16M = 0;
		rst = 1;
		bt = 0;
		sw = 0;

		// Wait 100 ns for global reset to finish
		#10;

        		rst =0 ;
		// Add stimulus here

	end
      
endmodule

