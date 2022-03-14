`timescale 1ns / 1ps

module dds_tb();


parameter       CLOCK_PERIOD    = 10;
parameter       MESSAGE_W       = 13;
parameter       MESSAGE         = 13'b0101010101010;


reg             aresetn = 0;
reg             aclk    = 0;


reg  [15 : 0]   s_axis_phase_0_tdata = 0;
reg             s_axis_phase_0_tvalid = 0;

reg  [15 : 0]   s_axis_phase_1_tdata = 0;
reg             s_axis_phase_1_tvalid = 0;

wire [31 : 0]   m_axis_data_0_tdata;
wire            m_axis_data_0_tvalid;
  
wire [31 : 0]   m_axis_data_1_tdata;
wire            m_axis_data_1_tvalid;

wire [15 : 0]   m_axis_phase_tdata;
wire            m_axis_phase_tvalid;


wire [15 : 0]   re_0 = m_axis_data_0_tdata[15: 0];
wire [15 : 0]   im_0 = m_axis_data_0_tdata[31:16];


wire [15 : 0]   re_1 = m_axis_data_1_tdata[15: 0];
wire [15 : 0]   im_1 = m_axis_data_1_tdata[31:16];

integer         fp_out  = 0;


/*
*   Function for calculation phase incrementation from desirable frequency
*   Here assuming sample clock is 100 MHz
*
*/
function [15:0] phase_incr ;
  input reg [31:0] des_freq;
  reg [47:0] tmp;
  begin
            tmp = (des_freq * CLOCK_PERIOD) << 16;
     phase_incr = tmp /  1000000000;
  end
endfunction



always
    #(CLOCK_PERIOD/2) aclk = ~aclk;
    
       
event reset_start;
event reset_done;

always // reset
begin
aresetn <= 1;
@(reset_start);
$display("<-- Reset");
    aresetn <= 0;
    repeat(10)@(posedge aclk);
    aresetn <= 1;
-> reset_done;
$display("<-- Reset done");
end

/*
    Phase-shift keying modulation task for dds compiler
    N           - number of clocks for one bit
    deltaPhase  - phase increment for LUT
    message     - binary code for phase modulation
*/

task PSK_DDS;
    input integer N;
    input reg [15 : 0] deltaPhase;
    input reg [MESSAGE_W-1:0] message;
    integer indx;
    begin
        s_axis_phase_0_tvalid = 1;
        s_axis_phase_1_tvalid = 1;
        repeat(MESSAGE_W) begin
            indx = 0;
                if(message[0])
                    s_axis_phase_0_tdata = s_axis_phase_0_tdata + 16'd32768;
                else 
                    s_axis_phase_0_tdata = s_axis_phase_0_tdata;
                
            while(indx < N - 1)begin
            
                if(message[0])begin
                    s_axis_phase_1_tdata = deltaPhase;
                end 
                else begin
                    s_axis_phase_1_tdata = 2**16 - deltaPhase;
                end
                
                s_axis_phase_0_tdata = s_axis_phase_0_tdata + deltaPhase;
            
                @(posedge aclk);
                indx = indx + 1;
            end // while
            message = message >> 1;
        end  // repeat
        s_axis_phase_0_tvalid = 0;
        s_axis_phase_1_tvalid = 0;
        
        s_axis_phase_0_tdata = 0;
        s_axis_phase_1_tdata = 0;
    end
endtask


/*
    Frequency-shift keying modulation task for dds compiler (2 frequency)
    N           - number of clocks for one bit
    deltaPhase_0- phase increment  for frequency 1
    deltaPhase_1- phase increment  for frequency 2
    message     - binary code for phase modulation
*/
task FSK_DDS;
    input integer N;
    input reg [15 : 0] deltaPhase_0;
    input reg [15 : 0] deltaPhase_1;
    input reg [MESSAGE_W-1:0] message;
    integer indx;
    begin
        s_axis_phase_0_tvalid = 1;
        s_axis_phase_1_tvalid = 1;
        repeat(MESSAGE_W) begin
            indx = 0;
            while(indx < N - 1)begin
                if(message[0])begin
                    s_axis_phase_0_tdata = s_axis_phase_0_tdata + deltaPhase_0;
                    s_axis_phase_1_tdata = deltaPhase_0;
                end 
                else begin
                    s_axis_phase_0_tdata = s_axis_phase_0_tdata + deltaPhase_1;
                    s_axis_phase_1_tdata = deltaPhase_1;
                end
            
                @(posedge aclk);
                indx = indx + 1;
            end // while
            message = message >> 1;
        end  // repeat
        s_axis_phase_0_tvalid = 0;
        s_axis_phase_1_tvalid = 0;
        
        s_axis_phase_0_tdata = 0;
        s_axis_phase_1_tdata = 0;
    end
endtask


/*
    Linear frequency modulation task for dds compiler 
    N           - number of clocks for modulation
    StartFreq   - start frequency
    EndFreq     - end   frequency
*/
task LFM_DDS;
    input integer N;
    input reg [31 : 0] StartFreq;
    input reg [31 : 0] EndFreq;
    integer len_lfm;
    reg [31 : 0] tmp_n;
    reg [31 : 0] diff;
    begin
    
        diff  = (EndFreq - StartFreq) / N;
        tmp_n = diff / N;
        
        s_axis_phase_0_tvalid = 1;
        s_axis_phase_1_tvalid = 1;
        
//        s_axis_phase_0_tdata  = phase_incr(StartFreq);
//        s_axis_phase_1_tdata  = phase_incr(StartFreq);
        
        len_lfm = 0;
        while(len_lfm < N - 1)begin
             
                s_axis_phase_0_tdata = s_axis_phase_0_tdata + phase_incr(StartFreq);
                s_axis_phase_1_tdata = phase_incr(StartFreq);
               
            @(posedge aclk);
            len_lfm   = len_lfm + 1;
            StartFreq = StartFreq + diff;
        end // while
            
        s_axis_phase_0_tvalid = 0;
        s_axis_phase_1_tvalid = 0;
        
        s_axis_phase_0_tdata = 0;
        s_axis_phase_1_tdata = 0;
    end
endtask
    
    
    
/*
    Without modulation task for dds compiler
    N           - number of clocks
    deltaPhase  - phase increment for LUT
*/
task SIN_DDS;
    input integer N;
    input reg [15:0] dF;
    integer idx;
    begin
          idx = 0;
          s_axis_phase_0_tvalid = 1;
          s_axis_phase_1_tvalid = 1;
          
          s_axis_phase_1_tdata  = dF;
          
        while(idx < N)begin            
            
            @(posedge aclk);
            s_axis_phase_0_tdata = s_axis_phase_0_tdata + dF;
            idx = idx + 1;
        end
        s_axis_phase_0_tvalid = 0;
        s_axis_phase_1_tvalid = 0;
        
        s_axis_phase_0_tdata  = 0;
        s_axis_phase_1_tdata  = 0;
    end
endtask


initial begin
$display("<-- Start simulation");
-> reset_start;
@(reset_done);

@(posedge aclk);

fp_out = $fopen("../../../../../files/simple.txt", "w");

SIN_DDS(1030, phase_incr(32'd2000000));

repeat(1000)@(posedge aclk);

$fclose(fp_out);

fp_out = $fopen("../../../../../files/psk.txt", "w");


PSK_DDS(100, phase_incr(32'd10000000), MESSAGE);

repeat(1000)@(posedge aclk);
$fclose(fp_out);
fp_out = $fopen("../../../../../files/fsk.txt", "w");

FSK_DDS(100, phase_incr(32'd4000000), phase_incr(32'd10000000), MESSAGE);

repeat(1000)@(posedge aclk);
$fclose(fp_out);
fp_out = $fopen("../../../../../files/lfm.txt", "w");

LFM_DDS(1030, 32'd5000000, 32'd10000000);


repeat(1000)@(posedge aclk);
$fclose(fp_out);

$display("<-- Simulation done !");
$finish;
end // initial begin

always @(posedge aclk)
begin
        if(m_axis_data_0_tvalid)begin
            $fwrite(fp_out, "%d \n", $signed(m_axis_data_0_tdata[15 : 0]));
            $fwrite(fp_out, "%d \n", $signed(m_axis_data_0_tdata[31 :16]));
        end 
end   


dds_compiler_0 dut_0
(
    .aclk (aclk),
    .aresetn(aresetn),
    
    .s_axis_phase_tvalid(s_axis_phase_0_tvalid),
    .s_axis_phase_tdata(s_axis_phase_0_tdata),
    
    .m_axis_data_tvalid(m_axis_data_0_tvalid),
    .m_axis_data_tdata(m_axis_data_0_tdata)
);


dds_compiler_1 dut_1
(
    .aclk (aclk),
    .aresetn(aresetn),
    
    .s_axis_phase_tvalid(s_axis_phase_1_tvalid),
    .s_axis_phase_tdata(s_axis_phase_1_tdata),
    
    .m_axis_data_tvalid(m_axis_data_1_tvalid),
    .m_axis_data_tdata(m_axis_data_1_tdata),
    
    .m_axis_phase_tvalid(m_axis_phase_tvalid),
    .m_axis_phase_tdata(m_axis_phase_tdata)
);


endmodule
