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
    plt.figure(figsize=(25,6))
    for i in range(spike_rates.shape[1]):
        plt.plot(1e-9*spike_data.time, spike_rates[:, i], label='Neuron ' + str(i))
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.legend()
    plt.grid()
    plt.show()



def plot_population_vector(spike_data, fr = (0, 10000)):
    pv = get_population_vector(spike_data)
    plt.figure(figsize=(30,3))
    plt.subplot(2,1,1)
    plt.plot(1e-9*spike_data.time[fr[0]:fr[1]], pv[fr[0]:fr[1],0], label='Activity')
    plt.plot(1e-9*spike_data.time[fr[0]:fr[1]], 6e-3*spike_data.input_signal[fr[0]:fr[1]], label='Input Signal')
    plt.legend()
    plt.xlabel('Time (s)')
    plt.ylabel('Activity')
    plt.grid()
    plt.subplot(2,1,2)
    plt.plot(1e-9*spike_data.time[fr[0]:fr[1]], pv[fr[0]:fr[1],1], label='Rate')
    plt.suptitle('Population Dynamics')
    plt.xlabel('Time (s)')
    plt.ylabel('Rate')
    plt.grid()
    plt.show()

# function to plot phase diagram of population activity
def plot_phase_diagra(spike_data):
    pv = get_population_vector(spike_data)
    plt.figure(figsize=(25,6))
    plt.plot(pv[:,0], pv[:,1])
    plt.title('Phase Diagram')
    plt.xlabel('Activity')
    plt.ylabel('Rate')
    plt.grid()
    plt.show()


def get_population_vector(spike_data):
    population_vector = np.zeros((spike_data.spike_times.shape[0], 2))
    spike_times = spike_data.spike_times
    spike_rates = spike_data.spike_rates
    population_vector[:,0] = np.mean(spike_times, axis=1)
    population_vector[:,1] = np.mean(spike_rates, axis=1)
    return population_vector



if __name__ == '__main__':
    # load data from file
    spike_data = spike_data.spikeData(file_path)
    print(f"Average spike rate: {np.mean(spike_data.spike_rates, axis=1)}")
    print(f"Variance spike rate: {np.var(spike_data.spike_rates, axis=1)}")
    print(f"Average spike time: {np.mean(spike_data.spike_times, axis=1)}")
    print(f"Variance spike time: {np.var(spike_data.spike_times, axis=1)}")
    # plot spike raster
    plot_spike_raster(spike_data)
    # plot spike rate histogram
    plot_spike_rate_histogram(spike_data)
    # # plot spike rates
    plot_spike_rates(spike_data)
    # plot phase diagram
    plot_phase_diagra(spike_data)
    plot_population_vector(spike_data)


    


