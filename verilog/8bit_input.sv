// Code your design here
module SLIF_unipolar_multi(i_in, clk, rst, VOUT, i_out);
  input [7:0] i_in; // Allow 8 input signals, represented as on/off
  input clk, rst;
  output reg signed [31:0] VOUT; // The voltage across this neuron
  output reg i_out; // Output signal

  // initial condition
  reg signed [31:0] v = 	32'h00000000; // v=0;

  // LIF parameters
  reg signed [31:0] Vth = 	32'h0000fc93; // Threshold voltage = 0.98
  reg signed [31:0] leaky = 32'h00002000; // Leakage = 0.125
  reg signed [31:0] w = 	32'h00002000; // Input weight = 0.125

  integer n;
  reg signed [31:0] a; // Adder output

  // clock
  parameter s0 = 8'h00;
  parameter s1 = 8'h01;
  parameter s2 = 8'h02;

  wire [7:0] p_s;
  reg [7:0] n_s;

  assign p_s = n_s;
  always @(posedge clk or negedge rst)
  begin
      if (!rst)
          n_s <= s0;
      else if (clk)
      begin
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
                  // Integrate
                  if (a > 0)
                  begin
                      v <= v + a;
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

