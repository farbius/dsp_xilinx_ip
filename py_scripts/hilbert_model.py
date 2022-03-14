import numpy as np
import matplotlib.pyplot as plt
import os

from scipy.signal import hilbert

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



def pulse(x, N):
    return np.concatenate((np.zeros(N), x, np.zeros(N)), axis=0) 

def hilbert_resp(N):
    phi = np.pi*(np.arange(N) - N // 2)/2

    h = np.zeros(N)
    for k in range(N):
        if phi[k] == 0:
            h[k] = 0
        else:
            h[k] = 2*np.sin(phi[k])**2 / (phi[k]*2)
    return h
    
def hilbert_transform(x, N):
    h       = hilbert_resp(N)
    x_im    = np.convolve(x, h, mode='same')
    return h, x_im
    

def main():
    
    plt.close('all')
    
    print('Hilbert transform modelling')
    print('aleksei.rostov@protonmail.com')
    
    N   = 512 
    Fs  = 100e6
    t   = np.linspace(0, N/Fs, N)
    f   = np.linspace(0, Fs, N)
    x_re= np.cos(2*np.pi*t*(8e6 + 8e6/(N/Fs)/2*t))
    
    x_re= pulse(x_re, 256)
    
    
    print(np.size(x_re))
    s_16 = np.round((2**15 - 16)*x_re)
    np.savetxt('../files/hilbert_input.txt', s_16, fmt='%d')  
    
    
    h, x_im = hilbert_transform(x_re, 63)
    
    write_hex_coe("../files/Hilbert.coe", h)
    
    x = x_re + 1j*x_im
    
    plt.figure(figsize=(10,10))
    plt.subplot(211)
    plt.plot(np.real(x), '.-b')
    plt.plot(np.imag(x), '.-r')
    plt.plot(np.abs(x),  '.-k')
    plt.title('Results of Hilbert transform')
    plt.grid()
    
    plt.subplot(212)
    plt.plot(h, '.-b')
    plt.title('Hilbert transform: impulse resposible')
    plt.grid()
    
    plt.figure()
    plt.plot(np.abs(np.fft.fft(x)), '.-b')
    plt.grid()
    
    
    
    plt.show()
    
    
    
    
	
	



if __name__ == "__main__":
    main()