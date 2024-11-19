import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from vcd.reader import TokenKind

file_path = 'sim_res/output_waveforms.csv'



def parse_vcd_to_numpy(vcd_file_path):
    signals = {}
    timestamps = []
    signal_data = {}

    with open(vcd_file_path, 'rbe') as vcd_file:
        reader = Reader(vcd_file)
        
        # Parse VCD content
        for token in reader:
            if token.kind == TokenKind.SCOPE:
                continue  # Ignore scopes
            elif token.kind == TokenKind.VAR:
                # Collect signal definitions
                signals[token.id_code] = token.reference
                signal_data[token.id_code] = []  # Initialize data storage
            elif token.kind == TokenKind.CHANGE:
                # Record signal value changes
                timestamps.append(token.timestamp)
                for change in token.changes:
                    signal_data[change.id_code].append(change.value)

    # Align all signals and timestamps into a numpy array
    unique_timestamps = sorted(set(timestamps))
    signal_ids = list(signals.keys())
    signal_matrix = np.zeros((len(unique_timestamps), len(signal_ids)), dtype=np.float32)

    for t_idx, time in enumerate(unique_timestamps):
        for s_idx, signal_id in enumerate(signal_ids):
            # Extract the value for the signal at the specific time (default 0)
            signal_matrix[t_idx, s_idx] = signal_data[signal_id][t_idx] if t_idx < len(signal_data[signal_id]) else 0

    return np.array(signal_matrix), unique_timestamps, signals

def parse_csv(csv_file_path):
    
    dataset = pd.read_csv(csv_file_path, header=None)
    data_frame = pd.DataFrame(dataset)
    data_array = np.array(data_frame.values)
    
    return data_array


if 'csv' in file_path:
    data_array = parse_csv(file_path)


if 'vcd' in file_path:
    signal_matrix, unique_timestamps, signals = parse_vcd_to_numpy(file_path)
    data_array = signal_matrix


plt.figure()
plt.plot(data_array)