`timescale 1ns / 1ps

module VGA_CTRL (
    // system signals
    input   wire                        CLK_40M                                 , // (i) clock 40MHz
    input   wire                        SYS_RST                                 , // (i) system reset (high-active)

    input   wire                        REG_VGA_EN                              , // (i)
    input   wire[15:0]                  SLCT_OUT_DATA                           , // (i)

    output  wire[8:0]                   VGA_DATA                                , // (o)
    output  wire                        VGA_DE                                  ,
    output  wire                        VGA_HSYNC                               ,
    output  wire                        VGA_VSYNC                               ,
    output  wire                        VGA_REQ                                   // (o)
    );

    parameter                           P_HSYNC                 = 8'd128        ;
    parameter                           P_HBACK                 = 7'd88         ;
    parameter                           P_HDATA                 = 10'd800       ;
    parameter                           P_HFRONT                = 6'd40         ;
                                             
    parameter                           P_VSYNC                 = 3'd4          ;
    parameter                           P_VBACK                 = 5'd23         ;
    parameter                           P_VDATA                 = 10'd600       ;
    parameter                           P_VFRONT                = 1'd1          ;

    reg         [10:0]                  r_hcnt                                  ;
    reg         [9:0]                   r_vcnt                                  ;

    reg                                 r_hsync                                 ;
    reg                                 r_vsync                                 ;

    reg                                 r_vga_de                                ;
    reg         [8:0]                   r_data                                  ;

    reg                                 r_req                                   ;

    reg         [8:0]                   r_data_ff                               ;
    reg                                 r_vga_de_ff                             ;
    reg                                 r_hsync_ff                              ;
    reg                                 r_vsync_ff                              ;


    // HSYNC counter
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_hcnt <= 11'd0;
        end else begin
            if (REG_VGA_EN) begin
                if (r_hcnt == P_HSYNC + P_HBACK + P_HDATA + P_HFRONT - 1) begin
                    r_hcnt <= 11'd0;
                end else begin
                    r_hcnt <= r_hcnt + 11'd1;
                end
            end
        end
    end

    // VSYNC counter
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_vcnt <= 10'd0;
        end else begin
            if (REG_VGA_EN && r_hcnt == P_HSYNC + P_HBACK + P_HDATA + P_HFRONT - 1) begin
                if (r_vcnt == P_VSYNC + P_VBACK + P_VDATA + P_VFRONT - 1) begin
                    r_vcnt <= 10'd0;
                end else begin
                    r_vcnt <= r_vcnt + 10'd1;
                end
            end
        end
    end

    // HSYNC
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_hsync <= 1'b0;
        end else begin
            if (REG_VGA_EN && r_hcnt <= P_HSYNC - 1) begin
                r_hsync <= 1'b1;
            end else begin
                r_hsync <= 1'b0;
            end
        end
    end

    // VSYNC
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_vsync <= 1'b0;
        end else begin
            if (REG_VGA_EN && r_vcnt <= P_VSYNC - 1) begin
                r_vsync <= 1'b1;
            end else begin
                r_vsync <= 1'b0;
            end
        end
    end

    // VGA data enable
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_vga_de <= 1'b0;
        end else begin
            if (REG_VGA_EN && r_hcnt <= P_HSYNC + P_HBACK + P_HDATA - 1 && r_hcnt >= P_HSYNC + P_HBACK) begin
                r_vga_de <= 1'b1;
            end else begin
                r_vga_de <= 1'b0;
            end
        end
    end

    // VGA data
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_data <= 9'b0;
        end else begin
            if (REG_VGA_EN && r_hcnt <= P_HSYNC + P_HBACK + P_HDATA - 1 && r_hcnt >= P_HSYNC + P_HBACK) begin
                r_data <= SLCT_OUT_DATA[8:0];
            end else begin
                r_data <= 9'b0;
            end
        end
    end

    // VGA data request
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_req <= 1'b0;
        end else begin
            if (REG_VGA_EN &&
                r_hcnt == P_HSYNC + P_HBACK - 4 &&
                r_vcnt >= P_VSYNC + P_VBACK &&
                r_vcnt <= P_VSYNC + P_VBACK + P_VDATA - 1) begin
                r_req <= 1'b1;
            end else begin
                r_req <= 1'b0;
            end
        end
    end

    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_data_ff      <= 9'b0;
            r_vga_de_ff    <= 1'b0;
            r_hsync_ff     <= 1'b0;
            r_vsync_ff     <= 1'b0;
        end else begin
            r_data_ff      <= r_data;
            r_vga_de_ff    <= r_vga_de;
            r_hsync_ff     <= r_hsync;
            r_vsync_ff     <= r_vsync;
        end
    end

    assign VGA_DATA  =   r_data_ff  ;
    assign VGA_DE    =   r_vga_de_ff;
    assign VGA_HSYNC =   r_hsync_ff ;
    assign VGA_VSYNC =   r_vsync_ff ;
    assign VGA_REQ   =   r_req;

endmodule