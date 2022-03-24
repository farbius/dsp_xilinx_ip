`timescale 1ns / 1ps

module fft_tb();

parameter       CLOCK_PERIOD    = 10;
parameter       T_HOLD    = 1;


reg 			s_axis_config_tvalid = 0;
reg [23 : 0] 	s_axis_config_tdata = 0;

wire 			s_axis_data_tready;

reg [63 : 0]    s_axis_data_tdata = 0;
reg     		s_axis_data_tvalid = 0;
wire     		s_axis_data_tready;
reg    			s_axis_data_tlast = 0;

wire [63 : 0] 	m_axis_data_tdata;
wire    		m_axis_data_tvalid;
reg    			m_axis_data_tready = 1;
wire    		m_axis_data_tlast = 0;

wire 			event_frame_started;
wire    		event_tlast_unexpected;
wire    		event_tlast_missing;
wire    		event_status_channel_halt;
wire    		event_data_in_channel_halt;
wire    		event_data_out_channel_halt;


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
    input reg [63:0]                data;
    input reg                       last;
    input integer                   valid_mode;
    begin
        s_axis_data_tdata <= data;
        s_axis_data_tlast <= last;
        
        if (valid_mode == 1) begin
            s_axis_data_tvalid <= 0;
            repeat(1 + $urandom%4)@(posedge aclk);
            s_axis_data_tvalid <= 1;
        
        end 
        else begin
            s_axis_data_tvalid <= 1;
        end
        
        @(posedge aclk);
        while(s_axis_data_tready == 0 ) @(posedge aclk);
        #T_HOLD;
        s_axis_data_tvalid <= 0;
    end
 endtask
    
    
 task drive_frame;
    input integer N;
    input integer valid_mode;
    input integer fp;
    reg sample_last;
    integer idx;
    reg [31:0] x_re, x_im;
    begin
         
          idx = 0;
          sample_last = 0;
          x_re = 32'd0;
		  x_im = 32'd0;
        while(idx < N)begin            
            
            $fscanf(fp, " %d\n",  x_re);
			$fscanf(fp, " %d\n",  x_im);			
            sample_last = (idx == N - 1) ? 1 : 0;
            drive_sample({x_im, x_re}, sample_last, valid_mode);    
            idx = idx + 1;
        end
        
    end
 endtask 

initial begin
$display("<-- Start simulation");
-> reset_start;
@(reset_done);

@(posedge aclk);

fp = $fopen("../../../../../files/fft_input.txt", "r");
drive_frame(1000, 0, fp_in);
repeat(100)@(posedge aclk);
$fclose(fp_in);

$display("<-- Simulation done !");
$finish;
end // initial begin


xfft_0 dut_0
(
    .aclk (aclk),
    .aresetn(aresetn),
	
	.s_axis_config_tdata(s_axis_config_tdata),
    .s_axis_config_tvalid(s_axis_config_tvalid),
    .s_axis_config_tready(s_axis_config_tready),
	
    
    .s_axis_data_tvalid(s_axis_data_tvalid),
    .s_axis_data_tdata(s_axis_data_tdata),
	.s_axis_data_tready(s_axis_data_tready),
	.s_axis_data_tlast(s_axis_data_tlast),
    
    .m_axis_data_tdata(m_axis_data_tdata),
    .m_axis_data_tvalid(m_axis_data_tvalid),
    .m_axis_data_tready(m_axis_data_tready),
    .m_axis_data_tlast(m_axis_data_tlast),
	
	.event_frame_started(),
    .event_tlast_unexpected(),
    .event_tlast_missing(),
    .event_status_channel_halt(),
    .event_data_in_channel_halt(),
    .event_data_out_channel_halt()
	
	
);

   

endmodule
