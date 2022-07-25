`timescale 1ns / 1ps

module COLORBAR_1 (
    // system signals
    input   wire                        CLK_100M                                , // (i) clock 100MHz
    input   wire                        SYS_RST                                 , // (i) system reset (high-active)

    input   wire[1:0]                   REG_SELECT                              , // (i) VGA display source select

    output  wire                        CLRB_1_DVLD                             , // (o) colorbar1 data valid
    output  wire[17:0]                  CLRB_1_ADDR                             , // (o) colorbar1 data valid
    output  wire[15:0]                  CLRB_1_DATA                               // (o) colorbar1 data
    );

    parameter                           P_LINE                  = 10'd400       ; // LINE 400 pixels
    parameter                           P_ROW                   = 10'd300       ; // ROW 300 pixels
    parameter                           P_ROW_2                 = 10'd600       ; // double ROW 600 pixels

    reg         [9:0]                   r_x_cnt                                 ; // LINE pixel count
    reg         [9:0]                   r_y_cnt                                 ; // ROW pixel count
    reg                                 r_dvld                                  ; // data vaild register
    reg         [15:0]                  r_data                                  ; // data register
    reg         [17:0]                  r_addr                                  ; // address register

    reg         [1:0]                   r_slct_delay                            ;
    reg                                 r_clrb1_en                              ;

    // REG_SELECT delay
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_slct_delay <= 2'b0;
        end else begin
            r_slct_delay <= REG_SELECT;
        end
    end

    // Colorbar1 enable
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_clrb1_en <= 1'b0;
        end else begin
            if ((REG_SELECT == 2'b01 && r_slct_delay == 2'b00) ||
                (REG_SELECT == 2'b01 && r_slct_delay == 2'b10)) begin
                r_clrb1_en <= 1'b1;
            end else if (r_y_cnt == P_ROW_2 - 1 && r_x_cnt == P_LINE - 1) begin
                r_clrb1_en <= 1'b0;
            end
        end
    end

    // LINE pixel counter
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_x_cnt <= 10'd0;
        end else begin
            if (r_clrb1_en == 1'b1) begin
                if (r_x_cnt == P_LINE - 1) begin
                    r_x_cnt <= 10'd0;
                end else begin
                    r_x_cnt <= r_x_cnt + 10'd1;
                end
            end else begin
                r_x_cnt <= 10'd0;
            end
        end
    end

    // ROW pixel counter
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_y_cnt <= 10'd0;
        end else begin
            if (r_clrb1_en == 1'b0) begin
                r_y_cnt <= 10'd0;
            end else if (r_clrb1_en == 1'b1 && r_x_cnt == P_LINE - 1) begin
                if (r_y_cnt <= P_ROW_2 - 1) begin
                    r_y_cnt <= r_y_cnt + 10'd1;
                end else begin
                    r_y_cnt <= r_y_cnt;
                end
            end
        end
    end

    // line data generate
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_data <= 16'h0000;
        end else begin
            if (r_clrb1_en == 1'b1 && r_y_cnt <= P_ROW - 1) begin
                if (r_x_cnt <= 10'd99 && r_x_cnt >= 10'd0) begin
                    r_data <= 16'h000F;
                end else if (r_x_cnt <= 10'd199 && r_x_cnt >= 10'd100) begin
                    r_data <= 16'h00F0;
                end else if (r_x_cnt <= 10'd299 && r_x_cnt >= 10'd200) begin
                    r_data <= 16'h0F00;
                end else if (r_x_cnt <= 10'd399 && r_x_cnt >= 10'd300) begin
                    r_data <= 16'h00FF;
                end else begin
                    r_data <= 16'h0000;
                end
            end else if (r_clrb1_en == 1'b1 && r_y_cnt <= P_ROW_2 - 1) begin
                if (r_x_cnt <= 10'd99 && r_x_cnt >= 10'd0) begin
                    r_data <= 16'h0F0F;
                end else if (r_x_cnt <= 10'd199 && r_x_cnt >= 10'd100) begin
                    r_data <= 16'h0FF0;
                end else if (r_x_cnt <= 10'd299 && r_x_cnt >= 10'd200) begin
                    r_data <= 16'h0FFF;
                end else if (r_x_cnt <= 10'd399 && r_x_cnt >= 10'd300) begin
                    r_data <= 16'h0000;
                end else begin
                    r_data <= 16'h0000;
                end
            end else begin
                r_data <= 16'h0000;
            end
        end
    end

    // line data vaild
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_dvld <= 1'b0;
        end else begin
            if (r_clrb1_en == 1'b1 && r_y_cnt <= P_ROW_2 - 1) begin
                r_dvld <= 1'b1;
            end else begin
                r_dvld <= 1'b0;
            end
        end
    end

    // line data address
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_addr <= 18'h0;
        end else begin
            if (r_clrb1_en == 1'b1 && r_y_cnt <= P_ROW - 1) begin
                r_addr <= 18'h0;
            end else if (r_clrb1_en == 1'b1 && r_y_cnt <= P_ROW_2 - 1) begin
                r_addr <= 18'h20000;
            end else begin
                r_addr <= 18'h00000;
            end
        end
    end

    assign CLRB_1_DVLD = r_dvld;
    assign CLRB_1_DATA = r_data;
    assign CLRB_1_ADDR = r_addr;

endmodule