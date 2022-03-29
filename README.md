# dsp_xilinx_ip
Some basic DSP algorithms implemented with xilinx IP cores with explanation, Verilog testbenches and modelling in Python 

## Software

| Software | Version, plugins |
| ------ | ------ |
| CygWin | make, git |
| Python | Python 3.9.0, Numpy, matplotlib, scipy |
| Vivado | 2019.1 |

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
