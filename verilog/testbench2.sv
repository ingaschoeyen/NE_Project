module RSNN();
  reg rst;
  reg clk = 1'b0;
  reg [7:0] ext_input1 = 6'b000000; // External input to the network
  reg [7:0] ext_input2 = 6'b000000; // External input to the network
  reg [7:0] ext_input3 = 6'b000000; // External input to the network
  // Internal signals
  wire signed [31:0] VOUT_1, VOUT_2, VOUT_3; // Outputs of each neuron
  wire i_out_1, i_out_2, i_out_3; // Spike signals from each neuron
  reg [7:0] i_in_1, i_in_2, i_in_3; // Inputs to each neuron
 
  // Instantiate the neurons
  SLIF_unipolar_multi neuron1 (
      .i_in(i_in_1), 
      .clk(clk), 
      .rst(rst), 
      .VOUT(VOUT_1), 
      .i_out(i_out_1)
    );
    
  SLIF_unipolar_multi neuron2 (
    .i_in(i_in_2), 
    .clk(clk), 
    .rst(rst), 
    .VOUT(VOUT_2), 
    .i_out(i_out_2)
  );
  
  SLIF_unipolar_multi neuron3 (
    .i_in(i_in_3), 
    .clk(clk), 
    .rst(rst), 
    .VOUT(VOUT_3), 
    .i_out(i_out_3)
  );
  
  initial
  begin
    // Enable waveform dumping for simulation
    $dumpfile("dump.vcd");
    $dumpvars(0, RSNN); // Record all signals in the testbench module
    
    rst = 1'b0;
    
    
    #5 rst = 1'b1;
    #1000 ext_input1 = 6'b000001;
    #1500 ext_input2 = 6'b000001;
    #2000 ext_input3 = 6'b000001; // 1500 time units later, enable one input
    
    #10000; // Stop simulation after 10000 time units
    $finish; // Gracefully terminate the simulation
    
  end
  
  always
    begin
      #50 clk = ~clk; // Generate clock signal with 90 time unit period
      
      i_in_1 = {ext_input1, i_out_2, i_out_3};
      
      // Connect outputs of neurons as inputs to others for recurrent behavior
      i_in_2 = {ext_input2, i_out_1, i_out_3}; // Example: output of neuron 1 as input to neuron 2
      i_in_3 = {ext_input3, i_out_1, i_out_2}; // output of neuron 2 as input to neuron 3
  end

endmodule
