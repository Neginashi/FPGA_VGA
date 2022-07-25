`timescale 1ns / 1ps

module COLORBAR_2 (
    // system signals
    input   wire                        CLK_40M                                 , // (i) clock 40MHz
    input   wire                        SYS_RST                                 , // (i) system reset (high-active)

    input   wire                        SLCT_OUT_REQ                            , // 
    
    input   wire[1:0]                   REG_SELECT                              ,

    output  wire                        CLRB_2_DVLD                             , // (o)
    output  wire[15:0]                  CLRB_2_DATA                               //
    );

    parameter                           P_LINE                    = 10'd800     ;
    parameter                           P_ROW                     = 10'd600     ;

    reg         [9:0]                   r_x_cnt                                 ;
    reg         [9:0]                   r_y_cnt                                 ;
    reg                                 r_dvld                                  ;
    reg         [15:0]                  r_data                                  ;

    // x counter
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_x_cnt <= P_LINE;
        end else begin
            if (REG_SELECT == 2'b10) begin
                if (SLCT_OUT_REQ) begin
                    r_x_cnt <= 10'd0;
                end else if (r_x_cnt <= P_LINE - 1) begin
                    r_x_cnt <= r_x_cnt + 10'd1;
                end
            end
        end
    end

    // y counter
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_y_cnt <= 10'd0;
        end else begin
            if (REG_SELECT == 2'b10 && r_x_cnt == P_LINE - 1) begin
                if (r_y_cnt == P_ROW - 1) begin
                    r_y_cnt <= 10'd0;
                end else begin
                    r_y_cnt <= r_y_cnt + 10'd1;
                end
            end
        end
    end

    // line data generate
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_dvld <= 1'b0;
            r_data <= 16'h0000;
        end else begin
            if (REG_SELECT == 2'b10 && r_x_cnt <= P_LINE - 1) begin
                r_dvld <= 1'b1;
                if (r_x_cnt <= 10'd99 && r_x_cnt >= 10'd0) begin
                    r_data <= 16'h0FFF;
                end else if (r_x_cnt <= 10'd199 && r_x_cnt >= 10'd100) begin
                    r_data <= 16'h0000;
                end else if (r_x_cnt <= 10'd299 && r_x_cnt >= 10'd200) begin
                    r_data <= 16'h0FF0;
                end else if (r_x_cnt <= 10'd399 && r_x_cnt >= 10'd300) begin
                    r_data <= 16'h0F0F;
                end else if (r_x_cnt <= 10'd499 && r_x_cnt >= 10'd400) begin
                    r_data <= 16'h00FF;
                end else if (r_x_cnt <= 10'd599 && r_x_cnt >= 10'd500) begin
                    r_data <= 16'h0F00;
                end else if (r_x_cnt <= 10'd699 && r_x_cnt >= 10'd600) begin
                    r_data <= 16'h00F0;
                end else if (r_x_cnt <= 10'd799 && r_x_cnt >= 10'd700) begin
                    r_data <= 16'h000F;
                end else begin
                    r_data <= 16'h0000;
                end
            end else begin
                r_dvld <= 1'b0;
                r_data <= 16'h0000;
            end
        end
    end

    assign CLRB_2_DVLD = r_dvld;
    assign CLRB_2_DATA = r_data;

endmodule