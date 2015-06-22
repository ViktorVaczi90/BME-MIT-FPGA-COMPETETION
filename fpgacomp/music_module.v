`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:13:25 06/11/2015 
// Design Name: 
// Module Name:    top_module 
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
module music_module(
    input inclk,
	 input [3:0] inlevel,
	 output audio_out,
	 input full_row,
	 input music_pause,
	 input music_game_over,
	 output [7:0]leds
    );
wire clk;
wire [7:0] phase1;
wire [7:0] phase2;
wire[12:0] freq_wire1;
wire[12:0] freq_wire2;
wire [7:0] ledswire;
wire aud_out_wire;
wire [8:0] wavetable1_wire;
wire [8:0] wavetable2_wire;
wire [7:0] mixer_wire;
wire [6:0] freqwire1;
wire [6:0] freqwire1_full_row;
reg [6:0] freqwire1_game_over;
reg [6:0] freqwire2_game_over;
wire [6:0] freqwire2;
wire [6:0] freqwire1_mux;
wire [6:0] freqwire2_mux;
reg [3:0] state; initial state = 0;
reg [23:0] full_row_cntr; initial full_row_cntr = 0;
reg full_row_reg;
always@(posedge clk)
	full_row_reg <= full_row;
always@(posedge clk)
begin
case (state)
	0:
	begin
		full_row_cntr <= 1;
		if(full_row && !full_row_reg)
		begin
			state <= 1; 
			full_row_cntr <= 1;
		end
		else if (music_game_over)
		begin
			state <= 2;
			full_row_cntr <= 1;
		end
	end
	
	1:
	begin
	full_row_cntr <= full_row_cntr +1;
	if(full_row_cntr[23])
	state <= 0;
	end
	
	2:
	begin
		freqwire1_game_over <= {3'd2,4'd10};
		freqwire2_game_over <= {3'd2,4'd8};
		if(!full_row_cntr)
		begin
			full_row_cntr <= 1;
			state <= state +1;
	end
		else
			begin
			if(!full_row_cntr[23])
				full_row_cntr <= full_row_cntr +1;
			else full_row_cntr <= 0;
		end
	end
	3:
	begin
		freqwire1_game_over <= {3'd2,4'd9};
		freqwire2_game_over <= {3'd2,4'd7};
		if(!full_row_cntr)
		begin
			full_row_cntr <= 1;
			state <= state +1;
	end
		else
			begin
			if(!full_row_cntr[23])
				full_row_cntr <= full_row_cntr +1;
			else full_row_cntr <= 0;
		end
	end
	
	4:
	begin
		freqwire1_game_over <= {3'd2,4'd8};
		freqwire2_game_over <= {3'd2,4'd6};
		if(!full_row_cntr)
		begin
			full_row_cntr <= 1;
			state <= state +1;
	end
		else
			begin
			if(!full_row_cntr[23])
				full_row_cntr <= full_row_cntr +1;
			else full_row_cntr <= 0;
		end
	end
	
	5:
	begin
		freqwire1_game_over <= {3'd2,4'd7};
		freqwire2_game_over <= {3'd2,4'd5};
		if(!full_row_cntr)
		begin
			full_row_cntr <= 1;
			state <= state +1;
	end
		else
			begin
			if(!full_row_cntr[23])
				full_row_cntr <= full_row_cntr +1;
			else full_row_cntr <= 0;
		end
	end
	
	6:
	begin
		freqwire1_game_over <= {3'd2,4'd6};
		freqwire2_game_over <= {3'd2,4'd4};
		if(!full_row_cntr)
		begin
			full_row_cntr <= 1;
			state <= state +1;
	end
		else
			begin
			if(!full_row_cntr[23])
				full_row_cntr <= full_row_cntr +1;
			else full_row_cntr <= 0;
		end
	end

	7:
	begin
		freqwire1_game_over <= {3'd2,4'd6};
		freqwire2_game_over <= {3'd2,4'd4};
		if(!full_row_cntr)
		begin
			full_row_cntr <= 1;
			state <= state +1;
	end
		else
			begin
			if(!full_row_cntr[23])
				full_row_cntr <= full_row_cntr +1;
			else full_row_cntr <= 0;
		end
	end	
	8:
	begin
		freqwire1_game_over <= {3'd2,4'd13};
		freqwire2_game_over <= {3'd2,4'd13};
		if(!music_game_over)
		state <= 0;
	end
	endcase
end

pwm_gen outpwm(.clk(clk),.level({mixer_wire[7:0]}),.audio_out(aud_out_wire));//wavetable2_wire[8:2]

wavetable sinwave(.clk(clk),.out_level(wavetable1_wire),.input_pos({phase1[5:0],2'b00}));
wavetable2 sinwave2(.clk(clk),.out_level(wavetable2_wire),.input_pos({phase2[5:0],2'b00}));

freqtophase phasemod1(.clk(clk),.freq(freq_wire1),.phase(phase1));
freqtophase phasemod2(.clk(clk),.freq(freq_wire2),.phase(phase2));

freq_gen myfreq(.freq_in(freqwire1_mux),.cntr_out(freq_wire1),.clk(clk));
freq_gen myfreq2(.freq_in(freqwire2_mux),.cntr_out(freq_wire2),.clk(clk));

song_reader firstsong(.clk(clk),.freq_out(freqwire1),.leds(ledswire),.level(inlevel));
song_reader2 firstsong2(.clk(clk),.freq_out(freqwire2),.level(inlevel));

assign clk = (music_pause && !music_game_over)?0:inclk;
assign audio_out = aud_out_wire;
assign mixer_wire = wavetable1_wire[8:2] + wavetable2_wire[8:2];
assign freqwire1_mux = (state==1)?freqwire1_full_row:(!state)?freqwire1:freqwire1_game_over;
assign freqwire2_mux = (state == 0)?freqwire2:freqwire2_game_over;
assign freqwire1_full_row = {1'b0,full_row_cntr[22:21],full_row_cntr[20:18],1'b0};
assign leds = state;
endmodule
