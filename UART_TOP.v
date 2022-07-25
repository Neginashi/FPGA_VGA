`timescale 1ns / 1ps

module UART_TOP (
    // system signals
    input   wire                        CLK_100M                                , // (i) clock 100MHz
    input   wire                        SYS_RST                                 , // (i) system reset (high-active)

    // UART TX&RX
    input   wire                        UART_IN                                 , // (i) UART input
    output  wire                        UART_OUT                                , // (o) UART output

    // data from REGISTER
    input   wire[1:0]                   REG_STATE                               , // (i) UART_REG state signal
    input   wire[31:0]                  REG_DATA                                , // (i) UART_REG data

    // data to REGISTER
    output  wire[1:0]                   UART_STATE                              , // (o) UART state signal
    output  wire[31:0]                  UART_DATA                               , // (o) UART data
    output  wire[7:0]                   UART_ADDR                                 // (o) UART address
    );

    // UART_RX
    wire        [7:0]                   s_UART_RX_DATA                          ; // uart rx data out
    wire                                s_UART_RX_DVLD                          ; // uart rx data done

    // UART_DEC
    wire                                s_UART_DEC_DVLD                         ; // uart dec data valid
    wire        [3:0]                   s_UART_DEC_DATA                         ; // uart dec data
    wire        [2:0]                   s_UART_DEC_STATE                        ; // uart dec state
    wire        [2:0]                   s_UART_DEC_TEXT                         ; // uart dec text

    // UART_CTRL
    wire        [7:0]                   s_UART_CTRL_TEXT                        ; // text signal
                                                                                  // s_uart_ctrl_text[7] = O signal
                                                                                  // s_uart_ctrl_text[6] = K signal
                                                                                  // s_uart_ctrl_text[5] = F signal
                                                                                  // s_uart_ctrl_text[4] = A signal
                                                                                  // s_uart_ctrl_text[3] = I signal
                                                                                  // s_uart_ctrl_text[2] = L signal
                                                                                  // s_uart_ctrl_text[1] = enter signal
                                                                                  // s_uart_ctrl_text[0] = right signal
    wire                                s_UART_CTRL_NUM                         ; // number signal
    wire        [3:0]                   s_UART_CTRL_DBACK                       ; // uart ctrl data


    // UART_ENC
    wire                                s_UART_ENC_START_OUT                    ; // uart enc start
    wire        [7:0]                   s_UART_ENC_DATA                         ; // uart enc data

    // -------------------------------------------------------------------------
    // UART_RX module Inst.
    // -------------------------------------------------------------------------
    UART_RX UART_RX(
        // clock & reset
        .CLK_100M                       ( CLK_100M              ),
        .SYS_RST                        ( SYS_RST               ),

        .UART_IN                        ( UART_IN               ),

        //output
        .UART_RX_DATA                   ( s_UART_RX_DATA        ),              // uart rx 8 bits data out
        .UART_RX_DVLD                   ( s_UART_RX_DVLD        )               // uart rx data done
        //.uart_rx_err                  ( s_UART_RX_ERR         ）
        );

    // -------------------------------------------------------------------------
    // UART_DEC module Inst.
    // -------------------------------------------------------------------------
    UART_DEC UART_DEC(
        // clock & reset
        .CLK_100M                       ( CLK_100M              ),
        .SYS_RST                        ( SYS_RST               ),

        .UART_RX_DVLD                   ( s_UART_RX_DVLD        ),
        .UART_RX_DATA                   ( s_UART_RX_DATA        ),

        // UART_DEC data
        .UART_DEC_DVLD                  ( s_UART_DEC_DVLD       ),              // uart dec 4 bits data
        .UART_DEC_DATA                  ( s_UART_DEC_DATA       ),              // uart dec done

        // UART_DEC state
        .UART_DEC_STATE                 ( s_UART_DEC_STATE      ),              // uart dec state

        // UART_DEC text signal
        .UART_DEC_TEXT                  ( s_UART_DEC_TEXT       )               // uart dec text
        );

    // -------------------------------------------------------------------------
    // UART_CTRL module Inst.
    // -------------------------------------------------------------------------
    UART_CTRL UART_CTRL(
        // clock & reset
        .CLK_100M                       ( CLK_100M              ),
        .SYS_RST                        ( SYS_RST               ),

        // UART_DEC
        .UART_DEC_DATA                  ( s_UART_DEC_DATA       ),
        .UART_DEC_DVLD                  ( s_UART_DEC_DVLD       ),
        .UART_DEC_STATE                 ( s_UART_DEC_STATE      ),

        .UART_DEC_TEXT                  ( s_UART_DEC_TEXT       ),

        // UART_REG_RX
        .REG_STATE                      ( REG_STATE             ),
        .REG_DATA                       ( REG_DATA              ),

        // UART_REG_TX
        .UART_STATE                     ( UART_STATE            ),              // uart ctrl state
        .UART_DATA                      ( UART_DATA             ),              // uart ctrl 32 bits data out
        .UART_ADDR                      ( UART_ADDR             ),              // uart ctrl 8 bits address out

        // UART_ENC
        // text signal
        .UART_CTRL_TEXT                 ( s_UART_CTRL_TEXT      ),              // text signal

        // DATA signal
        .UART_CTRL_NUM                  ( s_UART_CTRL_NUM       ),              // number signal
        .UART_CTRL_DBACK                ( s_UART_CTRL_DBACK     )               // uart ctrl 4 bits data
        );


    // -------------------------------------------------------------------------
    // UART_ENC module Inst.
    // -------------------------------------------------------------------------
    UART_ENC UART_ENC(
        // clock & reset
        .CLK_100M                       ( CLK_100M              ),
        .SYS_RST                        ( SYS_RST               ),

        // text signal
        .UART_CTRL_TEXT                 ( s_UART_CTRL_TEXT      ),

        // DATA signal
        .UART_CTRL_NUM                  ( s_UART_CTRL_NUM       ),
        .UART_CTRL_DBACK                ( s_UART_CTRL_DBACK     ),

        // output
        .UART_ENC_START_OUT             ( s_UART_ENC_START_OUT  ),              // uart enc start
        .UART_ENC_DATA                  ( s_UART_ENC_DATA       )               // uart enc 8 bits data
        );

    // -------------------------------------------------------------------------
    // UART_TX module Inst.
    // -------------------------------------------------------------------------
    UART_TX UART_TX(
        // clock & reset
        .CLK_100M                       ( CLK_100M              ),
        .SYS_RST                        ( SYS_RST               ),

        .UART_ENC_START_OUT             ( s_UART_ENC_START_OUT  ),
        .UART_ENC_DATA                  ( s_UART_ENC_DATA       ),

        //output
        .UART_OUT                       ( UART_OUT              )               // uart module data output
        );

endmodule
