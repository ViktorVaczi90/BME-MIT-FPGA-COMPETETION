`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:14:30 06/20/2015 
// Design Name: 
// Module Name:    BCD_LEVEL 
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
module BCD_LEVEL(
    input [5:0] level,
    input clk,
    output reg [3:0] ones,
    output reg [3:0] tens
    );
reg [14:0] temp_score;
reg [3:0] state;			initial state = 0;
reg [3:0] cntr;

always @ ( posedge clk )
begin
	case ( state )
		0:
		begin
			temp_score <= level;
			cntr <= 0;
			state <= 1;
		end
		1:
		begin
			if ( temp_score >= 10 )
			begin
				temp_score <= temp_score - 10;
				cntr <= cntr + 1;
			end
			else
			begin
				tens <= cntr;
				state <= 2;
				cntr <= 0;
			end
		end
		2:
		begin
			if ( temp_score >= 1 )
			begin
				temp_score <= temp_score - 1;
				cntr <= cntr + 1;
			end
			else
			begin
				ones <= cntr;
				state <= 0;
				cntr <= 0;
			end
		end
	endcase
end

endmodule
