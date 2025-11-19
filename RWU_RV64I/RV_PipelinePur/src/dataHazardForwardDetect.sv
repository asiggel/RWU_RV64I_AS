`timescale 1ns/1ps

import as_pack::*;

module as_data_hazard_forward_detect (input  logic ex_mem_reg_wr_i,
                                      input  logic [4:0] ex_mem_reg_rd_i,
                                      input  logic [4:0] id_ex_reg_rsx_i,
                                      input  logic mem_wb_reg_wr_i,
                                      input  logic [4:0] mem_wb_reg_rd_i,
                                      output logic [1:0] forward_x_o
                                     );

  always_comb
  begin
    if ( (ex_mem_reg_wr_i == 1) &&                         // write on register file (only ld and r-type)
         (ex_mem_reg_rd_i != 5'b00000) &&                  // ignore a write on X0
         (ex_mem_reg_rd_i == id_ex_reg_rsx_i) )            // register read follows a write immediately
      forward_x_o = 2'b10;
    else if ( (mem_wb_reg_wr_i == 1) && 
              (mem_wb_reg_rd_i != 5'b00000) &&
	      ~( (ex_mem_reg_wr_i == 1) && 
                 (ex_mem_reg_rd_i != 5'b00000) && 
                 (ex_mem_reg_rd_i == id_ex_reg_rsx_i) ) && // vector add problem
              (mem_wb_reg_rd_i == id_ex_reg_rsx_i) )       // register read follows a write; second read
      forward_x_o = 2'b01;
    else
      forward_x_o = 2'b00;
  end // always_comb
  
endmodule : as_data_hazard_forward_detect
