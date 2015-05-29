`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:22:36 04/15/2015 
// Design Name: 
// Module Name:    VGA_DRV 
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


module VGA_DRV(
    input clk,
	 input rst,
    output reg HSYNC,
    output reg VSYNC,
    output reg [5:0] RGB,
	 output reg [13:0] BLOCKadress,
	 input [5:0] BLOCKdata,
	 output reg  [10:0] BIGadress,
	 input [5:0] BIGdata,
	 output enable
    );
	 initial RGB = 0;
	 initial BLOCKadress = 0;
	 initial BIGadress = 0;
parameter horizontal_total = 799;
parameter vertical_total = 520;

parameter horizontal_resolution = 639;
parameter vertical_resolution = 479;

parameter hsync_begin = 655;
parameter hsync_end = 751;

parameter vsync_begin = 489;
parameter vsync_end = 491;
reg [9:0] hsync_reg;	initial hsync_reg = 0;
reg [9:0] vsync_reg;	initial vsync_reg = 0;
reg [4:0] BIG_X;	initial BIG_X = 0;
reg [4:0] BIG_Y;	initial BIG_Y = 0;
wire Vact;
wire Hact;
wire [5:0] hsync_wire1;
wire [3:0] hsync_wire2;
// HSYNC COUNTER
always@(posedge clk)
begin
if(rst || hsync_reg == horizontal_total)
	hsync_reg <= 0;
else
	hsync_reg <= hsync_reg +1;
end

//VSYNC COUNTER
always@(posedge clk)
begin
if(rst || vsync_reg == vertical_total)
	vsync_reg <= 0;
if(hsync_reg ==0&& !rst)
	vsync_reg <= vsync_reg +1;
end

// HSYNC FF
always@(posedge clk)
begin
	if(rst || hsync_reg == hsync_end+4)
		HSYNC <=1;
	if(hsync_reg == hsync_begin+4)
		HSYNC <=0;
end
// VSYNC FF
always@(posedge clk)
begin
	if(rst || (vsync_reg == vsync_end))
		VSYNC <=1;
	if(vsync_reg == vsync_begin  )
		VSYNC <=0;
end

// Color MUX
always@(posedge clk)
begin
if(Hact&&Vact)
	RGB <= BLOCKdata;
	else RGB <= 0;
end

always@(posedge clk)
begin
	if(Hact && Vact)
	begin
		//BIGadress <= {vsync_reg[8:4],hsync_reg[9:4]};
		BIGadress <= {vsync_reg[8:4],hsync_wire1};
	end
end

always@(posedge clk)
begin
	if(Hact && Vact)
	begin
		BLOCKadress <= {BIGdata,vsync_reg[3:0],hsync_wire2};
	end
end

assign enable = Vact;
assign Hact = (hsync_reg>=4 && hsync_reg<= horizontal_resolution+4)?1:0;
assign Vact = (vsync_reg>=0 && vsync_reg<= vertical_resolution )?1:0;
assign hsync_wire1 = hsync_reg[9:4] -4 ;
assign hsync_wire2 = hsync_reg[3:0] -2 ;
endmodule