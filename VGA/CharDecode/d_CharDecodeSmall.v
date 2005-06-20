//==================================================================//
// File:    d_CharDecodeSmall.v                                     //
// Version: 0.0.0.1                                                 //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   Jun 17, 2005                                                   //
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
// Ver 0.0.0.1     Jun 17, 2005   Initial Development Release       //
//                                Based on "d_CharDecode.v"         //
//                                                                  //
//==================================================================//

module CharacterDisplay(
    MASTER_CLK, MASTER_RST,
    CLK_VGA, HCNT, VCNT,
    RGB_OUT
    );
                                                                    
//==================================================================//
// PARAMETER DEFINITIONS                                            //
//==================================================================//
parameter P_black   = 3'b000;
parameter P_yellow  = 3'b110;
parameter P_cyan    = 3'b011;
parameter P_green   = 3'b010;
parameter P_white   = 3'b111;
parameter P_blue    = 3'b111;

//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input MASTER_CLK;                // System wide clock
input MASTER_RST;               // System wide reset
input CLK_VGA;                  // Pixel Clk
input[9:0] HCNT;                // Horizontal Sync Counter
input[9:0] VCNT;                // Vertical Sync Counter
output[2:0] RGB_OUT;            // The RGB data


//----------------------//
// WIRES / NODES        //
//----------------------//
wire MASTER_CLK, MASTER_RST, CLK_VGA;
wire[9:0] HCNT, VCNT;
reg[2:0]  RGB_OUT;



//----------------------//
// REGISTERS            //
//----------------------//
reg[3:0] cnt_charPxls;
reg[6:0] cnt_Hchar;
reg[10:0] cnt_Vchar;
wire     charRow1, charRow2, charRow3, charRow4, charRow5, charRow6, charRow7, charRow8;

wire[10:0] addr_charRamRead;
wire[7:0]  data_charRamRead;

reg[7:0]   mask_charMap;
wire[10:0] addr_charMap;
wire[7:0]  data_charMap;


//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//



//------------------------------------------------------------------//
// Character Input / Storage                                        //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// A useful description could go here!                              //
//------------------------------------------------------------------//





//------------------------------------------------------------------//
// Character Decode                                                 //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// A useful description could go here!                              //
//------------------------------------------------------------------//

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// DECODE the Character RAM Address via HCNT and VCNT               //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //

