module lfsr_req_generator (
  input wire clk,
  input wire rst,
  input wire [15:0] seed, // Seed for the LFSR
  output reg req
);
  reg [15:0] lfsr;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      lfsr <= seed; // Initialize LFSR with the seed
      req <= 0;
    end else begin
      // LFSR implementation (16-bit example with taps at positions 16 and 14)
      lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13]};
      req <= lfsr[0]; // Use the least significant bit as the REQ signal
    end
  end
endmodule

module sine_wave_generator (
  input wire clk,
  input wire rst,
  input wire [7:0] freq_control, // Frequency control: determines the number of clock cycles to wait before updating
  output reg [15:0] sine_wave_out
);
  reg [5:0] phase_accumulator; // 6-bit phase accumulator for 64 steps
  reg [15:0] sine_lut [0:63]; // Look-up table for sine values
  reg [7:0] clk_divider; // 8-bit Clock divider counter

  initial begin
    // Initialize the sine LUT with precomputed sine values
    // Values should be scaled to fit within 16 bits
    sine_lut[0]  = 16'h8000;
    sine_lut[1]  = 16'h8C8B;
    sine_lut[2]  = 16'h98F8;
    sine_lut[3]  = 16'hA527;
    sine_lut[4]  = 16'hB0FB;
    sine_lut[5]  = 16'hBC57;
    sine_lut[6]  = 16'hC71C;
    sine_lut[7]  = 16'hD133;
    sine_lut[8]  = 16'hDA82;
    sine_lut[9]  = 16'hE2F2;
    sine_lut[10] = 16'hEA6E;
    sine_lut[11] = 16'hF0E2;
    sine_lut[12] = 16'hF641;
    sine_lut[13] = 16'hFA7C;
    sine_lut[14] = 16'hFD89;
    sine_lut[15] = 16'hFF61;
    sine_lut[16] = 16'hFFFF;
    sine_lut[17] = 16'hFF61;
    sine_lut[18] = 16'hFD89;
    sine_lut[19] = 16'hFA7C;
    sine_lut[20] = 16'hF641;
    sine_lut[21] = 16'hF0E2;
    sine_lut[22] = 16'hEA6E;
    sine_lut[23] = 16'hE2F2;
    sine_lut[24] = 16'hDA82;
    sine_lut[25] = 16'hD133;
    sine_lut[26] = 16'hC71C;
    sine_lut[27] = 16'hBC57;
    sine_lut[28] = 16'hB0FB;
    sine_lut[29] = 16'hA527;
    sine_lut[30] = 16'h98F8;
    sine_lut[31] = 16'h8C8B;
    sine_lut[32] = 16'h8000;
    sine_lut[33] = 16'h7375;
    sine_lut[34] = 16'h6708;
    sine_lut[35] = 16'h5AD9;
    sine_lut[36] = 16'h4F05;
    sine_lut[37] = 16'h43A9;
    sine_lut[38] = 16'h38E4;
    sine_lut[39] = 16'h2ECD;
    sine_lut[40] = 16'h257E;
    sine_lut[41] = 16'h1D0E;
    sine_lut[42] = 16'h1592;
    sine_lut[43] = 16'h0F1E;
    sine_lut[44] = 16'h09BF;
    sine_lut[45] = 16'h057C;
    sine_lut[46] = 16'h0277;
    sine_lut[47] = 16'h009F;
    sine_lut[48] = 16'h0001;
    sine_lut[49] = 16'h009F;
    sine_lut[50] = 16'h0277;
    sine_lut[51] = 16'h057C;
    sine_lut[52] = 16'h09BF;
    sine_lut[53] = 16'h0F1E;
    sine_lut[54] = 16'h1592;
    sine_lut[55] = 16'h1D0E;
    sine_lut[56] = 16'h257E;
    sine_lut[57] = 16'h2ECD;
    sine_lut[58] = 16'h38E4;
    sine_lut[59] = 16'h43A9;
    sine_lut[60] = 16'h4F05;
    sine_lut[61] = 16'h5AD9;
    sine_lut[62] = 16'h6708;
    sine_lut[63] = 16'h7375;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      phase_accumulator <= 6'b0;
      sine_wave_out <= 16'b0;
      clk_divider <= 8'b0;
    end else begin
      if (clk_divider == freq_control) begin
        clk_divider <= 8'b0;
        phase_accumulator <= phase_accumulator + 6'b1; // Increment phase
        sine_wave_out <= sine_lut[phase_accumulator]; // Output sine value
      end else begin
        clk_divider <= clk_divider + 8'b1;
      end
    end
  end
