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
    print('Demonstration of FIR decimator and interpolator')
    print('aleksei.rostov@protonmail.com')
    
    q           = 4         # resampling factor (decimation/interpolation)
    fs          = 100.0e6   # sample rate, Hz
    T           = 10e-6     # length of signal, sec
    F1          = 1e6       # start frequency, Hz
    F2          = 4e6       # end frequency, Hz
    N           = int(fs*T) # number of signal's samples
    
    # signal 
    tx          = np.linspace(0, T, N, endpoint=False)
    x1_in       = np.linspace(1,2, N)*np.exp(2*1j*np.pi*tx*(F1 + (F2-F1)/T/2*tx))
    x2_in       = np.linspace(1,2, N)*np.exp(2*1j*np.pi*(40e6*tx))
    x_zeros     = np.zeros(1000)
    x           = np.concatenate((x_zeros, x1_in, x_zeros), axis=None)
    x          += np.concatenate((x_zeros, x2_in, x_zeros), axis=None)
    
    #  pulse
    n           = np.size(x)
    t           = np.linspace(0, n/fs, n, endpoint=False)
    t_dec       = np.linspace(0, n/fs, int(n/q), endpoint=False)
    
    
    # print(np.size(x))
    x_16 = np.round((2**15 - 16)*(np.real(x)/np.max(np.real(x))))
    np.savetxt('../files/fir_dec_input.txt', x_16, fmt='%d')  
    
    
   
    # decimation
    
    # anti-aliasing filter
    h_dec, x_alias     = fir_lowpass_filter(x,   10e6, fs, 31)
    write_hex_coe("../files/LPF_dec.coe", h_dec)
    
    
    
    # sample-rate compressor
    x_dec       = x_downsample(x_alias, 4)
    
    
   
    xfft        = np.fft.fftshift(np.fft.fft(x, n=n, axis=-1))
    freqs       = np.fft.fftshift(np.fft.fftfreq(n, 1/fs))
    
    xdec_fft    = np.fft.fftshift(np.fft.fft(x_dec, n=int(n/4), axis=-1))
    freqs_dec   = np.fft.fftshift(np.fft.fftfreq(int(n/4), 1/(fs/4)))
    
    
    plt.figure(figsize=(10,10))
    plt.suptitle("Decimation",fontsize=16,fontweight='bold')
    plt.subplot(221)
    plt.plot(t/1e-6, np.real(x), '.-b',   label="input")
    plt.xlabel('t,usec')
    plt.title('time domain')
    plt.grid()
    plt.legend(loc="upper left")
    
    plt.subplot(222)
    plt.plot(freqs/1e6, np.abs(xfft), '.-r',   label="input")
    plt.xlabel('f,MHz (sample rate is {} MHz)'.format(100))
    plt.title('frequency domain')
    plt.grid()
    plt.legend(loc="upper left")
    
    plt.subplot(223)
    plt.plot(t_dec/1e-6, np.real(x_dec), 'o-b', label="decimated")
    plt.title('time domain')
    plt.legend(loc="upper left")
    plt.xlabel('t, usec')
    plt.grid()
    
    plt.subplot(224)
    plt.plot(freqs_dec/1e6, np.abs(xdec_fft), '.-r', label="decimated")
    plt.xlabel('f, MHz (sample rate is {} MHz)'.format(25))
    plt.title('frequency domain')
    plt.grid()
    plt.legend(loc="upper left")
    
    
    # interpolation
    
    # sample-rate expander
    x_usmpl     = x_upsample(x_dec, 4)
    # anti-imaging filter
    h_dec, x_int= fir_lowpass_filter(x_usmpl,   10e6, fs, 31)
    
    write_hex_coe("../files/LPF_int.coe", h_dec)
    
    xfft        = np.fft.fftshift(np.fft.fft(x_usmpl, n=n, axis=-1))
    xfft_fir    = np.fft.fftshift(np.fft.fft(x_int, n=n, axis=-1))
    freqs       = np.fft.fftshift(np.fft.fftfreq(n, 1/fs))
    
    plt.figure(figsize=(10,10))
    plt.suptitle("Interpolation", fontsize=16, fontweight='bold')
    plt.subplot(221)
    plt.plot(t/1e-6, np.real(x_usmpl), '.-b',label="Interpolated")
    plt.xlabel('t,usec')
    plt.title('before filtering: time domain')
    plt.grid()
    plt.legend(loc="upper left")
    
    plt.subplot(222)
    plt.plot(freqs/1e6, np.abs(xfft), '.-r',label="Interpolated")
    plt.xlabel('f, MHz')
    plt.title('before filtering: frequency domain')
    plt.grid()
    plt.legend(loc="upper left")
    
    
    plt.subplot(223)
    plt.plot(t/1e-6, np.real(x_int), '.-b', label="interpolated")
    plt.legend(loc="upper left")
    plt.xlabel('time, usec')
    plt.title('after filtering: time domain')
    plt.grid()
    
    plt.subplot(224)
    plt.plot(freqs/1e6, np.abs(xfft_fir), '.-r', label="interpolated")
    plt.xlabel('f, MHz')
    plt.title('after filtering: frequency domain')
    plt.grid()
    plt.legend(loc="upper left")
    
    plt.subplots_adjust(hspace=0.35)
    
    plt.show()
    
    
    return 0



def fir_lowpass(cutoff, fs, order=5):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b = firwin(order, normal_cutoff)
    return b

def fir_lowpass_filter(data, cutoff, fs, order=5):
    b = fir_lowpass(cutoff, fs, order=order)
    y = lfilter(b, 0.5, data)
    return b, y

def x_downsample(x, q):
    return x[:np.size(x):q]


def x_upsample(x, q):
    Nnew = np.size(x)*q
    y = np.zeros(Nnew, dtype=complex)
    k = 0
    for n in range(Nnew):
        if (np.mod(n, q) == 0):
            y[n] = x[k]
            k = k + 1
            
    return y
    




if __name__ == "__main__":
    main()