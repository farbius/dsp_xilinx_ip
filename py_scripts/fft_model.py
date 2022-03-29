import numpy as np
import matplotlib.pyplot as plt
import os

def pulse(x, N):
    return np.concatenate((np.zeros(N), x, np.zeros(N)), axis=0) 

def main():
    
    plt.close('all')
    
    print('Fast Fourier Transform modelling')
    print('aleksei.rostov@protonmail.com')
    
    
    # 512 point FFT
    N   = 512 
    Fs  = 100e6
    snr = 20
    t   = np.linspace(0, N/Fs, N)
    f   = np.linspace(0, Fs, N)
    x   = np.exp(2*np.pi*1j*16e6*t)
    
    q   = 10**(-snr/20)
    
    
    # adding noise
    n   = (np.random.randn(np.size(x)) + 1j*np.random.randn(np.size(x)))
    # sum of the signal and noise
    u   = x + q*n
    
    # writing input signal for RTL simulation
    uRe_int16       = np.round((2**15 - 16)*(np.real(u)/np.max(np.real(u))))
    uIm_int16       = np.round((2**15 - 16)*(np.imag(u)/np.max(np.imag(u))))
    u_int16         = np.zeros(2*N) # parsing data in the format {re0, im0, re1, im1, ...}
    u_int16[0::2]   = uRe_int16
    u_int16[1::2]   = uIm_int16
    np.savetxt('../files/fft_512_input.txt', u_int16, fmt='%d')  
    
    
    # normalized FFT
    uF= np.fft.fft(u, n=np.size(x), norm="forward")
    # frequency axis 
    f_axis = np.arange(np.size(x))/(np.size(x)) * Fs
    
    SNR_signal = np.ones(np.size(f_axis))*(-snr)
    SNR_FFT    = SNR_signal - 10*np.log10(np.size(f_axis))
    
    plt.figure(figsize=(10,10))
    plt.subplot(211)
    plt.plot(f_axis/1e6, 20*np.log10(np.abs(uF)), '.-b')
    plt.plot(f_axis/1e6, SNR_signal, '.-r', label="Input SNR is {} dB".format(snr))
    plt.plot(f_axis/1e6, SNR_FFT, '.-k', label="FFT SNR is 10*log10({}) = {} dB".format(N, np.round(10*np.log10(N))))
    plt.ylabel('dB ')
    plt.xlabel('f, MHz')
    plt.title('Spectrum of {} point normalized FFT'.format(N))
    plt.legend(loc="upper right")
    plt.grid()
    
    
    # 1024 point FFT
    
    N   = 1024 
    Fs  = 100e6
    snr = 10
    t   = np.linspace(0, N/Fs, N)
    f   = np.linspace(0, Fs, N)
    x   = np.exp(2*np.pi*1j*16e6*t)
    
    q   = 10**(-snr/20)
    
    
    # adding noise
    n   = (np.random.randn(np.size(x)) + 1j*np.random.randn(np.size(x)))
    # sum of the signal and noise
    u   = x + q*n
    
    # writing input signal for RTL simulation
    uRe_int16       = np.round((2**15 - 16)*(np.real(u)/np.max(np.real(u))))
    uIm_int16       = np.round((2**15 - 16)*(np.imag(u)/np.max(np.imag(u))))
    u_int16         = np.zeros(2*N) # parsing data in the format {re0, im0, re1, im1, ...}
    u_int16[0::2]   = uRe_int16
    u_int16[1::2]   = uIm_int16
    np.savetxt('../files/fft_1024_input.txt', u_int16, fmt='%d') 
    
    # normalized FFT
    uF= np.fft.fft(u, n=np.size(x), norm="forward")
    # frequency axis 
    f_axis = np.arange(np.size(x))/(np.size(x)) * Fs
    
    SNR_signal = np.ones(np.size(f_axis))*(-snr)
    SNR_FFT    = SNR_signal - 10*np.log10(np.size(f_axis))
    
    plt.subplot(212)
    plt.plot(f_axis/1e6, 20*np.log10(np.abs(uF)), '.-b')
    plt.plot(f_axis/1e6, SNR_signal, '.-r', label="Input SNR is {} dB".format(snr))
    plt.plot(f_axis/1e6, SNR_FFT, '.-k', label="FFT SNR is 10*log10({}) = {} dB".format(N, np.round(10*np.log10(N))))
    plt.ylabel('dB ')
    plt.xlabel('f, MHz')
    plt.title('Spectrum of {} point normalized FFT'.format(N))
    plt.legend(loc="upper right")
    plt.grid()
    
    plt.figure(figsize=(10,10))
    
    sfft    = np.loadtxt('../files/fft_512_out.txt')
    ufft    = sfft[0::2]**2 + sfft[1::2]**2
   
    plt.subplot(211)
    plt.plot(10*np.log10(ufft/np.max(ufft)),'.-b')
    plt.title('FPGA FFT 512 points')
    plt.ylabel('dB ')
    plt.grid()
    
    sfft    = np.loadtxt('../files/fft_1024_out.txt')
    ufft    = sfft[0::2]**2 + sfft[1::2]**2
   
    plt.subplot(212)
    plt.plot(10*np.log10(ufft/np.max(ufft)),'.-b')
    plt.title('FPGA FFT 1024 points')
    plt.ylabel('dB ')
    plt.grid()
    
    
    plt.show()
    
    
    
     
    
    
    
if __name__ == "__main__":
    main()