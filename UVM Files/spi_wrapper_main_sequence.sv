package spi_wrapper_main_sequence_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import spi_wrapper_seq_item_pkg::*;

	class spi_wrapper_main_sequence extends uvm_sequence #(spi_wrapper_seq_item);
		`uvm_object_utils(spi_wrapper_main_sequence)

		spi_wrapper_seq_item seq_item;

		bit [7:0] ADD_DATA;
		bit [2:0] WR_FLAG;

		function new(string name = "spi_wrapper_main_sequence");
			super.new(name);
		endfunction

		task body;
			seq_item=spi_wrapper_seq_item::type_id::create("seq_item");
			seq_item.ADD_DATA=ADD_DATA;
			seq_item.WR_FLAG=WR_FLAG;

			start_item(seq_item);
			assert(seq_item.randomize()); 
			finish_item(seq_item);
		endtask
		
	endclass

endpackage


