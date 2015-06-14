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
	 output reg [7:0] leds,
    output reg [10:0] BIG_RD_ADDR,
    output reg [10:0] BIG_WR_ADDR,
    output reg BIG_WR_EN,
    output reg [5:0] BIG_WR_DATA,
    input[5:0] BIG_RD_DATA,
	 input [7:0] ps2,
	 input ps2_en
    );
	reg pause_keyboard; initial pause_keyboard = 0;
	//***************** parameters/positions
	parameter number_start = 28;
	parameter score_x_pos = 27;
	parameter score_y_pos = 8;
	parameter nextblock_x_pos = 29;
	parameter nextblock_y_pos = 21;
	parameter level_x_pos = 32;
	parameter level_y_pos = 14;
	//***************** end of parameters/positions
	reg [5:0] level; initial level = 1;
	reg [14:0] levelscore; initial levelscore = 0;
	wire [4:0] clear_next_ver;
	wire [5:0] clear_next_hor;
	wire [4:0] write_next_ver;
	wire [5:0] write_next_hor;
	reg [2:0] nextcolor;
	 reg [14:0] score; initial score = 0;
	 //*******PS2 kezelése
	 reg right_keyboard;
	 reg left_keyboard;
	 reg down_keyboard;
	 reg rot_keyboard; 
	 //*******PS2 kezelése
	 
	 //****************Bejövõk initje
	 initial BIG_RD_ADDR = 0;
	 initial BIG_WR_ADDR = 0;
	 initial BIG_WR_EN = 0;
	 initial BIG_WR_DATA = 0;
	 //****************Bejövõk initje
	 
	 //************Tetris tábla eleje és vége
	 parameter tetris_x_begin = 10;
	 parameter tetris_x_end = 20;
	 parameter tetris_y_begin = 5;
	 parameter teris_y_end = 24;
	 //************Tetris tábla eleje és vége
	 
	 //DEBUG
	 reg [3:0] debugreg [30:0];
	 //END OF DEBUG
	 
	 //*****************************Tud e lefelé menni
	 parameter check_down_start = 4000;
	 parameter check_down_end = 4999;
	 reg [14:0] down_cntr; 					initial down_cntr = 0;
	 wire [5:0] hor_wire_down;
	 wire [6:0] ver_wire_down;
	 reg canmove_down;						initial canmove_down = 0;
	 //*****************************Tud e lefelé menni
	 
	 //******************************Tud e balra menni
	 parameter check_left_start = 5000;
	 parameter check_left_end = 5999;
	 reg [14:0] left_cntr; 					initial left_cntr = 0;
	 wire [5:0] hor_wire_left;
	 wire [6:0] ver_wire_left;
	 reg canmove_left;						initial canmove_left = 0;
	 //******************************Tud e balra menni

	 //******************************Tud e jobbra menni	
	 parameter check_right_start = 6000;
	 parameter check_right_end = 6999;
	 reg [14:0] right_cntr; 				initial right_cntr = 0;
	 wire [5:0] hor_wire_right;
	 wire [6:0] ver_wire_right;
	 reg canmove_right;						initial canmove_right = 0;
	 //******************************Tud e jobbra menni

	//****************************************Tud e forogni
	 parameter check_rot_start = 8000;
	 parameter check_rot_end = 8999;
	 reg [14:0] rot_cntr; 					initial rot_cntr = 0;
	 reg [1:0] rotation; 					initial rotation = 1;
	 wire [1:0] nextrot;
	 wire [5:0] hor_wire_rot;
	 wire [6:0] ver_wire_rot;
	 wire [1:0] rot_cntr_0;
	 wire [1:0] rot_cntr_1;
	 wire [1:0] rot_cntr_2;
	 reg [5:0] vertical_rot_data [127:0];												//|block_id2|block_id1|block_id0|rotation1|rotation0|vertical1|vertical0| 
	 reg [6:0] horizontal_rot_data [127:0];											//|block_id2|block_id1|block_id0|rotation1|rotation0|vertical1|vertical0|
																									//Vonal, kocka, egyik L, másik L, cikcakk1,cikcakk2,'háromszög' a sorrend a fileban.  	 
	 reg canmove_rot; 								initial canmove_rot = 1;
	 reg [2:0] color; 								initial color = 1;				//Forgatáshoz szükséges, milyen elemet hívjon a tömbbõl
	 //****************************************Tud e forogni
	 
	 // ********************************************Sortörlés
	 reg [2:0] rowcombo; 				initial rowcombo = 0;
	 reg fullrow; 							initial fullrow = 0;
	 reg [4:0] firstrow; 				initial firstrow = 0;
	 reg [4:0] currentrow; 				initial currentrow = 0;
	 wire [5:0] hor_wire_clear_wr;
	 wire [6:0] ver_wire_clear_wr;
	 wire [5:0] hor_wire_clear_rd;
	 wire [6:0] ver_wire_clear_rd;
	 reg foundrow;							initial foundrow = 0;
	 // ********************************************Sortörlés
	 
	 //******************************Forgatás fájlok betöltése
	 initial begin
    $readmemb("vertical.bin",  vertical_rot_data) ;
    $readmemb("horizontal.bin",  horizontal_rot_data) ;
    end
	 //******************************Forgatás fájlok betöltése
	 
	 //*******************Mozog ha tud
	 parameter moves_start = 10000;
	 parameter moves_end = 13000;
	 //*******************Mozog ha tud

	 //********Címzés, és cntr-ek, valamint alap helyzet és forma
	 wire [5:0] hor_wire;
	 wire [6:0] ver_wire;
	 reg [14:0] move_cntr;		initial move_cntr = 0;
	 reg [14:0] cycle_cntr;		initial cycle_cntr = 0;
	 reg [6:0] gravity;			initial gravity = 0; //ALWAYS MOVE DOWN WHEN == 1
	 reg [6:0] gravity_speed;	initial gravity_speed = 21;
	 reg [20:0] vsync_cntr;	 	initial vsync_cntr = 0;
	 reg [5:0] pos_x; 			initial pos_x = 5;
	 reg [4:0] pos_y; 			initial pos_y = 1;
	 reg [5:0] vertical [3:0];
	 reg [6:0] horizontal [3:0];
	 reg [5:0] next_vertical [3:0];
	 reg [6:0] next_horizontal [3:0];
	 //********Címzés, és cntr-ek, valamint alap helyzet és forma
	 
	 //***Alap forma beállítása
	 initial begin 
	 vertical[0] = 0;
	 vertical[1] = 0;
	 vertical[2] = 1;
	 vertical[3]  = 1;
	 horizontal[0] = 0;
	 horizontal[1] = 1;
	 horizontal[2] = 0;
	 horizontal[3]  = 1;
	 
	 next_vertical[0] = 0;
	 next_vertical[1] = 0;
	 next_vertical[2] = 1;
	 next_vertical[3]  = 1;
	 next_horizontal[0] = 0;
	 next_horizontal[1] = 1;
	 next_horizontal[2] = 0;
	 next_horizontal[3]  = 1;
	 
	 nextcolor <= 1;
	 end
	 //***Alap forma beállítása
	 
	 //****Választás a blokkokból, delay (gombokhoz)
	 parameter number_of_blocks = 7;
	 reg en_posedge;
	 reg [2:0] random;					initial random = 1;
	 reg [5:0] input_delay;
	 reg [5:0] input_delay_max; 		initial input_delay_max = 10;
	 
	 //***************************** GAME ÁLLAPOTGÉP
	 reg [5:0] ver_clr; 	initial ver_clr = 0;
	 reg [6:0] hor_clr;	initial hor_clr = 0;
	 reg [6:0] gamestate; initial gamestate = 1;
	 reg [5:0] clear_cntr; initial clear_cntr = 0;
	 reg game_over; initial game_over = 0;
	 reg keyboard_new; initial keyboard_new = 0;
		always @ ( posedge clk )
		begin
		if (pos_y == 0 &&  gravity == 1 && move_cntr == 1 && !canmove_down) 
			game_over <= 1;
		if ( ps2_en == 1 && ps2 == 8'h50 )
			pause_keyboard <= 1;
		if ( ps2_en == 1 && ps2 == 8'h4E )
			keyboard_new <= 1;
		if ( en_posedge == 0 && en == 1 );
			begin
			case (gamestate)
				1:// GAME PLAYING
					begin
						if ( pause_keyboard == 1)
						begin
							gamestate <= 2;
							pause_keyboard <= 0;
						end
						if ( game_over == 1)
						begin
							gamestate <= 3;
							game_over <= 0;
						end
					end
				2://PAUSE
					begin
						if ( pause_keyboard == 1)
						begin
							gamestate <= 1;
							pause_keyboard <= 0;
						end
					end
				3://GAME_OVER 
				begin
					game_over <= 0;
					if (keyboard_new)
					begin
						clear_cntr <= 400;
						gamestate <= 4;
						keyboard_new <= 0;
					end
				end
				4://NEW_GAME
				begin
				clear_cntr <= clear_cntr -1;
				if(!clear_cntr)
					gamestate<= 1;
				end
			endcase
	 		end
		end
	 
	 //***************************** END OF GAME ÁLLAPOTGÉP
	 //****Választás a blokkokból, delay (gombokhoz)
	 wire [3:0] ONESwire, TENSwire;
    wire [1:0] HUNDREDSwire;
	 binary_to_BCD BCD_CONV(.A(score),.ONES(ONESwire),.TENS(TENSwire),.HUNDREDS(HUNDREDSwire));
	 always@ ( posedge clk)
	 begin
	 level <= levelscore[14:3] + 1;
	 end
	 //****Késleltetés (gombokhoz)
	 always @ (posedge clk)
	 begin
	 if( en_posedge == 0 && en == 1 ) 
		input_delay <= input_delay + 1;
	 if ( input_delay == input_delay_max )
		input_delay <=0;
	 end
	 //****Késleltetés (gombokhoz)
	 
	 //****Random blokk dobása !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Nem jó 
	 always @ ( posedge clk)
	 begin
	 if ( random == number_of_blocks  || ps2_en) 
	 random <= 1;
	 else random <= random + 1;
	 end
	 //****Random blokk dobása
	 
	//***********************Leesés 
	always @ (posedge clk)
	if ( gamestate == 1)
	begin
		begin
		if( en_posedge == 0 && en == 1 ) 
			gravity <= gravity + 1;
		if ( gravity == gravity_speed - level )
			gravity <=0;
		end
	end
	//***********************Leesés 
	
	/*//*********************Képernyõ vége
	always @ (posedge clk)
	if( en_posedge == 0 && en == 1 ) 
		vsync_cntr <= vsync_cntr + 1;
	//*********************Képernyõ vége*/
	
	//****Ütemezõ cntr növelése, képernyõn kívül
	always @ ( posedge clk)
	begin
		if( en_posedge == 0 && en == 1 ) 
			cycle_cntr <= 0;
		else 
			if (en) 
				cycle_cntr <= cycle_cntr + 1;
	end
	//****Ütemezõ cntr növelése, képernyõn kívül
	
	//********************FF
	always @ ( posedge clk ) 
		en_posedge <= en;
	//********************FF

	//********************************************************************CNTR INIT************************************************************************
	
	//********Left cntr kezelése
	always@(posedge clk)
	begin
		if( cycle_cntr == check_left_start )
			left_cntr <= 0 ;
		if ( cycle_cntr > check_left_start && cycle_cntr < check_left_end )
			left_cntr <= left_cntr + 1 ;
	end
	//********Left cntr kezelése
	
	//********Right cntr kezelése
	always@(posedge clk)
	begin
		if( cycle_cntr == check_right_start )
			right_cntr <= 0 ;
		if ( cycle_cntr > check_right_start && cycle_cntr < check_right_end )
			right_cntr <= right_cntr + 1;
	end
	//********Right cntr kezelése
	
	//********Down cntr kezelése
	always@(posedge clk)
	begin
		if( cycle_cntr == check_down_start )
			down_cntr <= 0 ;
		if ( cycle_cntr > check_down_start && cycle_cntr < check_down_end )
			down_cntr <= down_cntr + 1;
	end
	//********Down cntr kezelése
	
	//********rot cntr kezelése!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!DELETE
	always@(posedge clk)//ROTATION
	begin
		if(cycle_cntr == check_rot_start )
		rot_cntr <= 0 ;
		if (cycle_cntr > check_rot_start && cycle_cntr < check_rot_end)
		rot_cntr <= rot_cntr + 1;
	end
	//*********************************************************************eddig
	
	//********Rot cntr kezelése
	always@(posedge clk)
	begin
		if( cycle_cntr == check_rot_start )
			rot_cntr <= 0 ;
		if ( cycle_cntr > check_rot_start && cycle_cntr < check_rot_end )
			rot_cntr <= rot_cntr + 1;
	end	
	//********Rot cntr kezelése
	
	//********Move cntr kezelése
	always @ ( posedge clk )
	begin
		if( cycle_cntr == moves_start )
			move_cntr <= 0 ;
		if ( cycle_cntr > moves_start && cycle_cntr < moves_end )
			move_cntr <= move_cntr + 1;
	end
	//********Move cntr kezelése

	//*********************************************************************END OF INIT COUNTERS*************************************************************************************


	//*************************************************************************Check blokk******************************************************************************************
	
	always@(posedge clk)
	if ( gamestate == 1)
	begin
		//*******************************CHECKDOWN BEGIN
		if ( down_cntr == 0 && ( cycle_cntr > check_down_start && cycle_cntr < check_down_end ) ) 
			canmove_down <= 1;
		if( down_cntr >= 0 && down_cntr <= 3 && ( cycle_cntr > check_down_start && cycle_cntr < check_down_end ) )	
			BIG_RD_ADDR <= {ver_wire_down[4:0] + 1,hor_wire_down[5:0]};
		if( down_cntr >= 2 && down_cntr <= 5 && ( cycle_cntr > check_down_start && cycle_cntr < check_down_end ) )//Current block is move_cntr -1;
		begin
			if((BIG_RD_DATA && 
			!(//nem saját
			(vertical[down_cntr -2] + 1 == vertical[down_cntr -1] && horizontal[down_cntr -2] == horizontal[down_cntr -1]) ||
			(vertical[down_cntr -2] + 1 == vertical[down_cntr ] && horizontal[down_cntr -2] == horizontal[down_cntr ])||
			(vertical[down_cntr -2] + 1 == vertical[down_cntr +1] && horizontal[down_cntr -2] == horizontal[down_cntr +1])
			))
			|| tetris_y_begin +pos_y + vertical[down_cntr -2] >= teris_y_end) // Position
					canmove_down <= 0; 
		end
		//*******************************CHECKDOWN END
		
		//*******************************CHECKLEFT BEGIN
		if ( left_cntr == 0 &&  ( cycle_cntr > check_left_start && cycle_cntr < check_left_end ) ) 
			canmove_left <= 1;
		if ( left_cntr >= 0 && left_cntr <= 3 &&  ( cycle_cntr > check_left_start && cycle_cntr < check_left_end ) )	
			BIG_RD_ADDR <= {ver_wire_left[4:0],hor_wire_left[5:0]};
		if ( left_cntr >= 2 && left_cntr <= 5 &&  ( cycle_cntr > check_left_start && cycle_cntr < check_left_end ) )//Current block is move_cntr -2;
			if((BIG_RD_DATA && 
		!(//nem saját
		(horizontal[left_cntr +2]  == horizontal[left_cntr +3] +1 && vertical[left_cntr +2] == vertical[left_cntr +3]) ||
		(horizontal[left_cntr +2]  == horizontal[left_cntr   ] +1 && vertical[left_cntr +2] == vertical[left_cntr   ]) ||
		(horizontal[left_cntr +2]  == horizontal[left_cntr +1] +1 && vertical[left_cntr +2] == vertical[left_cntr +1])	)))//******balra túl csordul -> blokkon nem megy át
					canmove_left <= 0; 
		//*******************************CHECKLEFT END
	
		//*******************************CHECKRIGHT BEGIN
		if ( right_cntr == 0 &&  ( cycle_cntr > check_right_start && cycle_cntr < check_right_end ) ) 
			canmove_right <= 1;
		if ( right_cntr >= 0 && right_cntr <= 3 &&  ( cycle_cntr > check_right_start && cycle_cntr < check_right_end ) )	
			BIG_RD_ADDR <= {ver_wire_right[4:0],hor_wire_right[5:0]};
		if ( right_cntr >= 2 && right_cntr <= 5 &&  ( cycle_cntr > check_right_start && cycle_cntr < check_right_end ) )//Current block is move_cntr -2;
			if((BIG_RD_DATA && 
			!(//nem saját
			(horizontal[right_cntr -2]+1  == horizontal[right_cntr -1]  && vertical[right_cntr -2] == vertical[right_cntr -1]) ||
			(horizontal[right_cntr -2]+1  == horizontal[right_cntr   ]  && vertical[right_cntr -2] == vertical[right_cntr   ]) ||
			(horizontal[right_cntr -2]+1  == horizontal[right_cntr +1]  && vertical[right_cntr -2] == vertical[right_cntr +1])
			)) || tetris_x_begin +pos_x + horizontal[right_cntr -2] >= tetris_x_end) // Position
					canmove_right <= 0; 
		//*******************************CHECKRIGHT END
	
		//*******************************CHECKROT BEGIN *****************************************************************************!!!!!!!!!!!!!!!!!!DELETE???????
		if (rot_cntr == 0 &&  (cycle_cntr > check_rot_start && cycle_cntr < check_rot_end)) 
			canmove_rot <=1;
		if(rot_cntr >= 0 && rot_cntr <= 3 &&  (cycle_cntr > check_rot_start && cycle_cntr < check_rot_end))	
			BIG_RD_ADDR <= {ver_wire_rot[4:0],hor_wire_rot[5:0]};
		if(rot_cntr >= 2 && rot_cntr <= 5 &&  (cycle_cntr > check_rot_start && cycle_cntr < check_rot_end))
			begin
				/*debugreg[rot_cntr] <= BIG_RD_DATA;
				debugreg[rot_cntr + 4]<= horizontal_rot_data[{color,nextrot,rot_cntr_2}];
				debugreg[rot_cntr + 8] <= horizontal[rot_cntr ];
				debugreg[rot_cntr + 12]<= vertical_rot_data[{color,nextrot,rot_cntr_2}];
				debugreg[rot_cntr + 16] <= vertical[rot_cntr ];*/
			if(BIG_RD_DATA&& 
				!(//nem saját
				(horizontal[rot_cntr + 0]  == horizontal_rot_data[{color[2:0],nextrot[1:0],rot_cntr_2[1:0]}]  && vertical[rot_cntr ] == vertical_rot_data[{color[2:0],nextrot[1:0],rot_cntr_2[1:0]}] ) ||
				(horizontal[rot_cntr + 1]  == horizontal_rot_data[{color[2:0],nextrot[1:0],rot_cntr_2[1:0]}]   && vertical[rot_cntr +1] == vertical_rot_data[{color[2:0],nextrot[1:0],rot_cntr_2[1:0]}]) ||
				(horizontal[rot_cntr + 2]  == horizontal_rot_data[{color[2:0],nextrot[1:0],rot_cntr_2[1:0]}]   && vertical[rot_cntr +2] == vertical_rot_data[{color[2:0],nextrot[1:0],rot_cntr_2[1:0]}]) ||
				(horizontal[rot_cntr + 3]  == horizontal_rot_data[{color[2:0],nextrot[1:0],rot_cntr_2[1:0]}]   && vertical[rot_cntr +3] == vertical_rot_data[{color[2:0],nextrot[1:0],rot_cntr_2[1:0]}])))
					canmove_rot <= 0;
			end
		//*******************************CHECKROT END*/*****************************************************************

		//*******************************CHECKROW BEGIN
		if( (!move_cntr[14:11]) &&  gravity == 1 && !canmove_down && move_cntr[9:0] >= 128 && move_cntr[9:0] <= 128+16*20 )
			BIG_RD_ADDR <= {ver_wire_clear_rd[4:0],hor_wire_clear_rd[5:0]};
		if ( (!move_cntr[14:11]) &&  gravity == 1 && !canmove_down && move_cntr[9:0] >= 512 && move_cntr[9:0] <= 512+16*20 )
			BIG_RD_ADDR <= {ver_wire_clear_rd[4:0],hor_wire_clear_rd[5:0]};
		//*******************************CHECKROW END*/

	end
	//********************************************************************************END OF CHECKS**************************************************************************************
	
	//*********************************************************************************MOVE BLOCK****************************************************************************************
	
	always @ ( posedge clk )
	begin
		//****************PS2 kezelése
		if ( ps2_en == 1 && ps2 == 8'h41 )
			left_keyboard <= 1;
		if ( ps2_en == 1 && ps2 == 8'h44 )
			right_keyboard <= 1;
		if ( ps2_en == 1 && ps2 == 8'h53 )
			down_keyboard <= 1;
		if ( ps2_en == 1 && (ps2 ==  8'h20 || ps2 == 8'h57) )
			rot_keyboard <= 1;
		if( cycle_cntr == 1)
		begin
				BIG_WR_ADDR <= {5'd2,6'd2 };
				BIG_WR_DATA <= 28+gamestate;//G
				BIG_WR_EN <= 1;
			end
		if(cycle_cntr == 2)
		BIG_WR_EN <= 0;
		//****************PS2 kezelése
	if ( gamestate == 3)
	begin
			if ( move_cntr ==3 )
			begin
				BIG_WR_ADDR <= {5'd5,6'd14 };
				BIG_WR_DATA <= 44;//G
				BIG_WR_EN <= 1;
			end
			if ( move_cntr ==4 )
			begin
				BIG_WR_ADDR <= {5'd5,6'd15 };
				BIG_WR_DATA <= 38;//A
				BIG_WR_EN <= 1;
			end
			if ( move_cntr ==5 )
			begin
				BIG_WR_ADDR <= {5'd5,6'd16 };
				BIG_WR_DATA <= 50;//M
				BIG_WR_EN <= 1;
			end
			if ( move_cntr ==6 )
			begin
				BIG_WR_ADDR <= {5'd5,6'd17 };
				BIG_WR_DATA <= 42;//E
				BIG_WR_EN <= 1;
			end
			if ( move_cntr ==7 )
			begin
				BIG_WR_ADDR <= {5'd6,6'd14 };
				BIG_WR_DATA <= 52;//O
				BIG_WR_EN <= 1;
			end
			if ( move_cntr ==8 )
			begin
				BIG_WR_ADDR <= {5'd6,6'd15 };
				BIG_WR_DATA <= 59;//V
				BIG_WR_EN <= 1;
			end
			if ( move_cntr ==9 )
			begin
				BIG_WR_ADDR <= {5'd6,6'd16 };
				BIG_WR_DATA <= 42;//E
				BIG_WR_EN <= 1;
			end	
			if ( move_cntr ==10 )
			begin
				BIG_WR_ADDR <= {5'd6,6'd17 };
				BIG_WR_DATA <= 55;//R
				BIG_WR_EN <= 1;
			end				
		if ( move_cntr == 11) 
			BIG_WR_EN <= 0;
	end
	if ( gamestate == 4 )
	begin
				if ( move_cntr == 1 ) 
					currentrow <= 0;
				if ( move_cntr[3:0] >= 1 && move_cntr[3:0] <= 11 && move_cntr >= 1 && move_cntr <= 1000)
					begin
						BIG_WR_ADDR <= {ver_clr,hor_clr};
						BIG_WR_DATA <= 63;
						BIG_WR_EN <= 1;
					end
				if ( move_cntr[3:0] == 12) 
				begin
					BIG_WR_EN <= 0;
					currentrow <= currentrow + 1;
				end
				ver_clr <= tetris_x_begin + move_cntr[3:0];
				hor_clr <= tetris_y_begin + currentrow;
	end
	if ( gamestate == 1)
	begin
		//*************Elõzõ pozíció törlése
		if ( move_cntr >1 && move_cntr <= 6 )
			begin
				BIG_WR_ADDR <= {ver_wire[4:0],hor_wire[5:0]};
				BIG_WR_DATA <= 0;
				BIG_WR_EN <= 1;
			end
		if ( move_cntr == 7)
			BIG_WR_EN <= 0;
		//*************Elõzõ pozíció törlése
		
		//*************************************************Ha tud és meg van nyomva a megfelelõ gomb akkor mozog/fordul
		if ( move_cntr == 10 && (gravity == 1 || down_keyboard || (btn[3] && ! input_delay)) && canmove_down ) 
		begin
			pos_y <= pos_y + 1;
			down_keyboard<=0;
		end
		if ( move_cntr == 11 && canmove_right && (right_keyboard  || (btn[1] && ! input_delay))&& !( gravity == 1 && !canmove_down) ) //SORRENDET ÁT KELL GONDOLNI, LEHET HOGY NEM TUD LEFELE MENNI, LERAKJA, DE MÉG ELMEGY EGYET BALRA JOBBRA.
		begin
			pos_x <= pos_x + 1;
			right_keyboard<=0;
		end	
		if ( move_cntr == 12 && canmove_left &&( left_keyboard || (btn[2] && ! input_delay)) && !( gravity == 1 && !canmove_down ) && ! input_delay )
		begin
			pos_x <= pos_x - 1;
			left_keyboard <= 0;//****************PS2 höz kell
		end
		if (  move_cntr == 13 && canmove_rot && (rot_keyboard || (btn[0] && ! input_delay))&& !( gravity == 1 && !canmove_down )  && ! input_delay ) 
		begin
			rotation <= rotation + 1;
			rot_keyboard<=0;
		end
		if ( move_cntr == 14 && !( gravity == 1 && !canmove_down ) && ! input_delay ) 
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
		//*************************************************Ha tud és meg van nyomva a megfelelõ gomb akkor mozog/fordul
			
		//*************Új pozíció kiírása
		if ( move_cntr >= 17 && move_cntr <= 20 )
			begin
				BIG_WR_ADDR <= {ver_wire[4:0],hor_wire[5:0] };
				BIG_WR_DATA <= color;
				BIG_WR_EN <= 1;
			end
		if ( move_cntr == 21) 
			BIG_WR_EN <= 0;
		//*************Új pozíció kiírása	
		
		//*******************************************************CLEARING UP FULL ROWS**************************************************
		if ( gravity == 1 && !canmove_down )									// Csak ha leraktunk egyet.
		begin
				if ( (!move_cntr[14:11]) && move_cntr[9:0] >= 127 && move_cntr[9:0] <= 500 )
				begin
					if ( move_cntr[9:0] == 127 )
					begin
						rowcombo <=0; 													// Hány jó sort találtunk ( max 3 ugye (ami 4 :))
						fullrow <=1; 													// Teli van-e az adott sor
						firstrow <=0;													// az elso megtalált sorunk
						currentrow <= 0;	
						foundrow <= 0;
						// Jelenlegi vizsgált sorunk
					end
					if ( move_cntr[9:0] >= 128 && move_cntr[9:0] <= 128+16*20 )		// Végigmegyünk az összes soron, elvileg 448-ig megyünk
					begin
						if ( move_cntr[3:0] >= 2 && move_cntr[3:0] <= 12 )	// Ekkora már bejött az adat
						begin
							if ( !BIG_RD_DATA ) 
								fullrow<= 0;											// HA NEM TELJES A SOR AKKOR NULLÁZUNK ||||BAJ VAN!! MÁSIK BLOKK TUDJA CSAK OLVASNI B+...
						end
						if ( move_cntr[3:0] == 13 && ! rowcombo )				// Ha megtaláltuk az elso teli sort
						begin
								if ( fullrow )
								begin
									rowcombo <= 1; 									// növeljük a megszámolt teli sorok számát
									firstrow <= currentrow; 						// Lementjük a sor helyét
								end
						end
						if  (move_cntr[3:0] == 13 && rowcombo )				//Ha már találtunk jó sort
						begin
							if ( fullrow && !foundrow && rowcombo < 4)
							begin
								rowcombo <= rowcombo +1;							// Csak növeljük a  megtalált sorok számát
							end
						end
						if ( move_cntr[3:0] == 13 && !fullrow && rowcombo )
						begin
							foundrow <= 1;
						end
						if ( move_cntr[3:0] == 15 )
						begin
								currentrow <= currentrow +1;
								fullrow <= 1;											// Új lehetoség egy teli  sorra
								leds <= rowcombo;
						end
					end
				end
				if ( (!move_cntr[14:11]) &&  move_cntr[9:0] == 511 )
				begin
					currentrow<=0; 
				   levelscore <= levelscore +rowcombo;
					if(rowcombo == 4)
					score <=score + 8;
					else 
					score <= score + rowcombo;
				end
				if ( (!move_cntr[14:11]) &&  move_cntr[9:0] >= 511 && move_cntr[9:0] <= 900 )
				begin
					if ( move_cntr[9:0] == 511 )
					begin
						currentrow <= firstrow-1;
						BIG_WR_EN <= 0;
					end
					if ( move_cntr[9:0] >= 512 && move_cntr[9:0] <= 512+16*20 )
					begin
						if ( move_cntr[3:0] >= 2 && move_cntr[3:0] <= 12 )
							begin
								BIG_WR_ADDR <= {ver_wire_clear_wr[4:0],hor_wire_clear_wr[5:0]};
								BIG_WR_DATA <= BIG_RD_DATA;
								BIG_WR_EN <= 1;
							end
						if( move_cntr[3:0] == 13)
						begin
						BIG_WR_EN <=0;
						if(currentrow)
							currentrow <= currentrow -1;
						end
					end
				end
		end
	//***********************************************END OF CLEARING UP FULL ROWS*************************************
	if ( gravity == 1 && move_cntr == 2498 && !canmove_down )//Ha leérne akkor a rotációt nullába állítom
	begin
			rotation <= 0;
			color <= nextcolor;
			nextcolor <= random;
			 pos_x<= 5;
			 pos_y<= 0;
	end
		if ( gravity == 1 && move_cntr == 2499 && !canmove_down )//Ha leérne akkor a rotációt nullába állítom
		begin 

			vertical[0] <= next_vertical[0];
			 vertical[1] <= next_vertical[1];
			 vertical[2] <= next_vertical[2];
			 vertical[3] <= next_vertical[3];
			 horizontal[0] <= next_horizontal[0];
			 horizontal[1] <= next_horizontal[1];
			 horizontal[2] <= next_horizontal[2];
			 horizontal[3] <= next_horizontal[3];

		end
		if ( gravity == 1 && move_cntr == 2500 && !canmove_down ) 		//EZT A FELTÉTELT MÉG A LEFT RIGHTBA BE KELL ÍRNI.
		begin

			 next_vertical[0] <= vertical_rot_data[{nextcolor,rotation,2'b00}];
			 next_vertical[1] <= vertical_rot_data[{nextcolor,rotation,2'b01}];
			 next_vertical[2] <= vertical_rot_data[{nextcolor,rotation,2'b10}];
			 next_vertical[3] <= vertical_rot_data[{nextcolor,rotation,2'b11}];
			 next_horizontal[0] <= horizontal_rot_data[{nextcolor,rotation,2'b00}];
			 next_horizontal[1] <= horizontal_rot_data[{nextcolor,rotation,2'b01}];
			 next_horizontal[2] <= horizontal_rot_data[{nextcolor,rotation,2'b10}];
			 next_horizontal[3] <= horizontal_rot_data[{nextcolor,rotation,2'b11}];

		end
		/*
			parameter number_start = 28;
	parameter score_x_pos = 30;
	parameter score_y_pos = 3;
	parameter nextblock_x_pos = 30;
	parameter nextblock_y_pos = 5;
	parameter level_x_pos = 30;
	parameter level_y_pos = 10;
		*/
		if ( move_cntr == 2600 )
		begin
			leds <= rowcombo;
		end
		if ( move_cntr == 2601 )
			begin
				BIG_WR_ADDR <= {score_y_pos[4:0],6'd327};
				if(HUNDREDSwire)
				BIG_WR_DATA <= HUNDREDSwire+number_start;
				else
				BIG_WR_DATA <= 0;
				BIG_WR_EN <= 1;
			end
		if ( move_cntr == 2602 )
			begin
				BIG_WR_ADDR <= {score_y_pos[4:0],6'd28};
				if(HUNDREDSwire || TENSwire)
				BIG_WR_DATA <= TENSwire+number_start;
				else
				BIG_WR_DATA <= 0;
				BIG_WR_EN <= 1;
			end
		if ( move_cntr == 2603 && (HUNDREDSwire || TENSwire || ONESwire) )
			begin
				BIG_WR_ADDR <= {score_y_pos[4:0],6'd29};
				BIG_WR_DATA <= ONESwire+number_start;
				BIG_WR_EN <= 1;
			end
		if ( move_cntr == 2604 && (HUNDREDSwire || TENSwire || ONESwire))
			begin
				BIG_WR_ADDR <= {score_y_pos[4:0],6'd30};
				BIG_WR_DATA <= number_start;
				BIG_WR_EN <= 1;
			end
		if ( move_cntr == 2605 )
			begin
				BIG_WR_ADDR <= {score_y_pos[4:0],6'd31};
				BIG_WR_DATA <= number_start;
				BIG_WR_EN <= 1;
			end
			/*
				parameter level_x_pos = 30;
	parameter level_y_pos = 1;
			*/
			if ( move_cntr == 2606 )
			begin
				BIG_WR_ADDR <= {level_y_pos[4:0],level_x_pos[5:0]};//{level_x_pos[4:0],level_y_pos[5:0]};
				BIG_WR_DATA <= number_start + level;
				BIG_WR_EN <= 1;
			end
		if ( move_cntr == 2607)
			BIG_WR_EN <= 0;
		if ( move_cntr >= 2610 && move_cntr <= 2625 )
			begin
				BIG_WR_ADDR <= {clear_next_ver,clear_next_hor};
				BIG_WR_DATA <= 0;
				BIG_WR_EN <= 1;
			end
		if ( move_cntr >= 2626 && move_cntr >= 2629 )
			begin
				BIG_WR_ADDR <= {write_next_ver,write_next_hor};
				BIG_WR_DATA <= nextcolor;
				BIG_WR_EN <= 1;
			end
		if ( move_cntr == 2629)
			BIG_WR_EN <= 0;
	end
	end

	assign clear_next_ver = nextblock_y_pos[4:0] + move_cntr[3:2];
	assign clear_next_hor = nextblock_x_pos[5:0] + move_cntr[1:0];
	assign write_next_ver = nextblock_y_pos[4:0] + next_vertical[move_cntr[1:0]];
	assign write_next_hor = nextblock_x_pos[5:0] + next_horizontal[move_cntr[1:0]];	
	//********************************************************************************END OF MOVES*****************************************************************************************
	
	//*****************Az alap, le, balra, jobbra és rotálva lévõ elemk kiolvasásához szükséges
	assign ver_wire = tetris_y_begin + pos_y + vertical[move_cntr];
	assign hor_wire = tetris_x_begin + pos_x + horizontal[move_cntr];
	assign ver_wire_down = tetris_y_begin + pos_y + vertical[down_cntr];
	assign hor_wire_down = tetris_x_begin + pos_x + horizontal[down_cntr];
	assign ver_wire_left = tetris_y_begin + pos_y + vertical[left_cntr];
	assign hor_wire_left = (tetris_x_begin + pos_x + horizontal[left_cntr])-1; 												// Lehet gond, érdemes lehet 6 bitre csinálni a kivonásnál
	assign ver_wire_right = tetris_y_begin + pos_y + vertical[right_cntr];
	assign hor_wire_right = tetris_x_begin + pos_x + horizontal[right_cntr]+5'b1; 											// Lehet gond, érdemes lehet 6 bitre csinálni a kivonásnál
	assign ver_wire_rot = tetris_y_begin + pos_y + vertical_rot_data[{color[2:0],nextrot[1:0],rot_cntr[1:0]}];
	assign hor_wire_rot = tetris_x_begin + pos_x + horizontal_rot_data[{color[2:0],nextrot[1:0],rot_cntr[1:0]}]; 	// Lehet gond, érdemes lehet 6 bitre csinálni a kivonásnál
	//*****************Az alap, le, balra, jobbra és rotálva lévõ elemk kiolvasásához szükséges
	
	//*****************Sortörléshez szükséges ki- és beolvasási kábelek
	assign hor_wire_clear_rd =tetris_x_begin + 1 + move_cntr[3:0];
	assign ver_wire_clear_rd =tetris_y_begin + currentrow;
	assign hor_wire_clear_wr =tetris_x_begin + 1 + move_cntr[3:0]-2;
	assign ver_wire_clear_wr =tetris_y_begin + currentrow+rowcombo;// This the difference between
	//*****************Sortörléshez szükséges ki- és beolvasási kábelek
	
	//DEBUG
	//assign ver_wire_rot = tetris_y_begin + pos_y + vertical_rot_data[{color[2:0],nextrot[1:0],rot_cntr[1:0]}];
	//assign hor_wire_rot = tetris_x_begin + pos_x + horizontal_rot_data[{color[2:0],nextrot[1:0],rot_cntr[1:0]}]; // Lehet gond, érdemes lehet 6 bitre csinálni a kivonásnál
	//assign nextrottest = rotation + 1;
	//END OF DEBUG
	
	assign rot_cntr_0 = rot_cntr[1:0] + 3;
	assign rot_cntr_1 = rot_cntr[1:0] + 1;
	assign rot_cntr_2 = rot_cntr[1:0] + 2;
	
	assign nextrot = rotation + 1;
endmodule