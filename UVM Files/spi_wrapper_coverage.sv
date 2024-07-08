package spi_wrapper_coverage_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import spi_wrapper_seq_item_pkg::*;

	class spi_wrapper_coverage extends uvm_component;
		`uvm_component_utils(spi_wrapper_coverage)

		uvm_analysis_export #(spi_wrapper_seq_item) cov_export;
		uvm_tlm_analysis_fifo #(spi_wrapper_seq_item) cov_spi_wrapper;

		spi_wrapper_seq_item seq_item_cov;

		covergroup cvr_grp;
			WR_address_cp: // cp on the WR address to see if we write in all locations of the RAM or not
			coverpoint seq_item_cov.din[7:0] iff(seq_item_cov.rx_valid&&seq_item_cov.din[9:8]==2'b00) {
				bins wr_addr1 = {[0:31]};
				bins wr_addr2 = {[32:63]};
				bins wr_addr3 = {[64:95]};
				bins wr_addr4 = {[96:127]};
				bins wr_addr5 = {[128:159]};
				bins wr_addr6 = {[160:191]};
				bins wr_addr7 = {[192:223]};
				bins wr_addr8 = {[224:255]};
			}
			RD_address_cp: // cp on the RD address to see if we read all locations of the RAM or not
			coverpoint seq_item_cov.din[7:0] iff(seq_item_cov.rx_valid&&seq_item_cov.din[9:8]==2'b10) {
				bins rd_addr1 = {[0:31]};
				bins rd_addr2 = {[32:63]};
				bins rd_addr3 = {[64:95]};
				bins rd_addr4 = {[96:127]};
				bins rd_addr5 = {[128:159]};
				bins rd_addr6 = {[160:191]};
				bins rd_addr7 = {[192:223]};
				bins rd_addr8 = {[224:255]};
			}			
			data_patterns_cp: // cp on the data written in the RAM
			coverpoint seq_item_cov.din[7:0] iff(seq_item_cov.rx_valid&&seq_item_cov.din[9:8]==2'b01) {
				bins all_ones = {8'hFF};
				bins all_zeros = {8'h00};
				bins alternating_bits = {8'b1010_1010, 8'b0101_0101};
				bins random = default;
			}
		endgroup

		function new(string name = "spi_wrapper_coverage", uvm_component parent = null);
			super.new(name,parent);
			cvr_grp=new();
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			cov_export=new("cov_export",this);
			cov_spi_wrapper=new("cov_spi_wrapper",this);
		endfunction

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			cov_export.connect(cov_spi_wrapper.analysis_export);
		endfunction

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				cov_spi_wrapper.get(seq_item_cov);
				cvr_grp.sample();
			end
		endtask

	endclass
endpackage