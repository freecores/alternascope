//==================================================================
// File:    d_Driver_ADC.v
// Version: 0.01
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Copyright Stephen Pickett
//   April 28, 2005
//------------------------------------------------------------------
// Revisions:
// Ver 0.01     Apr 28, 2005    Initial Release
//
//==================================================================

module Driver_ADC(
    CLK_64MHZ, MASTER_RST,
    TIME_BASE,
    ADC_CLK, ADC_DATA,
    DATA_OUT
    );

//==================================================================//
// DEFINITIONS                                                      //
//==================================================================//
parameter US1       = 5'd0;
parameter US2       = 5'd1;
parameter US4       = 5'd2;
parameter US8       = 5'd3;
parameter US16      = 5'd4;
parameter US32      = 5'd5;
parameter US64      = 5'd6;
parameter US128     = 5'd7;
parameter US512     = 5'd8;
parameter US1024    = 5'd9;
parameter US2048    = 5'd10;
parameter US4096    = 5'd11;
parameter US8192    = 5'd12;
parameter US16384   = 5'd13;
parameter US32768   = 5'd14;
parameter US65536   = 5'd15;
parameter US131072  = 5'd16;
parameter US262144  = 5'd17;
parameter US524288  = 5'd18;
parameter US1048576 = 5'd19;
parameter US2097152 = 5'd20;
parameter US4194304 = 5'd21;
parameter US8388608 = 5'd22;


//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//

//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input       CLK_64MHZ;          // Global System Clock
input       MASTER_RST;         // Global Asyncronous Reset
input[5:0]  TIME_BASE;          // The selected V/Div
input[7:0]  ADC_DATA;           // Data recieved from ADC
output      ADC_CLK;            // Clock out to the ADC
output[7:0] DATA_OUT;           // Data output (essentially buffered from ADC by one clk)

//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_64MHZ, MASTER_RST;
wire[5:0] TIME_BASE;
wire[7:0] ADC_DATA;
reg  ADC_CLK;
reg [7:0] DATA_OUT;

//----------------------//
// VARIABLES            //
//----------------------//




//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//



//------------------------------------------------------------------//
// CLOCK GENERATION AND SELECTION                                   //
//------------------------------------------------------------------//
reg[15:0] Counter_CLK;
wire CLK_32MHZ, CLK_16MHZ, CLK_8MHZ, CLK_4MHZ, CLK_2MHZ, CLK_1MHZ, CLK_500KHZ, CLK_250KHZ, CLK_125KHZ,
     CLK_62KHZ, CLK_31KHZ, CLK_16KHZ, CLK_8KHZ, CLK_4KHZ, CLK_2KHZ, CLK_1KHZ;

