`timescale 1ns / 1ps

module top_level(
   input        clk16M,
   input        rst,
	input			 xps2_c,
	input			 xps2_d,
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

wire [31:0] ps2_data;
wire [31:0] ps2_status;
reg  ps2_rd;
reg  [10:0] ps2_cntr;
reg  [7:0] out;
reg  [1:0] state;
initial state = 2'b00;
reg  ps2_valid;
reg last_element;initial last_element = 1;

always @ ( posedge clk )
begin
	if ( rst )
		ps2_cntr = 0;
	else 
		ps2_cntr = ps2_cntr + 1;
end

always @ ( posedge clk )
begin
	if ( ps2_valid == 1 )
		ps2_valid <= 0;
	if ( ps2_cntr == 1 )
		ps2_rd <= 1;
	if ( ps2_cntr >= 64 )
	begin
		ps2_rd <= 0;
		if ( ps2_status[0] == 0 )
			begin
				case ( state )
				2'b00:
					begin
						if ( ps2_data[7:0] == 8'b11100000 )
							state <= 2'b01;
						else if ( ps2_data[7:0] == 8'b11110000 )
							state <= 2'b10;
						else
							begin
								ps2_valid <= 1;
								state <= 0;
								out <= ps2_data[7:0];
							end
					end
				2'b01:
					begin
						if ( ps2_data[7:0] == 8'b11110000 )
							state <= 2'b10;
						else
							state <= 2'b11;
					end
				2'b10:
					begin
						state <= 2'b11;
					end
				2'b11:
					begin
						state <= 2'b00;
					end
				default:
					state <= 2'b00;
				endcase
			end
		/*else
			begin
				out <= 8'b00000000;
			end*/
	end
end
//assign ld = ps2_data[7:0];
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
	 .leds(ld), //ide voltak kötve  ledek
    .clk(clk),
    .rst(rst),
    .en(enwire),
    .BIG_RD_ADDR(BIGrd_addr),
    .BIG_WR_ADDR(BIGwr_addr),
    .BIG_WR_EN(BIGwe),
    .BIG_WR_DATA(BIGwr_data),
    .BIG_RD_DATA(BIGrd_data),
	 .ps2(out),
	 .ps2_en(ps2_valid)
    );
	 
ps2_if ps2_if(
   .clk(clk),
   .rst(rst),
   .ps2_c(xps2_c),
   .ps2_d(xps2_d),
   .fifo_rd(ps2_rd),
   .status(ps2_status),
   .data(ps2_data)
);


endmodule
