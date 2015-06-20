`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:30:35 06/20/2015 
// Design Name: 
// Module Name:    BCD_SCORE 
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
module BCD_SCORE(
    input [14:0] score,
    input clk,
    output reg [3:0] thousands,
    output reg [3:0] hundreds,
    output reg [3:0] tens,
    output reg [3:0] ones
    );
reg [14:0] temp_score;
reg [3:0] state;			initial state = 0;
reg [3:0] cntr;

always @ ( posedge clk )
begin
	case ( state )
		0:
		begin
			temp_score <= score;
			cntr <= 0;
			state <= 1;
		end
		1:
		begin
			if ( temp_score >= 1000 )
			begin
				temp_score <= temp_score - 1000;
				cntr <= cntr + 1;
			end
			else
			begin
				thousands <= cntr;
				state <= 2;
				cntr <= 0;
			end
		end
		2:
		begin
			if ( temp_score >= 100 )
			begin
				temp_score <= temp_score - 100;
				cntr <= cntr + 1;
			end
			else
			begin
				hundreds <= cntr;
				state <= 3;
				cntr <= 0;
			end
		end
		3:
		begin
			if ( temp_score >= 10 )
			begin
				temp_score <= temp_score - 10;
				cntr <= cntr + 1;
			end
			else
			begin
				tens <= cntr;
				state <= 4;
				cntr <= 0;
			end
		end
		4:
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
