package spi_wrapper_scoreboard_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import spi_wrapper_seq_item_pkg::*;

	class spi_wrapper_scoreboard extends uvm_scoreboard;
		`uvm_component_utils(spi_wrapper_scoreboard)

		uvm_analysis_export #(spi_wrapper_seq_item) sb_export;
		uvm_tlm_analysis_fifo #(spi_wrapper_seq_item) sb_spi_wrapper;

		spi_wrapper_seq_item seq_item_sb;

		// golden/reference outputs
	    logic MISO_ref;
		int error_count=0, correct_count=0, i=-1;
		/* to receive the data written (golden) to compare with the design */
		bit [0:7] DATA_8bit;

		function new(string name = "spi_wrapper_scoreboard", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			sb_export=new("sb_export",this);
			sb_spi_wrapper=new("sb_spi_wrapper",this);
		endfunction

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			sb_export.connect(sb_spi_wrapper.analysis_export);
		endfunction

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				sb_spi_wrapper.get(seq_item_sb);
				check_data(seq_item_sb);
			end
		endtask

		function void report_phase(uvm_phase phase);
			super.report_phase(phase);
			`uvm_info("report_phase", $sformatf("At time %0t: Simulation Ends and Error Count= %0d, Correct Count= %0d",
					 $time, error_count, correct_count), UVM_MEDIUM);
		endfunction

		function void check_data(spi_wrapper_seq_item F_cd);
			reference_model(F_cd);
			outputs_check_assert: assert(MISO_ref===F_cd.MISO) begin
				correct_count++; 
			end
			else begin
				error_count++;
				`uvm_error("run_phase", "Comparison Error");
			end
			outputs_check_cover: cover(MISO_ref===F_cd.MISO);
		endfunction
		
		function void reference_model(spi_wrapper_seq_item F_rm);
			if (F_rm.tx_valid && i<=7) begin
				if (i>-1) begin
					MISO_ref=DATA_8bit[i];
					i++;
				end
				else
					i++;
			end
			// MISO is always 0, when there's no data shifted out
			else begin
				MISO_ref=1'b0;
			end

			if (!F_rm.tx_valid) begin
				i=-1;
			end

		endfunction

	endclass

endpackage