endmodule

module top_module (
  input wire clk,
  input wire rst,
  input wire [7:0] freq_control, // Frequency control input
  output wire [31:0] bitstream_out
);
  wire [15:0] sine_wave;

  sine_wave_generator sine_gen (
    .clk(clk),
    .rst(rst),
    .freq_control(freq_control),
    .sine_wave_out(sine_wave)
  );

  bitstream_converter bitstream_conv (
    .y_t(sine_wave),
    .rst(rst),
    .bitstream_out(bitstream_out)
  );
endmodule


module bitstream_converter (
  input wire [15:0] y_t,
  input wire rst,
  output reg [31:0] bitstream_out
);
  integer num_on_bits;
  integer i;
  
  always @(*) begin
    if (rst) begin
      bitstream_out = 32'b0;
    end else begin
      // Scale y_t to determine the number of "on" bits in the 32-bit output.
      // The scaling factor should map y_t's maximum value to 32 bits fully "on".
      num_on_bits = (y_t * 32) >> 16; // Ensure y_t is scaled proportionally to 32-bit rang
      
      // Initialize bitstream_out with all half of the bits on
      bitstream_out = 32'b0;
      // Turn on the calculated number of bits from the most significant bit down
      for (i = 0; i < num_on_bits; i = i + 1) begin
        bitstream_out[i] = 1'b1;
      end
    end
  end
endmodule


module lif_neuron(sp_in, ext_input, clk, rst, req_seed, VOUT, i_out);
  input [7:0] sp_in; // Allow 8 input channels for spikes, represented as on/off
  input [31:0] ext_input;      // 32-bit bitstream input from ARMA function
  input clk;
  input rst;
  input [0:15] req_seed;
  output reg signed [31:0] VOUT; // The voltage across this neuron
  output reg i_out; // Output signal

  // initial condition
  reg signed [31:0] v = 	32'h00000000; // v=0;

  // LIF parameters
  reg signed [31:0] Vth = 	32'h0000fc93; // Threshold voltage = 0.98
  reg signed [31:0] leaky = 32'h00002000; // Leakage = 0.125
  reg signed [31:0] w = 	32'h00002000; // Input weight = 0.125
  reg signed [31:0] ext_w = 32'h00000100; // 128-bit weight with value 0.03125

  integer n;
  integer i;
  reg signed [31:0] a; // Adder output
  reg signed [31:0] ext_a; // Adder output for ext_input

  // clock
  parameter s0 = 8'h00;
  parameter s1 = 8'h01;
  parameter s2 = 8'h02;

  wire [7:0] p_s;
  reg [7:0] n_s;
  
  wire req;
  
  lfsr_req_generator req_gen (
    .clk(clk),
    .rst(rst),
    .seed(req_seed),
    .req(req)
  );

  assign p_s = n_s;
  always @(posedge clk or posedge rst)
  begin
    if (rst) begin
      n_s <= s0;
      i_out <= 1'b0; // Initialize i_out to 0 on reset
    end else begin
      case (p_s)
              s0: begin
                  // Idle / refractory period
                  i_out <= 1'b0;
                  n_s <= s1;
              end
              s1: begin
                if (req) begin
                // Accumulate weighted inputs
                a = 32'h00000000;
                for (n = 0; n < 8; n++)
                  begin
                    a = a + (sp_in[n] * w);
                  end
                
                // Accumulate weighted inputs from ext_input
                ext_a = 32'h00000000;
                for (i = 0; i < 32; i++) 
                  begin
                    ext_a = ext_a + (ext_input[i] * ext_w);
                  end
               
                
                // Integrate
                if (a + ext_a > 0)
                  begin
                      v <= v + a + ext_a;
                  end
                // Leaky
                else if (v > 0)
                  begin
                      v <= v - leaky;
                    
                    // Ensure that v >= 0
                    if (v < 0)
                      begin
                        v <= 32'h00000000;
                      end
                  end 
                
                // Ensure that v >= 0
                if (v < 0)
                  begin
                    v <= 32'h00000000;
                  end
                VOUT <= v;
                
                if (v >= Vth)
                  begin
                    n_s <= s2;
                  end
              end
              end
              s2: begin
                  // Fire
                  v <= 32'h00000000;
                  VOUT <= 32'h00000000;
                  i_out <= 1'b1;
                  n_s <= s0;
              end
          endcase
      end
  end
endmodule

