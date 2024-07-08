package spi_wrapper_seq_item_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

	class spi_wrapper_seq_item extends uvm_sequence_item;
		`uvm_object_utils(spi_wrapper_seq_item)

		// Design inputs
		rand bit MOSI, rst_n, SS_n;
	    // Design outputs
		logic MISO;

		// internal signals
		bit tx_valid;
	    bit rx_valid;
	    logic [9:0] din;
	   	logic [7:0] dout;
	   	
		localparam RST_ASSERT=0, RST_DE_ASSERT=100;

		// flag to generate specific control bits depending on the operation (WADD, WDATA, RADD, RDATA)
		bit [2:0] WR_FLAG;
		// the address or the data depending on the operation (WADD, WDATA, RADD, RDATA)
		bit [7:0] ADD_DATA;
		/* constraint this array to generate the bits which will be written on MOSI 
			11 bits (3 Control bits + 8 DATA/ADD) */
		rand bit [10:0] write_add_arr;

		/* Constraint to prepare bits to be written on the MOSI input port 
			1. #control bits (R or W, DATA or ADD)
			2. #DATA to be written or the #ADD to write data at or read data from */
		constraint specific_data {
			write_add_arr[7:0]==ADD_DATA;
			if (WR_FLAG==3'b000) {
				{write_add_arr[10],write_add_arr[9],write_add_arr[8]}==3'b000;
			} 
			else if (WR_FLAG==3'b001) {
				{write_add_arr[10],write_add_arr[9],write_add_arr[8]}==3'b001;
			} 
			else if (WR_FLAG==3'b110) {
				{write_add_arr[10],write_add_arr[9],write_add_arr[8]}==3'b110;
			}
			else if (WR_FLAG==3'b111) {
				{write_add_arr[10],write_add_arr[9],write_add_arr[8]}==3'b111;		
			}
		}		

		// Assert reset (active low) less often
		constraint rst_c { rst_n dist {0:=RST_ASSERT, 1:=RST_DE_ASSERT}; }


		function new(string name = "spi_wrapper_seq_item");
			super.new(name);
		endfunction

		function string convert2string();
			return $sformatf("%s reset=0b%0b, MOSI=0b%0b, SS_n=0x%0x, MISO=0b%0b", 
							super.convert2string(), rst_n, MOSI, SS_n, MISO);
		endfunction

		function string convert2string_stimulus();
			return $sformatf("reset=0b%0b, MOSI=0b%0b, SS_n=0x%0x", 
				rst_n, MOSI, SS_n);
		endfunction

	endclass

endpackage