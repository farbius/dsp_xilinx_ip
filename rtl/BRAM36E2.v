`timescale 1ns / 1ps

module BRAM36E2 (
    clka,
    ena,
    wea,
    addra,
    dina,
    douta,
    enb,
    web,
    addrb,
    dinb,
    doutb
    );
    
  parameter RAM_WIDTH = 16;                         // Specify RAM data width
  parameter RAM_DEPTH = 2048;                       // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE";   // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    
//  Xilinx True Dual Port RAM No Change Single Clock
//  This code implements a parameterizable true dual port memory (both ports can read and write).
//  This is a no change RAM which retains the last read value on the output during writes
//  which is the most power efficient mode.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.

 
  input wire clka;                              // Clock
  input wire [10:0] addra;                      // Port A address bus, width determined from RAM_DEPTH
  input wire [10:0] addrb;                      // Port B address bus, width determined from RAM_DEPTH
  input wire [RAM_WIDTH-1:0] dina;              // Port A RAM input data
  input wire [RAM_WIDTH-1:0] dinb;              // Port B RAM input data
  input wire wea;                               // Port A write enable
  input wire web;                               // Port B write enable
  input wire ena;                               // Port A RAM Enable, for additional power savings, disable port when not in use
  input wire enb;                               // Port B RAM Enable, for additional power savings, disable port when not in use
 // input wire rsta;                            // Port A output reset (does not affect memory contents)
 // input wire rstb;                            // Port B output reset (does not affect memory contents)
 // input wire regcea;                          // Port A output register enable
 // input wire regceb;                          // Port B output register enable
  output wire [RAM_WIDTH-1:0] douta;            // Port A RAM output data
  output wire [RAM_WIDTH-1:0] doutb;            // Port B RAM output data

  reg [RAM_WIDTH-1:0] ram [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_data_a = {RAM_WIDTH{1'b0}};
  reg [RAM_WIDTH-1:0] ram_data_b = {RAM_WIDTH{1'b0}};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          ram[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge clka)
    if (ena)
      if (wea)
        ram[addra] <= dina;
      else
        ram_data_a <= ram[addra];

  always @(posedge clka)
    if (enb)
      if (web)
        ram[addrb] <= dinb;
      else
        ram_data_b <= ram[addrb];

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign douta = ram_data_a;
       assign doutb = ram_data_b;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH-1:0] douta_reg = {RAM_WIDTH{1'b0}};
      reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};

      always @(posedge clka)
          douta_reg <= ram_data_a;

      always @(posedge clka)
          doutb_reg <= ram_data_b;

      assign douta = douta_reg;
      assign doutb = doutb_reg;

    end
  endgenerate

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
							
							
endmodule