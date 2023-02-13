/************************************************************************************
Dummy Instruction Memory 
-> used only for basic testing of cpu 
************************************************************************************/ 

module instrMem(instrAddr, instr); 
	
	input[31:0] instrAddr; 
	output reg[31:0] instr; 
	
	reg[31:0] memory[31:0]; // memory consisting of 32 full-word regs 
	
	// assigning dummy values to memory regs 
	integer i; 
	initial begin 
	  for (i=0; i<=31; i=i+1) begin 
	    memory[i] = 32'b0000000_00000_00000_000_00000_0010011; // NOP 
	  end 
	  
//		memory[0] = 32'b0000000_00001_00000_000_00001_0010011; // ADDI x0 + 1 -> x1 
//		memory[1] = 32'b0000000_00010_00000_000_00010_0010011; // ADDI x0 + 2 -> x2 
//		memory[2] = 32'b0000000_00010_00001_000_00011_0110011; // ADD  x1 + x2 -> x3 
//		memory[3] = 32'b0100000_00001_00011_000_00100_0110011; // SUB  x3 - x1 -> x4 
//		memory[4] = 32'b1111111_00100_00010_000_10001_1100011; // BEQ  x2, x4 offset -8 -> -16 
		
		// loading values 
		memory[0] = 32'b0000000_00001_00000_000_00001_0010011; // ADDI x0 + 1 -> x1 			[0]	[1]
		memory[1] = 32'b0000000_00010_00000_000_00010_0010011; // ADDI x0 + 2 -> x2 			[4]	[2]
		memory[2] = 32'b0000000_00011_00000_000_00011_0010011; // ADDI x0 + 3 -> x3 			[8]	[3]
		
		// computational operations 
		memory[3] = 32'b0000000_00011_00001_000_00100_0110011; // ADD  x1 + x3 -> x4 			[12]	[4]
		memory[4] = 32'b0100000_00011_00100_000_00101_0110011; // SUB  x4 - x3 -> x5 			[16]	[1]
		memory[5] = 32'b0000000_00101_00100_110_00110_0110011; // OR   x4 | x5 -> x6			[20]	[5]
		
		// BLT 
		memory[6] = 32'b0000000_00110_00101_100_01000_1100011; // BLT  x5, x6 offset 8	   [24]	[XX]
		
		// branch does happen 
		// left shift 
		memory[8] = 32'b0000000_00001_00101_001_00101_0010011; // SLLI x5 << 1 -> x5        [32]  [2]
		// right shift 
		memory[9] = 32'b0000000_00001_00100_101_00100_0010011; // SRLI x4 >> 1 -> x4        [36]  [2]
		
		// compare the two results and brach if equal 
		memory[10] = 32'b0000001_00100_00101_000_11100_1100011;// BEQ  x4, x5 offset 60 	   [40]	[XX]
		
		// load a value and read it back 
		memory[25] = 32'b0000000_00110_00001_010_00011_0100011;// SW   x6 -> M[x1 + 3]		[100]	[4]
		memory[27] = 32'b1111111_11111_00110_010_00111_0000011;// LW  M[x6 - 1] -> x7			[108] [0]
		memory[28] = 32'b1111111_11111_00110_010_00111_0000011;// LW  M[x6 - 1] -> x7			[112] [5]
		
		memory[29] = 32'b00000000000000000001_01000_0010111;	 // AUIPC imm = 1					[116] []
		memory[30] = 32'b1_1111000100_1_11111111_00101_1101111;// JAL  offset -120 			[120]	[32]
	
	end 
	
	always @(*) begin 
		instr <= memory[instrAddr[6:2]]; 
	end 
	
endmodule // instrMem 

