`timescale 1ns / 1ps


module axis_module_tb();

    // Parameters
    parameter                   DATA_WIDTH = 32;
    parameter                   CLOCK_PERIOD = 10;
    parameter                   T_HOLD = 1;
    
    reg                         aresetn = 0;
    reg                         aclk = 0;
    
    reg  [ DATA_WIDTH-1:0]      s_axis_tdata = 0;
    reg                         s_axis_tlast = 0;
    reg                         s_axis_tvalid = 0;
    
    wire                        s_axis_tready;
    
    wire [ 2*DATA_WIDTH-1:0]    m_axis_tdata;
    wire                        m_axis_tlast;
    wire                        m_axis_tvalid;
    
    reg                         m_axis_tready = 1'b1;
    
    reg  [15 : 0]               s0_tdata = 0;
    reg                         s0_tvalid = 0;
    
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
    
    
     // BRAM initialization
     task bram_init;
     input integer N;
     integer idx;   
     reg [15 : 0] x_coe;
         begin
                x_coe = 0;
               
                s0_tvalid <= 0;
                idx    = 0;
                @(posedge aclk);
            while(idx < N)begin
                x_coe = x_coe + 16'd1;
                s0_tvalid <= 1;
                s0_tdata  <= x_coe;
                @(posedge aclk);
                idx    =   idx + 1; 
            end
            
                s0_tvalid <= 0;
         end
     endtask // bram init
     
     
     task drive_sample;
        input reg [DATA_WIDTH-1:0]      data;
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
        reg sample_last;
        integer idx;
        reg [15:0] x_im, x_re;
        begin
             
              idx = 0;
              sample_last = 0;
              x_im = 16'd20;
              x_re = 16'd30;
            while(idx < N)begin            
                
                 x_im = x_im + 1;
                 x_re = x_re + 1;
                sample_last = (idx == N - 1) ? 1 : 0;
                drive_sample({x_im, x_re}, sample_last, valid_mode);    
                idx = idx + 1;
            end
            
        end
     endtask 
     
     
     initial begin

        -> reset_start;
        @(reset_done);
        
        @(posedge aclk);
        
        bram_init(16);
        
        repeat(5)@(posedge aclk);
        
        drive_frame(8, 0);
        
        repeat(20)@(posedge aclk);
        $finish;    
            
     end // initial begin
        
        

    axis_module#(32, 16, 1024)
        dut (
            .aclk(aclk),
            .aresetn(aresetn),
            // AXI input
            .s_axis_tdata(s_axis_tdata),
            .s_axis_tvalid(s_axis_tvalid),
            .s_axis_tready(s_axis_tready),
            .s_axis_tlast(s_axis_tlast),
            
            .s0_tdata(s0_tdata),
            .s0_tvalid(s0_tvalid),
            
            // AXI output
            .m_axis_tdata(m_axis_tdata),
            .m_axis_tvalid(m_axis_tvalid),
            .m_axis_tready(m_axis_tready),
            .m_axis_tlast(m_axis_tlast)
        );

endmodule