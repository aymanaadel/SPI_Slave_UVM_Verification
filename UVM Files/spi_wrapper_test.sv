package spi_wrapper_test_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import spi_wrapper_env_pkg::*;
import spi_wrapper_reset_sequence_pkg::*;
import spi_wrapper_main_sequence_pkg::*;

import spi_wrapper_config_pkg::*;

	class spi_wrapper_test extends uvm_component;
		`uvm_component_utils(spi_wrapper_test)

		// env
		spi_wrapper_env env;
		// sequences
		spi_wrapper_reset_sequence reset_sequence;
		spi_wrapper_main_sequence main_sequence;
		// config object to get the if
		spi_wrapper_config spi_wrapper_cfg;

		/* holds data or address to be written */
		logic [7:0] data, address;
		/* parameters used to set a flag depending on the operation (WADD, WDATA, ...) */
		parameter WADD=3'b000, WDATA=3'b001, RADD=3'b110, RDATA=3'b111;

		function new(string name = "spi_wrapper_test", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			env=spi_wrapper_env::type_id::create("env",this);
			reset_sequence=spi_wrapper_reset_sequence::type_id::create("reset_sequence");
			main_sequence=spi_wrapper_main_sequence::type_id::create("main_sequence");
			spi_wrapper_cfg=spi_wrapper_config::type_id::create("spi_wrapper_cfg");
			// get the IF
			if (!uvm_config_db#(virtual spi_wrapper_if)::get(this, "", "spi_wrapper_IF", spi_wrapper_cfg.spi_wrapper_vif)) begin
				`uvm_fatal("build_phase", "TEST - unable to get the IF");
			end
			// set the config object (which containing the IF)
			uvm_config_db#(spi_wrapper_config)::set(this, "*", "CFG", spi_wrapper_cfg);
		endfunction

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			phase.raise_objection(this);

			// reset sequence at the beginning of the operation
			`uvm_info("run_phase", "Reset Asserted", UVM_LOW);
			reset_sequence.start(env.agt.sqr);
			`uvm_info("run_phase", "Reset De-asserted", UVM_LOW);
			// ********************************************************* //

			//**** Here's detailed description how to configure the sequence ****//

			/* Set the data and the address to write/read */
			data=8'hCB; /* 1100_1011 */ address=8'h1A;

			// 1- Write Address sequence
			main_sequence.WR_FLAG=WADD; /* Set the flag with WADD */
			main_sequence.ADD_DATA=address; /* Set the desired Address */
			main_sequence.start(env.agt.sqr); /* Start the Sequence */

			// 2- Write Data sequence
			main_sequence.WR_FLAG=WDATA; /* Set the flag with WDATA */
			main_sequence.ADD_DATA=data; /* Set the desired Data */
			main_sequence.start(env.agt.sqr); /* Start the Sequence */

			// 3- Read Address sequence
			main_sequence.WR_FLAG=RADD; /* Set the flag with RADD */
			main_sequence.ADD_DATA=address; /* Set the desired address */
			main_sequence.start(env.agt.sqr); /* Start the Sequence */

			// 4- Read Data sequence
			/* Data written in a certain address is sent to the scoreboard to check the MISO output */
			env.sb.DATA_8bit=data; 
			main_sequence.WR_FLAG=RDATA; /* Set the flag with RDATA */
			main_sequence.ADD_DATA=8'h00; /* Set the desired data (here, data ignored) */
			main_sequence.start(env.agt.sqr); /* Start the Sequence */
			
			// ********************************************************* //
			data=8'hAA; /* 10101010 */ address=8'hBB; /* 1011_1011 */

			// 1- Write Address sequence
			main_sequence.WR_FLAG=WADD;
			main_sequence.ADD_DATA=address;
			main_sequence.start(env.agt.sqr);

			// 2- Write Data sequence
			main_sequence.WR_FLAG=WDATA;
			main_sequence.ADD_DATA=data; 
			main_sequence.start(env.agt.sqr);

			// 3- Read Address sequence
			main_sequence.WR_FLAG=RADD;
			main_sequence.ADD_DATA=address; 
			main_sequence.start(env.agt.sqr);

			// 4- Read Data sequence
			env.sb.DATA_8bit=data;
			main_sequence.WR_FLAG=RDATA;
			main_sequence.ADD_DATA=8'h00; 
			main_sequence.start(env.agt.sqr);

			// ********************************************************* //
			// write in all ram locations
			for (int i = 0; i < 256; i++) begin
				data=i; address=i;

				// 1- Write Address sequence
				main_sequence.WR_FLAG=WADD;
				main_sequence.ADD_DATA=address; 
				main_sequence.start(env.agt.sqr);

				// 2- Write Data sequence
				main_sequence.WR_FLAG=WDATA;
				main_sequence.ADD_DATA=data; 
				main_sequence.start(env.agt.sqr);
			end

			// read all ram locations
			for (int i = 0; i < 256; i++) begin
				data=i; address=i;

				// 3- Read Address sequence
				main_sequence.WR_FLAG=RADD;
				main_sequence.ADD_DATA=address; 
				main_sequence.start(env.agt.sqr);

				// 4- Read Data sequence
				// Data written in a certain address is sent to the scoreboard to check the MISO output
				env.sb.DATA_8bit=data;
				main_sequence.WR_FLAG=RDATA;
				main_sequence.ADD_DATA=8'h00;
				main_sequence.start(env.agt.sqr);
			end
			// ********************************************************* //

			phase.drop_objection(this);
		endtask

	endclass

endpackage