// This module minimize 50MHz clock to 1 Hz
`define xtal_freq 50000000 
`define period 1 
`define timerValue `period*`xtal_freq/2 
`define counterWidth $clog2(`timerValue) 

module clock(clk_50Mhz,clk_1hz);
	input clk_50Mhz;
	output reg clk_1hz;
	
	reg [25:0] counter = 0;

	always @(posedge clk_50Mhz) begin
	  counter <= counter + 1;
	  if (counter == 50_000_000) begin
		 counter <= 0;
		 clk_1hz <= ~clk_1hz;
	  end
	end
endmodule 
	

	