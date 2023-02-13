// hextoSevenSegDis
module seven_segment_display(
  input[3:0] digit,
  output reg [6:0] segments
);

  always @(digit) begin
    case (digit)
      4'b0000: segments = 7'b1000000;
      4'b0001: segments = 7'b1111001;
      4'b0010: segments = 7'b0100100;
      4'b0011: segments = 7'b0110000;
      4'b0100: segments = 7'b0011001;
      4'b0101: segments = 7'b0010010;
      4'b0110: segments = 7'b0000010;
      4'b0111: segments = 7'b1111000;
      4'b1000: segments = 7'b0000000;
      4'b1001: segments = 7'b0010000;
      4'b1010: segments = 7'b0001000;
      4'b1011: segments = 7'b0000011;
      4'b1100: segments = 7'b1000110;
      4'b1101: segments = 7'b0100001;
      4'b1110: segments = 7'b0000110;
		4'b1111: segments = 7'b0001110;
      
    endcase
  end

endmodule