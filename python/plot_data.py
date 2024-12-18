# Description: This script is used to load and plot data from a CSV or VCD file.
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from vcd.reader import TokenKind
import spike_data


inpt = 'sine'
file_path = f'sim_res/output_waveforms_{inpt}.csv'

# function to plot spike rasters from waveform data
def plot_spike_raster(spike_data, save_figs, title='Spike Raster Plot', xlabel='Time (s)', ylabel='Neuron Index', win=[100, 1100]):
    spikes = spike_data.spike_times
    mean_cor = spike_data.get_correlation()
    f, (a0, a1) = plt.subplots(2, 1, height_ratios=[3,1], figsize=(30,6))
    for i in range(spikes.shape[1]):
        a0.plot((i+1)*spikes[win[0]:win[1], i], '|', linewidth=0.5, label='Neuron ' + str(i))
    a0.set_xlabel(xlabel)
    a0.set_ylabel(ylabel)
    a0.legend(loc='upper right', ncol = 2)
    a1.plot(mean_cor[win[0]:win[1]])
    a1.set_xlabel('Time (s)')
    a1.set_ylabel('Correlation')
    plt.suptitle(title)
    if save_figs:
        plt.savefig(f'plots/spike_raster_{inpt}.png')
    plt.show()

# function to plot spike histograms from waveform data
def plot_spike_rate_histogram(spike_data, save_figs, bins=50, title='Spike Histogram', xlabel='Frequency', ylabel='Frequency', win=[100, 1100]):
    av_spike_rates = np.mean(spike_data.spike_rates, axis=1)
    plt.figure()
    plt.hist(av_spike_rates, bins=bins)
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    if save_figs:
        plt.savefig(f'plots/spike_rate_hist_{inpt}.png')
    plt.show()

# function to plot spike rates from waveform data
def plot_spike_rates(spike_data, save_figs, title='Spike Rates', xlabel='Time (s)', ylabel='Rate (Hz)', win=[100, 1100]):
    spike_rates = spike_data.spike_rates    
    pv = get_population_vector(spike_data)
    plt.figure(figsize=(30,5))
    for i in range(spike_rates.shape[1]):
        plt.plot(spike_data.time[win[0]:win[1]], spike_rates[win[0]:win[1], i]+(i*0.2), linestyle='dotted', label='Neuron ' + str(i), alpha=0.5)
    plt.plot(spike_data.time[win[0]:win[1]], pv[win[0]:win[1],1]-0.25, label='Population Rate')
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.legend()
    plt.grid()
    if save_figs:
        plt.savefig(f'plots/spike_rates_{inpt}.png')
    plt.show()



def plot_population_vector(spike_data, save_figs, fr = (100, 1100)):
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
    if save_figs:
        plt.savefig(f'plots/population_vector_{inpt}.png')
    plt.show()

# function to plot phase diagram of population activity
def plot_phase_diagram(spike_data, save_figs):
    pv = get_population_vector(spike_data)
    plt.figure(figsize=(25,6))
    plt.plot(pv[:,0], pv[:,1])
    plt.title('Phase Diagram')
    plt.xlabel('Activity')
    plt.ylabel('Rate')
    plt.grid()
    if save_figs:
        plt.savefig(f'plots/phase_diagram_{inpt}.png')
    plt.show()




if __name__ == '__main__':
    # save figs?
    save_figs = True   
    
    # load data from file
    spike_data = spike_data.spikeData(file_path)
    print(f"Average spike rate: {np.mean(spike_data.spike_rates, axis=1)}")
    print(f"Variance spike rate: {np.var(spike_data.spike_rates, axis=1)}")
    print(f"Average spike time: {np.mean(spike_data.spike_times, axis=1)}")
    print(f"Variance spike time: {np.var(spike_data.spike_times, axis=1)}")
    # plot spike raster
    plot_spike_raster(spike_data, save_figs)
    # plot spike rate histogram
    # plot_spike_rate_histogram(spike_data, save_figs)
    # # plot spike rates
    plot_spike_rates(spike_data, save_figs)
    # plot phase diagram
    # plot_phase_diagram(spike_data, save_figs)
    plot_population_vector(spike_data, save_figs)


    


