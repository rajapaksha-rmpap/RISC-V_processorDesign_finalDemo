/*****************************************************************************************************
ALU 
-> supports all the arithmetic and logical operations required for implementing the complete 
   RISC RV32I Base Integer Instruction Set 
-> ADD/SUB and SRL/SRA operations are activated by the same 'ALUopr' control signal and differentiated 
   by the 'SUBorSRA' control signal. 
*****************************************************************************************************/

module ALU(data1, data2, ALUopr, SUBorSRA, ALUout, z); 
  localparam bus_size = 32; 
  input[bus_size-1:0] data1, data2; 
  input[2:0] ALUopr; 
  input SUBorSRA; 
  output reg[bus_size-1:0] ALUout; 
  output reg z; 
  
  // contain signed representation of data buses 
  reg signed[bus_size-1:0] data_s1, data_s2; 
  
  always @(data1, data2, ALUopr, SUBorSRA) begin 
    case (ALUopr)
      // ******* arithmetic operations ******* 
      (3'b000): begin 
        if (SUBorSRA == 1'b0) 
          ALUout = data1 + data2; // signed addition 
        else 
          ALUout = data1 - data2; // signed subtraction 
        end 
      (3'b111): ALUout = data1 & data2; // bit-wise AND 
      (3'b110): ALUout = data1 | data2; // bit-wise OR 
      (3'b100): ALUout = data1 ^ data2; // bit-wise XOR 
      
      // ******* comparison operations ******* 
      (3'b010): begin // set less than 
        data_s1 = data1; 
        data_s2 = data2; 
        if (data_s1 < data_s2) ALUout = 1; 
        else ALUout = 0;  
      end 
      
      (3'b011): begin // set less than unsigned 
        if (data1 < data2) ALUout = 1; 
        else ALUout = 0; 
      end 
      
      // ******* bit shift operations ******* 
      (3'b001): ALUout = data1 << data2[4:0]; // (logical) left shift 
      (3'b101): begin 
        if (SUBorSRA == 1'b0) 
          ALUout = data1 >> data2[4:0];      // logical right shift 
        else begin 
          data_s1 = data1; 
          data_s2 = data2; 
          ALUout = data_s1 >>> data_s2[4:0]; // arithmetic right shift 
        end 
      end 
    endcase 
    z = !(|ALUout); // zero flag (if out==0, then z=1, else 0) 
  end 
  
endmodule //ALU 
