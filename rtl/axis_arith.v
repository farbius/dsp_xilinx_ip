
`timescale 1ns / 1ps

module axis_arith #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 32
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
	
	input  wire [DATA_WIDTH-1:0]  s0_tdata,
       
    /*
     * AXI Stream output
     */
    output wire [2*DATA_WIDTH-1:0]m_axis_tdata,
    output wire                   m_axis_tvalid,
    input  wire                   m_axis_tready,
    output wire                   m_axis_tlast
);


  
    // datapath registers
    reg                     s_axis_tready_reg = 1'b0;

    reg                     m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
    reg                     m_axis_tlast_reg  = 1'b0;
   
    reg                     temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
    reg                     temp_m_axis_tlast_reg  = 1'b0;
    (* use_dsp="yes" *)
    reg [2*DATA_WIDTH  :0]  mltp[0:3];
    (* use_dsp="yes" *)
    reg [2*DATA_WIDTH  :0]  tmp_mltp[0:3];
    integer i;
    initial begin
      for (i=0;i<=3;i=i+1)begin
           mltp[i] = 0;
       tmp_mltp[i] = 0;
      end
      end
    
    // datapath control
    reg store_axis_input_to_output;
    reg store_axis_input_to_temp;
    reg store_axis_temp_to_output;
    
    wire signed [DATA_WIDTH:0] pr = mltp[0] - mltp[1];
    wire signed [DATA_WIDTH:0] pi = mltp[2] + mltp[3]; 

    assign s_axis_tready = s_axis_tready_reg;

    assign m_axis_tdata  = {pi[DATA_WIDTH-1:0], pr[DATA_WIDTH-1:0]};
    assign m_axis_tvalid = m_axis_tvalid_reg;
    assign m_axis_tlast  = m_axis_tlast_reg;

    // enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
    wire s_axis_tready_early = m_axis_tready || (!temp_m_axis_tvalid_reg && (!m_axis_tvalid_reg || !s_axis_tvalid));

    always @* begin
        // transfer sink ready state to source
        m_axis_tvalid_next = m_axis_tvalid_reg;
        temp_m_axis_tvalid_next = temp_m_axis_tvalid_reg;

        store_axis_input_to_output = 1'b0;
        store_axis_input_to_temp = 1'b0;
        store_axis_temp_to_output = 1'b0;

        if (s_axis_tready_reg) begin
            // input is ready
            if (m_axis_tready || !m_axis_tvalid_reg) begin
                // output is ready or currently not valid, transfer data to output
                m_axis_tvalid_next = s_axis_tvalid;
                store_axis_input_to_output = 1'b1;
            end else begin
                // output is not ready, store input in temp
                temp_m_axis_tvalid_next = s_axis_tvalid;
                store_axis_input_to_temp = 1'b1;
            end
        end else if (m_axis_tready) begin
            // input is not ready, but output is ready
            m_axis_tvalid_next = temp_m_axis_tvalid_reg;
            temp_m_axis_tvalid_next = 1'b0;
            store_axis_temp_to_output = 1'b1;
        end
    end

    always @(posedge aclk) begin
        if (!aresetn) begin
            s_axis_tready_reg <= 1'b0;
            m_axis_tvalid_reg <= 1'b0;
            temp_m_axis_tvalid_reg <= 1'b0;
        end else begin
            s_axis_tready_reg <= s_axis_tready_early;
            m_axis_tvalid_reg <= m_axis_tvalid_next;
            temp_m_axis_tvalid_reg <= temp_m_axis_tvalid_next;
        end

        // datapath
        if (store_axis_input_to_output) begin
            mltp[0] <= $signed(s_axis_tdata[15: 0]) * $signed(s0_tdata[15: 0]);
            mltp[1] <= $signed(s_axis_tdata[31:16]) * $signed(s0_tdata[31:16]);
            mltp[2] <= $signed(s_axis_tdata[15: 0]) * $signed(s0_tdata[31:16]);
            mltp[3] <= $signed(s_axis_tdata[31:16]) * $signed(s0_tdata[15: 0]);
            
            
            m_axis_tlast_reg <= s_axis_tlast;
        end else if (store_axis_temp_to_output) begin
            mltp[0] <= tmp_mltp[0];
            mltp[1] <= tmp_mltp[1];
            mltp[2] <= tmp_mltp[2];
            mltp[3] <= tmp_mltp[3];
        
            m_axis_tlast_reg <= temp_m_axis_tlast_reg;
        end

        if (store_axis_input_to_temp) begin
            tmp_mltp[0] <= $signed(s_axis_tdata[15: 0]) * $signed(s0_tdata[15: 0]);
            tmp_mltp[1] <= $signed(s_axis_tdata[31:16]) * $signed(s0_tdata[31:16]);
            tmp_mltp[2] <= $signed(s_axis_tdata[15: 0]) * $signed(s0_tdata[31:16]);
            tmp_mltp[3] <= $signed(s_axis_tdata[31:16]) * $signed(s0_tdata[15: 0]);
        
            temp_m_axis_tlast_reg <= s_axis_tlast;
        end
    end
    
    
endmodule