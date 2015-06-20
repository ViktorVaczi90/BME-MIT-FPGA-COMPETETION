`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:35:54 06/11/2015 
// Design Name: 
// Module Name:    pwm_gen 
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
module pwm_gen(
    input clk,
    input [7:0] level,
    output audio_out
    );
reg [7:0] cntr; initial cntr = 0;
always@(posedge clk)
begin
	cntr <= cntr +1;
end
assign audio_out = (cntr <= level);
endmodule
