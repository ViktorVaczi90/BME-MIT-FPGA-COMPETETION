`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:46:57 05/09/2015
// Design Name:   VGA
// Module Name:   F:/Users/Viktor/XILINX_PROJECTS/lab456/bambi_m456/ISE/VGATEST.v
// Project Name:  lab_456
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: VGA
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module VGATEST;

	// Inputs
	reg clk;
	reg [3:0] adat;
	reg [12:0] adress;
	reg rst;
	reg we;

	// Outputs
	wire [5:0] RGB;
	wire xhs;
	wire xvs;

	// Instantiate the Unit Under Test (UUT)
	VGA uut (
		.clk(clk), 
		.adat(adat), 
		.adress(adress), 
		.rst(rst), 
		.we(we), 
		.RGB(RGB), 
		.xhs(xhs), 
		.xvs(xvs)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		adat = 0;
		adress = 0;
		rst = 1;
		we = 0;

		// Wait 100 ns for global reset to finish
		#20;
      rst = 0;
		// Add stimulus here

	end
	always #2
	clk = ~clk;
      
endmodule

