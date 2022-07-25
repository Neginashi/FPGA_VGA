`timescale 1ns / 1ps

module REGISTER (
    // system signals
    input   wire                        CLK_100M                                , // (i) clock 100MHz
    input   wire                        SYS_RST                                 , // (i) system reset (high-active)

    // input signals
    input   wire[1:0]                   UART_STATE                              , // (i) UART_CTRL state signal

    input   wire[31:0]                  UART_DATA                               , // (i) UART_CTRL data
    input   wire[7:0]                   UART_ADDR                               , // (i) UART_CTRL address

    output  wire[1:0]                   REG_STATE                               , // (o) UART_REG state signal
    output  wire[31:0]                  REG_DATA                                , // (o) UART_REG data

    output  wire                        REG_VGA_EN                              , // (o) VGA enable

    output  wire[1:0]                   REG_SELECT                              , // (o) VGA display source select

    output  wire                        REG_IMG_DVLD                            , // (o) output image data valid
    output  wire[15:0]                  REG_IMG_DATA                            , // (o) output image data

    output  wire[17:0]                  REG_ADDR                                  // (o) address image data store
    );

    // -------------------------------------------------------------
    // Internal signal definition
    // -------------------------------------------------------------
    // write
    reg                                 r_reg_write                             ; // write enable

    // read
    reg         [31:0]                  r_reg_data                              ; // data
    reg         [7:0]                   r_reg_addr                              ; // address
    reg                                 r_reg_read                              ; // read enable

    // register
    reg         [31:0]                  r_reg_reg_00                            ; // register 00 FPGA Version
    reg         [31:0]                  r_reg_reg_04                            ; // register 04 FPGA Date
    reg         [31:0]                  r_reg_reg_08                            ; // register 08 VGA ON/OFF
    reg         [31:0]                  r_reg_reg_0C                            ; // register 0C VGA select(0:input 1:Colorbar1　2:Colorbar2)
    reg         [31:0]                  r_reg_reg_10                            ; // register 10 input file write
    reg         [31:0]                  r_reg_reg_14                            ; // register 14 input store address(32h'00000/32h'20000)

    reg                                 r_reg_img_dvld                          ; // image data valid

// =============================================================================
// RTL Body
// =============================================================================
    // write in register
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_reg_reg_00    <= 32'b0;
            r_reg_reg_04    <= 32'b0;
            r_reg_reg_08    <= 32'b0;
            r_reg_reg_0C    <= 32'b0;
            r_reg_reg_10    <= 32'b0;
            r_reg_reg_14    <= 32'b0;
        end else begin
            if (UART_STATE[1]) begin
                case ( UART_ADDR )
                    8'h00 : begin
                        r_reg_reg_00 <= UART_DATA;
                        r_reg_reg_04 <= r_reg_reg_04;
                        r_reg_reg_08 <= r_reg_reg_08;
                        r_reg_reg_0C <= r_reg_reg_0C;
                        r_reg_reg_10 <= r_reg_reg_10;
                        r_reg_reg_14 <= r_reg_reg_14;
                    end

                    8'h04 : begin
                        r_reg_reg_00 <= r_reg_reg_00;
                        r_reg_reg_04 <= UART_DATA;
                        r_reg_reg_08 <= r_reg_reg_08;
                        r_reg_reg_0C <= r_reg_reg_0C;
                        r_reg_reg_10 <= r_reg_reg_10;
                        r_reg_reg_14 <= r_reg_reg_14;
                    end

                    8'h08 : begin
                        r_reg_reg_00 <= r_reg_reg_00;
                        r_reg_reg_04 <= r_reg_reg_04;
                        r_reg_reg_08 <= UART_DATA;
                        r_reg_reg_0C <= r_reg_reg_0C;
                        r_reg_reg_10 <= r_reg_reg_10;
                        r_reg_reg_14 <= r_reg_reg_14;
                    end

                    8'h0C : begin
                        r_reg_reg_00 <= r_reg_reg_00;
                        r_reg_reg_04 <= r_reg_reg_04;
                        r_reg_reg_08 <= r_reg_reg_08;
                        r_reg_reg_0C <= UART_DATA;
                        r_reg_reg_10 <= r_reg_reg_10;
                        r_reg_reg_14 <= r_reg_reg_14;
                    end

                    8'h10 : begin
                        r_reg_reg_00 <= r_reg_reg_00;
                        r_reg_reg_04 <= r_reg_reg_04;
                        r_reg_reg_08 <= r_reg_reg_08;
                        r_reg_reg_0C <= r_reg_reg_0C;
                        r_reg_reg_10 <= UART_DATA;
                        r_reg_reg_14 <= r_reg_reg_14;
                    end

                    8'h14 : begin
                        r_reg_reg_00 <= r_reg_reg_00;
                        r_reg_reg_04 <= r_reg_reg_04;
                        r_reg_reg_08 <= r_reg_reg_08;
                        r_reg_reg_0C <= r_reg_reg_0C;
                        r_reg_reg_10 <= r_reg_reg_10;
                        r_reg_reg_14 <= UART_DATA;
                    end

                    default : begin
                        r_reg_reg_00 <= r_reg_reg_00;
                        r_reg_reg_04 <= r_reg_reg_04;
                        r_reg_reg_08 <= r_reg_reg_08;
                        r_reg_reg_0C <= r_reg_reg_0C;
                        r_reg_reg_10 <= r_reg_reg_10;
                        r_reg_reg_14 <= r_reg_reg_14;
                    end

                endcase
            end else begin
                r_reg_reg_00 <= r_reg_reg_00;
                r_reg_reg_04 <= r_reg_reg_04;
                r_reg_reg_08 <= r_reg_reg_08;
                r_reg_reg_0C <= r_reg_reg_0C;
                r_reg_reg_10 <= r_reg_reg_10;
                r_reg_reg_14 <= r_reg_reg_14;
            end
        end
    end

    // write address
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_reg_addr <= 8'h0;
        end else begin
            if (UART_STATE[1]) begin
                r_reg_addr <= UART_ADDR;
            end else begin
                r_reg_addr <= 8'h0;
            end
        end
    end

    // write enable
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_reg_write <= 1'b0;
        end else begin
            if (UART_STATE[1]) begin
                r_reg_write <= 1'b1;
            end else begin
                r_reg_write <= 1'b0;
            end
        end
    end

    // img data valid
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_reg_img_dvld <= 1'b0;
        end else begin
            if (r_reg_write && r_reg_addr == 8'h10) begin
                r_reg_img_dvld <= 1'b1;
            end else begin
                r_reg_img_dvld <= 1'b0;
            end
        end
    end

    // read from register
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_reg_data  <= 32'b0;
            r_reg_read  <= 1'b0;
        end else begin
            if (UART_STATE[0]) begin
                r_reg_read  <= 1'b1;
                if (UART_ADDR == 8'h00) begin
                    r_reg_data <= r_reg_reg_00;
                end else if (UART_ADDR == 8'h04) begin
                    r_reg_data <= r_reg_reg_04;
                end else if (UART_ADDR == 8'h10) begin
                    r_reg_data <= r_reg_reg_10;
                end
            end else begin
                r_reg_data  <= 32'b0;
                r_reg_read  <= 1'b0;
            end
        end
    end

    assign REG_STATE[0]         = r_reg_read;
    assign REG_STATE[1]         = r_reg_write;
    assign REG_DATA             = r_reg_data;
    assign REG_VGA_EN           = r_reg_reg_08[0];
    assign REG_SELECT           = {r_reg_reg_0C[4], r_reg_reg_0C[0]};
    assign REG_IMG_DVLD         = r_reg_img_dvld;
    assign REG_IMG_DATA[2:0]    = r_reg_reg_10[7:5];
    assign REG_IMG_DATA[5:3]    = r_reg_reg_10[15:13];
    assign REG_IMG_DATA[15:6]   = r_reg_reg_10[30:21];
    assign REG_ADDR             = r_reg_reg_14[17:0];

endmodule