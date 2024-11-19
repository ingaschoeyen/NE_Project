`timescale 1ns/1ps

module tb_top_level_narma_system;
  // Testbench signals
  reg clk;
  reg reset;
  wire [15:0] narma_output;
  wire [31:0] bitstream_input;
  
  // Instantiate the top-level NARMA system
  top_level_narma_system uut (
    .clk(clk),
    .reset(reset),
    .narma_output(narma_output)
  );
  
  // Instantiate bitstream converter
  bitstream_converter converter (
    .y_t(narma_output),
    .bitstream_out(bitstream_input)
  );
  
  // Clock generation
  initial begin
    clk = 0;
    forever #10 clk = ~clk; // 10ns period (100 MHz clock)
  end
  
  // Test procedure
  initial begin
    
    // Initialize waveform dumping for simulation
    $dumpfile("tb_top_level_narma_system.vcd");
    $dumpvars(0, tb_top_level_narma_system);
    
    // Reset sequence
    reset = 1;
    #20; // Hold reset for 20ns
    reset = 0;
    
    // Run simulation for a certain duration
    #2000; // Run for 2000ns
    
    // End simulation
    $finish;
  end
  
  // Monitor outputs in both hexadecimal and decimal formats
  initial begin
    $monitor("Time = %0t ns, NARMA Output (hex) = %0h", $time, narma_output);
  end
  
  // Optional: Conversion to float representation if needed
  function real convert_to_real(input [15:0] fixed_point_value);
    begin
      
      // Assumes the fixed-point value is scaled (e.g., divide by 2^10 to convert)
      convert_to_real = fixed_point_value / 1024.0;
    end
  endfunction
  
  always @(posedge clk) begin
    if (!reset) begin
      $display("Time = %0t ns, NARMA Output as float = %f", $time, convert_to_real(narma_output));
    end
  end
endmodule
