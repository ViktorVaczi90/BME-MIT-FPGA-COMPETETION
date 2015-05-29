`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:02:00 05/09/2015 
// Design Name: 
// Module Name:    game_mod 
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
module BLOCK_initialize(
    input clk,
    input rst,
    output reg [13:0] block_addr,
    output  reg [5:0] block_data,
    output block_we
    );
/*reg [1:0] upload_now;
always @(posedge clk)
begin
	if (rst)
		block_addr <=0;
	else if (upload_now == 1)
	block_addr <= block_addr +1;
end
always @(posedge clk)
begin
	if (block_addr < 256)
		block_data <= 6'b000000;
	if ( 255 < block_addr && block_addr < 512)
		block_data <= 6'b011001;
	if ( 511 < block_addr && block_addr < 768)
		block_data <= 6'b000111;
	if ( 767 < block_addr )
		block_data <= 6'b001110;
end
always @(posedge clk)
	upload_now <= upload_now +1;
assign block_we = (upload_now == 3);*/
endmodule
