# NE_Project
FInal Project for Neuromorphic Engineering 24/25 at Radboud


# Basic Idea

First try to replicate STDP on-chip in an FPGA

Then extend network architecture to RNN

Then if still time, make a testbench to get measures of dynamics for criticality analysis

# Setup of code

## Testbenches

## Designs

### Modules

# Test Plan

* Narma 10 too complex given time steps - too jittery, network will not capture it
    * Narma 2 is a good test for the network
    * alternatively, sine wave - could extend to negative values being inhibitory - frequency needs to be slow enough to let dynamics of network unfold
    * could also vary frequency of Narma, but need to adjust clock cicles then

* other issue - correlation of LIF neurons - need to decorrelate somehow
    * either add stochasticity
    * alternatively, include random request signal, and only update weights when request signal is high
        * can just be combination of LFSRs + gate to get lower probability of spikes
        * alternatively replace the clk signal with the request signal

* need to initialise weights randomly

* atm continuous input, no leakage