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
    input clk,
	 input [3:0] inlevel,
    //input rst,
    //output [7:0] ld,
   // input [7:0] sw,
    //input [3:0] bt,
	 output audio_out
    );

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
wire [6:0] freqwire2;

pwm_gen outpwm(.clk(clk),.level({mixer_wire[7:0]}),.audio_out(aud_out_wire));//wavetable2_wire[8:2]

wavetable sinwave(.clk(clk),.out_level(wavetable1_wire),.input_pos({phase1[5:0],2'b00}));
wavetable2 sinwave2(.clk(clk),.out_level(wavetable2_wire),.input_pos({phase2[5:0],2'b00}));

freqtophase phasemod1(.clk(clk),.freq(freq_wire1),.phase(phase1));
freqtophase phasemod2(.clk(clk),.freq(freq_wire2),.phase(phase2));

freq_gen myfreq(.freq_in(freqwire1),.cntr_out(freq_wire1),.clk(clk));
freq_gen myfreq2(.freq_in(freqwire2),.cntr_out(freq_wire2),.clk(clk));

song_reader firstsong(.clk(clk),.freq_out(freqwire1),.leds(ledswire),.level(inlevel));
song_reader2 firstsong2(.clk(clk),.freq_out(freqwire2),.level(inlevel));

assign audio_out = aud_out_wire;
assign mixer_wire = wavetable1_wire[8:2] + wavetable2_wire[8:2];
endmodule
