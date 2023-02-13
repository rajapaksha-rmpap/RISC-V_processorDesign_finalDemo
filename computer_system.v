/************************************************************************************************
The Complete Computer System 
-> combines the developed RISC processor and the instr/data memories along with the victim cache. 
************************************************************************************************/ 

// `timescale 1ms / 1ms 
module computer_system(primary_clk, seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7); // add primary_clk 
  
  input primary_clk; 
  output[6:0] seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7; 
  
  // for debugging
  wire[31:0] demo1, demo2, demo3; 
  
  wire secondary_clk; 
  wire[31:0] instr; 
  wire[31:0] instrAddr; 
  wire[31:0] MemAddr; 
  wire[31:0] toMem, fromMem; 
  wire WriteEn, ReadEn; 
  wire[1:0] MemControl; 
  
  supply0 resetLow; 
  
//  initial begin 
//		secondary_clk = 0; 
//		repeat(100) secondary_clk = #5 ~secondary_clk; 
//  end 
  
  clock CLKconvert(primary_clk, secondary_clk); 
  RISC_RV32I_cpu CPU(.instr(instr), .instrAddr(instrAddr), .MemAddr(MemAddr), .toMem(toMem), .fromMem(fromMem), 
							.WriteEn(WriteEn), .ReadEn(ReadEn), .addMemControl(MemControl), .clk(secondary_clk), 
							.DB1(demo1), .DB2(demo2), .DB3(demo3)); 
  instrMem IM(instrAddr, instr); 
  cache_system CACHE(.clk(secondary_clk), .reset(resetLow), .addr(MemAddr), .data_in(toMem), .write_en(WriteEn), 
						.read_en(ReadEn), .control(MemControl), .data_out(fromMem));
  
  // demo1 - toReg (output saved in regfile) 
  seven_segment_display D0(demo1[ 3: 0], seg0); 
  seven_segment_display D1(demo1[ 7: 4], seg1); 
  seven_segment_display D2(demo1[11: 8], seg2); 
  seven_segment_display D3(demo1[15:12], seg3); 
  
  // demo2 - regAddress (rd) 
  seven_segment_display D4(demo2[3:0], seg4); 
  seven_segment_display D5(demo2[7:4], seg5); 
  
  // demo3 - PC 
  seven_segment_display D6(demo3[3:0], seg6); 
  seven_segment_display D7(demo3[7:4], seg7); 
  
endmodule // ComComputerSystem 
