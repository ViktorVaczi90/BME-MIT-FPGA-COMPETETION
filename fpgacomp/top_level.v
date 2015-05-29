`timescale 1ns / 1ps

module top_level(
   input        clk16M,
   input        rst,
   output [5:0] rgb,
   output       hs,
   output       vs,
	output [7:0] ld,
	input [3:0] bt,
	input [7:0] sw
);

// Generating 25 MHz system clock
wire clk;
clk_gen clk_gen(
   .xclk(clk16M),
   .clk(clk)
);

wire 			BIGwe;
wire [10:0] BIGwr_addr;
wire [5:0] 	BIGwr_data;
wire [10:0] BIGrd_addr;
wire [5:0] BIGrd_data;
wire enwire;
//BIG INIT
/*BIG_initialize BIGinitialize(
	 .clk(clk),
	 .rst(rst),
	 .big_addr(BIGwr_addr),
	 .big_data(BIGwr_data),
	 .big_we(BIGwe)
	 );*/
//VGA
VGA BAMBIVGA(
    .clk(clk),
	 .rst(rst),
	 .RGB(rgb),
	 .xhs(hs),
	 .xvs(vs),
	 .BIG_RD_ADDR(BIGrd_addr),
	 .BIG_WR_ADDR(BIGwr_addr),
	 .BIG_WR_EN(BIGwe),
	 .BIG_WR_DATA(BIGwr_data),
	 .BIG_RD_DATA(BIGrd_data),
	 .en(enwire)
    );
TETRIS_GAME TETRIS_GAME(
	 .btn(bt),
	 .leds(ld),
    .clk(clk),
    .rst(rst),
    .en(enwire),
    .BIG_RD_ADDR(BIGrd_addr),
    .BIG_WR_ADDR(BIGwr_addr),
    .BIG_WR_EN(BIGwe),
    .BIG_WR_DATA(BIGwr_data),
    .BIG_RD_DATA(BIGrd_data)
    );

/*
//TESTING GAME
reg[19:0] tempcntr;
reg [4:0] vertical;
reg [5:0] horizontal;
initial vertical = 10;
initial horizontal = 10;
always@(posedge clk)
	tempcntr <= tempcntr + 1;
always@(posedge clk)
begin
if(tempcntr == 0)
	begin
	if(bt[0])
	begin
		vertical <= vertical +1;
		end
	if(bt[1])
	begin
		vertical <= vertical -1;
		end
	end
end

always@(posedge clk)
begin
if(tempcntr == 0)
	begin
	if(bt[2])
	begin
		horizontal <= horizontal +1;
	end
	if(bt[3])
	begin
		horizontal <= horizontal -1;
	end
	end
end
/*
assign BIGwe = 1;
assign BIGwr_addr = {vertical,horizontal};
assign BIGwr_data = (bt && !tempcntr)?0:sw;//Amig meg nem változik a horizontal v. vertical gyorsan beírunk 0-t..
assign ld = horizontal;*/
//assign ld = sw;

endmodule
