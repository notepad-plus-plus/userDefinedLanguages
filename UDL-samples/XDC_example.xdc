###############################################################################
# Example XDC (Xilinx Design Constraints) File for Notepad++ UDL Testing
# Demonstrates syntax highlighting for clocks, I/O pins, timing, and Tcl script
###############################################################################

# -----------------------------------------------------------------------------
# 1. Device Configuration & Operating Voltage
# -----------------------------------------------------------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

# -----------------------------------------------------------------------------
# 2. Primary Clocks & Generated Clocks
# -----------------------------------------------------------------------------
# 100 MHz System Clock (Period = 10.000 ns, 50% Duty Cycle)
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports sys_clk]

# 200 MHz Differential Reference Clock
create_clock -period 5.000 -name ref_clk_200mhz [get_ports clk_200_p]

# Generated Clock from MMCM / PLL output
create_generated_clock -name clk_core \
    -source [get_pins u_clk_wiz/inst/mmcm_adv_inst/CLKIN1] \
    -divide_by 2 \
    [get_pins u_clk_wiz/inst/mmcm_adv_inst/CLKOUT0]

# -----------------------------------------------------------------------------
# 3. Asynchronous Clock Groups
# -----------------------------------------------------------------------------
set_clock_groups -asynchronous \
    -group [get_clocks sys_clk_pin] \
    -group [get_clocks -include_replicated_objects clk_core]

# -----------------------------------------------------------------------------
# 4. Pin Placement & I/O Standards (set_property -dict)
# -----------------------------------------------------------------------------
# System Clock and Reset
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports sys_clk]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33 PULLUP true} [get_ports rst_n]

# LEDs (Active High, 3.3V LVCMOS, Slew Rate and Drive Strength)
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 8} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {led[3]}]

# High-speed Differential I/O (TMDS / LVDS)
set_property -dict {PACKAGE_PIN D14 IOSTANDARD TMDS_33} [get_ports tmds_clk_p]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD TMDS_33} [get_ports tmds_clk_n]

# -----------------------------------------------------------------------------
# 5. Timing Constraints: Input/Output Delays & Exceptions
# -----------------------------------------------------------------------------
# Setup & Hold constraints on external SPI bus
set_input_delay -clock [get_clocks sys_clk_pin] -max 3.500 [get_ports spi_miso]
set_input_delay -clock [get_clocks sys_clk_pin] -min 0.500 [get_ports spi_miso]
set_output_delay -clock [get_clocks sys_clk_pin] -max 2.000 [get_ports spi_mosi]

# False paths for asynchronous reset & static user switches
set_false_path -from [get_ports rst_n]
set_false_path -to [get_ports {led[*]}]

# Multicycle path for slow multi-cycle arithmetic logic
set_multicycle_path 2 -setup -from [get_cells {u_alu/reg_a_reg[*]}] -to [get_cells {u_alu/result_reg[*]}]
set_multicycle_path 1 -hold  -from [get_cells {u_alu/reg_a_reg[*]}] -to [get_cells {u_alu/result_reg[*]}]

# -----------------------------------------------------------------------------
# 6. Vivado Synthesis / Implementation Properties
# -----------------------------------------------------------------------------
set_property DONT_TOUCH true [get_cells u_core/u_crypto_core]
set_property ASYNC_REG true [get_cells -hier -filter {NAME =~ *sync_reg[0]* || NAME =~ *sync_reg[1]*}]
set_property RAM_STYLE block [get_cells u_fifo/u_ram/ram_reg]

# -----------------------------------------------------------------------------
# 7. Tcl Scripting Constructs inside XDC
# -----------------------------------------------------------------------------
set board_rev "rev2"
puts "Applying constraints for board revision: $board_rev"

if {$board_rev == "rev2"} {
    set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports uart_rx]
} else {
    set_property -dict {PACKAGE_PIN B8 IOSTANDARD LVCMOS18} [get_ports uart_rx]
}
