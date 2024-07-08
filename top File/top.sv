import uvm_pkg::*;
`include "uvm_macros.svh"
import spi_wrapper_test_pkg::*;

module top;
	// clock generation
	bit clk;
	initial begin
		clk=0;
		forever #1 clk=~clk;
	end
	// interface
	spi_wrapper_if s_if(clk);
	// DUT
	spi_wrapper dut(s_if);
	// assertions
	bind spi_wrapper spi_wrapper_sva spi_wrapper_sva_inst (s_if);

	initial begin
		uvm_config_db#(virtual spi_wrapper_if)::set(null, "uvm_test_top", "spi_wrapper_IF", s_if);
		run_test("spi_wrapper_test");
	end

endmodule