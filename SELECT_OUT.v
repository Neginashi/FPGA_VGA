`timescale 1ns / 1ps

module SELECT_OUT (
    // system signals
    input   wire                        CLK_40M                                 , // (i) clock 40MHz
    input   wire                        SYS_RST                                 , // (i) system reset (high-active)

    input   wire[1:0]                   REG_SELECT                              ,
    input   wire                        CLRB_2_DVLD                             , // (i)
    input   wire[15:0]                  CLRB_2_DATA                             , // (i)
    input   wire                        SRAM_CTRL_DVLD                          , // (i)
    input   wire[15:0]                  SRAM_CTRL_DATA                          , // (i)

    output  wire[15:0]                  SLCT_OUT_DATA                           , // (o)
    
    input   wire                        VGA_REQ                                 ,
    output  wire                        SLCT_OUT_REQ                              // (o)
    );

    assign SLCT_OUT_DVLD    = (REG_SELECT == 2'b10) ? CLRB_2_DVLD : SRAM_CTRL_DVLD;
    assign SLCT_OUT_DATA    = (REG_SELECT == 2'b10) ? CLRB_2_DATA : SRAM_CTRL_DATA;
    assign SLCT_OUT_REQ     = VGA_REQ;

endmodule