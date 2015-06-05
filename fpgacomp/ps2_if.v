module ps2_if(
   input         clk,
   input         rst,
   input         ps2_c,
   input         ps2_d,
   
   input         fifo_rd,
   output [31:0] status,
   output [31:0] data
);


// system synchronous PS2 clock falling edge detection
reg [1:0] ps2c_dl;
always @ (posedge clk)
   ps2c_dl <= {ps2c_dl[0], ps2_c};

wire smpl_en;
assign smpl_en = (ps2c_dl==2'b10);

// bit counter
// start bit, 8 data bits, parity bit, stop bit
reg [3:0] bit_cntr;
always @ (posedge clk)
if (rst)
   bit_cntr <= 0;
else if (smpl_en)
   if (bit_cntr==10)
      bit_cntr <= 0;
   else
      bit_cntr <= bit_cntr + 1;
      
reg data_valid;
always @ (posedge clk)
if (smpl_en==1 & bit_cntr==10)
   data_valid <= 1;
else
   data_valid <= 0;

// data shift register
reg [10:0] data_shr;
always @ (posedge clk)
if (smpl_en)
   data_shr <= {ps2_d, data_shr[10:1]};
   

// scan code to ascii conversion
(* rom_style = "distributed" *) reg [7:0] ascii_val/* synthesis syn_romstyle = "select_rom" */;
always @ ( * )
case (data_shr[8:1])	
   8'h1C: ascii_val = 8'h41;		//A
   8'h32: ascii_val = 8'h42;		//B
   8'h21: ascii_val = 8'h43;		//C
   8'h23: ascii_val = 8'h44;		//D
   8'h24: ascii_val = 8'h45;		//E
   8'h2B: ascii_val = 8'h46;		//F
   8'h34: ascii_val = 8'h47;		//G
   8'h33: ascii_val = 8'h48;		//H
   8'h43: ascii_val = 8'h49;		//I
   8'h3B: ascii_val = 8'h4A;		//J
   8'h42: ascii_val = 8'h4B;		//K
   8'h4B: ascii_val = 8'h4C;		//L
   8'h3A: ascii_val = 8'h4D;		//M
   8'h31: ascii_val = 8'h4E;		//N
   8'h44: ascii_val = 8'h4F;		//O
   8'h4D: ascii_val = 8'h50;		//P
   8'h15: ascii_val = 8'h51;		//Q
   8'h2D: ascii_val = 8'h52;		//R
   8'h1B: ascii_val = 8'h53;		//S
   8'h2C: ascii_val = 8'h54;		//T
   8'h3C: ascii_val = 8'h55;		//U
   8'h2A: ascii_val = 8'h56;		//V
   8'h1D: ascii_val = 8'h57;		//W
   8'h22: ascii_val = 8'h58;		//X
   8'h35: ascii_val = 8'h59;		//Y
   8'h1A: ascii_val = 8'h5A;		//Z
   
   8'h45: ascii_val = 8'h30;		//0
   8'h16: ascii_val = 8'h31;		//1
   8'h1E: ascii_val = 8'h32;		//2
   8'h26: ascii_val = 8'h33;		//3
   8'h25: ascii_val = 8'h34;		//4
   8'h2E: ascii_val = 8'h35;		//5
   8'h36: ascii_val = 8'h36;		//6
   8'h3D: ascii_val = 8'h37;		//7
   8'h3E: ascii_val = 8'h38;		//8
   8'h46: ascii_val = 8'h39;		//9
   
   8'h70: ascii_val = 8'h30;		//0
   8'h69: ascii_val = 8'h31;		//1
   8'h72: ascii_val = 8'h32;		//2
   8'h7a: ascii_val = 8'h33;		//3
   8'h6b: ascii_val = 8'h34;		//4
   8'h73: ascii_val = 8'h35;		//5
   8'h74: ascii_val = 8'h36;		//6
   8'h6c: ascii_val = 8'h37;		//7
   8'h75: ascii_val = 8'h38;		//8
   8'h7d: ascii_val = 8'h39;		//9
   
   8'h79: ascii_val = 8'h2b;		//+
   8'h7b: ascii_val = 8'h2d;		//-
   8'h7c: ascii_val = 8'h2a;		//*
   
   /*Numeric 0	70
   Numeric 1	69
   Numeric 2	72
   Numeric 3	7A
   Numeric 4	6B
   Numeric 5	73
   Numeric 6	74
   Numeric 7	6C
   Numeric 8	75
   Numeric 9	7D
   
   Numeric +	79
   Numeric *	7C
   Numeric -	7B*/
   
   8'h0E: ascii_val = 8'h60;		// `
   8'h4E: ascii_val = 8'h2D;		// -
   8'h55: ascii_val = 8'h3D;		// =
   8'h5C: ascii_val = 8'h5C;		// \
   8'h29: ascii_val = 8'h20;		// (space)
   8'h54: ascii_val = 8'h5B;		// [
   8'h5B: ascii_val = 8'h5D;		// ] 
   8'h4C: ascii_val = 8'h3B;		// ;
   8'h52: ascii_val = 8'h27;		// '
   8'h41: ascii_val = 8'h2C;		// ,
   8'h49: ascii_val = 8'h2E;		// .
   8'h4A: ascii_val = 8'h2F;		// /
   
   8'h5A: ascii_val = 8'h0D;		// enter (CR)
   8'h66: ascii_val = 8'h08;		// backspace
   
   // arrows
   //8'h74: ascii_val = 8'h4A;		// left arrow
   //8'h6b: ascii_val = 8'h42;		// right arrow
   
   8'hF0: ascii_val = 8'hF0;		   // BREAK CODE
   default: ascii_val = 8'h23;		// #
endcase

// Instantiating SRL16 based FIFO
wire [7:0] fifo_dout;
wire fifo_empty, fifo_full;
srl_fifo data_fifo(
   .clk(clk),
   .rst(rst),
   .wr(data_valid),
   .rd(fifo_rd),
   .din(ascii_val),
   .dout(fifo_dout),
   .empty(fifo_empty),
   .full(fifo_full)
);

// Generating 32 bit output ports
assign status = {30'b0, fifo_full, fifo_empty};
assign data   = {24'b0, fifo_dout};

endmodule


