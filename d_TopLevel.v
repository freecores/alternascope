//==================================================================
// File:    d_TopLevel.v
// Version: 0.01
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Copyright Stephen Pickett
//   April 28, 2005
//------------------------------------------------------------------
// Revisions:
// Ver 0.01     Apr 28, 2005    Initial Release
//
//==================================================================

module TopLevel(
    CLK_50MHZ_IN, MASTER_RST,
    H_SYNC, V_SYNC, VGA_OUTPUT,
    PS2C, PS2D,
//    TIME_BASE,
    ADC_DATA, ADC_CLK,
    VGA_RAM_ADDR, VGA_RAM_DATA,
    VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS,
    
    SEG_OUT, SEG_SEL, leds, SHOW_LEVELS_BUTTON
    );

//==================================================================//
// DEFINITIONS                                                      //
//==================================================================//

//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//

//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input CLK_50MHZ_IN, MASTER_RST;
output H_SYNC, V_SYNC;
output[2:0] VGA_OUTPUT;
//input[5:0] TIME_BASE;
inout PS2C, PS2D;
input[7:0] ADC_DATA;
output ADC_CLK;
output[17:0] VGA_RAM_ADDR;
inout[15:0] VGA_RAM_DATA;
output VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;

output[7:0] leds;
output[6:0] SEG_OUT;
output[3:0] SEG_SEL;
input SHOW_LEVELS_BUTTON;
wire SHOW_LEVELS_BUTTON;


//----------------------//
// WIRES / NODES        //
//----------------------//
wire      CLK_50MHZ_IN, MASTER_RST;
wire      H_SYNC, V_SYNC;
wire[2:0] VGA_OUTPUT;
wire[5:0] TIME_BASE;
wire      PS2C, PS2D;
wire[7:0] ADC_DATA;
wire      ADC_CLK;
wire[17:0] VGA_RAM_ADDR;
wire[15:0] VGA_RAM_DATA;
wire       VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;


//----------------------//
// VARIABLES            //
//----------------------//
assign TIME_BASE = 6'b0;


//==================================================================//
// TEMP                                                             //
//==================================================================//
wire[17:0] VGA_RAM_ADDRESS_w;
wire[15:0] VGA_RAM_DATA_w;

wire VGA_RAM_ACCESS_OK;
wire CLK_50MHZ, CLK_64MHZ, CLK180_64MHZ;
wire[6:0] SEG_OUT;
wire[3:0] SEG_SEL;

wire TEST_in_range_Trig;

sub_SegDriver segs(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .DATA_IN(),
    .SEG_OUT(SEG_OUT), .SEG_SEL(SEG_SEL)
    );

wire[7:0] leds;
assign leds[0] = L_BUTTON;
assign leds[1] = M_BUTTON;
assign leds[2] = R_BUTTON;
assign leds[3] = TEST_in_range_Trig;
assign leds[7:4] = 4'b0;
//==================================================================//
// SUBROUTINES                                                      //
//==================================================================//
//wire CLK_50MHZ, CLK_64MHZ, CLK180_64MHZ;
wire CLK_64MHZ_LOCKED;
d_DCM clock_generator(
    .CLKIN_IN(CLK_50MHZ_IN),
    .RST_IN(MASTER_RST),
    .CLKIN_IBUFG_OUT(CLK_50MHZ),
    .CLK_64MHZ(CLK_64MHZ),
    .CLK180_64MHZ(CLK180_64MHZ),
    .LOCKED_OUT(CLK_64MHZ_LOCKED)
    );

wire[11:0] XCOORD, YCOORD;
wire L_BUTTON, R_BUTTON, M_BUTTON;
wire[8:0] TRIGGER_LEVEL;
Driver_mouse driver_MOUSE(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .PS2C(PS2C), .PS2D(PS2D),
    .XCOORD(XCOORD), .YCOORD(YCOORD),
    .L_BUTTON(L_BUTTON), .M_BUTTON(M_BUTTON), .R_BUTTON(R_BUTTON)
    );
    
