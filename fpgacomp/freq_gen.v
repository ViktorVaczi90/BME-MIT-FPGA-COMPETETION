`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:31:02 06/18/2015 
// Design Name: 
// Module Name:    freq_gen 
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
module freq_gen(
    input [6:0] freq_in,
	 input clk,
    output reg [12:0] cntr_out
    );
reg [12:0] frequencies [127:0];//adress: |octave2|octave1|octave0|note3|note2|note1|note0|
reg[10:0] k;
initial 
// C2-H#2
begin
frequencies[{3'd0,4'd0}] =5971;
frequencies[{3'd0,4'd1}] = 5636;
frequencies[{3'd0,4'd2}] = 5320;
frequencies[{3'd0,4'd3}] = 5022;
frequencies[{3'd0,4'd4}] = 4740;
frequencies[{3'd0,4'd5}] = 4474;
frequencies[{3'd0,4'd6}] = 4222;
frequencies[{3'd0,4'd7}] = 3985;
frequencies[{3'd0,4'd8}] = 3765;
frequencies[{3'd0,4'd9}] = 3551;
frequencies[{3'd0,4'd10}] = 3367;
frequencies[{3'd0,4'd11}] = 3163;
frequencies[{3'd0,4'd12}] = 0;
frequencies[{3'd0,4'd13}] = 0;
frequencies[{3'd0,4'd14}] = 0;
frequencies[{3'd0,4'd15}] = 0;

frequencies[{3'd1,4'd0}] = 2986;
frequencies[{3'd1,4'd1}] = 2818;
frequencies[{3'd1,4'd2}] = 3624;
frequencies[{3'd1,4'd3}] = 2511;
frequencies[{3'd1,4'd4}] = 5370;
frequencies[{3'd1,4'd5}] = 2237;
frequencies[{3'd1,4'd6}] = 2111;
frequencies[{3'd1,4'd7}] = 1992;
frequencies[{3'd1,4'd8}] = 1881;
frequencies[{3'd1,4'd9}] = 1775;
frequencies[{3'd1,4'd10}] = 1675;
frequencies[{3'd1,4'd11}] = 1581;
frequencies[{3'd1,4'd12}] = 0;
frequencies[{3'd1,4'd13}] = 0;
frequencies[{3'd1,4'd14}] = 0;
frequencies[{3'd1,4'd15}] = 0;

frequencies[{3'd2,4'd0}] = 1493;
frequencies[{3'd2,4'd1}] = 1409;
frequencies[{3'd2,4'd2}] = 1330;
frequencies[{3'd2,4'd3}] = 1255;
frequencies[{3'd2,4'd4}] = 1185;
frequencies[{3'd2,4'd5}] = 1118;
frequencies[{3'd2,4'd6}] = 1055;
frequencies[{3'd2,4'd7}] = 996;
frequencies[{3'd2,4'd8}] = 940;
frequencies[{3'd2,4'd9}] = 887;
frequencies[{3'd2,4'd10}] = 837;
frequencies[{3'd2,4'd11}] = 790;
frequencies[{3'd2,4'd12}] = 0;
frequencies[{3'd2,4'd13}] = 0;
frequencies[{3'd2,4'd14}] = 0;
frequencies[{3'd2,4'd15}] = 0;

frequencies[{3'd3,4'd0}] = 746;
frequencies[{3'd3,4'd1}] = 704;
frequencies[{3'd3,4'd2}] = 665;
frequencies[{3'd3,4'd3}] = 627;
frequencies[{3'd3,4'd4}] = 592;
frequencies[{3'd3,4'd5}] = 559;
frequencies[{3'd3,4'd6}] = 527;
frequencies[{3'd3,4'd7}] = 498;
frequencies[{3'd3,4'd8}] = 470;
frequencies[{3'd3,4'd9}] = 443;
frequencies[{3'd3,4'd10}] = 418;
frequencies[{3'd3,4'd11}] = 395;
frequencies[{3'd3,4'd12}] = 0;
frequencies[{3'd3,4'd13}] = 0;
frequencies[{3'd3,4'd14}] = 0;
frequencies[{3'd3,4'd15}] = 0;

frequencies[{3'd4,4'd0}] = 337;
frequencies[{3'd4,4'd1}] = 352;
frequencies[{3'd4,4'd2}] = 332;
frequencies[{3'd4,4'd3}] = 313;
frequencies[{3'd4,4'd4}] = 396;
frequencies[{3'd4,4'd5}] = 279;
frequencies[{3'd4,4'd6}] = 262;
frequencies[{3'd4,4'd7}] = 249;
frequencies[{3'd4,4'd8}] = 235;
frequencies[{3'd4,4'd9}] = 321;
frequencies[{3'd4,4'd10}] = 209;
frequencies[{3'd4,4'd11}] = 197;
frequencies[{3'd4,4'd12}] = 0;
frequencies[{3'd4,4'd13}] = 0;
frequencies[{3'd4,4'd14}] = 0;
frequencies[{3'd4,4'd15}] = 0;

frequencies[{3'd5,4'd0}] = 0;
frequencies[{3'd5,4'd1}] = 0;
frequencies[{3'd5,4'd2}] = 0;
frequencies[{3'd5,4'd3}] = 0;
frequencies[{3'd5,4'd4}] = 0;
frequencies[{3'd5,4'd5}] = 0;
frequencies[{3'd5,4'd6}] = 0;
frequencies[{3'd5,4'd7}] = 0;
frequencies[{3'd5,4'd8}] = 0;
frequencies[{3'd5,4'd9}] = 0;
frequencies[{3'd5,4'd10}] = 0;
frequencies[{3'd5,4'd11}] = 0;
frequencies[{3'd5,4'd12}] = 0;
frequencies[{3'd5,4'd13}] = 0;
frequencies[{3'd5,4'd14}] = 0;
frequencies[{3'd5,4'd15}] = 0;

frequencies[{3'd6,4'd0}] = 0;
frequencies[{3'd6,4'd1}] = 0;
frequencies[{3'd6,4'd2}] = 0;
frequencies[{3'd6,4'd3}] = 0;
frequencies[{3'd6,4'd4}] = 0;
frequencies[{3'd6,4'd5}] = 0;
frequencies[{3'd6,4'd6}] = 0;
frequencies[{3'd6,4'd7}] = 0;
frequencies[{3'd6,4'd8}] = 0;
frequencies[{3'd6,4'd9}] = 0;
frequencies[{3'd6,4'd10}] = 0;
frequencies[{3'd6,4'd11}] = 0;
frequencies[{3'd6,4'd12}] = 0;
frequencies[{3'd6,4'd13}] = 0;
frequencies[{3'd6,4'd14}] = 0;
frequencies[{3'd6,4'd15}] = 0;

frequencies[{3'd6,4'd0}] = 0;
frequencies[{3'd6,4'd1}] = 0;
frequencies[{3'd6,4'd2}] = 0;
frequencies[{3'd6,4'd3}] = 0;
frequencies[{3'd6,4'd4}] = 0;
frequencies[{3'd6,4'd5}] = 0;
frequencies[{3'd6,4'd6}] = 0;
frequencies[{3'd6,4'd7}] = 0;
frequencies[{3'd6,4'd8}] = 0;
frequencies[{3'd6,4'd9}] = 0;
frequencies[{3'd6,4'd10}] = 0;
frequencies[{3'd6,4'd11}] = 0;
frequencies[{3'd6,4'd12}] = 0;
frequencies[{3'd6,4'd13}] = 0;
frequencies[{3'd6,4'd14}] = 0;
frequencies[{3'd6,4'd15}] = 0;

frequencies[{3'd7,4'd0}] = 0;
frequencies[{3'd7,4'd1}] = 0;
frequencies[{3'd7,4'd2}] = 0;
frequencies[{3'd7,4'd3}] = 0;
frequencies[{3'd7,4'd4}] = 0;
frequencies[{3'd7,4'd5}] = 0;
frequencies[{3'd7,4'd6}] = 0;
frequencies[{3'd7,4'd7}] = 0;
frequencies[{3'd7,4'd8}] = 0;
frequencies[{3'd7,4'd9}] = 0;
frequencies[{3'd7,4'd10}] = 0;
frequencies[{3'd7,4'd11}] = 0;
frequencies[{3'd7,4'd12}] = 0;
frequencies[{3'd7,4'd13}] = 0;
frequencies[{3'd7,4'd14}] = 0;
frequencies[{3'd7,4'd15}] = 0;
end
always @(posedge clk)
cntr_out <= frequencies[freq_in];
//cntr_out <= 5971;



endmodule
