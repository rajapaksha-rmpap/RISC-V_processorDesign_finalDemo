module main_memory(input clk,input  reset,input[31:0] addr,input[127:0] data_in,input write_en,input read_en,
                      output reg[127:0] data_out);

  // Main memory array
  reg [31:0] memory [0:63][0:3];
  wire [27:0] block_addr;
  wire [1:0] word_addr;
  wire [1:0] byte_addr;
  
  assign block_addr = addr[31:4];
  assign word_addr = addr[3:2];
  assign byte_addr = addr[1:0];
  // State machine
  reg [1:0] state = 2'b00;
  initial begin
     state = 2'b00;
  end
  always @(posedge clk) begin
    case (state)
      2'b00: begin
      $display("Initial State Mem");
        if (write_en) begin
        $display("Writing Mem %b",addr);
//          memory[addr[10:0]] = data_in;
          memory[block_addr][0] = data_in[127:96]; 
          memory[block_addr][1] = data_in[95:64]; 
          memory[block_addr][2] = data_in[63:32];
          memory[block_addr][3] = data_in[31:0]; 
          state = 2'b01;
        end
        else if (read_en) begin
          data_out = {memory[block_addr][0],memory[block_addr][1],memory[block_addr][2],memory[block_addr][3]};
          state = 2'b10;
        end
      end
      2'b01: begin
        state = 2'b00;
      end
      2'b10: begin
        state = 2'b00;
      end
    endcase
  end

  // Reset logic
  always @(posedge clk) begin
    if (reset) begin
      state <= 2'b00;
    end
  end

endmodule