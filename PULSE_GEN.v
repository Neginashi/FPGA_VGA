// =================================================================================================
// File Name      : PULSE_GEN.v
// Module         : PULSE_GEN
// Function       : Synchronous. pulse from CLK_I to CLK_O
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by        Contents
// 0.1.0      xxxx/xx/xx   TEDWX)wang.d    Create new
//
// =================================================================================================
// End Revision
// =================================================================================================

// =============================================================================
// RTL Header
// =============================================================================

`timescale 1ns / 1ps

module PULSE_GEN (
    XRST            ,   // Reset Input ( Asynchronous )
    CLK_I           ,   // clock at input side
    CLK_O           ,   // clock at output side
    PULSE_I         ,   // pulse input
    PULSE_O             // pulse output
) ;

    parameter           P_TYPE = 8'd0   ;

//==========================================================
//  Declare the port directions
//==========================================================

    input               XRST            ;   // Reset Input ( Asynchronous )
    input               CLK_I           ;   // clock at input side
    input               CLK_O           ;   // clock at output side
    input               PULSE_I         ;   // pulse input
    output              PULSE_O         ;   // pulse output

//==========================================================
//  Internal signals define
//==========================================================

    reg                 r_PULSE_I   ;
    reg     [2:0]       r_PULSE_O   /* synthesis syn_maxfan=9999 */; //r_PULSE_O[0], r_pluse_o[1] should not be duplicated
	// synthesis attribute MAX_FANOUT of r_PULSE_O is 9999;

//==========================================================
//  RTL Body
//==========================================================

    generate
    if(P_TYPE == 0) begin :TYPE_0_PULSEGEN

//==========================================================
//  Input pulse keep ( CLK_I domain )
//==========================================================
        always @( posedge CLK_I or posedge XRST ) begin
            if( XRST ) begin
                r_PULSE_I       <= 1'b0 ;
            end else begin
                if ( PULSE_I == 1'b1 ) begin
                    r_PULSE_I   <= ~r_PULSE_I ;
                end
            end
        end

//==========================================================
//  Output pulse sync. and generate  ( CLK_O domain )
//==========================================================
        always @( posedge CLK_O or posedge XRST ) begin
            if( XRST ) begin
                r_PULSE_O   <= 3'b000 ;
            end else begin
                r_PULSE_O   <= { r_PULSE_O[1:0] , r_PULSE_I } ;
            end
        end

        assign PULSE_O = (r_PULSE_O[2] != r_PULSE_O[1] ) ;   // 0 -> 1

    end
    endgenerate

endmodule