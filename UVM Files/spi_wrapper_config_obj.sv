package spi_wrapper_config_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

	class spi_wrapper_config extends uvm_object;
		`uvm_object_utils(spi_wrapper_config)

		virtual spi_wrapper_if spi_wrapper_vif;

		function new(string name = "spi_wrapper_config");
			super.new(name);
		endfunction

	endclass

endpackage