`timescale 1ns/1ps

module top_level_ESN_system;
  // Testbench signals
  reg clk = 1'b0;
  reg rst;
  reg [7:0] freq_control;
  wire [31:0] bitstream_out;
  reg [31:0] ext_input = 32'h00000000;
  wire [15:0] step_wave_out;
  wire [9:0] i_outs;    // Outputs from each neuron, connected cyclically. Size = N neurons
  
  // Seeds for LFSR instances
  reg [15:0] seed1 = 16'hACE1;
  reg [15:0] seed2 = 16'hBEEF;
  reg [15:0] seed3 = 16'hC0DE;
  reg [15:0] seed4 = 16'hDEAD;
  reg [15:0] seed5 = 16'hFACE;
  reg [15:0] seed6 = 16'h1234;
  reg [15:0] seed7 = 16'h5678;
  reg [15:0] seed8 = 16'h9ABC;
  reg [15:0] seed9 = 16'hDEF0;
  reg [15:0] seed10 = 16'hFEDC;
  
  // Output wires from each neuron
  wire signed [31:0] VOUT1, VOUT2, VOUT3, VOUT4, VOUT5;
  wire signed [31:0] VOUT6, VOUT7, VOUT8, VOUT9, VOUT10;
  reg [7:0] sp_in_1, sp_in_2, sp_in_3, sp_in_4, sp_in_5;
  reg [7:0] sp_in_6, sp_in_7, sp_in_8, sp_in_9, sp_in_10;
  
  // File handle for CSV output
  integer csv_file;
  
  // Instantiate the top module
  top_module uut (
    .clk(clk),
    .rst(rst),
    .freq_control(freq_control),
    .bitstream_out(bitstream_out),
    .step_wave_out(step_wave_out)
  );
  
  // Instantiate 10 LIF neurons and connect them cyclically
  lif_neuron neuron1(
    .sp_in(sp_in_1), // Input connected to output of neuron10
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .req_seed(seed1),
    .VOUT(VOUT1),
    .i_out(i_outs[0])
  );

  lif_neuron neuron2(
    .sp_in(sp_in_2),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .req_seed(seed2),
    .VOUT(VOUT2),
    .i_out(i_outs[1])
  );

  lif_neuron neuron3(
    .sp_in(sp_in_3),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .req_seed(seed3),
    .VOUT(VOUT3),
    .i_out(i_outs[2])
  );
  
  lif_neuron neuron4(
    .sp_in(sp_in_4),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .req_seed(seed4),
    .VOUT(VOUT4),
    .i_out(i_outs[3])
  );

  lif_neuron neuron5(
    .sp_in(sp_in_5),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .req_seed(seed5),
    .VOUT(VOUT5),
    .i_out(i_outs[4])
  );

  lif_neuron neuron6(
    .sp_in(sp_in_6),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .req_seed(seed6),
    .VOUT(VOUT6),
    .i_out(i_outs[5])
  );
  
  lif_neuron neuron7(
    .sp_in(sp_in_7),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .req_seed(seed7),
    .VOUT(VOUT7),
    .i_out(i_outs[6])
  );

  lif_neuron neuron8(
    .sp_in(sp_in_8),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .req_seed(seed8),
    .VOUT(VOUT8),
    .i_out(i_outs[7])
  );

  lif_neuron neuron9(
    .sp_in(sp_in_9),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .req_seed(seed9),
    .VOUT(VOUT9),
    .i_out(i_outs[8])
  );

  lif_neuron neuron10(
    .sp_in(sp_in_10),
    .ext_input(ext_input),
    .clk(clk),
    .rst(rst),
    .req_seed(seed10),
    .VOUT(VOUT10),
    .i_out(i_outs[9])
  );
  
  // Test procedure
  initial begin
    
    // Open CSV file for writing
    csv_file = $fopen("sim_res/output_waveforms_step.csv", "w");
    if (!csv_file) begin
      $display("Error: Could not open CSV file for writing.");
      $finish;
    end
    
    // Write CSV header
    $fwrite(csv_file, "Time (ns), Step Input (Float), Bits\n");
    
    // Initialize waveform dumping for simulation
    $dumpfile("verilog_out/top_level_ESN_system_step.vcd");
    $dumpvars(0, top_level_ESN_system);
    
    // Reset sequence
    rst = 1;
    freq_control = 8'b00000101; // Default frequency control update every 5th clock cycle

    #5; // Hold reset for 20ns
    rst = 0;
    
    // Run simulation for a certain duration
    #50000; // Run
    
    // Close the CSV file
    $fclose(csv_file);
    
    // End simulation
    $finish;
  end
  
  always
    begin
      #10 clk = ~clk; // Generate clock signal with 90 time unit period
      
      ext_input = bitstream_out;
      
      sp_in_1 = {7'b0, i_outs[9]};
      sp_in_2 = {7'b0, i_outs[0]};
      sp_in_3 = {7'b0, i_outs[1]};
      sp_in_4 = {7'b0, i_outs[2]};
      sp_in_5 = {7'b0, i_outs[3]};
      sp_in_6 = {7'b0, i_outs[4]};
      sp_in_7 = {7'b0, i_outs[5]};
      sp_in_8 = {7'b0, i_outs[6]};
      sp_in_9 = {7'b0, i_outs[7]};
      sp_in_10 = {7'b0, i_outs[8]};
  end

integer i;

// Monitor outputs in floats and write to CSV
always @(posedge clk) begin
  if (!rst) begin
    $fwrite(csv_file, "%0t, %0f", $time, convert_to_real(step_wave_out));
    for (i = 0; i < 10; i = i + 1) begin
      $fwrite(csv_file, ", %0b", i_outs[i]);
    end
    $fwrite(csv_file, "\n");
  end
end
  
  
  // Optional: Conversion to float representation if needed
  function real convert_to_real(input [15:0] fixed_point_value);
    begin
      // Assumes the fixed-point value is scaled (divide by 2^10 to convert)
      convert_to_real = fixed_point_value / 1024.0;
    end
  endfunction
endmodule
