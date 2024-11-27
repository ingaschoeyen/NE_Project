import os
import subprocess
import pandas as pd

# Get the absolute path to the directory containing the script
script_dir = os.path.dirname(os.path.abspath(__file__))

# input signal form
inpt = 'narma'

# Paths to the Verilog folder and files
project_dir = os.path.dirname(script_dir)  # Move one level up to the project directory
verilog_folder = os.path.join(project_dir, "verilog")
testbench_file = os.path.join(verilog_folder, f"testbench_{inpt}.sv")
design_file = os.path.join(verilog_folder, f"design_{inpt}.sv")

# Output directory for simulation
output_csv = os.path.join(project_dir, "sim_res")
output_vcd = os.path.join(project_dir, "verilog_out")
os.makedirs(output_csv, exist_ok=True)
os.makedirs(output_vcd, exist_ok=True)

# VCD (Value Change Dump) file and CSV output file
vcd_file = os.path.join(output_vcd, f"top_level_ESN_system_{inpt}.vcd")
csv_file = os.path.join(output_csv, f"output_waveforms_{inpt}.csv")

# Compile and run the Verilog files using Icarus Verilog
def run_verilog_simulation():
    # Compile command
    compile_cmd = ["iverilog", "-o", os.path.join(output_vcd, "sim.out"), testbench_file, design_file]
    print("Compiling Verilog files...")
    subprocess.run(compile_cmd, check=True)

    # Run the simulation
    run_cmd = ["vvp", os.path.join(output_vcd, "sim.out")]
    print("Running simulation...")
    with open(csv_file, "w") as csv_output:
        subprocess.run(run_cmd, stdout=csv_output, check=True)
    print("Simulation completed!")

# Clean CSV output (if required)
def parse_csv_output(csv_path):
    print("Cleaning CSV output...")
    # remove first two lines from csv file
    with open(csv_path, "r") as f:
        lines = f.readlines()
    with open(csv_path, "w") as f:
        f.writelines(lines[2:])
    print("CSV output cleaned!")

# Main function to execute
if __name__ == "__main__":
    try:
        # Run the simulation
        run_verilog_simulation()
        parse_csv_output(csv_file)
    except Exception as e:
        print(f"Error during simulation: {e}")
