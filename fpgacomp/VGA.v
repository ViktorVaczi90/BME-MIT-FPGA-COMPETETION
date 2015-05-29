`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:36:29 04/15/2015 
// Design Name: 
// Module Name:    VGA 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//`define INSIDE_BIGINITFASZ
module VGA(
    input clk,
	 input rst,
	 output [5:0]RGB,
	 output xhs,
	 output xvs,
	 input [10:0] BIG_RD_ADDR,
	 input [10:0] BIG_WR_ADDR,
	 input BIG_WR_EN,
	 input [5:0] BIG_WR_DATA,
	 output [5:0] BIG_RD_DATA,
	 output  en
    );
	 //BIG
	 wire [10:0] BIG_ADRESS;
	 wire [5:0] BIG_DATA;
	 
	//BLOCK
	 wire [13:0] BLOCK_ADRESS;
	 wire [5:0] BLOCK_DATA;
	 
	 wire BLOCKwe;
	 wire [13:0] BLOCKwr_addr;
	 wire [5:0] BLOCKwr_data;
	 
	 wire enablewire;
	 wire [10:0]RDMUXwire;

	 VGA_DRV bambiVGA(.enable(enablewire),
	 .clk(clk),
	 .HSYNC(xhs),
	 .VSYNC(xvs),
	 .RGB(RGB),
	 .rst(rst),
	 .BLOCKadress(BLOCK_ADRESS),
	 .BLOCKdata(BLOCK_DATA),
	 .BIGadress(BIG_ADRESS),
	 .BIGdata(BIG_DATA));
	 
	 BLOCK_framebuffer BLOCKframe(.clk(clk),
	 .rst(rst),
	 .wr_en(BLOCKwe),
	 .wr_addr(BLOCKwr_addr),
	 .wr_data(BLOCKwr_data),
	 .rd_addr(BLOCK_ADRESS),
	 .rd_data(BLOCK_DATA));
	 /*BLOCK_initialize BLOCKinitialize(.clk(clk),
	 .rst(rst),
	 .block_addr(BLOCKwr_addr),
	 .block_data(BLOCKwr_data),
	 .block_we(BLOCKwe));*/
	 
	 BIG_framebuffer BIGframe(.clk(clk),
	 .rst(rst),	 
	 .wr_en(BIG_WR_EN),
	 .wr_addr(BIG_WR_ADDR),
	 .wr_data(BIG_WR_DATA),
	 .rd_addr(RDMUXwire),
	 .rd_data(BIG_DATA));


	 assign BIG_RD_DATA = BIG_DATA;
	 assign RDMUXwire = enablewire?BIG_ADRESS:BIG_RD_ADDR;
	 assign en = !enablewire;
endmodule
