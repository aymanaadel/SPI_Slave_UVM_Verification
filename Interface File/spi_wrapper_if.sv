interface spi_wrapper_if (input bit clk);
	// Design inputs
	logic MOSI, rst_n, SS_n;
    // Design outputs
	logic MISO;

	// internal signals
	bit tx_valid;
    bit rx_valid;
    logic [9:0] din;
   	logic [7:0] dout;

	// DUT modport
	modport DUT(
		input clk, MOSI, rst_n, SS_n,
		output MISO, tx_valid, rx_valid, din, dout
	);

endinterface