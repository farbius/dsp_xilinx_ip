# dsp_xilinx_ip
Some basic DSP algorithms implemented with xilinx IP cores with explanation, Verilog testbenches and modelling in Python 

## Software

| Software | Version, plugins |
| ------ | ------ |
| CygWin | make, git |
| Python | Python 3.9.0, Numpy, matplotlib, scipy |
| Vivado | 2019.1 |

In Environment Variables (PATH variable) should be added path to bin folder of the Vivado IDE. For example:
```
C:\Xilinx\Vivado\2019.1\bin 
```
## List of DSP algorithms are used in the lections
```
Xilinx IP cores
 |
 +-dds compiler
 |      |
 |      +-IQ modulation / demodulation
 |      +-LFM, PSK, FSK modulations
 |
 +-fir compiler
 |      |
 |      +-Low, High, Band Pass FIR filters
 |      +-Decimation
 |      +-Interpolation
 |      +-Hilbert Transform
 |
 +-cic compiler
 |      |
 |      +-Decimation
 |      +-Interpolation
 |
 +-fft
 |      |
 |      +-FFT
 |      +-Inverse FFT
 ```
## Usage
After cloning the repository run in a directory run Cygwin terminal. Run MAKE command
```
make 
```
