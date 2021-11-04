// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Thu Nov  4 20:10:04 2021
// Host        : LAPTOP-2GK32TES running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub c:/Users/admin/fyp/fyp.gen/sources_1/ip/clk_wizard/clk_wizard_stub.v
// Design      : clk_wizard
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wizard(clk50, clk25, reset, CLK100)
/* synthesis syn_black_box black_box_pad_pin="clk50,clk25,reset,CLK100" */;
  output clk50;
  output clk25;
  input reset;
  input CLK100;
endmodule
