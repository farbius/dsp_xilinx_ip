import numpy as np
import matplotlib.pyplot as plt


def main():
    
    plt.close('all')
    print('Demonstration of Direct Digital Synthesizer')
    print('aleksei.rostov@protonmail.com')

# reading FPGA data

    dds_lut()
    fpga_data()
    plt.show()
    
    
def psk(s, n_clocks):
    N = int(s.size)
    tmp = 1
    psi = np.zeros((N, 1))
    for i in range(N):
        if(np.mod(i , n_clocks) == 0):
            tmp = ~(tmp)
        if(tmp == 1):    
            s[i] = 1 * s[i]
        else:
            s[i] = -1 * s[i]
        psi[i] = tmp
    return s, psi
    
    
def fpga_data():


    s       = np.loadtxt('../files/simple.txt')
    N       = int(s.size / 2)
    s_new   = np.reshape(s, (N, 2))
    x_cmpx  = s_new[:, 0] + 1j*s_new[:, 1]
    XF      = np.fft.fft(x_cmpx, axis=0, norm=None)
    f_axis  = np.linspace(0, 100, N)

    plt.figure()
    plt.subplot(2, 1, 1)
    plt.title("sin and cos")
    plt.plot(np.real(x_cmpx), '.-r', label='real')
    plt.plot(np.imag(x_cmpx), '.-b', label='imag')
    plt.xlabel("time, bins")
    plt.grid()
    plt.legend()
    
    plt.subplot(2, 1, 2)
    plt.plot(f_axis, np.abs(XF), '.-b')
    plt.xlabel("freq [MHz]")
    plt.grid()
    
    plt.subplots_adjust(hspace=0.35)


    s       = np.loadtxt('../files/psk.txt')
    N       = int(s.size / 2)
    s_new   = np.reshape(s, (N, 2))
    x_cmpx  = s_new[:, 0] + 1j*s_new[:, 1]
    XF      = np.fft.fft(x_cmpx, axis=0, norm=None)
    f_axis  = np.linspace(0, 100, N)

    plt.figure()
    plt.subplot(2, 1, 1)
    plt.title("PSK")
    plt.plot(np.real(x_cmpx), '.-r', label='real')
    plt.plot(np.imag(x_cmpx), '.-b', label='imag')
    plt.xlabel("time, bins")
    plt.grid()
    plt.legend()
    
    plt.subplot(2, 1, 2)
    plt.plot(f_axis, np.abs(XF), '.-b')
    plt.xlabel("freq [MHz]")
    plt.grid()
    
    plt.subplots_adjust(hspace=0.35)


    s       = np.loadtxt('../files/fsk.txt')
    N       = int(s.size / 2)
    s_new   = np.reshape(s, (N, 2))
    x_cmpx  = s_new[:, 0] + 1j*s_new[:, 1]
    XF      = np.fft.fft(x_cmpx, axis=0, norm=None)
    f_axis  = np.linspace(0, 100, N)

    plt.figure()
    plt.subplot(2, 1, 1)
    plt.title("FSK")
    plt.plot(np.real(x_cmpx), '.-r')
    plt.plot(np.imag(x_cmpx), '.-b')
    plt.xlabel("time, bins")
    plt.grid()
    
    plt.subplot(2, 1, 2)
    plt.plot(f_axis, np.abs(XF), '.-b')
    plt.xlabel("freq [MHz]")
    plt.grid()
    
    plt.subplots_adjust(hspace=0.35)

    s       = np.loadtxt('../files/lfm.txt')
    N       = int(s.size / 2)
    s_new   = np.reshape(s, (N, 2))
    x_cmpx  = s_new[:, 0] + 1j*s_new[:, 1]
    XF      = np.fft.fft(x_cmpx, axis=0, norm=None)
    f_axis  = np.linspace(0, 100, N)

    plt.figure()
    plt.subplot(2, 1, 1)
    plt.title("LFM")
    plt.plot(np.real(x_cmpx), '.-r')
    plt.plot(np.imag(x_cmpx), '.-b')
    plt.xlabel("time, bins")
    plt.grid()
    
    plt.subplot(2, 1, 2)
    plt.plot(f_axis, np.abs(XF), '.-b')
    plt.xlabel("freq [MHz]")
    plt.grid()
    
    plt.subplots_adjust(hspace=0.35)
    

    # N       = 1024
    # s       = np.exp(2*np.pi*1j*10e6*np.linspace(0, N/100e6, N))
    # s, psi  = psk(s, 100)


    # XF      = np.fft.fft(s, axis=0, norm=None)
    # f_axis  = np.linspace(0, 100, N)

    # fig, axis_4 = plt.subplots(nrows=3, ncols=1, figsize=(7, 7))
    # axis_4[0].set_title("Example")
    # axis_4[0].plot(np.real(s), '.-r')
    # axis_4[0].plot(np.imag(s), '.-b')
    # axis_4[0].set_xlabel("time, bins")
    # axis_4[0].grid()
    # axis_4[1].set_title("freq")
    # axis_4[1].plot(f_axis, np.abs(XF), '.-b')
    # axis_4[1].set_xlabel("freq, MHz")
    # axis_4[1].grid()
    # axis_4[2].set_title("freq")
    # axis_4[2].plot(psi, '.-b')
    # axis_4[2].set_xlabel("freq, MHz")
    # axis_4[2].grid()
    
    return 0




def dds_lut():

    sin_lut = np.sin(2*np.pi*np.linspace(0, 1, 2**16))
    
   
    
    sin_out = np.zeros((2**16, 1))
    for n in range(0, 2**16):
        sin_out[n] = sin_lut[np.mod(10*n, 2**16)]
        
    plt.figure()
    plt.title('dds')
    plt.plot(sin_lut, '.-b', label='lut')
    plt.plot(sin_out, '.-r', label='out')
    plt.xlabel("time, bins")
    plt.grid()
    plt.legend()
        
    





    return 0





if __name__ == "__main__":
    main()

