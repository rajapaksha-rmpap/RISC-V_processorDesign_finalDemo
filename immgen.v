/******************************************************************************************
Immediate Operand Generator Unit 
-> generate a 32-bit immediate value based on I, S, B, U, and J immediate enocding variants 
******************************************************************************************/ 

module immGen(
  input[31:0] instr,
  output reg[31:0] imm
);

  always @(*) begin 
    case (instr[6:0])
      7'b0010011: // I-type
        imm = {{20{instr[31]}}, instr[31:20]}; 
		7'b0000011: // I-type - Load 
		  imm = {{20{instr[31]}}, instr[31:20]}; 
      7'b1100111: // I-type - JALR 
        imm = {{20{instr[31]}}, instr[31:20]}; 
      7'b0110111: // U-type - LUI 
        imm = {instr[31:12], 12'b0};
		7'b0010111: // U-type - AUIPC 
        imm = {instr[31:12], 12'b0};
      7'b1101111: // J-type
        imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
      7'b1100011: // B-type
        imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // #
      7'b0100011: // S-type
        imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      // default: // R-type immediate = 0;
    endcase
  end

endmodule // immGen 
