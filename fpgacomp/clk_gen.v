`timescale 1ns / 1ps

module clk_gen(
   input  xclk,
   output clk
);

wire xclk_bufg;
wire clk0_dcm, clkfx_dcm;
wire clk0_bufg, clkfx_bufg;

IBUFG BUFG_xclk (
   .O(xclk_bufg),
   .I(xclk)
);

DCM_SP #(
   .CLKDV_DIVIDE(2.0), // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                       //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
   .CLKFX_DIVIDE(16),   // Can be any integer from 1 to 32
   .CLKFX_MULTIPLY(25), // Can be any integer from 2 to 32
   .CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
   .CLKIN_PERIOD(62.5),  // Specify period of input clock
   .CLKOUT_PHASE_SHIFT("NONE"), // Specify phase shift of NONE, FIXED or VARIABLE
   .CLK_FEEDBACK("1X"),  // Specify clock feedback of NONE, 1X or 2X
   .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                         //   an integer from 0 to 15
   .DLL_FREQUENCY_MODE("LOW"),  // HIGH or LOW frequency mode for DLL
   .DUTY_CYCLE_CORRECTION("TRUE"), // Duty cycle correction, TRUE or FALSE
   .PHASE_SHIFT(0),     // Amount of fixed phase shift from -255 to 255
   .STARTUP_WAIT("FALSE")   // Delay configuration DONE until DCM LOCK, TRUE/FALSE
) DCM_SP_inst (
   .CLK0(clk0_dcm),     // 0 degree DCM CLK output
   .CLK180(), // 180 degree DCM CLK output
   .CLK270(), // 270 degree DCM CLK output
   .CLK2X(),   // 2X DCM CLK output
   .CLK2X180(), // 2X, 180 degree DCM CLK out
   .CLK90(),   // 90 degree DCM CLK output
   .CLKDV(),   // Divided DCM CLK out (CLKDV_DIVIDE)
   .CLKFX(clkfx_dcm),   // DCM CLK synthesis out (M/D)
   .CLKFX180(), // 180 degree CLK synthesis out
   .LOCKED(), // DCM LOCK status output
   .PSDONE(), // Dynamic phase adjust done output
   .STATUS(), // 8-bit DCM status bits output
   .CLKFB(clk0_bufg),   // DCM clock feedback
   .CLKIN(xclk_bufg),   // Clock input (from IBUFG, BUFG or DCM)
   .PSCLK(1'b0),   // Dynamic phase adjust clock input
   .PSEN(1'b0),     // Dynamic phase adjust enable input
   .PSINCDEC(1'b0), // Dynamic phase adjust increment/decrement
   .RST(1'b0)        // DCM asynchronous reset input
);

BUFG BUFG_clk0 (
   .O(clk0_bufg),
   .I(clk0_dcm)
);
BUFG BUFG_clkfx (
   .O(clkfx_bufg),
   .I(clkfx_dcm)
);

assign clk = clkfx_bufg;
//assign clk = xclk;
endmodule
