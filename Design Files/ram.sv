module ram(din,rx_valid,tx_valid,dout,clk,rst_n);
input [9:0] din;
input rx_valid;
input clk,rst_n;
output reg tx_valid;
output reg[7:0] dout;
reg [7:0] WRITE_ADD, READ_ADD;
reg [7:0] mem [255:0];

always@(posedge clk or negedge rst_n) begin
     if(rst_n==0) begin
          dout<=0; WRITE_ADD<=0; READ_ADD<=0; tx_valid<=0;
     end
     else if(rx_valid==1) begin
          if(din[9:8]==2'b00) begin
               WRITE_ADD<=din[7:0]; tx_valid<=0;
          end 
          else if(din[9:8]==2'b01) begin
             mem[WRITE_ADD]<=din[7:0]; tx_valid<=0;
          end
          else if(din[9:8]==2'b10) begin
               READ_ADD<=din[7:0]; tx_valid<=0;
          end
          else if(din[9:8]==2'b11) begin
               dout<=mem[READ_ADD];
               tx_valid<=1;
          end
     end
end

endmodule