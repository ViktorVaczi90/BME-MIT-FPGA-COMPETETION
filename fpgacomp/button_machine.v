`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:50:06 06/21/2015 
// Design Name: 
// Module Name:    button_machine 
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
module button_machine(
    input [7:0] button,
    input clk,
    output pulse,
    input [7:0] ps2_out,
    input ps2_pulse,
	 output [7:0] leds
    );
reg [21:0] cntr; initial cntr = 0;
reg [2:0] state; initial state = 0;
always@(posedge clk)
begin
	case (state)
		0:
		begin
			if (ps2_pulse && (ps2_out == button))
			state <= 1;
		end
		1:
		begin
			state <= 2;
			cntr <= 1;
		end
		2:
		begin
			cntr <= cntr +1;
			if (!cntr)
			state <= 4;
			if (ps2_pulse && (ps2_out == 8'hF0))
				state <= 3;
		end
		3:
		begin
			if (ps2_pulse )
			begin
			if (ps2_out == button)
					state <= 0;
				else 
					state <= 2;
			end
		end
		4:
		begin
			if (ps2_pulse && (ps2_out == 8'hF0))
				state <= 5;
		end
		5:
		begin
			if (ps2_pulse )
			begin
			if (ps2_out == button)
					state <= 0;
				else 
					state <= 4;
			end
		end	
	endcase
end
assign pulse = ((state == 1)||(state == 4)||(state == 5));
assign leds = state;
endmodule
