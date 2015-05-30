`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:28:29 05/26/2015 
// Design Name: 
// Module Name:    TETRIS_GAME 
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
module TETRIS_GAME(
    input [3:0] btn,
    input clk,
    input rst,
    input en,
	 output [7:0] leds,
    output reg [10:0] BIG_RD_ADDR,
    output reg [10:0] BIG_WR_ADDR,
    output reg BIG_WR_EN,
    output reg [5:0] BIG_WR_DATA,
    input[5:0] BIG_RD_DATA
    );
	 initial BIG_RD_ADDR = 0;
	 initial BIG_WR_ADDR = 0;
	 initial BIG_WR_EN = 0;
	 initial BIG_WR_DATA = 0;
	 
	 parameter tetris_x_begin = 10;
	 parameter tetris_x_end = 19;
	 parameter tetris_y_begin = 5;
	 parameter teris_y_end = 24;
	 
	 parameter check_down_start = 4000;
	 parameter check_down_end = 4999;
	 reg [14:0] down_cntr; initial down_cntr = 0;
	 wire [5:0] hor_wire_down;
	 wire [6:0] ver_wire_down;
	 reg canmove_down;initial canmove_down = 0;

	 parameter check_left_start = 5000;
	 parameter check_left_end = 5999;
	 reg [14:0] left_cntr; initial left_cntr = 0;
	 wire [5:0] hor_wire_left;
	 wire [6:0] ver_wire_left;
	 reg canmove_left;initial canmove_left = 0;

	 parameter check_right_start = 6000;
	 parameter check_right_end = 6999;
	 reg [14:0] right_cntr; initial right_cntr = 0;
	 wire [5:0] hor_wire_right;
	 wire [6:0] ver_wire_right;
	 reg canmove_right;initial canmove_right = 0;

	//ROTATION PARAMETERS
	//THERE ARE 7 BLOCKS, THE COLOR DEFINES THE BLOCK_ID. THE 0 COLOR IS THE EMPTY CELL
	 parameter check_rot_start = 7000;
	 parameter check_rot_end = 7999;
	 reg [14:0] rot_cntr; initial rot_cntr = 0;
	 reg [1:0] rotation; initial rotation = 0;
	 wire [1:0] nextrot;
	 wire [5:0] hor_wire_rot;
	 wire [6:0] ver_wire_rot;
	 wire [1:0] rot_cntr_0;
	 wire [1:0] rot_cntr_1;
	 wire [1:0] rot_cntr_2;
	 reg [5:0] vertical_rot_data [127:0];//|block_id2|block_id1|block_id0|rotation1|rotation0|vertical1|vertical0| 
	 reg [6:0] horizontal_rot_data [127:0];//|block_id2|block_id1|block_id0|rotation1|rotation0|vertical1|vertical0| 	 
	 reg canmove_rot; initial canmove_rot = 1;
	  
	 reg [2:0] color; 
	 initial color = 1;
	 initial begin
  $readmemb("vertical.bin",  vertical_rot_data) ;
  $readmemb("horizontal.bin",  horizontal_rot_data) ;
  end
	 
	 parameter moves_start = 10000;
	 parameter moves_end = 12000;

	 wire [5:0] hor_wire;
	 wire [6:0] ver_wire;
	 reg [14:0] move_cntr;initial move_cntr = 0;
	 reg [14:0] cycle_cntr;initial cycle_cntr = 0;
	 reg [6:0] gravity;initial gravity = 0; //ALWAYS MOVE DOWN WHEN == 0
	 reg [6:0] gravity_speed;initial gravity_speed = 20;
	 reg [20:0] vsync_cntr;	 initial vsync_cntr = 0;
	 reg [5:0] pos_x; initial pos_x = 5;
	 reg [4:0] pos_y; initial pos_y = 1;

	 reg [5:0] vertical [3:0]; 
	 initial begin 
	 vertical[0] = 0;
	 vertical[1] = 0;
	 vertical[2] = 1;
	 vertical[3]  = 1;
	 end
	 
	 reg [6:0] horizontal [3:0];
	 initial begin 
	 horizontal[0] = 0;
	 horizontal[1] = 1;
	 horizontal[2] = 0;
	 horizontal[3]  = 1;
	 end
	 
	 reg en_posedge;
	 
	 parameter number_of_blocks = 3;
	 reg [2:0] random ;initial random = 1;
	 
	 always @ ( posedge clk)
	 begin
	 if ( random == number_of_blocks ) 
	 random <= 1;
	 else random <= random +1;
	 end
	 
	always@(posedge clk)
	begin
	if( en_posedge == 0 && en == 1 ) 
		gravity <= gravity +1;
	if (gravity == gravity_speed)
		gravity <=0;
	end
	always@(posedge clk)
	if( en_posedge == 0 && en == 1 ) 
		vsync_cntr <= vsync_cntr +1;
		
	always@(posedge clk)
	begin
	if( en_posedge == 0 && en == 1 ) 
		cycle_cntr <= 0;
		else if (en) cycle_cntr <= cycle_cntr +1;
	end
	always@(posedge clk) 
		en_posedge <= en;

	//CHECK BLOCKS
	always@(posedge clk)// INIT COUNTERS //LEFT
		begin
		if(cycle_cntr ==check_left_start )
		left_cntr <= 0 ;
		if (cycle_cntr > check_left_start && cycle_cntr < check_left_end)
		left_cntr <= left_cntr +1;
	end
	always@(posedge clk)//RIGHT
		begin
		if(cycle_cntr ==check_right_start )
		right_cntr <= 0 ;
		if (cycle_cntr > check_right_start && cycle_cntr < check_right_end)
		right_cntr <= right_cntr +1;
	end
	always@(posedge clk)//DOWN
	begin
		if(cycle_cntr ==check_down_start )
		down_cntr <= 0 ;
		if (cycle_cntr > check_down_start && cycle_cntr < check_down_end)
		down_cntr <= down_cntr +1;
	end	
	always@(posedge clk)//ROTATION
	begin
		if(cycle_cntr ==check_rot_start )
		rot_cntr <= 0 ;
		if (cycle_cntr > check_rot_start && cycle_cntr < check_rot_end)
		rot_cntr <= rot_cntr +1;
	end	
	//***********************************END OF INIT COUNTERS

	always@(posedge clk)
	begin
		//*******************************CHECKDOWN BEGIN
	if (down_cntr == 0 && (cycle_cntr > check_down_start && cycle_cntr < check_down_end)) canmove_down <=1;
	
	if(down_cntr >= 0 && down_cntr <= 3 && (cycle_cntr > check_down_start && cycle_cntr < check_down_end))	
   BIG_RD_ADDR <= {ver_wire_down[4:0]+1,hor_wire_down[5:0]};
	if(down_cntr >= 2 && down_cntr <= 5 && (cycle_cntr > check_down_start && cycle_cntr < check_down_end))//Current block is move_cntr -1;
	begin
		if((BIG_RD_DATA && 
	
	!(//nem saját
	(vertical[down_cntr -2] + 1 == vertical[down_cntr -1] && horizontal[down_cntr -2] == horizontal[down_cntr -1]) ||
	(vertical[down_cntr -2] + 1 == vertical[down_cntr ] && horizontal[down_cntr -2] == horizontal[down_cntr ])||
	(vertical[down_cntr -2] + 1 == vertical[down_cntr +1] && horizontal[down_cntr -2] == horizontal[down_cntr +1])
	))
	||
			tetris_y_begin +pos_y + vertical[down_cntr -2] >= teris_y_end) // Position
				canmove_down <= 0; 
	end
		//*******************************CHECKDOWN END
		//*******************************CHECKLEFT BEGIN
	if (left_cntr == 0 &&  (cycle_cntr > check_left_start && cycle_cntr < check_left_end)) canmove_left <=1;
	
	if(left_cntr >= 0 && left_cntr <= 3 &&  (cycle_cntr > check_left_start && cycle_cntr < check_left_end))	
   BIG_RD_ADDR <= {ver_wire_left[4:0],hor_wire_left[5:0]};
	if(left_cntr >= 2 && left_cntr <= 5 &&  (cycle_cntr > check_left_start && cycle_cntr < check_left_end))//Current block is move_cntr -2;
		if((BIG_RD_DATA && 
	!(//nem saját
	(horizontal[left_cntr -2]  == horizontal[left_cntr -1] +1 && vertical[left_cntr -2] == vertical[left_cntr -1]) ||
	(horizontal[left_cntr -2]  == horizontal[left_cntr   ] +1 && vertical[left_cntr -2] == vertical[left_cntr   ]) ||
	(horizontal[left_cntr -2]  == horizontal[left_cntr +1] +1 && vertical[left_cntr -2] == vertical[left_cntr +1])
	))||
			tetris_x_begin +pos_x + horizontal[left_cntr -2] <= tetris_x_begin) // Position
				canmove_left <= 0; 
	//*******************************CHECKLEFT END*/
	//*******************************CHECKRIGHT BEGIN
	if (right_cntr == 0 &&  (cycle_cntr > check_right_start && cycle_cntr < check_right_end)) canmove_right <=1;
	
	if(right_cntr >= 0 && right_cntr <= 3 &&  (cycle_cntr > check_right_start && cycle_cntr < check_right_end))	
   BIG_RD_ADDR <= {ver_wire_right[4:0],hor_wire_right[5:0]};
	if(right_cntr >= 2 && right_cntr <= 5 &&  (cycle_cntr > check_right_start && cycle_cntr < check_right_end))//Current block is move_cntr -2;
		if((BIG_RD_DATA && 
	!(//nem saját
	(horizontal[right_cntr -2]+1  == horizontal[right_cntr -1]  && vertical[right_cntr -2] == vertical[right_cntr -1]) ||
	(horizontal[right_cntr -2]+1  == horizontal[right_cntr   ]  && vertical[right_cntr -2] == vertical[right_cntr   ]) ||
	(horizontal[right_cntr -2]+1  == horizontal[right_cntr +1]  && vertical[right_cntr -2] == vertical[right_cntr +1])
	))||
			tetris_x_begin +pos_x + horizontal[right_cntr -2] >= tetris_x_end) // Position
				canmove_right <= 0; 
	//*******************************CHECKLEFT END*/
		//*******************************CHECKROT BEGIN
	if (rot_cntr == 0 &&  (cycle_cntr > check_rot_start && cycle_cntr < check_rot_end)) canmove_rot <=1;
	
	if(rot_cntr >= 0 && rot_cntr <= 3 &&  (cycle_cntr > check_rot_start && cycle_cntr < check_rot_end))	
   BIG_RD_ADDR <= {ver_wire_rot[4:0],hor_wire_rot[5:0]};
	if(rot_cntr >= 2 && rot_cntr <= 5 &&  (cycle_cntr > check_rot_start && cycle_cntr < check_rot_end))//Current block is move_cntr -2;
		if((BIG_RD_DATA && 
	!(//nem saját
	(horizontal[rot_cntr -2]  == horizontal_rot_data[{color,nextrot,rot_cntr_0}]  && vertical[rot_cntr -2] == vertical_rot_data[{color,nextrot,rot_cntr_0}] ) ||
	(horizontal[rot_cntr -2]  == horizontal_rot_data[{color,nextrot,rot_cntr_1}]   && vertical[rot_cntr -2] == vertical_rot_data[{color,nextrot,rot_cntr_1}]) ||
	(horizontal[rot_cntr -2]  == horizontal_rot_data[{color,nextrot,rot_cntr_2}]   && vertical[rot_cntr -2] == vertical_rot_data[{color,nextrot,rot_cntr_2}])
	))/*||
			tetris_x_begin +pos_x + horizontal[right_cntr -2] >= tetris_x_end*/) // Position
				canmove_rot <= 0; 
	//*******************************CHECKROT END*/
	end
	//END OF CHECKS
	
//MOVES BLOCKS
	always@(posedge clk) // SETUP MOVE_CNTR
	begin
		if(cycle_cntr ==moves_start )
		move_cntr <= 0 ;
		if (cycle_cntr > moves_start && cycle_cntr < moves_end)
		move_cntr <= move_cntr +1;
	end
	
	always@(posedge clk)
	begin

		if (/* gravity == 1 &&*/ move_cntr >1 && move_cntr <= 6)// ERASE PREVIOUS POSITION
			begin
				BIG_WR_ADDR <= {ver_wire[4:0],hor_wire[5:0]};
				BIG_WR_DATA <= 0;
				BIG_WR_EN <= 1;
			end
		if ( move_cntr == 7)
			BIG_WR_EN <= 0;
		if ( move_cntr >= 17 && move_cntr <= 20 )//WRITE OUT NEW POSITION
		begin
		BIG_WR_ADDR <= {ver_wire[4:0],hor_wire[5:0] };
		BIG_WR_DATA <= color;
		BIG_WR_EN <= 1;
		end
		if ( move_cntr == 21) BIG_WR_EN <= 0;
		if ( move_cntr == 10&& gravity == 1 && canmove_down) // MOVE DOWN ON 16TH MOVE_CNTR CYCLE
			pos_y <= pos_y +1;
		if(move_cntr == 11 && canmove_right && btn[0] && !(gravity == 1 && !canmove_down)) //SORRENDET ÁT KELL GONDOLNI, LEHET HOGY NEM TUD LEFELE MENNI, LERAKJA, DE MÉG ELMEGY EGYET BALRA JOBBRA.
			pos_x <= pos_x +1;
		if(move_cntr == 12 && canmove_left && btn[1]&& !(gravity == 1 && !canmove_down))
			pos_x <= pos_x -1;
		if(move_cntr == 13 && btn[2] && !(gravity == 1 && !canmove_down)&& canmove_rot) 
			rotation <= rotation +1;
		if(move_cntr == 14 && btn[2] && !(gravity == 1 && !canmove_down)&& canmove_rot) 
			begin
			vertical[0] <= vertical_rot_data[{color,rotation,2'b00}];
			 vertical[1] <= vertical_rot_data[{color,rotation,2'b01}];
			 vertical[2] <= vertical_rot_data[{color,rotation,2'b10}];
			 vertical[3]  <= vertical_rot_data[{color,rotation,2'b11}];
			 horizontal[0] <= horizontal_rot_data[{color,rotation,2'b00}];
			 horizontal[1] <= horizontal_rot_data[{color,rotation,2'b01}];
			 horizontal[2] <= horizontal_rot_data[{color,rotation,2'b10}];
			 horizontal[3]  <= horizontal_rot_data[{color,rotation,2'b11}];
			end
		if (gravity == 1 && move_cntr ==21 && !canmove_down) //EZT A FELTÉTELT MÉG A LEFT RIGHTBA BE KELL ÍRNI.
		begin
		color <= 1;
		 vertical[0] <= vertical_rot_data[{color,rotation,2'b00}];
		 vertical[1] <= vertical_rot_data[{color,rotation,2'b01}];
		 vertical[2] <= vertical_rot_data[{color,rotation,2'b10}];
		 vertical[3]  <= vertical_rot_data[{color,rotation,2'b11}];
		 horizontal[0] <= horizontal_rot_data[{color,rotation,2'b00}];
		 horizontal[1] <= horizontal_rot_data[{color,rotation,2'b01}];
		 horizontal[2] <= horizontal_rot_data[{color,rotation,2'b10}];
		 horizontal[3]  <= horizontal_rot_data[{color,rotation,2'b11}];
		 pos_x<= 5;
		 pos_y<= 1;
		end
		
				
		
		//DEBUG
		
		if ( move_cntr == 1000)
		begin
		BIG_WR_ADDR <= {5'd24,6'd9};
		BIG_WR_DATA <= 3;
		BIG_WR_EN <= 1;
		end
				if ( move_cntr == 1001)
		begin
		BIG_WR_ADDR <= {5'd24,6'd20};
		BIG_WR_DATA <= 3;
		BIG_WR_EN <= 1;
		end
		if ( move_cntr == 1002)
		begin
		BIG_WR_ADDR <= {5'd4,6'd30};
		BIG_WR_DATA <= 54+pos_y;
		BIG_WR_EN <= 1;
		end
		if ( move_cntr == 1003)
		begin
		BIG_WR_ADDR <= {5'd3,6'd30};
		BIG_WR_DATA <= 54+pos_x;
		BIG_WR_EN <= 1;
		end
		if ( move_cntr == 1004)
		begin
		BIG_WR_ADDR <= {5'd2,6'd30};
		BIG_WR_DATA <= 54+vertical_rot_data[{color,rotation,2'b10}];
		BIG_WR_EN <= 1;
		end
		if ( move_cntr == 1005)
		begin
		BIG_WR_ADDR <= {5'd1,6'd30};
		BIG_WR_DATA <= 54+vertical_rot_data[{color,rotation,2'b11}];
		BIG_WR_EN <= 1;
		end
		if ( move_cntr == 1006)
		begin
		BIG_WR_ADDR <= {5'd10,6'd30};
		BIG_WR_DATA <= 54+canmove_rot;
		BIG_WR_EN <= 1;
		end
		if ( move_cntr == 1007)
		BIG_WR_EN <= 0;
		
		//END DEBUBG
	end
	//END OF MOVES
	assign ver_wire = tetris_y_begin + pos_y + vertical[move_cntr];
	assign hor_wire = tetris_x_begin +pos_x + horizontal[move_cntr];
	
	assign ver_wire_down = tetris_y_begin + pos_y + vertical[down_cntr];
	assign hor_wire_down = tetris_x_begin +pos_x + horizontal[down_cntr];
	
	assign ver_wire_left = tetris_y_begin + pos_y + vertical[left_cntr];
	assign hor_wire_left = tetris_x_begin +pos_x + horizontal[left_cntr]-5'b1; // Lehet gond, érdemes lehet 6 bitre csinálni a kivonásnál
	
	assign ver_wire_right = tetris_y_begin + pos_y + vertical[right_cntr];
	assign hor_wire_right = tetris_x_begin +pos_x + horizontal[right_cntr]+5'b1; // Lehet gond, érdemes lehet 6 bitre csinálni a kivonásnál
	
	assign ver_wire_rot = tetris_y_begin + pos_y + vertical_rot_data[{color,nextrot,rot_cntr}];
	assign hor_wire_rot = tetris_x_begin +pos_x + horizontal_rot_data[{color,nextrot,rot_cntr}]; // Lehet gond, érdemes lehet 6 bitre csinálni a kivonásnál
	
	 assign rot_cntr_0 = rot_cntr +3;
	 assign rot_cntr_1 = rot_cntr +0;
	 assign rot_cntr_2 = rot_cntr +1;
	
	assign nextrot = rotation +1;
	assign leds ={color,rotation};
	
endmodule