// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Thu Jun 13 17:23:17 2024
// Host        : DESKTOP-7CFQ9ND running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/FPGA_RISC/20240608_CPU_prj2/20240608_CPU_prj2.gen/sources_1/bd/design_1/design_1_stub.v
// Design      : design_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module design_1(diff_clock_rtl_clk_n, diff_clock_rtl_clk_p, 
  reset)
/* synthesis syn_black_box black_box_pad_pin="diff_clock_rtl_clk_n,diff_clock_rtl_clk_p,reset" */;
  input diff_clock_rtl_clk_n;
  input diff_clock_rtl_clk_p;
  input reset;
endmodule
