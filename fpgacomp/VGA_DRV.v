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
wire [10:0] hsync_wire1;
wire [10:0] hsync_wire2;
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
if(hsync_reg ==796&& !rst)
	vsync_reg <= vsync_reg +1;
end

// HSYNC FF
always@(posedge clk)
begin
	if(rst || hsync_reg == hsync_end)//+4)
		HSYNC <=1;
	if(hsync_reg == hsync_begin)//+4)
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
	if(1)
	begin
		//BIGadress <= {vsync_reg[8:4],hsync_reg[9:4]};
		BIGadress <= {vsync_reg[8:4],hsync_wire1[9:4]};
	end
end

always@(posedge clk)
begin
	if(1)
	begin
		BLOCKadress <= {BIGdata,vsync_reg[3:0],hsync_wire2[3:0]};
		//BLOCKadress <= {BIGdata,vsync_reg[3:0],hsync_reg[3:0]};
	end
end

assign enable = Vact;
assign Hact = (hsync_reg>=0 && hsync_reg<= horizontal_resolution)?1:0;// +4-tol kéne.
assign Vact = (vsync_reg>=0 && vsync_reg<= vertical_resolution )?1:0;
//assign hsync_wire1 = hsync_reg +4 ;
//assign hsync_wire2 = hsync_reg +2;
assign hsync_wire1 = (hsync_reg>=0 && hsync_reg <=790)?hsync_reg+4:0 ;
assign hsync_wire2 = (hsync_reg>=0 && hsync_reg <=797)?hsync_reg +2 :(hsync_reg ==798)?0:1 ;
endmodule