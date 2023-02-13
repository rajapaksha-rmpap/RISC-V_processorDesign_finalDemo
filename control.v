/*************************************************************************************
Control Signal Generator Unit 
  -> generates all the control signals that can be solely induced by the opcode itself. 
  -> outputs a 9-bit bus controls[8:0] where each bit represents a unique control signal 
  -> change 'ALUopr' to 'ALUcontrol' 
**************************************************************************************/ 

module control(opcode, controls); 
  input[6:0] opcode; 
  output reg[9:0] controls; // change the bus size 
  
  always @(opcode) begin 
    case (opcode[6:4])
      // ****** computational operations (reg-reg) ******
      (3'b011): begin 
        controls[0] = 0; // no branch 
        controls[1] = 0; // no MemRead *(same as MemtoReg)
        controls[2] = 0; // no MemWrite 
        controls[4] = 0; // ALUsrc1 = gen. pur. register operand 
        controls[6] = 0; // result = ALUout 
        controls[7] = 1; // do RegWrite 
        case (opcode[2]) 
          (1'b1): begin // LUI 
            // rs on data1 must be forced to x0 
            controls[3] = 0; // ALUcontrol = default (ADD, SUBorSRA = 0) 
            controls[5] = 1; // ALUsrc2 = immediate operand# 
          end 
          (1'b0): begin // other 
            controls[3] = 1; // ALUcontrol = funct3 
            controls[5] = 0; // ALUsrc2 = register operand 
            controls[9] = 0; // R-type 
          end 
        endcase 
      end 
      // ****** computational operations (reg-imm) ****** 
      (3'b001): begin 
        controls[0] = 0; // no branching 
        controls[1] = 0; // no MemRead *(same as MemtoReg)
        controls[2] = 0; // no MemWrite 
        controls[5] = 1; // ALUsrc2 = immediate operand 
        controls[6] = 0; // result = ALUout 
        controls[7] = 1; // do RegWrite 
        case (opcode[2]) 
          (1'b1): begin // AUIPC 
            controls[3] = 0; // ALUcontrol = default (ADD, SUBorSRA = 0) 
            controls[4] = 1; // ALUsrc1 = pc 
          end 
          (1'b0): begin // other 
            controls[3] = 1; // ALUcontrol = funct3; 
            controls[4] = 0; // ALUsrc1 = gen. pur. register operand 
            controls[9] = 1; // I-type 
          end 
        endcase 
      end 
      
      // ****** Mem Load Instructions ****** 
      (3'b000): begin 
        controls[0] = 0; // no branching 
        controls[1] = 1; // do MemRead *(same as MemtoReg)
        controls[2] = 0; // no MemWrite 
        controls[3] = 0; // ALUcontrol = default (ADD, SUBorSRA = 0) 
        controls[4] = 0; // ALUsrc1 = gen. pur. register operand 
        controls[5] = 1; // ALUsrc2 = immediate operand 
        controls[6] = 0; // result = ALUout  
        controls[7] = 1; // do RegWrite 
      end 
      
      // ****** Mem Store Instructions ****** 
      (3'b010): begin 
        controls[0] = 0; // no branching 
        controls[1] = 0; // no MemRead *(same as MemtoReg)
        controls[2] = 1; // do MemWrite 
        controls[3] = 0; // ALUcontrol = default (ADD, SUBorSRA = 0) 
        controls[4] = 0; // ALUsrc1 = gen. pur. register operand 
        controls[5] = 1; // ALUsrc2 = immediate operand 
        controls[6] = 0; // result = ALUout 
        controls[7] = 0; // no RegWrite 
      end 
      
      // ****** Branching and Jumping Instructions ****** 
      (3'b110): begin 
        controls[0] = 1; // do branching 
        controls[1] = 0; // no MemRead *(same as MemtoReg)
        controls[2] = 0; // no MemWrite 
        
        case (opcode[3:2]) 
          (2'b00): begin // ***** conditional branching ***** 
            controls[3] = 0; // ALUcontrol = cond (here, funct3 contains branching condition info)
            controls[4] = 0; // ALUsrc1 = gen. pur. register operand 
            controls[5] = 0; // ALUsrc2 = register operand 
            controls[6] = 0; // result = ALUout (?)
            controls[7] = 0; // no RegWrite 
            
            controls[8] = 0; // branching is conditional 
          end 
          (2'b01): begin // ***** JALR ***** 
            controls[3] = 0; // ALUcontrol = default (ADD and SUBorSRA = 0) 
            controls[4] = 0; // ALUsrc1 = gen. pur. register operand 
            controls[5] = 1; // ALUsrc2 = register operand 
            controls[6] = 1; // result = (pc + 4) 
            controls[7] = 1; // do RegWrite 
            
            controls[8] = 1; // branching is UNconditional 
          end 
          (2'b11): begin // ***** JAL ***** 
            controls[3] = 0; // ALUcontrol = default (ADD, SUBorSRA = 0) 
            controls[4] = 1; // ALUsrc1 = pc 
            controls[5] = 1; // ALUsrc2 = immediate operand 
            controls[6] = 1; // result = (pc + 4) 
            controls[7] = 1; // do RegWrite 
            
            controls[8] = 1; // branching is UNconditional 
          end 
          // ##### to avoid the warning 'incomplete case statement has no default case item'
          // default: controls = 10'b0; 
        endcase 
      end 
      // ##### to avoid the warning 'inferring latch(es) for variable "controls"'
      // default: controls = 10'b0; 
    endcase 
  end 
endmodule // control 
