`timescale 1ns / 1ps

module fir_tb();

parameter       CLOCK_PERIOD    = 10;
parameter       T_HOLD    = 1;

reg             aresetn = 0;
reg             aclk    = 0;

reg  [15 : 0]   s_axis_tdata = 0;
reg             s_axis_tvalid = 0;
reg             s_axis_tlast = 0;

wire [31 : 0]   m_axis_0_tdata;
wire            m_axis_0_tvalid;
  
wire [31 : 0]   m_axis_1_tdata;
wire            m_axis_1_tvalid;

wire [31 : 0]   m_axis_2_tdata;
wire            m_axis_2_tvalid;

wire 			s_axis_tready;

integer         fp_in  = 0;


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

task drive_sample;
    input reg [15:0]                data;
    input reg                       last;
    input integer                   valid_mode;
    begin
        s_axis_tdata <= data;
        s_axis_tlast <= last;
        
        if (valid_mode == 1) begin
            s_axis_tvalid <= 0;
            repeat(1 + $urandom%4)@(posedge aclk);
            s_axis_tvalid <= 1;
        
        end 
        else begin
            s_axis_tvalid <= 1;
        end
        
        @(posedge aclk);
        while(s_axis_tready == 0 ) @(posedge aclk);
        #T_HOLD;
        s_axis_tvalid <= 0;
    end
 endtask
    
    
 task drive_frame;
    input integer N;
    input integer valid_mode;
    input integer fp;
    reg sample_last;
    integer idx;
    reg [15:0] x_data;
    begin
         
          idx = 0;
          sample_last = 0;
          x_data = 16'd0;
        while(idx < N)begin            
            
            $fscanf(fp, " %d\n",  x_data); 
            sample_last = (idx == N - 1) ? 1 : 0;
            drive_sample(x_data, sample_last, valid_mode);    
            idx = idx + 1;
        end
        
    end
 endtask 

initial begin
$display("<-- Start simulation");
-> reset_start;
@(reset_done);

@(posedge aclk);

fp_in = $fopen("../../../../../files/fir_input.txt", "r");
drive_frame(1000, 0, fp_in);
repeat(100)@(posedge aclk);
$fclose(fp_in);

$display("<-- Simulation done !");
$finish;
end // initial begin


fir_lowpass dut_0
(
    .aclk (aclk),
    .aresetn(aresetn),
    
    .s_axis_data_tvalid(s_axis_tvalid),
    .s_axis_data_tdata(s_axis_tdata),
	.s_axis_data_tready(s_axis_tready),
    
    .m_axis_data_tvalid(m_axis_0_tvalid),
    .m_axis_data_tdata(m_axis_0_tdata)
);


fir_bandpass dut_1
(
    .aclk (aclk),
    .aresetn(aresetn),
    
    .s_axis_data_tvalid(s_axis_tvalid),
    .s_axis_data_tdata(s_axis_tdata),
	.s_axis_data_tready(),
    
    .m_axis_data_tvalid(m_axis_1_tvalid),
    .m_axis_data_tdata(m_axis_1_tdata)
);


fir_highpass dut_2
(
    .aclk (aclk),
    .aresetn(aresetn),
    
    .s_axis_data_tvalid(s_axis_tvalid),
    .s_axis_data_tdata(s_axis_tdata),
	.s_axis_data_tready(),
    
    .m_axis_data_tvalid(m_axis_2_tvalid),
    .m_axis_data_tdata(m_axis_2_tdata)
);


endmodule
