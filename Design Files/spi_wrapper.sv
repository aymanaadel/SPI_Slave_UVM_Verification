module spi_wrapper(spi_wrapper_if.DUT s_if);

wire [9:0] din;
wire rx_valid, tx_valid;
wire [7:0] dout;

// internal signals
assign s_if.tx_valid=tx_valid; 
assign s_if.rx_valid=rx_valid; 
assign s_if.din=din; 
assign s_if.dout=dout; 

spi m1(
	.MOSI(s_if.MOSI),.MISO(s_if.MISO),.clk(s_if.clk),.rst_n(s_if.rst_n),
	.SS_n(s_if.SS_n),.rx_data(din),.rx_valid(rx_valid),
	.tx_data(dout),.tx_valid(tx_valid)
);

ram m2(
	.clk(s_if.clk),.rst_n(s_if.rst_n),
	.din(din),.rx_valid(rx_valid),
	.dout(dout),.tx_valid(tx_valid)
);


// *************************** Some Assertions **************************** //
// When master starts a communication (pulls SS_n from 1 to 0) then
// after 11 cycles (control bit + the 10 more bits) rx_data will be valid so rx_valid will be asserted
rx_valid_assert: assert property(@(posedge s_if.clk) $fell(s_if.SS_n) |=>  ##11 rx_valid);
rx_valid_cover:  cover  property(@(posedge s_if.clk) $fell(s_if.SS_n) |=>  ##11 rx_valid);

// When rx_valid rises (rx_data is valid) and din[9:8] is 2'b11 (read data from RAM) then
// tx_data will be valid so, tx_valid will be asserted (rises) 
tx_rx_valid_assert: assert property(@(posedge s_if.clk) $rose(rx_valid)&&din[9:8]==2'b11 |=> $rose(tx_valid));
tx_rx_valid_cover:  cover  property(@(posedge s_if.clk) $rose(rx_valid)&&din[9:8]==2'b11 |=> $rose(tx_valid));
	
	
	// Add more assertions if needed...

endmodule 