always @ (posedge CLK_VGA or posedge MASTER_RST) begin
    if(MASTER_RST) begin
        cnt_charPxls <= 4'd5;
    end else if(HCNT >= 10'd6) begin //7
        if(cnt_charPxls == 4'd0)
            cnt_charPxls <= 4'd5;
        else
            cnt_charPxls <= cnt_charPxls-1;
    end else begin
        cnt_charPxls <= 4'd5;
    end
end

always @ (posedge CLK_VGA or posedge MASTER_RST) begin
    if(MASTER_RST) begin
        cnt_Hchar <= 7'd0;
    end else if(HCNT >= 10'd6 && cnt_charPxls == 4'd0) begin
        if(cnt_Hchar == 7'd102)
            cnt_Hchar <= 7'd0;
        else
            cnt_Hchar <= cnt_Hchar+1;
    end else if(HCNT < 10'd6) begin
        cnt_Hchar <= 7'd0;
    end else begin
        cnt_Hchar <= cnt_Hchar;
    end
end

assign charRow1 = ((VCNT <= 512) && (VCNT >= 505));
assign charRow2 = ((VCNT <= 503) && (VCNT >= 496));
assign charRow3 = ((VCNT <= 494) && (VCNT >= 487));
assign charRow4 = ((VCNT <= 485) && (VCNT >= 478));
assign charRow5 = ((VCNT <= 476) && (VCNT >= 469));
assign charRow6 = ((VCNT <= 467) && (VCNT >= 460));
assign charRow7 = ((VCNT <= 458) && (VCNT >= 451));
assign charRow8 = ((VCNT <= 449) && (VCNT >= 442));

always @ (charRow1 or charRow2 or charRow3 or charRow4 or charRow5 or charRow6 or charRow7 or charRow8) begin
         if(charRow1) cnt_Vchar = 11'd0;
    else if(charRow2) cnt_Vchar = 11'd103;
    else if(charRow3) cnt_Vchar = 11'd206;
    else if(charRow4) cnt_Vchar = 11'd309;
    else if(charRow5) cnt_Vchar = 11'd412;
    else if(charRow6) cnt_Vchar = 11'd515;
    else if(charRow7) cnt_Vchar = 11'd618;
    else if(charRow8) cnt_Vchar = 11'd721;
    else              cnt_Vchar = 11'd0;
end

assign addr_charRamRead = cnt_Vchar + cnt_Hchar;



//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// DECODE the Character Map via HCNT and VCNT and CHAR_DATA         //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
always @ (posedge CLK_VGA or posedge MASTER_RST) begin
    if(MASTER_RST) begin
        mask_charMap <= 8'd0;
    end else if(VCNT <= 10'd512) begin
        if(HCNT == 10'd0) begin
            if(mask_charMap == 8'd0)
                mask_charMap <= 8'b10000000;
            else
                mask_charMap <= mask_charMap >> 1;
        end else
            mask_charMap <= mask_charMap;
    end else begin
        mask_charMap <= 8'd0;
    end
end



assign addr_charMap = ((data_charRamRead * 8'd5) + cnt_charPxls);


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// DECODE the VGA_OUTPUT via the Character Map                      //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
reg[2:0] rgb_buf;

always @ (mask_charMap or data_charMap) begin
    if((charRow1 | charRow2 | charRow3 | charRow4 | charRow5 | charRow6 | charRow7 | charRow8) && ((mask_charMap & data_charMap) != 8'b0) && (cnt_charPxls != 4'd5) && (HCNT >= 10'd7) && (HCNT <= 10'd632))
        rgb_buf = P_yellow;
    else
        rgb_buf = P_black;
end
    
always @ (posedge CLK_VGA) begin
    RGB_OUT <= rgb_buf;
end


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// COUNTER TESTING                                                  //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
reg[63:0] test_cnt;
reg[10:0] test_cntAddr;
reg[7:0]  data_time;
always @ (posedge MASTER_CLK or posedge MASTER_RST) begin
    if(MASTER_RST)
        test_cnt <= 64'd0;
    else
        test_cnt <= test_cnt+1;
end

always @ (posedge MASTER_CLK or posedge MASTER_RST) begin
    if(MASTER_RST)
        test_cntAddr <= 11'd41;
    else if(test_cntAddr == 11'd56)
        test_cntAddr <= 11'd41;
    else
        test_cntAddr <= test_cntAddr+1;
end

always @ (test_cntAddr or test_cnt) begin
         if(test_cntAddr == 11'd41) data_time[3:0] = test_cnt[63:60];
    else if(test_cntAddr == 11'd42) data_time[3:0] = test_cnt[59:56];
    else if(test_cntAddr == 11'd43) data_time[3:0] = test_cnt[55:52];
    else if(test_cntAddr == 11'd44) data_time[3:0] = test_cnt[51:48];
    else if(test_cntAddr == 11'd45) data_time[3:0] = test_cnt[47:44];
    else if(test_cntAddr == 11'd46) data_time[3:0] = test_cnt[43:40];
    else if(test_cntAddr == 11'd47) data_time[3:0] = test_cnt[39:36];
    else if(test_cntAddr == 11'd48) data_time[3:0] = test_cnt[35:32];
    else if(test_cntAddr == 11'd49) data_time[3:0] = test_cnt[31:28];
    else if(test_cntAddr == 11'd50) data_time[3:0] = test_cnt[27:24];
    else if(test_cntAddr == 11'd51) data_time[3:0] = test_cnt[23:20];
    else if(test_cntAddr == 11'd52) data_time[3:0] = test_cnt[19:16];
    else if(test_cntAddr == 11'd53) data_time[3:0] = test_cnt[15:12];
    else if(test_cntAddr == 11'd54) data_time[3:0] = test_cnt[11:8];
    else if(test_cntAddr == 11'd55) data_time[3:0] = test_cnt[7:4];
    else if(test_cntAddr == 11'd56) data_time[3:0] = test_cnt[3:0];
    else                            data_time[3:0] = 4'b0000;
end

always begin
    data_time[7:4] = 4'b0;
end









//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// Character Decode RAM INSTANTIATION                               //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// A useful description could go here!                              //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
wire VCC, GND;
assign VCC = 1'b1;
assign GND = 1'b0;

RAMB16_S9_S9 #(
//                  6666555555555544444444443333333333222222222211111111110000000000
//    .INIT_00(256'h920de29292928ee0101010fe449292927c668A9292662242FE02027C8282827C),
      .INIT_00(256'h920de29292928ee0101010fe449292927c668A9292660042FE02007C86BAC27C),
//                  CCCCCCCCBBBBBBBBBBAAAAAAAAAA999999999988888888887777777777666666
      .INIT_01(256'h828282c6Fe9292926c7e9090907e609292927d6d9292926d808698a0C07d9292),
//                  JJIIIIIIIIIIHHHHHHHHHHGGGGGGGGGGFFFFFFFFFFEEEEEEEEEEDDDDDDDDDDCC
      .INIT_02(256'h808282F78282F7101010F77c829294d7Fe909090c0Fe929292c6FE8282827c7c),
//                  PPPPPPOOOOOOOOOONNNNNNNNNNMMMMMMMMMMLLLLLLLLLLKKKKKKKKKKJJJJJJJJ
      .INIT_03(256'h9090607C8282827CF7403804F7F7402040F7F702020206F7102844818482FC80),
//                  VVVVVVVVVVUUUUUUUUUUTTTTTTTTTTSSSSSSSSSSRRRRRRRRRRQQQQQQQQQQPPPP
      .INIT_04(256'h78040204787C0202027CC080F780C064929292467C909894627C828A7C027C90),
//                                --space---ZZZZZZZZZZYYYYYYYYYYXXXXXXXXXXWWWWWWWWWW
      .INIT_05(256'h0000000000000000000000008286BAC28280403740806281028C6F7040804F7),
      .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000)
) RAM_Character_Map (
    .DOA(),         .DOB(data_charMap),
    .DOPA(),        .DOPB(),
    .ADDRA(11'b111),  .ADDRB(addr_charMap),
    .CLKA(GND),     .CLKB(MASTER_CLK),
    .DIA(8'b0),     .DIB(8'b0),
    .DIPA(GND),     .DIPB(GND),
    .ENA(GND),      .ENB(VCC),
    .WEA(GND),      .WEB(GND),
    .SSRA(GND),     .SSRB(GND)
    );


RAMB16_S9_S9 #(
      .INIT_00(256'h3633636363636363636363636F0E0D0C0B0A0908070605040302010036363636),
      .INIT_01(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_02(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_03(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_04(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_05(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_06(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_07(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_08(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_09(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_0A(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_0B(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_0C(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_0D(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_0E(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_0F(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_10(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_11(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_12(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_13(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_14(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_15(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_16(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_17(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_18(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_19(256'h3636363636363636363636363636363636363636363636363636363636363636),
      .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000)
) RAM_Character_Test (
    .DOA(),                 .DOB(data_charRamRead),
    .DOPA(),                .DOPB(),
    .ADDRA(test_cntAddr),   .ADDRB(addr_charRamRead),
    .CLKA(MASTER_CLK),      .CLKB(MASTER_CLK),
    .DIA(data_time),        .DIB(8'b0),
    .DIPA(GND),             .DIPB(GND),
    .ENA(VCC),              .ENB(VCC),
    .WEA(VCC),              .WEB(GND),
    .SSRA(GND),             .SSRB(GND)
    );








endmodule
