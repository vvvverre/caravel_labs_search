# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

set ::env(PDK) $::env(PDK)
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_proj_example

set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/user_proj_example.v \
	$script_dir/../../verilog/rtl/calc_ck.v \
	$script_dir/../../verilog/rtl/calc_ck_split.v \
	$script_dir/../../verilog/rtl/gen_mask.v \
	$script_dir/../../verilog/rtl/square_accumulate.v \
	$script_dir/../../verilog/rtl/calc_e_pl.v \
	$script_dir/../../verilog/rtl/calc_e_buf.v \
	$script_dir/../../verilog/rtl/wb_interface_e.v \
	$script_dir/../../verilog/rtl/wb_calc_e.v \
	$script_dir/../../verilog/rtl/sync_fifo.v"

set ::env(DESIGN_IS_CORE) 0

set ::env(SYNTH_MAX_FANOUT) 12

set ::env(CTS_CLK_BUFFER_LIST) "sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_2"
set ::env(CTS_SINK_CLUSTERING_SIZE) "16"
set ::env(CLOCK_BUFFER_FANOUT) "16"

#set ::env(CTS_SINK_CLUSTERING_MAX_DIAMETER) 2000
set ::env(CTS_DISTANCE_BETWEEN_BUFFERS) 150

set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_NET) "wb_find.wb_clk_i"
set ::env(CLOCK_PERIOD) "8"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 2250 2250"

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 1
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_TARGET_DENSITY) 0.15

# Maximum layer used for routing is metal 4.
# This is because this macro will be inserted in a top level (user_project_wrapper) 
# where the PDN is planned on metal 5. So, to avoid having shorts between routes
# in this macro and the top level metal 5 stripes, we have to restrict routes to metal4.  
# 
set ::env(RT_MAX_LAYER) {met4}

# You can draw more power domains if you need to 
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

set ::env(DIODE_INSERTION_STRATEGY) 4 
# If you're going to use multiple power domains, then disable cvc run.
#set ::env(RUN_CVC) 1

if {[catch {exec nproc} result] == 0} {
	set ::env(ROUTING_CORES) $result
} else {
	set ::env(ROUTING_CORES) 24
}

