/******************************************************************************
Program Counter (32-bit)
-> As RISC-V specifications, pc contains the address of the instruction that is 
   currently being executed. 
-> The pc register will change its stored value to the next instruction address 
   at each positive edge of the clk signal. 
******************************************************************************/ 

module pc(PCin, clk, PCout); 
  localparam addr_bus_size = 32; 
  
  input[addr_bus_size-1:0] PCin; 
  input clk; 
  output reg[addr_bus_size-1:0] PCout; 
  
  initial PCout = 32'b0; // initialize with 0 in pc 
  
  always @(posedge clk) PCout <= PCin; 
  
endmodule // pc 
