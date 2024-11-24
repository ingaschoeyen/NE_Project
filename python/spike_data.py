import numpy as np
import pandas as pd

file_path = 'sim_res/output_waveforms_sine.csv'
class spikeData():
    def __init__(self, file_path, w=10):
        data_array = self.load_data(file_path)
        self.time = data_array[:, 0]
        self.input_signal = data_array[:, 1]
        self.spike_times = data_array[:, 2:]
        self.spike_rates = np.array([np.convolve(self.spike_times[:, i], np.ones(w), 'same') / w for i in range(self.spike_times.shape[1])]).T


    def load_data(self, file_path):
        if 'csv' in file_path:
            dataset = pd.read_csv(file_path, header=None)
            data_frame = pd.DataFrame(dataset)
            data_array = np.array(data_frame.values)
            print(data_array.shape)
        elif 'vcd' in file_path:
            print('VCD file type not supported yet, mayebe in the future')
            exit(1)
        else:
            print('File type not supported')
            exit(1)
        return data_array

    def compute_spike_rates(self):
        for i in range(self.spike_times.shape[1]):
            # sliding window of 10ms
            w = 10
            self.spike_rates[:,i] = np.convolve(self.spike_times[:, i], np.ones(w), 'same') / w

if __name__ == '__main__':

    spike_data = spikeData(file_path)
    print(spike_data.spike_times.shape)
    print(spike_data.spike_rates.shape)
    print(spike_data.input_signal.shape)
    print(spike_data.time.shape)
