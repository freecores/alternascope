//==================================================================//
// File:    d_VGAdriver.v                                           //
// Version: 0.0.0.2                                                 //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   Jun 09, 2005                                                   //
//                                                                  //
// This program is free software; you can redistribute it and/or    //
// modify it under the terms of the GNU General Public License      //
// as published by the Free Software Foundation; either version 2   //
// of the License, or (at your option) any later version.           //
//                                                                  //
// This program is distributed in the hope that it will be useful,  //
// but WITHOUT ANY WARRANTY; without even the implied warranty of   //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    //
// GNU General Public License for more details.                     //
//                                                                  //
// If you have not received a copy of the GNU General Public License//
// along with this program; write to:                               //
//     Free Software Foundation, Inc.,                              //
//     51 Franklin Street, Fifth Floor,                             //
//     Boston, MA  02110-1301, USA.                                 //
//                                                                  //
//------------------------------------------------------------------//
// Revisions:                                                       //
// Ver 0.0.0.1     Apr 28, 2005   Under Development                 //
//     0.0.0.2     Jun 09, 2005   Cleaning                          //
//                                                                  //
//==================================================================//

module Driver_VGA(
    CLK_50MHZ, MASTER_RST,
    VGA_RAM_DATA, VGA_RAM_ADDR,
    VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS,
    VGA_RAM_ACCESS_OK,
    H_SYNC, V_SYNC, VGA_OUTPUT,
    XCOORD, YCOORD, ram_vshift,
    TRIGGER_LEVEL,
    SHOW_LEVELS
    );
    
//==================================================================//
// PARAMETER DEFINITIONS                                            //
//==================================================================//
parameter P_black   = 3'b000;
parameter P_yellow  = 3'b110;
parameter P_cyan    = 3'b011;
parameter P_green   = 3'b010;
parameter P_white   = 3'b111;

//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input CLK_50MHZ;                // System wide clock
input MASTER_RST;               // System wide reset
output H_SYNC;                  // The H_SYNC timing signal to the VGA monitor
output V_SYNC;                  // The V_SYNC timing signal to the VGA monitor
output[2:0]  VGA_OUTPUT;        // The 3-bit VGA output
input[11:0]  XCOORD, YCOORD;
input[15:0]  VGA_RAM_DATA;
output[17:0] VGA_RAM_ADDR;
output VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;
output VGA_RAM_ACCESS_OK;
input[8:0] TRIGGER_LEVEL;
input SHOW_LEVELS;

output[15:0] ram_vshift;



//----------------------//
// WIRES / NODES        //
//----------------------//
reg H_SYNC, V_SYNC;
reg [2:0]  VGA_OUTPUT;
wire CLK_50MHZ, MASTER_RST;
wire[11:0] XCOORD, YCOORD;
wire[15:0] VGA_RAM_DATA;
reg[17:0]  VGA_RAM_ADDR;
reg VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;
reg VGA_RAM_ACCESS_OK;
wire[8:0] TRIGGER_LEVEL;
wire SHOW_LEVELS;


//----------------------//
// REGISTERS            //
//----------------------//
reg CLK_25MHZ;      // General system clock for VGA timing
reg [9:0] hcnt;     // Counter - generates the H_SYNC signal
reg [9:0] vcnt;     // Counter - counts the H_SYNC pulses to generate V_SYNC signal
reg[2:0]  vga_out;

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

