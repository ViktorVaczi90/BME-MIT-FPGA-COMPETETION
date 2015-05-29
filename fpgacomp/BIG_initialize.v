`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:22:54 05/09/2015 
// Design Name: 
// Module Name:    BIG_initialize 
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
module BIG_initialize(
    input clk,
    input rst,
    output reg [10:0] big_addr,
    output reg [5:0] big_data,
    output big_we
    );
reg [2:0] upload_now;
always @(posedge clk)
begin
	if (rst)
		big_addr <=0;
	else if ( upload_now == 0)
		big_addr <= big_addr +1;
end

reg [5:0] vmi;

always @(posedge clk)
begin
	vmi = {big_addr[8:6], big_addr[2:0]};
	big_data <= vmi;
	/*if (vmi == 0) big_data <= 0;//else
	if (vmi == 1) big_data <= 1;//else
	if (vmi == 2) big_data <= 2;//else
	if (vmi == 3) big_data <= 3;//else*/
	//if (vmi >  2 && big_addr != 20) big_data <= 0;//{4'b0000,big_addr[1:0]};
	//if (vmi > 2) big_data <= 1;
end
always @(posedge clk)
begin
	if(rst)
		upload_now <=0;
	else 
		upload_now <= upload_now +1;
end
assign big_we = (upload_now == 2);

endmodule
