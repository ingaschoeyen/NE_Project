`timescale 1ns/1ps

module tb_top_level_narma_system;
  // Testbench signals
  reg clk;
  reg reset;
  wire [15:0] narma_output;
  wire [31:0] ext_input;
  wire [9:0] i_outs;    // Outputs from each neuron, connected cyclically. Size = N neurons
  
  // Output wires from each neuron
  wire [31:0] VOUT1, VOUT2, VOUT3, VOUT4, VOUT5;
  wire [31:0] VOUT6, VOUT7, VOUT8, VOUT9, VOUT10;
  
  // File handle for CSV output
  integer csv_file;
  
  // Instantiate the top-level NARMA system
  top_level_narma_system uut (
    .clk(clk),
    .reset(reset),
    .narma_output(narma_output)
  );
  
  // Instantiate bitstream converter
  bitstream_converter converter (
    .y_t(narma_output),
    .bitstream_out(ext_input)
  );
  
  // Instantiate 10 LIF neurons and connect them cyclically
  lif_neuron neuron1(
    .i_in({7'b0, i_outs[9]}), // Input connected to output of neuron10 (cyclic)
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .VOUT(VOUT1),
    .i_out(i_outs[0])
  );

  lif_neuron neuron2(
    .i_in({7'b0, i_outs[0]}),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .VOUT(VOUT2),
    .i_out(i_outs[1])
  );

  lif_neuron neuron3(
    .i_in({7'b0, i_outs[1]}),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .VOUT(VOUT3),
    .i_out(i_outs[2])
  );
  
  
  lif_neuron neuron4(
    .i_in({7'b0, i_outs[2]}),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .VOUT(VOUT4),
    .i_out(i_outs[3])
  );

  lif_neuron neuron5(
    .i_in({7'b0, i_outs[3]}),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .VOUT(VOUT5),
    .i_out(i_outs[4])
  );

  lif_neuron neuron6(
    .i_in({7'b0, i_outs[4]}),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .VOUT(VOUT6),
    .i_out(i_outs[5])
  );
  
  lif_neuron neuron7(
    .i_in({7'b0, i_outs[5]}),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .VOUT(VOUT7),
    .i_out(i_outs[6])
  );

  lif_neuron neuron8(
    .i_in({7'b0, i_outs[6]}),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .VOUT(VOUT8),
    .i_out(i_outs[7])
  );

  lif_neuron neuron9(
    .i_in({7'b0, i_outs[7]}),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .VOUT(VOUT9),
    .i_out(i_outs[8])
  );

  lif_neuron neuron10(
    .i_in({7'b0, i_outs[8]}),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .VOUT(VOUT10),
    .i_out(i_outs[9])
  );
  
  // Intantiate LIF Neurons
  
  // Clock generation
  initial begin
    clk = 0;
    forever #10 clk = ~clk; // 10ns period (100 MHz clock)
  end
  
  // Test procedure
  initial begin
    // Open CSV file for writing
    csv_file = $fopen("output_waveforms.csv", "w");
    if (!csv_file) begin
      $display("Error: Could not open CSV file for writing.");
      $finish;
    end
    
    // Write CSV header
    $fwrite(csv_file, "Time (ns), NARMA Output (Float), Bits\n");
    
    // Initialize waveform dumping for simulation
    $dumpfile("tb_top_level_narma_system.vcd");
    $dumpvars(0, tb_top_level_narma_system);
    
    // Reset sequence
    reset = 1;
    
    #20; // Hold reset for 20ns
    reset = 0;
    
    // Run simulation for a certain duration
    #2000; // Run for 2000ns
    
    // Close the CSV file
    $fclose(csv_file);
    
    // End simulation
    $finish;
  end
  
  // Monitor outputs in both hexadecimal and decimal formats and write to CSV
  always @(posedge clk) begin
    if (!reset) begin
      $display("Time = %0t ns, NARMA Output as float = %f", $time, convert_to_real(narma_output));
      $fwrite(csv_file, "%0t,%f,%0b\n", $time, convert_to_real(narma_output), bitstream_input);
    end
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
