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
	input [7:0] sw,
	output aud_out
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
wire [5:0] levelwire;
wire [31:0] ps2_data;
wire [31:0] ps2_status;
wire music_pause_wire;
wire music_game_over_wire;
wire full_row_wire;
reg  ps2_rd;
reg  [7:0] out;
reg  [1:0] state;
initial state = 2'b00;

reg [3:0] ps2state2; initial ps2state2 = 1;
reg  ps2_valid;
reg last_element;initial last_element = 1;

always @ ( posedge clk)
begin
	
	if (ps2state2 == 0)
	begin
		
		if(!ps2_status[0]) 
		begin
			ps2_rd <= 1;
			ps2state2 <= 1;
		end
		else
			ps2_rd <= 0;
	end
	
	if (ps2state2 == 1)
	begin
		ps2_rd <= 0;
		ps2state2 <= 0;
	end
	
	if ( ps2_valid == 1 )
		ps2_valid <= 0;
		
		
		
	if ( ps2state2 == 1   )
	begin
		out <= ps2_data[7:0];
				case ( state )
				2'b00:
					begin
						if ( ps2_data[7:0] == 8'b11100000 )
							state <= 2'b01;
						else if ( ps2_data[7:0] == 8'b11110000 )
							state <= 2'b11;
						else
							begin
								ps2_valid <= 1;
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
end
wire down_pulse, left_pulse, right_pulse;
button_machine downbutton(
		.clk(clk),
		.button(8'h32),
		.ps2_out(ps2_data[7:0]),
		.ps2_pulse(ps2state2),
		//.leds(ld[7:0]),
		.pulse(down_pulse)
		);
		
button_machine leftbutton(
		.clk(clk),
		.button(8'h34),
		.ps2_out(ps2_data[7:0]),
		.ps2_pulse(ps2state2),
		.leds(ld[7:0]),
		.pulse(left_pulse)
		);
		
button_machine rightbutton(
		.clk(clk),
		.button(8'h36),
		.ps2_out(ps2_data[7:0]),
		.ps2_pulse(ps2state2),
		//.leds(ld[7:0]),
		.pulse(right_pulse)
		);
		
music_module mymusic(
		.inclk(clk),
		.inlevel(levelwire[3:0]),
		.audio_out(aud_out),
		.full_row(full_row_wire),
		.music_pause(music_pause_wire),
		.music_game_over(music_game_over_wire)/*,
		.leds(ld)*/);
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
	 //.leds(ld), //ide voltak kötve  ledek
    .clk(clk),
    .rst(rst),
    .en(enwire),
    .BIG_RD_ADDR(BIGrd_addr),
    .BIG_WR_ADDR(BIGwr_addr),
    .BIG_WR_EN(BIGwe),
    .BIG_WR_DATA(BIGwr_data),
    .BIG_RD_DATA(BIGrd_data),
	 .ps2(out),
	 .ps2_en(ps2_valid),
	 .level(levelwire),
	 .full_row(full_row_wire),
	 .music_pause(music_pause_wire),
	 .music_game_over(music_game_over_wire),
	 .down_pulse(down_pulse),
	 .left_pulse(left_pulse),
	 .right_pulse(right_pulse)
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
//assign ld = {ps2_status[1:0],out[5:0]};

endmodule
