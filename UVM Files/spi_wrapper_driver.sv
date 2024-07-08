package spi_wrapper_driver_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import spi_wrapper_seq_item_pkg::*;

	class spi_wrapper_driver extends uvm_driver #(spi_wrapper_seq_item);
		`uvm_component_utils(spi_wrapper_driver)

		virtual spi_wrapper_if spi_wrapper_vif;
		spi_wrapper_seq_item stim_seq_item;

		function new(string name = "spi_wrapper_driver", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				stim_seq_item=spi_wrapper_seq_item::type_id::create("stim_seq_item");
				seq_item_port.get_next_item(stim_seq_item);

				/* reset sequence case */
				if (!stim_seq_item.rst_n) begin
					spi_wrapper_vif.rst_n=stim_seq_item.rst_n;
					@(negedge spi_wrapper_vif.clk);
				end
				/* communication sequence case */
				else begin
					/* Start of communication (make SS_n = 0) */
					spi_wrapper_vif.rst_n=1;
					spi_wrapper_vif.SS_n=0;
					@(negedge spi_wrapper_vif.clk);

					/* Normal cases (WADD, WDATA, RADD) vs RDATA case */
					if (stim_seq_item.WR_FLAG!=3'b111)  begin /* Normal cases */
						/* drive MOSI with data generated depending on R DATA/ADD or W DATA/ADD
							and also depending on required DATA/ADD to be Written */
						for (int i = 10; i > 0; i--) begin
							spi_wrapper_vif.MOSI=stim_seq_item.write_add_arr[i];
							@(negedge spi_wrapper_vif.clk);
						end
						/* End of communication (make SS_n = 1) */
						spi_wrapper_vif.SS_n=1; 
						spi_wrapper_vif.MOSI=stim_seq_item.write_add_arr[0];
						@(negedge spi_wrapper_vif.clk);
					end

					else begin /* RDATA case */
						/* drive MOSI with data generated to R DATA (111_xxxx_xxxx...) */
						for (int i = 10; i >= 0; i--) begin
							spi_wrapper_vif.MOSI=stim_seq_item.write_add_arr[i];
							@(negedge spi_wrapper_vif.clk);
						end

						// drive MOSI with 0 (doesn't matter)
						spi_wrapper_vif.MOSI=0;
						// Wait MISO (Shifting out)
						repeat(8) @(negedge spi_wrapper_vif.clk);

						/* End of communication (make SS_n = 1) */
						spi_wrapper_vif.SS_n=1;
						@(negedge spi_wrapper_vif.clk);

					end // 2nd else

				end // 1st else
				seq_item_port.item_done();
			end
		endtask
	endclass
endpackage