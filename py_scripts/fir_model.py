import numpy as np
import os
import sys
from scipy.signal import firwin, lfilter
import matplotlib.pyplot as plt

def write_hex_coe(f_name, h):
    """
    Function for converting float array to hex and writing to Xilinx coe file
    f_name  - name of output file ("LPF.coe")
    h       - normalized float array (-1 ... 1)
    """
    if os.path.exists(f_name):
        os.remove(f_name)
        
    if (np.max(h) > 1) | (np.min(h) < -1):
        sys.exit("Error: Input array exceed 1 or -1")
        
    
    h = np.round(2**15 * h).astype('int')
    with open(f_name, 'a') as fp:
        fp.write('radix=16;\n')
        fp.write('CoefData=\n')
        for k in range(np.size(h)):
            if h[k] >= 0:
                h_16 = hex(h[k])
                if   len(h_16) == 3:fp.write('000')
                elif len(h_16) == 4:fp.write('00')
                elif len(h_16) == 5:fp.write('0')
            else:
                h[k] = 2**16 - abs(h[k])
                h_16 = hex(h[k])
            fp.write(h_16[2:])
            if k < np.size(h)-1: fp.write(',\n')
            else:fp.write(';')



def main():
    
    plt.close('all')
    
    print('Demonstration of LP, BP, HP FIR filter')
    print('aleksei.rostov@protonmail.com')

    # Filter requirements.
    order   = 31
    fs      = 100.0e6   # sample rate, Hz
    # First make some data to be filtered.
    T   = 10e-6    # seconds
    F1  = 1e6
    F2  = 18e6
    n   = int(T * fs) # total number of samples
    t   = np.linspace(0, T, n, endpoint=False)
    # LFM signal
    s   = np.cos(2*np.pi*t*(F1 + (F2-F1)/T/2*t))

    
    s_16 = np.round((2**15 - 16)*s)
    np.savetxt('../files/fir_input.txt', s_16, fmt='%d')  

    # Filter the data, and plot both the original and filtered signals.
    hLP, sLP = fir_lowpass_filter( s,  8e6, fs, order)
    hHP, sHP = fir_highpass_filter(s, 12e6, fs, order)
    hBP, sBP = fir_bandpass_filter(s, np.array([8.0e6, 12.0e6]), fs, order)
    
    write_hex_coe("../files/LPF.coe", hLP)
    write_hex_coe("../files/BPF.coe", hBP)
    write_hex_coe("../files/HPF.coe", hHP)
          
    

      
    # get frequency responses for every FIR
    delta = np.zeros(np.size(s))
    delta[0] = 1
    
    hLP, yLP = fir_lowpass_filter(delta,  8e6, fs, order)
    yLPF= np.fft.fft(yLP)
              
    
    hHP, yHP = fir_highpass_filter(delta, 12e6, fs, order)
    yHPF= np.fft.fft(yHP)
    
    hBP, yBP = fir_bandpass_filter(delta, np.array([8.0e6, 12.0e6]), fs, order)
    yBPF= np.fft.fft(yBP)
    
    
    f_axis = np.arange(0, np.size(yBPF))/np.size(yBPF)*fs/1e6
    
    
    sF= np.fft.fft(s)
    plt.figure(figsize=(10,10))
    plt.plot(f_axis, np.abs(sF)  /np.max(np.abs(sF))  ,  '.-', label='input signal spectrum')
    plt.plot(f_axis, np.abs(yLPF)/np.max(np.abs(yLPF)), '.-r', label='LP freq response')
    plt.plot(f_axis, np.abs(yHPF)/np.max(np.abs(yHPF)), '.-b', label='HP freq response')
    plt.plot(f_axis, np.abs(yBPF)/np.max(np.abs(yBPF)), '.-k', label='BP freq response')
    plt.title('Normilized Spectrum')
    plt.grid()
    plt.xlabel('frequency, MHz')
    plt.legend()
    
    
    

    plt.figure(figsize=(10,10))
    
    plt.subplot(221)
    plt.plot(t/1e-6, s, '.-')
    plt.grid()
    plt.title('input signal')
    plt.xlabel('Time, usec')
    
    plt.subplot(222)
    plt.plot(t/1e-6,  sLP, '.-r')
    plt.grid()
    plt.title('low pass FIR')
    plt.xlabel('Time, usec')
    
    plt.subplot(223)
    plt.plot(t/1e-6,  sHP, '.-b')
    plt.grid()
    plt.title('high pass FIR')
    plt.xlabel('Time, usec')
    
    plt.subplot(224)
    plt.plot(t/1e-6,  sBP, '.-k')
    plt.xlabel('Time, usec')
    plt.grid()
    plt.title('band pass FIR')

    plt.tight_layout()
    
    plt.show()

    return 0




def fir_lowpass(cutoff, fs, order=5):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b = firwin(order, normal_cutoff)
    return b
    
def fir_bandpass(cutoff, fs, order=5):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b = firwin(order, normal_cutoff, pass_zero=False)
    return b
    
def fir_highpass(cutoff, fs, order=5):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b = firwin(order, normal_cutoff, pass_zero=False)
    return b

def fir_lowpass_filter(data, cutoff, fs, order=5):
    b = fir_lowpass(cutoff, fs, order=order)
    y = lfilter(b, 1.0, data)
    return b, y
    
def fir_bandpass_filter(data, cutoff, fs, order=5):
    b = fir_bandpass(cutoff, fs, order=order)
    y = lfilter(b, 1.0, data)
    return b, y
    
    
def fir_highpass_filter(data, cutoff, fs, order=5):
    b = fir_highpass(cutoff, fs, order=order)
    y = lfilter(b, 1.0, data)
    return b, y


if __name__ == "__main__":
    main()