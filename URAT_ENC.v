`timescale 1ns / 1ps

module UART_ENC (
    // system signals
    input   wire                        CLK_100M                                , // (i) clock
    input   wire                        SYS_RST                                 , // (i) reset (high-active)

    input   wire[7:0]                   UART_CTRL_TEXT                          , // (i) UART_CTRL text signal

    input   wire                        UART_CTRL_NUM                           , // (i) UART_CTRL num signal
    input   wire[3:0]                   UART_CTRL_DBACK                         , // (i) UART_CTRL data

    output  wire                        UART_ENC_START_OUT                      , // (o) UART_ENC start
    output  wire[7:0]                   UART_ENC_DATA                             // (o) UART_ENC data
    );

    // -------------------------------------------------------------
    // Parameter definition
    // -------------------------------------------------------------
    //text ASCII
    parameter                           ENTER                   = 8'h0A         ; // Enter
    parameter                           RIGHT                   = 8'h3E         ; // >
    parameter                           F                       = 8'h46         ; // F
    parameter                           A                       = 8'h41         ; // A
    parameter                           I                       = 8'h49         ; // I
    parameter                           L                       = 8'h4C         ; // L
    parameter                           O                       = 8'h4F         ; // O
    parameter                           K                       = 8'h4B         ; // K

    // -------------------------------------------------------------
    // Internal signal definition
    // -------------------------------------------------------------

    //regs of send
    reg                                 r_start_out                             ; // start out register

    reg         [7:0]                   r_data_out                              ; // data out register

// =============================================================================
// RTL Body
// =============================================================================
    assign UART_ENC_START_OUT   = r_start_out;
    assign UART_ENC_DATA        = r_data_out;

    // encode
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_start_out <= 1'b0;
            r_data_out  <= 8'h0;
        end else begin
            if (UART_CTRL_TEXT[7]) begin
                r_start_out <= 1'b1;
                r_data_out  <= O;
            end else if (UART_CTRL_TEXT[6]) begin
                r_start_out <= 1'b1;
                r_data_out  <= K;
            end else if (UART_CTRL_TEXT[5]) begin
                r_start_out <= 1'b1;
                r_data_out  <= F;
            end else if (UART_CTRL_TEXT[4]) begin
                r_start_out <= 1'b1;
                r_data_out  <= A;
            end else if (UART_CTRL_TEXT[3]) begin
                r_start_out <= 1'b1;
                r_data_out  <= I;
            end else if (UART_CTRL_TEXT[2]) begin
                r_start_out <= 1'b1;
                r_data_out  <= L;
            end else if (UART_CTRL_TEXT[1]) begin
                r_start_out <= 1'b1;
                r_data_out  <= ENTER;
            end else if (UART_CTRL_TEXT[0]) begin
                r_start_out <= 1'b1;
                r_data_out  <= RIGHT;
            end else if (UART_CTRL_NUM) begin
                r_start_out <= 1'b1;
                case (UART_CTRL_DBACK)
                    4'h0 : begin r_data_out <= 8'h30; end
                    4'h1 : begin r_data_out <= 8'h31; end
                    4'h2 : begin r_data_out <= 8'h32; end
                    4'h3 : begin r_data_out <= 8'h33; end
                    4'h4 : begin r_data_out <= 8'h34; end
                    4'h5 : begin r_data_out <= 8'h35; end
                    4'h6 : begin r_data_out <= 8'h36; end
                    4'h7 : begin r_data_out <= 8'h37; end
                    4'h8 : begin r_data_out <= 8'h38; end
                    4'h9 : begin r_data_out <= 8'h39; end
                    4'hA : begin r_data_out <= 8'h41; end
                    4'hB : begin r_data_out <= 8'h42; end
                    4'hC : begin r_data_out <= 8'h43; end
                    4'hD : begin r_data_out <= 8'h44; end
                    4'hE : begin r_data_out <= 8'h45; end
                    4'hF : begin r_data_out <= 8'h46; end
                    default: begin r_data_out <= 8'h0; end
                endcase
            end else begin
                r_start_out <= 1'b0;
                r_data_out  <= 8'b0;
            end
        end
    end

endmodule