`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:48:52 06/18/2015 
// Design Name: 
// Module Name:    song_reader 
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
module song_reader(
    input clk, // 16 Mhz!!!!??
    input[3:0] level,
	 output [7:0] leds,
    output [6:0] freq_out
	 
    );
reg [5:0] state; initial state = 0;
reg [20:0] cycle_cntr; initial cycle_cntr = 0;
reg [7:0] notes [255:0];
reg [10:0] notes_cntr; initial notes_cntr =0;
reg [4:0] wait_cntr; initial wait_cntr = 0;// 15-ÖS ESETBEN BEíROD -> 16 ÓRAJELET VÁRSZ
reg [2:0] current_octave; initial current_octave = 0;
reg [3:0] current_note;initial current_note = 0;
reg [3:0] repeat_times;initial repeat_times = 0;
always @(posedge clk)
begin
	if (cycle_cntr == {5'b11111,16'b1111111111111111}-{1'b0,level[3:0],16'b1111111111111111})
		cycle_cntr <=0;
	else
		cycle_cntr <= cycle_cntr +1;
end
always @(posedge clk)
begin
	
	if(!cycle_cntr && wait_cntr)
		wait_cntr <= wait_cntr -1;
		
	case (state)
		0:
		begin
			if(notes[notes_cntr][7:4] < 12 | notes[notes_cntr][7:4] == 14 /*NOTE OFF*/)// WAIT
			begin
				current_note <= notes[notes_cntr][7:4];
				wait_cntr <= notes[notes_cntr][3:0] +1 ;//lEGYEN 16 IS!!! AZ AZ F!!!!
				state <= 2;
			end
			if(notes[notes_cntr][7:4] == 13)//REPEAT
			begin
				if(!repeat_times)
					repeat_times <= notes[notes_cntr][3:0];
				else 
					repeat_times <= repeat_times -1;
				if(notes[notes_cntr][3:0])
				begin
					notes_cntr <= notes_cntr +1;
					state <= 4;
				end
				else
				begin
					notes_cntr <= notes[notes_cntr+1][3:0];
					state <=0;
				end
			end
			if(notes[notes_cntr][7:4] == 12)//next read
			begin
				notes_cntr <= notes_cntr +1;
				state <= 1;
			end
		end
		1:
		begin
		if (notes[notes_cntr][7:4] < 5)
			begin
				current_octave<=notes[notes_cntr][7:4];
				state <= 2;
			end
		end
		2:
		begin
			if(!wait_cntr)
			state <= 3;
		end
		3:
		begin
			notes_cntr <= notes_cntr +1;
			state <= 0;
		end
		4://REPEAT!!!!
		begin
			if(repeat_times)
			notes_cntr <= notes[notes_cntr];
			else notes_cntr <= notes_cntr +1;
			state <= 0;
		end
	endcase
end
initial $readmemh("notes.hex", notes) ;
//assign freq_out = 1;
assign leds = repeat_times;
assign freq_out = {current_octave,current_note};
endmodule