always @ (posedge CLK_64MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        Counter_CLK <= 16'b0;
    end else begin
        Counter_CLK <= Counter_CLK + 1;
    end
end

assign CLK_32MHZ    = Counter_CLK[0];
assign CLK_16MHZ    = Counter_CLK[1];
assign CLK_8MHZ     = Counter_CLK[2];
assign CLK_4MHZ     = Counter_CLK[3];
assign CLK_2MHZ     = Counter_CLK[4];
assign CLK_1MHZ     = Counter_CLK[5];
assign CLK_500KHZ   = Counter_CLK[6];
assign CLK_250KHZ   = Counter_CLK[7];
assign CLK_125KHZ   = Counter_CLK[8];
assign CLK_62KHZ    = Counter_CLK[9];
assign CLK_31KHZ    = Counter_CLK[10];
assign CLK_16KHZ    = Counter_CLK[11];
assign CLK_8KHZ     = Counter_CLK[12];
assign CLK_4KHZ     = Counter_CLK[13];
assign CLK_2KHZ     = Counter_CLK[14];
assign CLK_1KHZ     = Counter_CLK[15];
//assign CLK_500HZ    = Counter_CLK[16];


always @ (TIME_BASE or MASTER_RST or CLK_64MHZ or CLK_32MHZ or CLK_16MHZ or
            CLK_8MHZ or CLK_4MHZ or CLK_2MHZ or CLK_1MHZ or CLK_500KHZ or CLK_250KHZ or
            CLK_125KHZ or CLK_62KHZ or CLK_31KHZ or CLK_16KHZ or CLK_8KHZ or CLK_4KHZ or
            CLK_2KHZ or CLK_1KHZ) begin
    if(MASTER_RST == 1'b1) begin
        ADC_CLK = 1'b0;
    end else if(TIME_BASE == 6'd0) begin    // 1us/Div, 1samp/pxl
        ADC_CLK = CLK_64MHZ;
    end else if(TIME_BASE == 6'd1) begin    // 2us/Div, 2samp/pxl
        ADC_CLK = CLK_64MHZ;
    end else if(TIME_BASE == 6'd2) begin    // 4us/Div, 2samp/pxl
        ADC_CLK = CLK_32MHZ;
    end else if(TIME_BASE == 6'd3) begin    // 8us/Div, 2samp/pxl
        ADC_CLK = CLK_16MHZ;
    end else if(TIME_BASE == 6'd4) begin    // 16us/Div, 2samp/pxl
        ADC_CLK = CLK_8MHZ;
    end else if(TIME_BASE == 6'd5) begin    // 32us/Div, 2samp/pxl
        ADC_CLK = CLK_4MHZ;
    end else if(TIME_BASE == 6'd6) begin    // 64us/Div, 2samp/pxl
        ADC_CLK = CLK_2MHZ;
    end else if(TIME_BASE == 6'd7) begin    // 128us/Div, 2samp/pxl
        ADC_CLK = CLK_1MHZ;
    end else if(TIME_BASE == 6'd8) begin    // 256us/Div, 2samp/pxl
        ADC_CLK = CLK_500KHZ;
    end else if(TIME_BASE == 6'd9) begin    // 512us/Div, 2samp/pxl
        ADC_CLK = CLK_250KHZ;
    end else if(TIME_BASE == 6'd10) begin   //      ...
        ADC_CLK = CLK_125KHZ;
    end else if(TIME_BASE == 6'd11) begin
        ADC_CLK = CLK_62KHZ;
    end else if(TIME_BASE == 6'd12) begin
        ADC_CLK = CLK_31KHZ;
    end else if(TIME_BASE == 6'd13) begin
        ADC_CLK = CLK_16KHZ;
    end else if(TIME_BASE == 6'd14) begin
        ADC_CLK = CLK_8KHZ;
    end else if(TIME_BASE == 6'd15) begin
        ADC_CLK = CLK_4KHZ;
    end else if(TIME_BASE == 6'd16) begin
        ADC_CLK = CLK_2KHZ;
    end else if(TIME_BASE == 6'd17) begin
        ADC_CLK = CLK_1KHZ;
//    end else if(TIME_BASE == 6'd18) begin
//        ADC_CLK = CLK_500HZ;
/*
    end else if(TIME_BASE == 6'd19) begin
        ADC_CLK = CLK_US524288;
    end else if(TIME_BASE == 6'd20) begin
        ADC_CLK = CLK_US1048576;
    end else if(TIME_BASE == 6'd21) begin
        ADC_CLK = CLK_US2097152;
    end else if(TIME_BASE == 6'd22) begin
        ADC_CLK = CLK_US4194304;
    end else if(TIME_BASE == 6'd23) begin
        ADC_CLK = CLK_US8388608;
*/
    end else begin
        ADC_CLK = 1'b0;
    end
end
    
//------------------------------------------------------------------//
// ADC DATA READING                                                 //
//------------------------------------------------------------------//
always @ (negedge ADC_CLK or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        DATA_OUT <= 8'b0;
    end else begin
        DATA_OUT <= ADC_DATA;
    end
end

//assign DATA_OUT = ADC_DATA;

endmodule