//------------------------------------------------------------------//
// CLOCK FUNCTIONS                                                  //
//------------------------------------------------------------------//
always @ (posedge CLK_50MHZ or posedge MASTER_RST)
        if (MASTER_RST == 1'b1)
            CLK_25MHZ <= 1'b0;
        else
            CLK_25MHZ <= ~CLK_25MHZ;


//------------------------------------------------------------------//
// SYNC TIMING COUNTERS                                             //
//------------------------------------------------------------------//
always @ (posedge CLK_25MHZ or posedge MASTER_RST) begin
    if (MASTER_RST == 1'b1) begin
        hcnt <= 10'd0;
        vcnt <= 10'd0;
    end else if (hcnt == 10'd0799) begin
        hcnt <= 10'd0;
        if (vcnt == 10'd0520)
            vcnt <= 10'd0;
        else
            vcnt <= vcnt + 1'b1;
    end else
        hcnt <= hcnt + 1'b1;
end


//------------------------------------------------------------------//
// HORIZONTAL SYNC TIMING                                           //
//------------------------------------------------------------------//
always @ (hcnt)
    if (hcnt <= 10'd0095)
        H_SYNC = 1'b0;
    else
        H_SYNC = 1'b1;


//------------------------------------------------------------------//
// VERTICAL SYNC TIMING                                             //
//------------------------------------------------------------------//
always @ (vcnt)
    if (vcnt <= 10'd0001)
        V_SYNC = 1'b0;
    else
        V_SYNC = 1'b1;


//------------------------------------------------------------------//
// VGA DATA SIGNAL TIMING                                           //
//------------------------------------------------------------------//
always @ (hcnt or vcnt or XCOORD or YCOORD or MASTER_RST or vga_out or SHOW_LEVELS or TRIGGER_LEVEL) begin
    if(MASTER_RST == 1'b1) begin
        VGA_OUTPUT = P_black;
    //------------------------------------------------------------------------------//
    // UNSEEN BORDERS                                                               //
    end else if( (vcnt <= 10'd30) || (vcnt >= 10'd511) ) begin
        VGA_OUTPUT = P_black;
    end else if( (hcnt <= 10'd143) || (hcnt >= 10'd784) ) begin
        VGA_OUTPUT = P_black;
    //------------------------------------------------------------------------------//
    // MOUSE CURSORS                                                                //
    end else if(vcnt == (YCOORD+10'd31)) begin
        VGA_OUTPUT = P_green;
    end else if(hcnt == (XCOORD+10'd144)) begin
        VGA_OUTPUT = P_green;
    //------------------------------------------------------------------------------//
    // TRIGGER SPRITE         (shows as ------T------ )                             //
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (TRIGGER_LEVEL+10'd31) && hcnt != 10'd700 && hcnt != 10'd702) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (TRIGGER_LEVEL-1'b1+10'd31) && hcnt >= 10'd700 && hcnt <= 10'd702) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (TRIGGER_LEVEL+1'b1+10'd31) && hcnt == 10'd701) begin
        VGA_OUTPUT = P_yellow;
///*
    //------------------------------------------------------------------------------//
    // MOVE THE WAVEFORM TO THE 'TOP'                                               //
    end else if(vga_out != 0 && (vcnt < 10'd431)) begin
        VGA_OUTPUT = vga_out;
//*/
    //------------------------------------------------------------------------------//
    // TOP, BOTTOM, LEFT AND RIGHT GRID LINES                                       //
    end else if( vcnt == 10'd031 || vcnt == 10'd431 || vcnt == 10'd510) begin
        VGA_OUTPUT = P_cyan;
    end else if( hcnt == 10'd144 || hcnt == 10'd783) begin
        VGA_OUTPUT = P_cyan;
    //------------------------------------------------------------------------------//
    // MIDDLE GRID LINES (dashed at 8pxls)                                          //
    end else if(vcnt == 10'd231 && hcnt[3] == 1'b1) begin
        VGA_OUTPUT = P_cyan;
    end else if((hcnt == 10'd464) && (vcnt <= 10'd431) && (vcnt[3] == 1'b1)) begin
        VGA_OUTPUT = P_cyan;
    //------------------------------------------------------------------------------//
    // OTHER HORIZONTAL LINES (dashed at 4pxls)                                     //
    end else if((vcnt == 10'd071 || vcnt == 10'd111 || vcnt == 10'd151 || vcnt == 10'd191 || vcnt == 10'd271 || vcnt == 10'd311 || vcnt == 10'd351 || vcnt == 10'd391) && (hcnt[2] == 1'b1)) begin
        VGA_OUTPUT = P_cyan;
    //------------------------------------------------------------------------------//
    // OTHER VERTICAL LINES (dashed at 4pxls)                                       //
    end else if(((hcnt[5:0] == 6'b010000) && (vcnt <= 10'd431)) && (vcnt[2] == 1'b1)) begin
        VGA_OUTPUT = P_cyan;
    //------------------------------------------------------------------------------//
    // OTHERWISE...                                                                 //
    end else
        VGA_OUTPUT = P_black;
/*
    //------------------------------------------------------------------------------//
    // DISPLAY DATA                                                                 //
    end else if(vcnt >= 10'd431) begin
        VGA_OUTPUT = P_black;
    end else begin
        VGA_OUTPUT = vga_out;
    end
*/
end

//------------------------------------------------------------------//
// RAM DATA READING                                                 //
//------------------------------------------------------------------//
// on reset, ram_addr = 24 and add 25 on each pxl
//     row 0: ram_addr = 24 and 25 for each pxl
//     row 1: ram_addr = 24 and 25 for each pxl
//       ...
//     row 15: ram_addr = 24 and 25 for each pxl
//     row 16: ram_addr = 23 and 25 for each pxl *
//     row 17: ram_addr = 23 and 25 for each pxl *
//       ...
reg[9:0]  ram_hcnt;
reg[4:0]  ram_vcnt;
reg[15:0] ram_vshift;


always @ (posedge CLK_25MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        ram_hcnt <= 10'd639;
    end else if(hcnt >= 10'd143 && hcnt <= 782) begin
        if(ram_hcnt == 10'd639)
            ram_hcnt <= 10'b0;
        else
            ram_hcnt <= ram_hcnt + 1'b1;
    end else begin
        ram_hcnt <= 10'd639;
    end
end

always @ (posedge CLK_25MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        ram_vshift <= 16'h8000;
    end else if(vcnt < 10'd31) begin
        ram_vshift <= 16'h8000;
    end else if((vcnt >= 10'd31) && (hcnt == 10'd0799)) begin
        if(ram_vshift == 16'h0001)
            ram_vshift <= 16'h8000;
        else
            ram_vshift <= (ram_vshift >> 1);
    end else
        ram_vshift <= ram_vshift;
end

always @ (posedge CLK_25MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        ram_vcnt <= 5'd0;
    end else if(vcnt < 10'd30) begin
        ram_vcnt <= 5'd0;
    end else if((vcnt >= 10'd30) && (hcnt == 10'd0799) && (ram_vshift == 16'h0001)) begin
        if(ram_vcnt == 5'd0)
            ram_vcnt <= 5'd24;
        else
            ram_vcnt <= ram_vcnt - 1'b1;
    end else begin
        ram_vcnt <= ram_vcnt;
    end
end



always @ (ram_hcnt or ram_vcnt) begin
    VGA_RAM_ADDR = ram_vcnt + (ram_hcnt * 7'd025);
end


always @ (VGA_RAM_DATA or ram_vshift) begin
    if((VGA_RAM_DATA & ram_vshift) != 16'b0)
        vga_out = P_white;
    else
        vga_out = 3'b0;
end


always begin
    VGA_RAM_CS = 1'b0;  // #CS
    VGA_RAM_OE = 1'b0;  // #OE
    VGA_RAM_WE = 1'b1;  // #WE
end


//------------------------------------------------------------------//
// ALL CLEAR?                                                       //
//------------------------------------------------------------------//
always @ (vcnt) begin
    if(vcnt >= 10'd512 || vcnt < 10'd30)
        VGA_RAM_ACCESS_OK = 1'b1;
    else
        VGA_RAM_ACCESS_OK = 1'b0;
end


endmodule
