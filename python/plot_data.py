# Description: This script is used to load and plot data from a CSV or VCD file.
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from vcd.reader import TokenKind
import spike_data
# from nengo_extras.plot_spikes import plot_spikes


file_path = 'sim_res/output_waveforms_sine.csv'

# function to plot spike rasters from waveform data
def plot_spike_raster(spike_data, title='Spike Raster Plot', xlabel='Time (s)', ylabel='Neuron Index'):
    spikes = spike_data.spike_times
    plt.figure()
    for i in range(spikes.shape[1]):
        plt.scatter(spikes[:, i], i * np.ones_like(spikes[:, i]), color='k', s=2)
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.show()

# function to plot spike histograms from waveform data
def plot_spike_rate_histogram(spike_data, bins=50, title='Spike Histogram', xlabel='Frequency', ylabel='Frequency'):
    av_spike_rates = np.mean(spike_data.spike_rates, axis=1)
    plt.figure()
    plt.hist(av_spike_rates, bins=bins)
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.show()

# function to plot spike rates from waveform data
def plot_spike_rates(spike_data, title='Spike Rates', xlabel='Time (s)', ylabel='Rate (Hz)'):
    spike_rates = spike_data.spike_rates    
    plt.figure()
    for i in range(spike_rates.shape[1]):
        plt.plot(spike_data.time, spike_rates[:, i], label='Neuron ' + str(i))
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.legend()
    plt.grid()
    plt.show()

# function to plot phase diagram of population activity




if __name__ == '__main__':
    # load data from file
    spike_data = spike_data.spikeData(file_path)
    print(spike_data.spike_rates)
    # plot spike raster
    plot_spike_raster(spike_data)
    # plot spike rate histogram
    plot_spike_rate_histogram(spike_data)
    # plot spike rates
    plot_spike_rates(spike_data)


    


