import numpy as np
import matplotlib.pyplot as plt
import os

def pulse(x, N):
    return np.concatenate((np.zeros(N), x, np.zeros(N)), axis=0) 

def main():
    
    plt.close('all')
    
    print('Fast Fourier Transform modelling')
    print('aleksei.rostov@protonmail.com')
    
    N   = 512 
    Fs  = 100e6
    snr = 20
    t   = np.linspace(0, N/Fs, N)
    f   = np.linspace(0, Fs, N)
    x   = np.exp(2*np.pi*1j*16e6*t)
    
    q = 10**(-snr/20)
    
    # x = pulse(x, 256)
    
    # adding noise
    n = q*(np.random.randn(np.size(x)) + 1j*np.random.randn(np.size(x)))
    u = x + n
    
    print(np.size(x))
    uF= np.fft.fft(u, n=np.size(x), norm=None)/np.size(x)
    f_axis = np.arange(np.size(x))/(np.size(x)) * Fs
    
    SNR_signal = np.ones(np.size(f_axis))*(-snr)
    SNR_FFT    = SNR_signal - 10*np.log10(np.size(f_axis))
    print(10*np.log10(np.size(f_axis)))
    
    plt.figure()
    plt.plot(f_axis/1e6, 20*np.log10(np.abs(uF)), '.-b')
    plt.plot(f_axis/1e6, SNR_signal, '.-r', label="snr level of the input")
    plt.plot(f_axis/1e6, SNR_FFT, '.-k', label="increased by FFT snr level")
    plt.ylabel('dB ')
    plt.xlabel('f, MHz')
    plt.legend(loc="upper right")
    plt.grid()
    
    
    plt.show()
    
    
    
     
    
    
    
if __name__ == "__main__":
    main()