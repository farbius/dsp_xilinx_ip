
`timescale 1ns / 1ps

module axis_register #
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
       
    /*
     * AXI Stream output
     */
    output wire [DATA_WIDTH-1:0]  m_axis_tdata,
    output wire                   m_axis_tvalid,
    input  wire                   m_axis_tready,
    output wire                   m_axis_tlast
);


    // datapath registers
    reg                  s_axis_tready_reg = 1'b0;

    reg [DATA_WIDTH-1:0] m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
    reg                  m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
    reg                  m_axis_tlast_reg  = 1'b0;
   
    reg [DATA_WIDTH-1:0] temp_m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
    reg                  temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
    reg                  temp_m_axis_tlast_reg  = 1'b0;
    
    // datapath control
    reg store_axis_input_to_output;
    reg store_axis_input_to_temp;
    reg store_axis_temp_to_output;

    assign s_axis_tready = s_axis_tready_reg;

    assign m_axis_tdata  = m_axis_tdata_reg;
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
            m_axis_tdata_reg <= s_axis_tdata;    
            m_axis_tlast_reg <= s_axis_tlast;
        end else if (store_axis_temp_to_output) begin
            m_axis_tdata_reg <= temp_m_axis_tdata_reg;
            m_axis_tlast_reg <= temp_m_axis_tlast_reg;
        end

        if (store_axis_input_to_temp) begin
            temp_m_axis_tdata_reg <= s_axis_tdata;          
            temp_m_axis_tlast_reg <= s_axis_tlast;
        end
    end
    
    
    
endmodule