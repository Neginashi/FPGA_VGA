`timescale 1ns / 1ps

module SRAM_CTRL (
    // system signals
    input   wire                        CLK_100M                                , // (i) clock 100MHz
    input   wire                        CLK_40M                                 , // (i) clock 40MHz
    input   wire                        SYS_RST                                 , // (i) system reset (high-active)

    input   wire                        REG_VGA_EN                              , // (i)
    input   wire[1:0]                   REG_SELECT                              ,

    input   wire                        SLCT_IN_DVLD                            , // (i) SELECT_IN data valid
    input   wire[15:0]                  SLCT_IN_DATA                            , // (i) SELECT_IN data
    input   wire[17:0]                  SLCT_IN_ADDR                            , // (i) address image data store

    input   wire                        SLCT_OUT_REQ                            , // (i) SELECT_OUT data request
    input   wire                        VGA_VSYNC                               , // (i) VGA VSYNC signal
    input   wire                        VGA_HSYNC                               , // (i) VGA HSYNC signal

    output  wire                        SRAM_CE                                 , // (o) SRAM chip enable
    output  wire                        SRAM_WE                                 , // (o) SRAM write enable
    output  wire                        SRAM_UB                                 , // (o) SRAM upper-byte enable
    output  wire                        SRAM_LB                                 , // (o) SRAM lower-byte enable
    output  wire[17:0]                  SRAM_ADDR                               , // (o) SRAM address
    inout   wire[15:0]                  SRAM_DATA                               , // (o) SRAM data
    output  wire                        SRAM_OE                                 , // (o) SRAM output enable

    output  wire                        SRAM_CTRL_DVLD                          , // (o) SRAM_CTRL data valid
    output  wire[15:0]                  SRAM_CTRL_DATA                            // (o) SRAM_CTRL data
    );

    parameter                           P_IMG_PIXEL             = 17'd120000    ; // one image 400 X 300 pixels
    parameter                           P_IMG_LINE              = 10'd400       ; // one line 400 pixels
    parameter                           P_IMG_ROW               = 10'd300       ; // one row 300 pixels

    parameter                           P_VGA_LINE              = 10'd800       ; // VGA display one line 800 pixels
    parameter                           P_VGA_ROW               = 10'd600       ; // VGA display one row 600 pixels
    parameter                           P_VGA_HSYNC             = 10'd628       ;

    reg         [1:0]                   r_slct_delay                            ;

    reg                                 r_sram_ce                               ; // SRAM chip enable
    reg         [17:0]                  r_sram_addr                            ; // SRAM write address
    reg                                 r_sram_we_ff                               ; // SRAM write enable
    reg                                 r_sram_we                               ; // SRAM write enable
    reg         [16:0]                  r_sram_wcnt                             ; // SRAM write count
    reg         [17:0]                  r_sram_waddr                            ; // SRAM write address
    reg                                 r_sram_addren                            ; // SRAM write address
    reg         [15:0]                  r_sram_wdata                            ; // SRAM write data
    reg         [15:0]                  r_sram_dataen                            ; // SRAM write data
    reg         [15:0]                  r_sram_wdata_ff                            ; // SRAM write data

    reg         [9:0]                   r_bram_rcnt                             ; // BRAM read count
    reg         [9:0]                   r_bram_rcnt_delay                             ; // BRAM read count
    reg                                 r_bram_ren                              ; // BRAM read enable
    reg                                 r_bram_rsw                              ; // BRAM read switch
    reg         [10:0]                  r_bram_raddr                            ;

    reg                                 r_vsync_delay                           ; // VSYNC delay
    reg                                 r_hsync_delay                           ; // HSYNC delay
    reg         [9:0]                   r_hsync_cnt                             ;

    reg                                 r_sram_oe                               ; // SRAM output enable
    reg                                 r_sram_oe_ff1                               ; // SRAM output enable
    reg                                 r_sram_oe_ff2                               ; // SRAM output enable
    reg         [17:0]                  r_sram_raddr                            ; // SRAM read address
    reg         [17:0]                  r_sram_raddr_ff                            ; // SRAM read address
    reg         [15:0]                  r_sram_rdata                            ;
    reg         [8:0]                   r_sram_pcnt                             ; // SRAM pixel count
    reg         [9:0]                   r_sram_rcnt                             ; // SRAM row count
    reg         [16:0]                  r_sram_row_addr                         ; // SRAM row address

   // reg                                 r_bram_en                               ;
    reg         [10:0]                  r_bram_dwcnt                            ;
    reg         [10:0]                  r_bram_dwcnt_delay                      ;

    reg         [1:0]                   r_bram_lcnt                             ; // BRAN line count
    reg         [9:0]                   r_bram_wcnt                             ; // BRAM write count
    reg         [9:0]                   r_bram_wcnt_ff1                             ; // BRAM write count
    reg         [9:0]                   r_bram_wcnt_ff2                             ; // BRAM write count
    reg                                 r_bram_we                               ; // BRAM write enable
    reg                                 r_bram_we_ff1                               ; // BRAM write enable
    reg                                 r_bram_we_ff2                               ; // BRAM write enable
    reg                                 r_bram_wsw                              ; // BRAM write switch
    reg         [10:0]                  r_bram_waddr                            ;
    reg         [10:0]                  r_bram_waddr_ff                            ;

    reg                                 r_sram_ctrl_dvld                             ; // SRAM data valid
    reg                                 r_sram_ctrl_dvld_ff                             ; // SRAM data valid
    reg         [15:0]                  r_sram_ctrl_data                             ; // SRAM data

    reg                                 r_bram_wpls_100m                        ;
    reg                                 r_bram_rpls_40m                         ;

    wire                                s_bram_wpls_100m                        ;
    wire                                s_bram_wpls_40m                         ;

    wire        [15:0]                  s_bram_rdata                            ; // BRAM read data
    wire        [10:0]                  s_bram_raddr                            ; // BRAM read address
    wire                                s_bram_ren                              ; // BRAM read enable

    wire        [15:0]                  s_bram_wdata                            ; // BRAM write data
    wire        [10:0]                  s_bram_waddr                            ; // BRAM write address
    wire                                s_bram_we                               ; // BRAM write enable

    // =========================================================================
    // |                            SRAM write                                 |
    // =========================================================================
    // REG_SELECT delay
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_slct_delay <= 2'b0;
        end else begin
            r_slct_delay <= REG_SELECT;
        end
    end

    // SRAM chip enable
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_ce <= 1'b0;
        end else begin
            r_sram_ce <= 1'b1;
        end
    end

    assign SRAM_CE = r_sram_ce ? 1'b0 : 1'b1;
    assign SRAM_UB = r_sram_ce ? 1'b0 : 1'b1;
    assign SRAM_LB = r_sram_ce ? 1'b0 : 1'b1;

    // SRAM write enable
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_we <= 1'b0;
        end else begin
            if (SLCT_IN_DVLD) begin
                r_sram_we <= 1'b1;
            end else begin
                r_sram_we <= 1'b0;
            end
        end
    end

    // SRAM write enable
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_dataen <= 16'hFFFF;
        end else begin
            if (r_sram_we) begin
                r_sram_dataen <= 16'h0;
            end else begin
                r_sram_dataen <= 16'hFFFF;
            end
        end
    end

    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_we_ff <= 1'b1;
        end else begin
            r_sram_we_ff <= ~r_sram_we;
        end
    end

    assign SRAM_WE = r_sram_we_ff;

    // SRAM write counter
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_wcnt <= 17'd0;
        end else begin
            if (r_slct_delay != REG_SELECT) begin
                r_sram_wcnt <= 17'd0;
            end else if (SLCT_IN_DVLD) begin
                if (r_sram_wcnt == P_IMG_PIXEL - 1) begin
                    r_sram_wcnt <= 17'd0;
                end else begin
                    r_sram_wcnt <= r_sram_wcnt + 17'd1;
                end
            end
        end
    end

    // SRAM write address
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_waddr <= 18'd0;
        end else begin
            r_sram_waddr <= r_sram_wcnt + SLCT_IN_ADDR;
        end
    end

    // SRAM write data
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_wdata <= 16'd0;
        end else begin
            if (SLCT_IN_DVLD) begin
                r_sram_wdata <= SLCT_IN_DATA;
            end
        end
    end

    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_wdata_ff <= 16'd0;
        end else begin
            r_sram_wdata_ff <= r_sram_wdata;
        end
    end

    generate
        genvar i;
        for ( i = 0; i <= 15; i = i + 1 )
        begin: data_loop
            assign SRAM_DATA[i] = r_sram_dataen[i] ? 1'bz : r_sram_wdata_ff[i];
        end
    endgenerate

    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_addr <= 18'b0;
        end else begin
            if (r_sram_we) begin
                r_sram_addr <= r_sram_waddr;
            end else if (r_sram_oe) begin
                r_sram_addr <= r_sram_raddr;
            end
        end
    end

    assign SRAM_ADDR = r_sram_addr;

    // =========================================================================
    // |                            SRAM read                                  |
    // =========================================================================
    // SRAM output enable
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_oe <= 1'b0;
        end else begin
            if (r_sram_ce) begin
                if (r_bram_dwcnt[9:1] != r_bram_dwcnt_delay[9:1] && r_bram_lcnt <= 2'b1 && r_bram_dwcnt <= P_VGA_LINE + P_VGA_LINE - 1) begin
                    r_sram_oe <= 1'b1;
                end else begin
                    r_sram_oe <= 1'b0;
                end
            end
        end
    end

    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_oe_ff1 <= 1'b0;
            r_sram_oe_ff2 <= 1'b0;
        end else begin
            r_sram_oe_ff1 <= ~r_sram_oe;
            r_sram_oe_ff2 <= r_sram_oe_ff1;
        end
    end

    assign SRAM_OE = r_sram_oe_ff2;

    // SRAM switch
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_raddr[17] <= 1'd0;
        end else begin
            if (r_sram_rcnt <= P_IMG_ROW - 1) begin
                if (r_hsync_cnt == P_VGA_HSYNC - 1) begin
                    r_sram_raddr[17] <= 1'd0;
                end else if (r_bram_wcnt <= P_IMG_LINE - 1) begin
                    r_sram_raddr[17] <= 1'd0;
                end else if (r_bram_wcnt <= P_VGA_LINE - 1) begin
                    r_sram_raddr[17] <= 1'd1;
                end
            end else if (r_sram_rcnt <= P_VGA_ROW - 1) begin
                if (r_hsync_cnt == P_VGA_HSYNC - 1) begin
                    r_sram_raddr[17] <= 1'd1;
                end else if (r_bram_wcnt <= P_IMG_LINE - 1) begin
                    r_sram_raddr[17] <= 1'd1;
                end else if (r_bram_wcnt <= P_VGA_LINE - 1) begin
                    r_sram_raddr[17] <= 1'd0;
                end
            end
        end
    end

    // SRAM pixel counter
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_pcnt <= 9'd0;
        end else begin
            if (r_hsync_cnt == P_VGA_HSYNC - 1) begin
                r_sram_pcnt <= 9'd0;
            end else if (r_sram_oe) begin
                if (r_sram_pcnt == P_IMG_LINE - 1) begin
                    r_sram_pcnt <= 9'd0;
                end else begin
                    r_sram_pcnt <= r_sram_pcnt + 9'd1;
                end
            end
        end
    end

    // SRAM read row counter
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_rcnt <= 10'd0;
        end else begin
            if (r_hsync_cnt == P_VGA_HSYNC - 1) begin
                r_sram_rcnt <= 10'd0;
            end else if (r_bram_dwcnt == P_VGA_LINE + P_VGA_LINE - 1) begin
                if (r_sram_rcnt == P_VGA_ROW - 1) begin
                    r_sram_rcnt <= 10'd0;
                end else begin
                    r_sram_rcnt <= r_sram_rcnt + 10'd1;
                end
            end
        end
    end

    // SRAM read row address
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_row_addr <= 17'd0;
        end else begin
            if (r_hsync_cnt == P_VGA_HSYNC - 1) begin
                r_sram_row_addr <= 17'd0;
            end else begin
                if (r_bram_dwcnt == P_VGA_LINE + P_VGA_LINE - 1) begin
                    if (r_sram_row_addr == P_IMG_PIXEL - P_IMG_LINE) begin
                        r_sram_row_addr <= 17'd0;
                    end else begin
                        r_sram_row_addr <= r_sram_row_addr + P_IMG_LINE;
                    end
                end
            end
        end
    end

    // SRAM read address
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_raddr[16:0] <= 17'd0;
        end else begin
            if (r_hsync_cnt == P_VGA_HSYNC - 1) begin
                r_sram_raddr[16:0] <= 17'd0;
            end else begin
                r_sram_raddr[16:0] <= r_sram_row_addr + r_sram_pcnt;
            end
        end
    end

    // SRAM read data
    always @(posedge CLK_100M) begin
        r_sram_rdata <= SRAM_DATA;
    end

    //--------------------------------------------------------------------------------------
    LINE_BUF  LINE_BUF (
        .clka                           ( CLK_100M              ),
        .wea                            ( s_bram_we             ),
        .addra                          ( s_bram_waddr          ),
        .dina                           ( s_bram_wdata          ),
        .clkb                           ( CLK_40M               ),
        .enb                            ( s_bram_ren            ),
        .addrb                          ( s_bram_raddr          ),
        .doutb                          ( s_bram_rdata          )
    );

    //--------------------------------------------------------------------------------------
    //--------------------------------------------------------------------------------------
    PULSE_GEN  PULSE_GEN (
        .XRST                           (  SYS_RST              ),
        .CLK_I                          (  CLK_100M             ),
        .CLK_O                          (  CLK_40M              ),
        .PULSE_I                        (  s_bram_wpls_100m     ),
        .PULSE_O                        (  s_bram_wpls_40m      )
    );

    //--------------------------------------------------------------------------------------
    //// BRAM enable
    //always @(posedge CLK_100M or posedge SYS_RST) begin
    //    if (SYS_RST) begin
    //        // reset
    //        r_bram_en <= 1'b0;
    //    end else begin
    //        r_bram_en <= 1'b1;
    //    end
    //end

    // bram write pulse 100MHz
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_wpls_100m <= 1'b0;
        end else begin
            if (r_bram_dwcnt == P_VGA_LINE + P_VGA_LINE - 1) begin
                r_bram_wpls_100m <= 1'b1;
            end else begin
                r_bram_wpls_100m <= 1'b0;
            end
        end
    end

    assign s_bram_wpls_100m = r_bram_wpls_100m;

    // bram read pulse 40MHz
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_rpls_40m <= 1'b0;
        end else begin
            if (r_bram_rcnt == P_VGA_LINE - 1) begin
                r_bram_rpls_40m <= 1'b1;
            end else begin
                r_bram_rpls_40m <= 1'b0;
            end
        end
    end

    // BRAM line counter
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_lcnt <= 2'd0;
        end else begin
            if (r_hsync_cnt == P_VGA_HSYNC - 1) begin
                r_bram_lcnt <= 2'd0;
            end else if (s_bram_wpls_40m) begin
                r_bram_lcnt <= r_bram_lcnt + 2'd1;
            end else if (r_bram_rpls_40m) begin
                r_bram_lcnt <= r_bram_lcnt - 2'd1;
            end
        end
    end

    // =========================================================================
    // |                            BRAM write                                 |
    // =========================================================================

    // Bram write double counter
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_dwcnt <= P_VGA_LINE + P_VGA_LINE;
        end else begin
            if (r_bram_lcnt <= 2'd1) begin
                if (VGA_HSYNC == 1'b1 && r_hsync_delay == 1'b0) begin
                    r_bram_dwcnt <= 11'd0;
                end else if (r_bram_dwcnt <= P_VGA_LINE + P_VGA_LINE - 1) begin
                    r_bram_dwcnt <= r_bram_dwcnt + 1'd1;
                end
            end
        end
    end

    always @(posedge CLK_100M) begin
        r_bram_dwcnt_delay <= r_bram_dwcnt;
    end

    // BRAM write counter
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_wcnt <= P_VGA_LINE;
        end else begin
            if (r_bram_lcnt <= 2'd1) begin
                if (VGA_HSYNC == 1'b1 && r_hsync_delay == 1'b0) begin
                    r_bram_wcnt <= 10'd0;
                end else if (r_bram_wcnt <= P_VGA_LINE - 1 && r_bram_dwcnt[10:1] != r_bram_dwcnt_delay[10:1]) begin
                    r_bram_wcnt <= r_bram_wcnt + 10'd1;
                end
            end
        end
    end

    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_wcnt_ff1 <= 10'd0;
            r_bram_wcnt_ff2 <= 10'd0;
        end else begin
            r_bram_wcnt_ff1 <= r_bram_wcnt;
            r_bram_wcnt_ff2 <= r_bram_wcnt_ff1;
        end
    end

    // BRAM write line switch
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_wsw <= 1'b0;
        end else begin
            if (r_hsync_cnt == P_VGA_HSYNC - 1) begin
                r_bram_wsw <= 1'b0;
            end else if (VGA_HSYNC == 1'b1 && r_hsync_delay == 1'b0) begin
                r_bram_wsw <= ~r_bram_wsw;
            end
        end
    end

    // BRAM write address
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_waddr <= 11'b0;
        end else begin
            r_bram_waddr <= { r_bram_wsw, r_bram_wcnt_ff1 };
        end
    end

    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_waddr_ff <= 11'd0;
        end else begin
            r_bram_waddr_ff <= r_bram_waddr;
        end
    end

    // BRAM write enable
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_we <= 1'b0;
        end else begin
            if (r_bram_wcnt <= P_VGA_LINE - 1 && r_sram_oe) begin
                r_bram_we <= 1'b1;
            end else begin
                r_bram_we <= 1'b0;
            end
        end
    end

    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_we_ff1 <= 1'b0;
            r_bram_we_ff2 <= 1'b0;
        end else begin
            r_bram_we_ff1 <= r_bram_we;
            r_bram_we_ff2 <= r_bram_we_ff1;
        end
    end

    // BRAM write data
    assign s_bram_wdata = r_sram_rdata;
    assign s_bram_waddr = r_bram_waddr_ff;
    assign s_bram_we    = r_bram_we_ff2;

    // =========================================================================
    // |                            BRAM read                                  |
    // =========================================================================
    // BRAM read counter
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_rcnt <= 10'd0;
        end else begin
            if (SLCT_OUT_REQ) begin
                r_bram_rcnt <= 10'd0;
            end else if (r_bram_ren && r_bram_rcnt <= P_VGA_LINE - 1) begin
                r_bram_rcnt <= r_bram_rcnt + 10'd1;
            end
        end
    end

    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_rcnt_delay <= 10'd0;
        end else begin
            r_bram_rcnt_delay <= r_bram_rcnt;
        end
    end

    // BRAM read enable
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_ren <= 1'b0;
        end else begin
            if (SLCT_OUT_REQ) begin
                r_bram_ren <= 1'b1;
            end else if (r_bram_rcnt == P_VGA_LINE - 1) begin
                r_bram_ren <= 1'b0;
            end
        end
    end

    // BRAM read line switch
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_bram_rsw <= 1'b1;
        end else begin
            if (r_hsync_cnt == P_VGA_HSYNC - 1) begin
                r_bram_rsw <= 1'b1;
            end else if (SLCT_OUT_REQ) begin
                r_bram_rsw <= ~r_bram_rsw;
            end
        end
    end

    assign s_bram_raddr = { r_bram_rsw, r_bram_rcnt };
    assign s_bram_ren   = r_bram_ren;

    //--------------------------------------------------------------------------------------
    // VSYNC rising edge
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_vsync_delay <= 1'b0;
        end else begin
            r_vsync_delay <= VGA_VSYNC;
        end
    end

    // HSYNC rising edge
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_hsync_delay <= 1'b0;
        end else begin
            r_hsync_delay <= VGA_HSYNC;
        end
    end

    // HSYNC counter
    always @(posedge CLK_100M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_hsync_cnt <= P_VGA_HSYNC - 1;
        end else begin
            if (!REG_VGA_EN) begin
                r_hsync_cnt <= P_VGA_HSYNC - 1;
            end else if (VGA_VSYNC == 1'b1 && r_vsync_delay == 1'b0) begin
                r_hsync_cnt <= 10'd0;
            end else if (VGA_HSYNC == 1'b1 && r_hsync_delay == 1'b0) begin
                r_hsync_cnt <= r_hsync_cnt + 1'd1;
            end
        end
    end

    // =========================================================================
    // |                            SRAM CTRL                                  |
    // =========================================================================
    // SRAM_CTRL data valid
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_ctrl_dvld    <= 1'b0;
            r_sram_ctrl_dvld_ff <= 1'b0;
        end else begin
            r_sram_ctrl_dvld    <= r_bram_ren;
            r_sram_ctrl_dvld_ff <= r_sram_ctrl_dvld;
        end
    end

    // SRAM_CTRL data
    always @(posedge CLK_40M or posedge SYS_RST) begin
        if (SYS_RST) begin
            // reset
            r_sram_ctrl_data <= 16'b0;
        end else begin
            r_sram_ctrl_data <= s_bram_rdata;
        end
    end

    assign SRAM_CTRL_DVLD = r_sram_ctrl_dvld_ff;
    assign SRAM_CTRL_DATA = r_sram_ctrl_data;

endmodule