`timescale 1ns / 1ps
module BLOCK_framebuffer(
   input        clk,
   input        rst,
   input [13:0] wr_addr,
   input        wr_en,
   input [5:0] wr_data,
   input [13:0] rd_addr,
   output [5:0] rd_data
);
// Creating 128x64 8-bit-word array
reg [5:0] dp_ram[16383:0];
initial begin
  $readmemb("data.bin",  dp_ram) ;
end

// Implementing dual-port BlockRAM
// Both read and write ports are synchronous
// Read port has one clock cycle latency from valid adress
reg [5:0] rd_reg;
always @ (posedge clk)
begin
   if (wr_en)
      dp_ram[wr_addr] <= wr_data;
      
   rd_reg <= dp_ram[rd_addr];
end
assign rd_data = rd_reg;


endmodule
