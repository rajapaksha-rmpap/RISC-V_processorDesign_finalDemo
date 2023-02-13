/**************************************************************** 
Register File 
-> contains 32 general purpose 32-bit registers (from x0 to x31) 
-> x0 is hardwired to 0. 
****************************************************************/ 

module regfile(fromReg1, fromReg2, toReg, rs2, rs1, rd, RegWrite, clk); 
  localparam bus_size = 32; 
  
  input[bus_size-1:0] toReg; 
  input[4:0] rs1, rs2, rd; 
  input RegWrite; 
  input clk; 
  output reg[bus_size-1:0] fromReg1, fromReg2; 
  
  supply0[bus_size-1:0] zero;       // a register hardwired to zero 
  reg[bus_size-1:0] regArray[1:31]; // an array of registers of length 31 
  
  // hardwiring x0 to 0 and reading regs 
  always @(rs1, rs2) begin 
    if (!rs1) fromReg1 = zero; // if rs1 == 0
    else fromReg1 = regArray[rs1]; 
    
    if (!rs2) fromReg2 = zero; // if rs2 == 0 
    else fromReg2 = regArray[rs2]; 
  end 
  
  // if RegWrite is enabled only, update the reg specified by 'rd' with 'toReg' 
  always @(posedge clk) begin 
    if (RegWrite && rd) regArray[rd] <= toReg; 
  end 
  
endmodule // regfile 
