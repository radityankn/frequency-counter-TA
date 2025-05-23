//altpll bandwidth_type="LOW" CBX_DECLARE_ALL_CONNECTED_PORTS="OFF" clk0_divide_by=1 clk0_duty_cycle=20 clk0_multiply_by=2 clk0_phase_shift="0" clk1_divide_by=1 clk1_duty_cycle=20 clk1_multiply_by=2 clk1_phase_shift="2000" clk2_divide_by=1 clk2_duty_cycle=20 clk2_multiply_by=2 clk2_phase_shift="4000" clk3_divide_by=1 clk3_duty_cycle=20 clk3_multiply_by=2 clk3_phase_shift="6000" clk4_divide_by=1 clk4_duty_cycle=20 clk4_multiply_by=2 clk4_phase_shift="8000" compensate_clock="CLK0" device_family="MAX 10" inclk0_input_frequency=20000 intended_device_family="MAX 10" lpm_hint="CBX_MODULE_PREFIX=pll_module" operation_mode="normal" pll_type="AUTO" port_clk0="PORT_USED" port_clk1="PORT_USED" port_clk2="PORT_USED" port_clk3="PORT_USED" port_clk4="PORT_USED" port_clk5="PORT_UNUSED" port_extclk0="PORT_UNUSED" port_extclk1="PORT_UNUSED" port_extclk2="PORT_UNUSED" port_extclk3="PORT_UNUSED" port_inclk1="PORT_UNUSED" port_phasecounterselect="PORT_UNUSED" port_phasedone="PORT_UNUSED" port_scandata="PORT_UNUSED" port_scandataout="PORT_UNUSED" self_reset_on_loss_lock="OFF" width_clock=5 clk inclk locked CARRY_CHAIN="MANUAL" CARRY_CHAIN_LENGTH=48
//VERSION_BEGIN 24.1 cbx_altclkbuf 2025:03:05:20:03:09:SC cbx_altiobuf_bidir 2025:03:05:20:03:09:SC cbx_altiobuf_in 2025:03:05:20:03:09:SC cbx_altiobuf_out 2025:03:05:20:03:09:SC cbx_altpll 2025:03:05:20:03:09:SC cbx_cycloneii 2025:03:05:20:03:09:SC cbx_lpm_add_sub 2025:03:05:20:03:09:SC cbx_lpm_compare 2025:03:05:20:03:09:SC cbx_lpm_counter 2025:03:05:20:03:09:SC cbx_lpm_decode 2025:03:05:20:03:09:SC cbx_lpm_mux 2025:03:05:20:03:09:SC cbx_mgl 2025:03:05:20:10:25:SC cbx_nadder 2025:03:05:20:03:09:SC cbx_stratix 2025:03:05:20:03:09:SC cbx_stratixii 2025:03:05:20:03:09:SC cbx_stratixiii 2025:03:05:20:03:09:SC cbx_stratixv 2025:03:05:20:03:09:SC cbx_util_mgl 2025:03:05:20:03:09:SC  VERSION_END
//CBXI_INSTANCE_NAME="top_level_pll_module_pll_module_inst_altpll_altpll_component"
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2025  Altera Corporation. All rights reserved.
//  Your use of Altera Corporation's design tools, logic functions 
//  and other software and tools, and any partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Altera Program License 
//  Subscription Agreement, the Altera Quartus Prime License Agreement,
//  the Altera IP License Agreement, or other applicable license
//  agreement, including, without limitation, that your use is for
//  the sole purpose of programming logic devices manufactured by
//  Altera and sold by Altera or its authorized distributors.  Please
//  refer to the Altera Software License Subscription Agreements 
//  on the Quartus Prime software download page.



//synthesis_resources = fiftyfivenm_pll 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  pll_module_altpll
	( 
	clk,
	inclk,
	locked) /* synthesis synthesis_clearbox=1 */;
	output   [4:0]  clk;
	input   [1:0]  inclk;
	output   locked;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   [1:0]  inclk;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [4:0]   wire_pll1_clk;
	wire  wire_pll1_fbout;
	wire  wire_pll1_locked;

	fiftyfivenm_pll   pll1
	( 
	.activeclock(),
	.clk(wire_pll1_clk),
	.clkbad(),
	.fbin(wire_pll1_fbout),
	.fbout(wire_pll1_fbout),
	.inclk(inclk),
	.locked(wire_pll1_locked),
	.phasedone(),
	.scandataout(),
	.scandone(),
	.vcooverrange(),
	.vcounderrange()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.areset(1'b0),
	.clkswitch(1'b0),
	.configupdate(1'b0),
	.pfdena(1'b1),
	.phasecounterselect({3{1'b0}}),
	.phasestep(1'b0),
	.phaseupdown(1'b0),
	.scanclk(1'b0),
	.scanclkena(1'b1),
	.scandata(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		pll1.bandwidth_type = "low",
		pll1.clk0_divide_by = 1,
		pll1.clk0_duty_cycle = 20,
		pll1.clk0_multiply_by = 2,
		pll1.clk0_phase_shift = "0",
		pll1.clk1_divide_by = 1,
		pll1.clk1_duty_cycle = 20,
		pll1.clk1_multiply_by = 2,
		pll1.clk1_phase_shift = "2000",
		pll1.clk2_divide_by = 1,
		pll1.clk2_duty_cycle = 20,
		pll1.clk2_multiply_by = 2,
		pll1.clk2_phase_shift = "4000",
		pll1.clk3_divide_by = 1,
		pll1.clk3_duty_cycle = 20,
		pll1.clk3_multiply_by = 2,
		pll1.clk3_phase_shift = "6000",
		pll1.clk4_divide_by = 1,
		pll1.clk4_duty_cycle = 20,
		pll1.clk4_multiply_by = 2,
		pll1.clk4_phase_shift = "8000",
		pll1.compensate_clock = "clk0",
		pll1.inclk0_input_frequency = 20000,
		pll1.operation_mode = "normal",
		pll1.pll_type = "auto",
		pll1.self_reset_on_loss_lock = "off",
		pll1.lpm_type = "fiftyfivenm_pll";
	assign
		clk = {wire_pll1_clk[4:0]},
		locked = wire_pll1_locked;
endmodule //pll_module_altpll
//VALID FILE
