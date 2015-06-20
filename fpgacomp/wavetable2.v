`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:41:41 06/11/2015 
// Design Name: 
// Module Name:    wavetable 
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
module wavetable2(
    input clk,
    output reg [8:0] out_level,
    input [7:0] input_pos
    );
reg [8:0] dp_ram[255:0];
initial begin
  $readmemb("sine.bin",  dp_ram) ;
end
always@(posedge clk)
out_level <=dp_ram[input_pos];
endmodule
