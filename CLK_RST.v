`timescale 1ns / 1ps

module CLK_RST (
    // signals from FPGA
    input   wire                        CLK_50M                                 , // (i) clock 50MHz
    input   wire                        RST_N                                   , // (i) reset (low-active)

    // system signals
    output  wire                        CLK_40M                                 , // (o) system clock 40MHz
    output  wire                        CLK_100M                                , // (o) system clock 100MHz
    output  wire                        SYS_RST                                   // (o) system reset (high-active)
    );

    // -------------------------------------------------------------
    // Internal signal definition
    // -------------------------------------------------------------
    // CLK_GEN signal
    wire                                s_locked_40M                                ; // DCM locked signal
    wire                                s_locked_80M                                ; // DCM locked signal
    wire                                s_rst_in                                ; // 15th r_rst_in as rst input to DCM

    // reset signal
    wire                                s_rst_h                                 ; // reset input (high-active)
    wire                                s_rst                                   ; // rst_in && locked

    // delay register
    reg         [15:0]                  r_rst_in                                ; // rst_in delay register
    reg         [15:0]                  r_rst_out                               ; // rst_out delay register

    assign s_rst_h = !RST_N ;

    // rst_in delay 16 clocks
    always @(posedge CLK_50M or posedge s_rst_h) begin
        if (s_rst_h) begin
            r_rst_in <= 16'hFFFF;
        end else begin
            r_rst_in <= { r_rst_in[14:0], 1'b0 };
        end
    end

    assign s_rst_in = r_rst_in[15] ;

    //BUFG  U_CLK_50M (
    //    .I                              ( CLK_50M               ),
    //    .O                              ( CLK_100M             )
    //);

   CLK_GEN  CLK_GEN (
       .CLKIN_IN                       ( CLK_50M               ),              // (i) clock 50M
       .RST_IN                         ( s_rst_in              ),              // (i) rst input to DCM

       .CLKFX_OUT                      ( CLK_40M               ),              // (o) system clock 40M
       //.CLK2X_OUT                      ( CLK_100M              ),              // (o) system clock 100M
       .LOCKED_OUT                     ( s_locked_40M              )               // (o) system reset (high-active)
   );

   CLK_GEN_80M  CLK_GEN_80M (
       .CLKIN_IN                       ( CLK_50M               ),              // (i) clock 50M
       .RST_IN                         ( s_rst_in              ),              // (i) rst input to DCM

       .CLKFX_OUT                      ( CLK_100M               ),              // (o) system clock 80M
       //.CLK2X_OUT                      ( CLK_100M              ),              // (o) system clock 100M
       .LOCKED_OUT                     ( s_locked_80M              )               // (o) system reset (high-active)
   );

    assign s_rst = s_rst_in && s_locked_40M && s_locked_80M;

    // rst_out delay register
    always @(posedge CLK_50M or posedge s_rst) begin
        if (s_rst) begin
            r_rst_out <= 16'hFFFF;
        end else begin
            r_rst_out <= { r_rst_out[14:0], 1'b0 };
        end
    end

    assign SYS_RST = r_rst_out[15];

endmodule