Driver_MouseInput Driver_MouseInput_inst(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .XCOORD(XCOORD), .YCOORD(YCOORD),
    .L_BUTTON(L_BUTTON), .M_BUTTON(M_BUTTON), .R_BUTTON(R_BUTTON),
    .TRIGGER_LEVEL(TRIGGER_LEVEL),
    .TEST_in_range_Trig(TEST_in_range_Trig)
    );



wire[7:0] ADC_RAM_DATA;
wire[10:0] ADC_RAM_ADDR;
wire ADC_RAM_CLK;
wire[10:0] TRIG_ADDR;
wire VGA_WRITE_DONE;
ADCDataBuffer ram_ADC_databuffer(
    .CLK_64MHZ(CLK_64MHZ), .MASTER_RST(MASTER_RST),
    .CLK180_64MHZ(CLK180_64MHZ),
    .TIME_BASE(TIME_BASE),
    .RAM_ADDR(ADC_RAM_ADDR), .RAM_DATA(ADC_RAM_DATA), .RAM_CLK(ADC_RAM_CLK),
    .ADC_DATA(ADC_DATA), .ADC_CLK(ADC_CLK),
    .TRIG_ADDR(TRIG_ADDR), .VGA_WRITE_DONE(VGA_WRITE_DONE),
    .TRIGGER_LEVEL(TRIGGER_LEVEL)
    );



//wire[17:0] VGA_RAM_ADDRESS_w;
//wire[15:0] VGA_RAM_DATA_w;
wire VGA_RAM_OE_w, VGA_RAM_WE_w, VGA_RAM_CS_w;
wire[17:0] VGA_RAM_ADDRESS_r;
wire VGA_RAM_OE_r, VGA_RAM_WE_r, VGA_RAM_CS_r;
//wire VGA_RAM_ACCESS_OK;

assign VGA_RAM_ADDR = (VGA_RAM_ACCESS_OK) ? VGA_RAM_ADDRESS_w : VGA_RAM_ADDRESS_r;
assign VGA_RAM_DATA = (VGA_RAM_ACCESS_OK) ? VGA_RAM_DATA_w : 16'bZ;
assign VGA_RAM_OE = (VGA_RAM_ACCESS_OK) ? VGA_RAM_OE_w : VGA_RAM_OE_r;
assign VGA_RAM_WE = (VGA_RAM_ACCESS_OK) ? VGA_RAM_WE_w : VGA_RAM_WE_r;
assign VGA_RAM_CS = (VGA_RAM_ACCESS_OK) ? VGA_RAM_CS_w : VGA_RAM_CS_r;

VGADataBuffer ram_VGA_ramwrite(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .VGA_RAM_DATA(VGA_RAM_DATA_w), .VGA_RAM_ADDR(VGA_RAM_ADDRESS_w),
    .VGA_RAM_OE(VGA_RAM_OE_w), .VGA_RAM_WE(VGA_RAM_WE_w), .VGA_RAM_CS(VGA_RAM_CS_w),
    .VGA_RAM_ACCESS_OK(VGA_RAM_ACCESS_OK),
    .ADC_RAM_DATA(ADC_RAM_DATA), .ADC_RAM_ADDR(ADC_RAM_ADDR), .ADC_RAM_CLK(ADC_RAM_CLK),
    .TIME_BASE(TIME_BASE),
    .TRIG_ADDR(TRIG_ADDR), .VGA_WRITE_DONE(VGA_WRITE_DONE)
    );

Driver_VGA driver_VGA(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .H_SYNC(H_SYNC), .V_SYNC(V_SYNC), .VGA_OUTPUT(VGA_OUTPUT),
    .XCOORD(XCOORD), .YCOORD(YCOORD),
    .VGA_RAM_DATA(VGA_RAM_DATA), .VGA_RAM_ADDR(VGA_RAM_ADDRESS_r),
    .VGA_RAM_OE(VGA_RAM_OE_r), .VGA_RAM_WE(VGA_RAM_WE_r), .VGA_RAM_CS(VGA_RAM_CS_r),
    .VGA_RAM_ACCESS_OK(VGA_RAM_ACCESS_OK),
    .TRIGGER_LEVEL(TRIGGER_LEVEL),
    .SHOW_LEVELS(SHOW_LEVELS_BUTTON)
    );



    


//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

endmodule

