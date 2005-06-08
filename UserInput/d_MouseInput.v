//==================================================================
// File:    d_MouseInput.v
// Version: 0.01
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Copyright Stephen Pickett
//   May 19, 2005
//------------------------------------------------------------------
// Revisions:
// Ver 0.01     May 19, 2005    Initial Release
//
//==================================================================

module Driver_MouseInput(
    CLK_50MHZ, MASTER_RST,
    XCOORD, YCOORD, L_BUTTON, R_BUTTON, M_BUTTON,
    TRIGGER_LEVEL,
    TEST_in_range_trig
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
input CLK_50MHZ;            // System wide clock
input MASTER_RST;           // System wide reset
input[11:0] XCOORD;         // X coordinate of the cursor
input[11:0] YCOORD;         // Y coordinate of the cursor
input L_BUTTON;             // Left Mouse Button Press
input R_BUTTON;             // Right Mouse Button Press
input M_BUTTON;             // Middle Mouse Button Press
output[8:0] TRIGGER_LEVEL;  // Current Trigger Level

//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_50MHZ, MASTER_RST;
wire[11:0] XCOORD;
wire[11:0] YCOORD;
wire L_BUTTON, R_BUTTON, M_BUTTON;
reg[8:0] TRIGGER_LEVEL;

//----------------------//
// REGISTERS            //
//----------------------//


//----------------------//
// TESTING              //
//----------------------//
output TEST_in_range_Trig;
wire TEST_in_range_Trig;




//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

//------------------------------------------------------------------//
// INTERMEDIATES                                                    //
//------------------------------------------------------------------//
wire Lrise, Lfall;
reg  Lbuf;
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        Lbuf <= 1'b0;
    else
        Lbuf <= L_BUTTON;
end

assign Lrise = (!Lbuf &  L_BUTTON);
assign Lfall = ( Lbuf & !L_BUTTON);

//------------------------------------------------------------------//
// TRIGGER                                                          //
//------------------------------------------------------------------//
reg in_range_Trig;
reg Ldrag_Trig;
always @ (YCOORD or XCOORD or TRIGGER_LEVEL) begin
    in_range_Trig = (((YCOORD >= TRIGGER_LEVEL-1'b1) && (YCOORD <= TRIGGER_LEVEL+1'b1)) && ((XCOORD >= 10'd556 && XCOORD <= 10'd558)));
end

assign TEST_in_range_Trig = in_range_Trig;

always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST)
        Ldrag_Trig <= 1'b0;
    else if(Lrise && in_range_Trig)
        Ldrag_Trig <= 1'b1;
    else if(Lfall)
        Ldrag_Trig <= 1'b0;
    else
        Ldrag_Trig <= Ldrag_Trig;
end


always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST)
        TRIGGER_LEVEL <= 9'd200;
    else if(Ldrag_Trig)
        TRIGGER_LEVEL <= YCOORD;
    else
        TRIGGER_LEVEL <= TRIGGER_LEVEL;
end





endmodule

