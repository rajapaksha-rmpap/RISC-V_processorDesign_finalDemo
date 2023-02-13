/*************************************************************** 
Adder ALU module used for incrementing/changing PC 
-> only capable of adding a constant 32-bit offset to the PCout. 
-> used to implement PC increment and branching. 
***************************************************************/ 

module addALU(PCout, offset, increPC); 
  localparam addr_bus_size = 32; // memory address bus width 
  
  input[addr_bus_size-1:0] PCout, offset; 
  output reg[addr_bus_size-1:0] increPC; 
  
  always @* increPC = PCout + offset; 
  
endmodule //addALU 
