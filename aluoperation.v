/****************************************************************************
ALU Operation Signal Generator Unit 
-> generates the ALU control signal which specifies the ALU operation 
-> generates the additional control signal to specify SUB and SRA operations 
   when ALU_operation is ADD and SRL respectively 
-> Here, funct7 is 30th bit of R/I-type instructions, and funct3 is used for 
   R, I, and B type instructions. 
****************************************************************************/ 

module ALUopration(ALUcontrol, IRtype, BranchEn, IsUncond, funct7, funct3, ALUopr, SUBorSRA); 
  input [2:0] funct3; 
  input ALUcontrol, IRtype, BranchEn, IsUncond, funct7; 
  output reg[2:0] ALUopr; 
  output reg SUBorSRA; 
  
  always @* begin 
    // ***** R and computational-I type instructions ***** 
    if (ALUcontrol) begin // basic ALU operation is specified in funct3; not default ADD and SUBorSRA = 0 
      ALUopr = funct3; 
      case (ALUopr) 
        // specifing SUB operation 
        (3'b000): begin 
          if (!IRtype) // R-type 
            SUBorSRA = funct7; 
          else         // I-type 
            SUBorSRA = 0; 
        end 
        // specifing SRA operation 
        (3'b101): SUBorSRA = funct7; 
        default SUBorSRA = 0; 
      endcase 
    end 
    
    // ***** B type instructions *****   
    else if (BranchEn && !IsUncond) begin 
      case (funct3[2:1]) 
        (2'b00): begin ALUopr = 3'b000; SUBorSRA = 1; end // BEQ and BNE 
        (2'b10): ALUopr = 3'b010; // BLT and BGE 
        (2'b11): ALUopr = 3'b011; // BLTU and BGEU 
      endcase 
    end 
    
    // ***** all other instructions ***** 
    // -> other instructions all use default ADD and SUBorSRA = 0. 
    else begin 
      ALUopr = 3'b000; SUBorSRA = 0; 
    end 
  end 
endmodule // ALUoperation 
