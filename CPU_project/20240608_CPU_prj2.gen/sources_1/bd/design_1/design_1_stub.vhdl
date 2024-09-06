-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
-- Date        : Thu Jun 13 17:23:17 2024
-- Host        : DESKTOP-7CFQ9ND running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/FPGA_RISC/20240608_CPU_prj2/20240608_CPU_prj2.gen/sources_1/bd/design_1/design_1_stub.vhdl
-- Design      : design_1
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1 is
  Port ( 
    diff_clock_rtl_clk_n : in STD_LOGIC;
    diff_clock_rtl_clk_p : in STD_LOGIC;
    reset : in STD_LOGIC
  );

end design_1;

architecture stub of design_1 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "diff_clock_rtl_clk_n,diff_clock_rtl_clk_p,reset";
begin
end;
