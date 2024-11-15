import subprocess

# Step 1: Compile the Verilog file using Icarus Verilog
verilog_file = 'test.v'
output_executable = 'test_out'
compile_command = ['iverilog', '-o', output_executable, verilog_file]

try:
    compile_result = subprocess.run(compile_command, check=True, capture_output=True, text=True)
    print("Compilation Output:\n", compile_result.stdout)
except subprocess.CalledProcessError as e:
    print("Compilation failed with error:\n", e.stderr)
    exit(1)

# Step 2: Run the compiled executable and capture the output
run_command = ['vvp', output_executable]
try:
    run_result = subprocess.run(run_command, check=True, capture_output=True, text=True)
    simulation_output = run_result.stdout
    print("Simulation Output:\n", simulation_output)

    # Step 3: Save the output to a file
    with open('verilog_output.txt', 'w') as file:
        file.write(simulation_output)
    print("Output saved to verilog_output.txt")

except subprocess.CalledProcessError as e:
    print("Simulation failed with error:\n", e.stderr)
