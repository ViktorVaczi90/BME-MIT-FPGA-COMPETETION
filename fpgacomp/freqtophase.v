`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:35:21 06/20/2015 
// Design Name: 
// Module Name:    freqtophase 
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
module freqtophase(
    input clk,
    input [12:0] freq,
    output reg [7:0] phase
    );
reg [12:0] temp_cntr;
always@(posedge clk)
begin
	if (temp_cntr == freq[12:0])
		temp_cntr <= 0;
	else
		temp_cntr <= temp_cntr +1;
end
	
	
always@(posedge clk)
begin
	if (0!= freq)
		begin
			if(!temp_cntr)
				phase <= phase +1;
		end
		else 
			phase <= 0;
end

endmodule
