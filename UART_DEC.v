`timescale 1ns / 1ps

module UART_DEC (
    // system signals
    input   wire                        CLK_100M                                , // (i) clock
    input   wire                        SYS_RST                                 , // (i) reset (high-active)

    // UART_DEC
    input   wire                        UART_RX_DVLD                            , // (i) UART_DEC start
    input   wire[7:0]                   UART_RX_DATA                            , // (i) UART_DEC data in

    // UART_DEC state
    output  wire[2:0]                   UART_DEC_STATE                          , // (o) UART_DEC_STATE[ write, read, fail ]

    // UART_DEC text signal
    output  wire[2:0]                   UART_DEC_TEXT                           , // (o) UART_DEC_TEXT[ space, cr, lf]

    // UART_DEC data
    output  wire                        UART_DEC_DVLD                           , // (o) UART_DEC done
    output  wire[3:0]                   UART_DEC_DATA                             // (o) UART_DEC data out
    );

    // -------------------------------------------------------------
    // Internal signal definition
    // -------------------------------------------------------------
    reg         [2:0]                   r_state                                 ; // state register
    reg         [2:0]                   r_text                                  ; // text register

    reg                                 r_done                                  ; // UART_DEC done register

    reg         [3:0]                   r_data_out                              ; // UART_DEC output register

// =============================================================================
// RTL Body
// =============================================================================
    //decoding
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_data_out  <= 4'h0;
            r_done      <= 1'b0;
            r_state     <= 3'b0;
            r_text      <= 3'b0;
        end else if (UART_RX_DVLD) begin
            case ( UART_RX_DATA )
                8'h30: begin r_data_out[3:0]    <= 4'h0;    end
                8'h31: begin r_data_out[3:0]    <= 4'h1;    end
                8'h32: begin r_data_out[3:0]    <= 4'h2;    end
                8'h33: begin r_data_out[3:0]    <= 4'h3;    end
                8'h34: begin r_data_out[3:0]    <= 4'h4;    end
                8'h35: begin r_data_out[3:0]    <= 4'h5;    end
                8'h36: begin r_data_out[3:0]    <= 4'h6;    end
                8'h37: begin r_data_out[3:0]    <= 4'h7;    end
                8'h38: begin r_data_out[3:0]    <= 4'h8;    end
                8'h39: begin r_data_out[3:0]    <= 4'h9;    end
                8'h41: begin r_data_out[3:0]    <= 4'hA;    end
                8'h42: begin r_data_out[3:0]    <= 4'hB;    end
                8'h43: begin r_data_out[3:0]    <= 4'hC;    end
                8'h44: begin r_data_out[3:0]    <= 4'hD;    end
                8'h45: begin r_data_out[3:0]    <= 4'hE;    end
                8'h46: begin r_data_out[3:0]    <= 4'hF;    end
                8'h57: begin r_state            <= 3'b100;  end
                8'h52: begin r_state            <= 3'b010;  end
                8'h20: begin r_text             <= 3'b100;  end
                8'h0D: begin r_text             <= 3'b010;  end
                8'h0A: begin r_text             <= 3'b001;  end
                default: begin r_state          <= 3'b001;  end
            endcase
            r_done <= 1'b1;
        end else begin
            r_data_out  <= 4'h0;
            r_done      <= 1'b0;
            r_state     <= 3'b0;
            r_text      <= 3'b0;
        end
    end

    assign UART_DEC_DATA        = r_data_out;
    assign UART_DEC_DVLD        = r_done;
    assign UART_DEC_STATE       = r_state;
    assign UART_DEC_TEXT        = r_text;

endmodule