`timescale 1ns / 1ps

module SELECT_IN (
    // system signals
    input   wire                        CLK_100M                                , // (i) clock 100MHz
    input   wire                        SYS_RST                                 , // (i) system reset (high-active)

    input   wire[1:0]                   REG_SELECT                              , // (i) VGA display source select

    input   wire                        CLRB_1_DVLD                             , // (i) colorbar1 data valid
    input   wire[15:0]                  CLRB_1_DATA                             , // (i) colorbar1 data
    input   wire[17:0]                  CLRB_1_ADDR                             , // (i) colorbar1 address

    input   wire                        REG_IMG_DVLD                            , // (i) REGISTER image data valid
    input   wire[15:0]                  REG_IMG_DATA                            , // (i) REGISTER image data
    input   wire[17:0]                  REG_ADDR                                , // (i) address image data store

    output  wire                        SLCT_IN_DVLD                            , // (o) SELECT_IN data valid
    output  wire[15:0]                  SLCT_IN_DATA                            , // (o) SELECT_IN data
    output  wire[17:0]                  SLCT_IN_ADDR                              // (o) address image data store
    );

    assign SLCT_IN_DVLD = (REG_SELECT == 2'b01) ? CLRB_1_DVLD : REG_IMG_DVLD;
    assign SLCT_IN_DATA = (REG_SELECT == 2'b01) ? CLRB_1_DATA : REG_IMG_DATA;
    assign SLCT_IN_ADDR = (REG_SELECT == 2'b01) ? CLRB_1_ADDR : REG_ADDR;

endmodule