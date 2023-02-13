/********************************************************************************************
RISC RV32I (version 2.0) CPU 
-> This RISC-V processor module is designed to support all of the instructions in the 
   RISC RV32I Base Integer Instruction set (version 2.0), excluding the two FENCE and 
   FENCE.I memory access instructions, the Control and Status Register Instructions, 
   and the two ECALL and EBREAK instructions in the Environment Call and Breakpoints 
   section.(refer to the "The RISC-V Instruction Set Manual, Volume I: User-Level ISA") 
   
-> This is a single cycle design; the program counter (pc) will update at each positive 
   edge of the clk signal, and a standard 32-bit instruction will be fetch into the CPU. 
   Then, the instruction will be decoded and completely executed within a finite latency. 
********************************************************************************************/ 

module RISC_RV32I_cpu(instr, instrAddr, toMem, fromMem, MemAddr, WriteEn, ReadEn, addMemControl, clk, 
							DB1, DB2, DB3); 
  localparam bus_size = 32;      // instruction and data bus width 
  localparam addr_bus_size = 32; // memory address bus width 
  supply0 singleBitZero; 
  
  input[bus_size-1:0] instr; 
  input[bus_size-1:0] fromMem; 
  input clk; 
  output[bus_size-1:0] toMem; 
  output[addr_bus_size-1:0] instrAddr, MemAddr; 
  output WriteEn, ReadEn; 
  output[1:0] addMemControl; 
  
  // for demonstrating the output 
  output[31:0] DB1, DB2, DB3; 
  
  wire[6:0] opcode; 
  wire[9:0] controls; 
  
  // ///////////////////////////////////// DATA PATHs //////////////////////////////////////////// 
  // data paths used with ALU 
  wire[bus_size-1:0] fromReg1, fromReg2; // two register outputs from regfile 
  wire[bus_size-1:0] imm;       // immediate operand 
  reg [bus_size-1:0] data1, data2; // input data buses to ALU 
  wire[bus_size-1:0] ALUout;    // output of ALU 
  reg [bus_size-1:0] dataOut;   // output of data to be written in memory of regfile 
  
  // data paths used for branching (width may be defined using "addr_bus_size" instead) 
  wire[bus_size-1:0] condBranchPC;   // address of next instruction if a conditional branching is to occur 
  wire[bus_size-1:0] uncondBranchPC; // address of next instruction if an unconditional branching is to occur  
  reg [bus_size-1:0] BranchPC;  // address of next instruction if a branching has to occur 
  wire[bus_size-1:0] PCplus4;   // address of the adjacent instruction of current pc (pc+4) 
  reg [bus_size-1:0] PCin;      // input to pc (address of next instruction) 
  wire[bus_size-1:0] PCout;     // current pc value (updated at each posedge of clk) 
  
  // data paths used for load and store instructions 
  wire[bus_size-1:0] dataIn;    // data read from data memory 
  reg [bus_size-1:0] toReg;     // data to be written in regfile 
  
  // /////////////////////////////////// CONTROL SIGNALS ///////////////////////////////////////// 
  // instruction based control signals 
  wire[4:0] rs1, rs2, rd;       // register addresses for regfile 
  wire[2:0] funct3;             // used to specify ALUoperation, branch condition, and Mem Load/store type 
  wire funct7;                  // used to specify SUB and SRA operations 
  
  // main control signals 
  wire BranchEn, MemRead, MemWrite, ALUcontrol, ALUsrc1, ALUsrc2, result, RegWrite, IsUncond, IRtype; 
  
  // ALU control signals 
  wire[2:0] ALUopr;             // ALU operation 
  wire SUBorSRA;                // used to activate SUB and SRA operations 
  wire z;                       // zero flag 
  
  // branch control signals 
  wire branch, lt; 
  
  // load and store control signals 
  
  // /////////////////////////////// CONTINUOUS ASSIGNMENTS ////////////////////////////////////// 
  
  // ports of CPU module 
  assign instrAddr = PCout;     // instruction address 
  assign MemAddr   = dataOut;   // address for data memory 
  assign toMem     = fromReg2;  // data to be written in data memory 
  assign dataIn    = fromMem;   // data read from data memory 
  assign WriteEn   = MemWrite;  // write data 
  assign ReadEn    = MemRead;   // read data 
  assign addMemControl = instr[13:12]; // specify to load/store word/half-word/byte 
  
  // Data Paths 
  assign uncondBranchPC = {ALUout[bus_size-1:1], singleBitZero}; 
  
  // opcode sections 
  assign opcode = instr[6:0]; 
  assign rd = instr[11:7]; 
  assign funct3 = instr[14:12]; 
  assign rs1 = instr[19:15]; 
  assign rs2 = instr[24:20]; 
  assign funct7 = instr[30]; 
  
  // control signals 
  assign BranchEn   = controls[0]; 
  assign MemRead    = controls[1]; 
  assign MemWrite   = controls[2]; 
  assign ALUcontrol = controls[3]; 
  assign ALUsrc1    = controls[4]; 
  assign ALUsrc2    = controls[5]; 
  assign result     = controls[6]; 
  assign RegWrite   = controls[7]; 
  assign IsUncond   = controls[8]; 
  assign IRtype     = controls[9]; 
  
  assign lt = ALUout[0];          // less than flag used for conditional branching 
  
  // demo 
  assign DB1 = toReg; 
  assign DB2 = rd; 
  assign DB3 = PCout; 
  
  // //////////////////////////////// MODULE INSTANTIATION ////////////////////////////////////// 
  control C(opcode, controls); 
  ALUopration ACSGU(ALUcontrol, IRtype, BranchEn, IsUncond, funct7, funct3, ALUopr, SUBorSRA); 
  ALU mainALU(data1, data2, ALUopr, SUBorSRA, ALUout, z); 
  addALU GALU(.PCout(PCout), .offset(32'b0100), .increPC(PCplus4)); 
  addALU CBALU(.PCout(PCout), .offset(imm), .increPC(condBranchPC)); 
  branch B(BranchEn, IsUncond, funct3, z, lt, branch); 
  pc PC(PCin, clk, PCout); 
  regfile RegF(fromReg1, fromReg2, toReg, rs2, rs1, rd, RegWrite, clk); 
  immGen IG(instr, imm); 
  
  always @(fromReg1, PCout, ALUsrc1) begin 
    // MUX1 (for ALUoperand1) 
    if (!ALUsrc1) data1 = fromReg1; 
    else data1 = PCout; 
  end 
  
  always @(fromReg2, imm, ALUsrc2) begin 
    // MUX2 (for ALUoperand2)
    if (!ALUsrc2) data2 = fromReg2; 
    else data2 = imm; 
  end 
  
  always @(ALUout, PCplus4, result) begin 
    // MUX3 (for dataOut) 
    if (!result)  dataOut = ALUout; 
    else dataOut = PCplus4; 
  end 
  
  always @(condBranchPC, uncondBranchPC, IsUncond) begin 
    // MUX4 (for specifying cond/uncond branching) 
    if (IsUncond) BranchPC = uncondBranchPC; 
    else BranchPC = condBranchPC; 
  end 
  
  always @(BranchPC, PCplus4, branch) begin 
    // MUX5 (for branching) 
    if (branch) PCin = BranchPC; 
    else PCin = PCplus4; 
  end 
  
  always @(dataOut, dataIn, MemRead) begin 
    // MUX6 (to specify what to be written in regfile) 
    if (MemRead) toReg = dataIn; 
    else toReg = dataOut; 
  end 
  
endmodule // RISC_RV32I_cpu 