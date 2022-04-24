`timescale 1ns / 1ps

module fft_tb();

parameter       CLOCK_PERIOD    = 10;
parameter       T_HOLD    = 1;


reg             aresetn = 0;
reg             aclk    = 0;

reg 			s_axis_config_tvalid = 0;
reg  [23 : 0] 	s_axis_config_tdata = 0;

wire 			s_axis_config_tready;

reg  [31 : 0]   s_axis_data_tdata = 0;
reg     		s_axis_data_tvalid = 0;
wire     		s_axis_data_tready;
reg    			s_axis_data_tlast = 0;

wire [31 : 0] 	m_axis_data_tdata;
wire    		m_axis_data_tvalid;
reg    			m_axis_data_tready = 1;
wire    		m_axis_data_tlast = 0;

wire 			event_frame_started;
wire    		event_tlast_unexpected;
wire    		event_tlast_missing;
wire    		event_status_channel_halt;
wire    		event_data_in_channel_halt;
wire    		event_data_out_channel_halt;


integer         fp_in   = 0;
integer         fp_out  = 0;
integer         fft_en  = 0;

function integer clogb2;
input [31:0] value;
integer i;
begin
    clogb2 = 0;
    for(i = 0; 2**i < value; i = i + 1)
    clogb2 = i + 1;
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

task drive_sample;
    input reg [31:0]                data;
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
    reg [15:0] x_re, x_im;
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
 
reg  [11 : 0]   config_reg = 0;
reg   [3 : 0]     log2nFFT = 0;
reg   [4 : 0]   FWD  = 5'b10000;
reg   [4 : 0]   INV  = 5'b00000;
 
always @(*)
      case (log2nFFT)
         4'b0000: config_reg = 12'd6;
         4'b0001: config_reg = 12'd6;
         4'b0010: config_reg = 12'd6;
         4'b0011: config_reg = 12'd6;
         4'b0100: config_reg = 12'd10;
         4'b0101: config_reg = 12'd26;
         4'b0110: config_reg = 12'd42;
         4'b0111: config_reg = 12'd106;
         
         4'b1000: config_reg = 12'd170;
         4'b1001: config_reg = 12'd426;
         4'b1010: config_reg = 12'd682;
         4'b1011: config_reg = 12'd1706;
         4'b1100: config_reg = 12'd2730;
         4'b1101: config_reg = 12'd2730;
         4'b1110: config_reg = 12'd2730;
         4'b1111: config_reg = 12'd2730;
      endcase


initial begin
$display("<-- Start simulation");
-> reset_start;
@(reset_done);

@(posedge aclk);
repeat(10)@(posedge aclk);

$display("<-- Start FFT 512 points");
fft_en = 1;
log2nFFT = clogb2(512);

@(posedge aclk);
s_axis_config_tdata  = {3'b000, config_reg, FWD, log2nFFT};
@(posedge aclk);
s_axis_config_tvalid = 0;
@(posedge aclk);
s_axis_config_tvalid = 1;
@(posedge aclk);
s_axis_config_tvalid = 0;


fp_in  = $fopen("../../../../../files/fft_512_input.txt", "r");
fp_out = $fopen("../../../../../files/fft_512_out.txt", "w");
drive_frame(512, 0, fp_in);
@(posedge aclk);
$fclose(fp_in);
// wait for master tlast
@(posedge m_axis_data_tlast);
repeat(10)@(posedge aclk);
$fclose(fp_out);
fft_en = 0;

$display("<-- Start Inverse FFT 512 points");
fp_in = $fopen("../../../../../files/fft_512_out.txt", "r");
fp_out = $fopen("../../../../../files/ifft_512_out.txt", "w");
log2nFFT = clogb2(512);
@(posedge aclk);
s_axis_config_tdata  = {3'b000, config_reg, INV, log2nFFT};
@(posedge aclk);
s_axis_config_tvalid = 0;
@(posedge aclk);
s_axis_config_tvalid = 1;
@(posedge aclk);
s_axis_config_tvalid = 0;

drive_frame(512, 0, fp_in);
@(posedge aclk);
$fclose(fp_in);
// wait for master tlast
@(posedge m_axis_data_tlast);
repeat(10)@(posedge aclk);
$fclose(fp_out);


$display("<-- Simulation done !");
$finish;
end // initial begin


always @(posedge aclk)
        if(m_axis_data_tvalid)begin
            $fwrite(fp_out, "%d \n", $signed(m_axis_data_tdata[15: 0]));
            $fwrite(fp_out, "%d \n", $signed(m_axis_data_tdata[31:16]));
        end 
   


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
	
	.event_frame_started(event_frame_started),
    .event_tlast_unexpected(event_tlast_unexpected),
    .event_tlast_missing(event_tlast_missing),
    .event_status_channel_halt(event_status_channel_halt),
    .event_data_in_channel_halt(event_data_in_channel_halt),
    .event_data_out_channel_halt(event_data_out_channel_halt)
	
	
);

   

endmodule
