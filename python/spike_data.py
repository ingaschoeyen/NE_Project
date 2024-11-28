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
        self.population_vector = self.get_population_vector()
        self.correlation = self.get_correlation()
        self.tuning_curves = self.get_tuning_curves()

    def load_data(self, file_path):
        if 'csv' in file_path:
            dataset = pd.read_csv(file_path, header=None)
            data_frame = pd.DataFrame(dataset)
            data_array = np.array(data_frame.values)
            print(f"Shape of data:{data_array.shape}")
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

    def get_population_vector(self):
        population_vector = np.zeros((self.spike_times.shape[0], 2))
        spike_times = self.spike_times
        spike_rates = self.spike_rates
        population_vector[:,0] = np.mean(spike_times, axis=1)
        population_vector[:,1] = np.mean(spike_rates, axis=1)
        return population_vector

    def get_correlation(self):
        T = self.spike_times.shape[0]
        N = self.spike_times.shape[1]
        window_size = 500
        spike_trains = self.spike_times
        mean_corrs = []
        for t in range(self.spike_times.shape[0]):
            if t < window_size // 2 or t >= T - window_size // 2:
                # Skip edges if using a window
                mean_corrs.append(np.nan)
            else:
                # Extract activity in the window
                window_data = spike_trains[t - window_size // 2:t + window_size // 2, :]
                # Pairwise correlations
                corr_matrix = np.corrcoef(window_data, rowvar=False)
                # Compute mean of upper triangle (excluding diagonal)
                mean_corr = np.mean(corr_matrix[np.triu_indices(N, k=1)])
                mean_corrs.append(mean_corr)
        return np.array(mean_corrs)


    def get_tuning_curves(self):
        input = self.input_signal
        spike_rates = self.spike_rates
        tuning_curves = np.zeros((input.shape[0], spike_rates.shape[1]))


if __name__ == '__main__':

    spike_data = spikeData(file_path)
    print(spike_data.spike_times.shape)
    print(spike_data.spike_rates.shape)
    print(spike_data.input_signal.shape)
    print(spike_data.time.shape)
