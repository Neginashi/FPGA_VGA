`timescale 1ns / 1ps

module FPGA_TOP(
    // board clock & reset signals
    input   wire                        CLK_50M                                 , // (i) FPGA osc clock 50MHz
    input   wire                        RST_N                                   , // (i) FPGA reset (Low-active)

    // uart in/out
    input   wire                        UART_IN                                 , // (i) UART Rx Port
    output  wire                        UART_OUT                                ,

    output  wire                        SRAM_CE                                 , //
    output  wire                        SRAM_WE                                 , //
    output  wire                        SRAM_UB                                 , //
    output  wire                        SRAM_LB                                 , //
    output  wire[17:0]                  SRAM_ADDR                               , //
    inout   wire[15:0]                  SRAM_DATA                               , //
    output  wire                        SRAM_OE                                 , //

    output  wire                        s_CLK_100M                                 , //

    output  wire[8:0]                   VGA_DATA                                , // (o)
    output  wire                        VGA_DE                                  ,
    output  wire                        VGA_HSYNC                               ,
    output  wire                        VGA_VSYNC
    );

    // -------------------------------------------------------------------------
    // Internal Signal Definition
    // -------------------------------------------------------------------------
    // clock & reset
    wire                                s_CLK_40M                               ; // System Clk 40MHz
    //wire                                s_CLK_100M                              ; // System Clk 100MHz
    wire                                s_SYS_RST                               ; // System Reset(Active High)

    // REGISTER
    wire        [1:0]                   s_REG_STATE                             ; // register state
    wire        [31:0]                  s_REG_DATA                              ; // register data
    wire                                s_REG_VGA_EN                            ; //
    wire        [1:0]                   s_REG_SELECT                            ; //
    wire                                s_REG_IMG_DVLD                          ; //
    wire        [15:0]                  s_REG_IMG_DATA                          ; //
    wire        [17:0]                  s_REG_ADDR                              ; //

    wire        [1:0]                   s_UART_STATE                            ;
    wire        [31:0]                  s_UART_DATA                             ;
    wire        [7:0]                   s_UART_ADDR                             ;

    // COLORBAR_1
    wire                                s_CLRB_1_DVLD                           ; //
    wire        [17:0]                  s_CLRB_1_ADDR                           ; //
    wire        [15:0]                  s_CLRB_1_DATA                           ; //

    // SELECT_IN
    wire                                s_SLCT_IN_DVLD                          ; //
    wire        [15:0]                  s_SLCT_IN_DATA                          ; //
    wire        [17:0]                  s_SLCT_IN_ADDR                          ; //

    // SRAM_CTRL
    wire                                s_SRAM_CTRL_DVLD                        ; //
    wire        [15:0]                  s_SRAM_CTRL_DATA                        ; //

    // COLORBAR_2
    wire                                s_CLRB_2_DVLD                           ; //
    wire        [15:0]                  s_CLRB_2_DATA                           ; //

    // SELECT_OUT
    wire        [15:0]                  s_SLCT_OUT_DATA                         ; //
    wire                                s_SLCT_OUT_REQ                          ; //

    // VGA_CTRL
    wire                                s_VGA_REQ                               ; //


// =============================================================================
// RTL Body
// =============================================================================
    // -------------------------------------------------------------------------
    // Clock & reset module Inst.
    // -------------------------------------------------------------------------
    //BUFG  U_CLK_50M (
    //    .I                              ( CLK_50M               ),
    //    .O                              ( s_CLK_50M             )
    //);

    CLK_RST  CLK_RST (
        .CLK_50M                        ( CLK_50M               ),              //
        .RST_N                          ( RST_N                 ),              //
        .CLK_40M                        ( s_CLK_40M             ),              //
        .CLK_100M                       ( s_CLK_100M            ),              //
        .SYS_RST                        ( s_SYS_RST             )               //
    );

    // -------------------------------------------------------------------------
    // UART module Inst.
    // -------------------------------------------------------------------------
    UART_TOP UART_TOP(
        .CLK_100M                       ( s_CLK_100M            ),
        .SYS_RST                        ( s_SYS_RST             ),

        .UART_IN                        ( UART_IN               ),
        .UART_OUT                       ( UART_OUT              ),

        .REG_STATE                      ( s_REG_STATE           ),
        .REG_DATA                       ( s_REG_DATA            ),

        .UART_STATE                     ( s_UART_STATE          ),
        .UART_DATA                      ( s_UART_DATA           ),
        .UART_ADDR                      ( s_UART_ADDR           )
    );

    // -------------------------------------------------------------------------
    // REGISTER module Inst.
    // -------------------------------------------------------------------------
    REGISTER REGISTER(
        // clock & reset
        .CLK_100M                       ( s_CLK_100M            ),
        .SYS_RST                        ( s_SYS_RST             ),

        .UART_STATE                     ( s_UART_STATE          ),
        .UART_DATA                      ( s_UART_DATA           ),
        .UART_ADDR                      ( s_UART_ADDR           ),

        .REG_STATE                      ( s_REG_STATE           ),
        .REG_DATA                       ( s_REG_DATA            ),
        .REG_VGA_EN                     ( s_REG_VGA_EN          ),
        .REG_SELECT                     ( s_REG_SELECT          ),
        .REG_IMG_DVLD                   ( s_REG_IMG_DVLD        ),
        .REG_IMG_DATA                   ( s_REG_IMG_DATA        ),
        .REG_ADDR                       ( s_REG_ADDR            )
        );

    // -------------------------------------------------------------------------
    // COLORBAR_1 module Inst.
    // -------------------------------------------------------------------------
    COLORBAR_1 COLORBAR_1(
        .CLK_100M                       ( s_CLK_100M            ),
        .SYS_RST                        ( s_SYS_RST             ),

        .REG_SELECT                     ( s_REG_SELECT          ),

        .CLRB_1_DVLD                    ( s_CLRB_1_DVLD         ),
        .CLRB_1_ADDR                    ( s_CLRB_1_ADDR         ),
        .CLRB_1_DATA                    ( s_CLRB_1_DATA         )
        );

    // -------------------------------------------------------------------------
    // SELECT_IN module Inst.
    // -------------------------------------------------------------------------
    SELECT_IN SELECT_IN(
        .CLK_100M                       ( s_CLK_100M            ),
        .SYS_RST                        ( s_SYS_RST             ),

        .REG_SELECT                     ( s_REG_SELECT          ),

        .CLRB_1_DVLD                    ( s_CLRB_1_DVLD         ),
        .CLRB_1_ADDR                    ( s_CLRB_1_ADDR         ),
        .CLRB_1_DATA                    ( s_CLRB_1_DATA         ),

        .REG_IMG_DVLD                   ( s_REG_IMG_DVLD        ),
        .REG_IMG_DATA                   ( s_REG_IMG_DATA        ),

        .REG_ADDR                       ( s_REG_ADDR            ),

        .SLCT_IN_DVLD                   ( s_SLCT_IN_DVLD        ),
        .SLCT_IN_DATA                   ( s_SLCT_IN_DATA        ),
        .SLCT_IN_ADDR                   ( s_SLCT_IN_ADDR        )
        );

    // -------------------------------------------------------------------------
    // SRAM_CTRL module Inst.
    // -------------------------------------------------------------------------
    SRAM_CTRL SRAM_CTRL(
        .CLK_100M                       ( s_CLK_100M            ),
        .CLK_40M                        ( s_CLK_40M             ),
        .SYS_RST                        ( s_SYS_RST             ),

        .REG_VGA_EN                     ( s_REG_VGA_EN          ),
        .REG_SELECT                     ( s_REG_SELECT          ),

        .SLCT_IN_DVLD                   ( s_SLCT_IN_DVLD        ),
        .SLCT_IN_DATA                   ( s_SLCT_IN_DATA        ),
        .SLCT_IN_ADDR                   ( s_SLCT_IN_ADDR        ),
        .SLCT_OUT_REQ                   ( s_SLCT_OUT_REQ        ),

        .VGA_VSYNC                      ( VGA_VSYNC             ),
        .VGA_HSYNC                      ( VGA_HSYNC             ),

        .SRAM_CE                        ( SRAM_CE               ),
        .SRAM_WE                        ( SRAM_WE               ),
        .SRAM_UB                        ( SRAM_UB               ),
        .SRAM_LB                        ( SRAM_LB               ),
        .SRAM_ADDR                      ( SRAM_ADDR             ),
        .SRAM_DATA                      ( SRAM_DATA             ),
        .SRAM_OE                        ( SRAM_OE               ),

        .SRAM_CTRL_DVLD                 ( s_SRAM_CTRL_DVLD      ),
        .SRAM_CTRL_DATA                 ( s_SRAM_CTRL_DATA      )
        );

    // -------------------------------------------------------------------------
    // COLORBAR_2 module Inst.
    // -------------------------------------------------------------------------
    COLORBAR_2 COLORBAR_2(
        .CLK_40M                        ( s_CLK_40M             ),
        .SYS_RST                        ( s_SYS_RST             ),

        .SLCT_OUT_REQ                   ( s_SLCT_OUT_REQ        ),

        .REG_SELECT                     ( s_REG_SELECT          ),

        .CLRB_2_DVLD                    ( s_CLRB_2_DVLD         ),
        .CLRB_2_DATA                    ( s_CLRB_2_DATA         )
        );

    // -------------------------------------------------------------------------
    // SELECT_OUT module Inst.
    // -------------------------------------------------------------------------
    SELECT_OUT SELECT_OUT(
        .CLK_40M                        ( s_CLK_40M             ),
        .SYS_RST                        ( s_SYS_RST             ),

        .REG_SELECT                     ( s_REG_SELECT          ),

        .CLRB_2_DVLD                    ( s_CLRB_2_DVLD         ),
        .CLRB_2_DATA                    ( s_CLRB_2_DATA         ),

        .SRAM_CTRL_DVLD                 ( s_SRAM_CTRL_DVLD      ),
        .SRAM_CTRL_DATA                 ( s_SRAM_CTRL_DATA      ),

        .SLCT_OUT_DATA                  ( s_SLCT_OUT_DATA       ),
        .SLCT_OUT_REQ                   ( s_SLCT_OUT_REQ        ),

        .VGA_REQ                        ( s_VGA_REQ             )
        );

    // -------------------------------------------------------------------------
    // VGA_CTRL module Inst.
    // -------------------------------------------------------------------------
    VGA_CTRL VGA_CTRL(
        .CLK_40M                        ( s_CLK_40M             ),
        .SYS_RST                        ( s_SYS_RST             ),

        .REG_VGA_EN                     ( s_REG_VGA_EN          ),
        .SLCT_OUT_DATA                  ( s_SLCT_OUT_DATA       ),

        .VGA_DATA                       ( VGA_DATA              ),
        .VGA_DE                         ( VGA_DE                ),
        .VGA_HSYNC                      ( VGA_HSYNC             ),
        .VGA_VSYNC                      ( VGA_VSYNC             ),
        .VGA_REQ                        ( s_VGA_REQ             )
        );

endmodule
