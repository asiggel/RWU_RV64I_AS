`timescale 1ns/1ps

import as_pack::*;

module as_pc (input  logic                   clk_i,
              input  logic                   rst_i,
              input  logic                   stall_n_i,
              input  logic [iaddr_width-1:0] PCnext_i,
              output logic [iaddr_width-1:0] PC_o
             );

  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      PC_o <= 0;
    else
      if (stall_n_i == 1'b1)
        PC_o <= PCnext_i;
  end

endmodule : as_pc

