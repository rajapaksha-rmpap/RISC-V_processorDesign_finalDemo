module cache_system(input clk,input reset,input[31:0] addr,input[31:0] data_in,input write_en,input read_en,input[1:0] control,
                      output reg[31:0] data_out);


//////////////////////////////////////// Main Memory
  // Inputs to main memory
  reg[31:0]   mm_addr ;
  reg[127:0] mm_data_in;
  reg mm_write_en;
  reg mm_read_en;
  wire [127:0] mm_data_out;

  // Instantiate the main memory module
  main_memory mm(.clk(clk), .reset(reset),
                 .addr(mm_addr), .data_in(mm_data_in),
                 .write_en(mm_write_en),.read_en(mm_read_en), .data_out(mm_data_out));
  
 ////////////////////////////////////// Cache memory
  reg [31:0] memory [0:15][0:3];

  // Address decoder
  wire [27:0] block_addr;
  wire [1:0] word_addr;
  wire [1:0] byte_addr;
  wire [3:0] cache_index;
  wire [23:0] cache_tag;

  
  assign block_addr = addr[31:4];
  assign word_addr = addr[3:2];
  assign byte_addr = addr[1:0];
  assign cache_index = block_addr[3:0];
  assign cache_tag = block_addr[27:4];

  // Tag memory
  reg [23:0] tag_memory [0:15];
    reg valid_cache[0:15];
//////////////////////////////////////Victim Cache
    reg [31:0] vc_memory [0:3][0:3];

// Address decoder
    wire [1:0] vc_index;
    wire [25:0] vc_tag;
    assign vc_index = block_addr[1:0];
    assign vc_tag = block_addr[27:2];
// Tag memory
    reg [25:0] vc_tag_memory [0:3];

  // State machine
    reg [2:0] state ;

 initial begin
    state = 3'b0;
 end
 always @(posedge clk) begin

    case (state)
      3'b000: begin
        if (write_en) begin  
                if (valid_cache[cache_index] && (tag_memory[cache_index] !=cache_tag))  begin
             
                    vc_memory[vc_index][0] = memory[cache_index][0];
                    vc_memory[vc_index][1] = memory[cache_index][1];
                    vc_memory[vc_index][2] = memory[cache_index][2];
                    vc_memory[vc_index][3] = memory[cache_index][3];
                    vc_tag_memory[vc_index]={tag_memory[cache_index],cache_index[3:2]};
                    mm_addr = addr;
      //              mm_data_in = data_in;
                    mm_write_en = 0;
                    mm_read_en = 1;
                    state = 3'b111;
                end
                else begin
               
                    memory[cache_index][word_addr] = data_in ;
                    tag_memory[cache_index] = cache_tag;
                    valid_cache[cache_index] = 1'b1;
                    mm_addr = addr;
                    mm_data_in = {memory[cache_index][0],memory[cache_index][1],memory[cache_index][2],memory[cache_index][3]};
                    mm_write_en = write_en;
                    mm_read_en = read_en;
                    state = 3'b000;
                
                end


        end
        else if(read_en) begin
          // Check if data is in cache memory
          if (tag_memory[cache_index] == cache_tag) begin
            $display("Read from cache");
            data_out = memory[cache_index][word_addr];
            state = 3'b000;
          end
          else begin
          // Check if data is in victim cache
            if (vc_tag_memory[vc_index]==vc_tag) begin
              $display("Read from victim cache");
              data_out = vc_memory[vc_index][word_addr];
              $display("Read from victim cache %h",vc_memory[vc_index][word_addr]);
              memory[cache_index][word_addr] = vc_memory[vc_index][word_addr];
              tag_memory[cache_index] = cache_tag;
              state = 3'b000;
            end
            else begin
              // Data is not in cache or victim cache, need to fetch from main memory
              mm_addr = addr;
//              mm_data_in = data_in;
              mm_write_en = write_en;
              mm_read_en = read_en;
              if(valid_cache[cache_index]) begin
                   vc_memory[vc_index][0] = memory[cache_index][0];
                   vc_memory[vc_index][1] = memory[cache_index][1];
                   vc_memory[vc_index][2] = memory[cache_index][2];
                   vc_memory[vc_index][3] = memory[cache_index][3];
                   vc_tag_memory[vc_index]=vc_tag;
              end
              state = 3'b100;
            end
          end
        end
      end
      3'b001: begin // Cache Write
        memory[cache_index][word_addr] = data_in ;
        tag_memory[cache_index] = cache_tag;
        valid_cache[cache_index] = 1'b1;
        mm_addr = addr;
        mm_data_in = {memory[cache_index][0],memory[cache_index][1],memory[cache_index][2],memory[cache_index][3]};
        $display("Write to mem %b",mm_data_in);
        mm_write_en = write_en;
        mm_read_en = read_en;
        state = 3'b000;
      end
      3'b010: begin
        data_out = memory[cache_index][word_addr];
        state = 3'b000;
      end
      3'b100: begin // Main memory Read
        memory[cache_index][0] = mm_data_out[127:96]; 
        memory[cache_index][1] = mm_data_out[95:64]; 
        memory[cache_index][2] = mm_data_out[63:32];
        memory[cache_index][3] = mm_data_out[31:0]; 
        tag_memory[cache_index] = cache_tag;
        state = 3'b010;
      end
      3'b101: begin // Victim Cache Read
//        memory[cache_index][word_addr] = vc_memory[vc_index][word_addr];
//        tag_memory[cache_index] = cache_tag;
        state = 3'b000;
      end
      3'b111: begin // Read Before Write
        $display("Read before write %b",mm_data_out);
        memory[cache_index][0] = mm_data_out[127:96]; 
        memory[cache_index][1] = mm_data_out[95:64]; 
        memory[cache_index][2] = mm_data_out[63:32];
        memory[cache_index][3] = mm_data_out[31:0]; 
        tag_memory[cache_index] = cache_tag;
        state = 3'b001;
      end
    endcase
  end

  // Reset logic
  always @(posedge clk) begin
    if (reset) begin
      state <= 3'b000;
    end
  end


endmodule