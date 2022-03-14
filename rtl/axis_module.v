`timescale 1ns / 1ps

module axis_module #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 32,
	parameter BRAM_WIDTH = 16,
    parameter BRAM_DEPTH = 1024
)
(
    input  wire                   aclk,
    input  wire                   aresetn,

    /*
     * AXI Stream input
     */
    input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire                   s_axis_tvalid,
    output wire                   s_axis_tready,
    input  wire                   s_axis_tlast,
	
	/*
	 *  BRAM interface
	 */
	input  wire [BRAM_WIDTH-1:0]  s0_tdata,
	input  wire  				  s0_tvalid,

    /*
     * AXI Stream output
     */
    output wire [2*DATA_WIDTH-1:0]m_axis_tdata,
    output wire                   m_axis_tvalid,
    input  wire                   m_axis_tready,
    output wire                   m_axis_tlast
);

    wire [DATA_WIDTH-1:0]       axis_tdata[1 : 0];
    wire                        axis_tvalid[1 : 0];
    wire                        axis_tready[1 : 0];
    wire                        axis_tlast[1 : 0];
    
    wire [2*DATA_WIDTH-1:0]     axis_2xtdata;
    wire                        axis_2xtvalid;
    wire                        axis_2xtready;
    wire                        axis_2xtlast;
    
    wire [BRAM_WIDTH-1:0]       bram_tdata;
    
    reg  [10 : 0]               addra = 0;
    reg  [10 : 0]               addrb = 0;
    
    reg  [15 : 0]   circular_mem[3 : 0];
    integer i;
    initial
      for (i=0;i< 4;i=i+1)
            circular_mem[i] = 0;
      
    reg  [15 : 0]    d_out = 0;
    reg  [ 1 : 0]    rd_addr = 0;
    reg  [ 1 : 0]    wr_addr = 0;
        
    reg              bufen_z   = 0, bufen_zz   = 0;
    reg              buflast_z = 0, buflast_zz = 0;
    
    
    always @(posedge aclk)
        if (!aresetn)
            addrb <= 0;
        else if(s0_tvalid)
            addrb <= (addrb == BRAM_DEPTH - 1) ? 0 : addrb + 1;
            
    always @(posedge aclk)
        if(!aresetn)
            addra <= 0;
        else if(s_axis_tvalid & s_axis_tready)
            addra <= (s_axis_tlast) ? 0 :addra + 1;
    
   
   // piplined input     
    axis_register#(32)
    inst_0 (
        .aclk(aclk),
        .aresetn(aresetn),
        // AXI input
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(axis_tready[0]),
        .s_axis_tlast(s_axis_tlast),
        
        // AXI output
        .m_axis_tdata(axis_tdata[0]),
        .m_axis_tvalid(axis_tvalid[0]),
        .m_axis_tready(axis_tready[1]),
        .m_axis_tlast(axis_tlast[0])
    );
    
    axis_register#(32)
    inst_1 (
        .aclk(aclk),
        .aresetn(aresetn),
        // AXI input
        .s_axis_tdata(axis_tdata[0]),
        .s_axis_tvalid(axis_tvalid[0]),
        .s_axis_tready(axis_tready[1]),
        .s_axis_tlast(axis_tlast[0]),
        
        // AXI output
        .m_axis_tdata(axis_tdata[1]),
        .m_axis_tvalid(axis_tvalid[1]),
        .m_axis_tready(axis_2xtready),
        .m_axis_tlast(axis_tlast[1])
    );
    
    
    axis_arith #(32)
    inst_2 (
        .aclk(aclk),
        .aresetn(aresetn),
        // AXI input
        .s_axis_tdata(axis_tdata[1]),
        .s_axis_tvalid(axis_tvalid[1]),
        .s_axis_tready(axis_2xtready),
        .s_axis_tlast(axis_tlast[1]),
      
        .s0_tdata({d_out, d_out}),
        // AXI output
        .m_axis_tdata(axis_2xtdata),
        .m_axis_tvalid(axis_2xtvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(axis_2xtlast)
    );
    
    BRAM36E2 inst_3
 (
    .clka(aclk),
    .ena(1'b1),
    .wea(1'b0),
    .addra(addra),
    .dina(16'h0000),
    .douta(bram_tdata),
    .enb(1'b1),
    .web(s0_tvalid),
    .addrb(addrb),
    .dinb(s0_tdata),
    .doutb()
  );
      
    

    always @(posedge aclk)begin
    
        buflast_z   <= s_axis_tvalid & s_axis_tready & s_axis_tlast;
        buflast_zz  <= buflast_z;
        
        bufen_z     <= s_axis_tvalid & s_axis_tready;
        bufen_zz    <= bufen_z;
       
    end
    
    // circular buffer addresses
    always @(posedge aclk)
        if(!aresetn)
            rd_addr <= 2'b00;
        else if(axis_tvalid[1] & axis_2xtready)
            rd_addr <= rd_addr + 1;
            
    
    always @(posedge aclk)
        if(!aresetn)
            wr_addr <= 2'b00;
        else if(bufen_zz)
            wr_addr <= wr_addr + 1;
              
    
    always @(*)
        if(rd_addr != wr_addr)begin
            circular_mem[wr_addr] = bram_tdata;
            d_out  = circular_mem[rd_addr];
        end 
        else begin
            d_out  = bram_tdata;
            circular_mem[wr_addr] = bram_tdata;
        end


    assign m_axis_tdata    =  axis_2xtdata;
    assign m_axis_tvalid   =  axis_2xtvalid;
    assign m_axis_tlast    =  axis_2xtlast;
    
    assign s_axis_tready   =  axis_tready[0]; 


endmodule


