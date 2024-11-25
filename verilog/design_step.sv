module step_function (
    input wire clk,           // Clock signal
    input wire reset,         // Reset signal
    output reg [31:0] step_wave_out     // 32-bit output
);
    parameter T = 64;         // Total number of clock cycles for the steps
    parameter MAX_STEPS = 32; // Maximum steps (final value)

    // Internal counter to track time steps
    reg [$clog2(T):0] counter;
    
    // Calculate step interval
    localparam STEP_INTERVAL = T / MAX_STEPS;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset output and counter
            out <= 0;
            counter <= 0;
        end else begin
            // Increment the counter
            counter <= counter + 1;

            // Increment the output when counter reaches step interval
            if (counter % STEP_INTERVAL == 0 && out < MAX_STEPS) begin
                out <= out + 1;
            end
        end
    end
endmodule

module top_module (
  input wire clk,
  input wire rst,
  input wire [7:0] freq_control, // Frequency control input
  output wire [31:0] bitstream_out,
  output wire [15:0] step_wave_out
);
  //wire [15:0] step_wave;

  step_function step_wave (
    .clk(clk),
    .rst(rst),
    .freq_control(freq_control),
    .step_wave_out(step_wave_out)
  );

  bitstream_converter bitstream_conv (
    .y_t(step_wave_out),
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