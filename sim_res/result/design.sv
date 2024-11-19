// LFSR Module for Generating Pseudo-Random Input
module lfsr_random_input (
  input wire clk,
  input wire rst,
  output reg [15:0] lfsr_out
);
  reg [15:0] lfsr = 16'hACE1; // Initial seed for LFSR
  
  always @(posedge clk or negedge rst) begin
    if (rst) begin
      lfsr <= 16'hACE1; // Reset LFSR to initial seed
    end else begin
      // Feedback calculation for 16-bit LFSR (x^16 + x^14 + x^13 + x^11 + 1)
      lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
    end
    lfsr_out <= lfsr >> 1; // Scale to range [0, 0.5] by dividing by 2
  end
endmodule


// NARMA-10 Generator Module
module narma10_generator (
  input wire clk,
  input wire rst,
  input wire [15:0] u_t, // Input from LFSR
  output reg [15:0] y_t // 16-bit output representing the NARMA output
);
  parameter N = 10; // Order of the NARMA series
  reg [15:0] y_history [0:N-1]; // Buffer to hold past outputs
  reg [15:0] u_history [0:N-1]; // Buffer to hold past inputs
  
  integer i;
  
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // Initialize histories
      for (i = 0; i < N; i = i + 1) begin
        y_history[i] <= 16'd0;
        u_history[i] <= 16'd0;
      end
      y_t <= 16'd0;
    end else begin
      // Shift history buffers
      for (i = N-1; i > 0; i = i - 1) begin
        y_history[i] <= y_history[i-1];
        u_history[i] <= u_history[i-1];
      end
      u_history[0] <= u_t;
      
      // NARMA-10 computation: y(t+1) = 0.5*y(t) + 0.3*y(t) * sum(y(t-1) to y(t-9)) + 0.8*u(t-9)*u(t) + 0.1
      y_t <= (5 * y_history[0] / 10) +
      ((3 * y_history[0] * (y_history[1] + y_history[2] + y_history[3] +
                            y_history[4] + y_history[5] + y_history[6] +
                            y_history[7] + y_history[8] + y_history[9])) / 10) +
      (8 * u_history[9] * u_history[0] / 10) +
      (1 << 10); // Adding 0.1 as fixed-point representation
      y_history[0] <= y_t; 
    end
  end
endmodule


// Top-level Module to Integrate LFSR with NARMA
module top_level_narma_system (
  input wire clk,
  input wire rst,
  output wire [15:0] narma_output
);
  wire [15:0] lfsr_output;
  
  // Instantiate LFSR module
  lfsr_random_input lfsr_inst (
    .clk(clk),
    .rst(rst),
    .lfsr_out(lfsr_output)
  );
  
  // Instantiate NARMA-10 generator module
  narma10_generator narma_gen (
    .clk(clk),
    .rst(rst),
    .u_t(lfsr_output),
    .y_t(narma_output)
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
      num_on_bits = (y_t * 32) >> 16; // Ensure y_t is scaled proportionally to 32-bit range
      
      // Initialize bitstream_out with all bits off
      bitstream_out = 32'b0;
      // Turn on the calculated number of bits from the most significant bit down
      for (i = 0; i < num_on_bits; i = i + 1) begin
        bitstream_out[i] = 1'b1;
      end
    end
  end
endmodule


module lif_neuron(i_in, ext_input, clk, rst, VOUT, i_out);
  input [7:0] i_in; // Allow 8 input signals, represented as on/off
  input [31:0] ext_input;      // 32-bit bitstream input from ARMA function
  input clk;
  input rst;
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
  reg signed [31:0] a_delayed; // Delayed adder output
  reg signed [31:0] ext_a; // Adder output for ext_input

  // clock
  parameter s0 = 8'h00;
  parameter s1 = 8'h01;
  parameter s2 = 8'h02;

  wire [7:0] p_s;
  reg [7:0] n_s;

  assign p_s = n_s;
  always @(posedge clk or posedge rst)
  begin
    if (rst) begin
      n_s <= s0;
      i_out <= 1'b0; // Initialize i_out to 0 on reset
      a_delayed <= 32'h00000000; // Initialize delayed adder output
    end else begin
      case (p_s)
              s0: begin
                  // Idle / refractory period
                  i_out <= 1'b0;
                  n_s <= s1;
              end
              s1: begin
                // Accumulate weighted inputs
                a = 32'h00000000;
                for (n = 0; n < 8; n++)
                  begin
                      a = a + (i_in[n] * w);
                  end
                
                a_delayed <= a;
                
                // Accumulate weighted inputs from ext_input
                ext_a = 32'h00000000;
                for (i = 0; i < 32; i++) 
                  begin
                    ext_a = ext_a + (ext_input[i] * ext_w);
                  end
               
                
                // Integrate
                if (a_delayed + ext_a > 0)
                  begin
                      v <= v + a_delayed + ext_a;
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

                  VOUT <= v;

                  if (v >= Vth)
                  begin
                      n_s <= s2;
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
