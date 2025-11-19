`timescale 1ns/1ps

import as_pack::*;

module as_writeback (input  logic [iaddr_width-1:0]   return_address_i,
                     input  logic [reg_width-1:0]     data_mem_i,
                     input  logic [reg_width-1:0]     alu_result_i,
                     input  logic [dmuxsel_width-1:0] mux_result_src_i,
                     output logic [reg_width-1:0]     write_data_o
	            );

  //--------------------------------------------
  // Mux for aluResult, dmem or PC+4 to register file
  //--------------------------------------------
  as_mux3 dmmux (.d0_i(alu_result_i),
                 .d1_i(data_mem_i),
                 .d2_i(return_address_i),
                 .sel_i(mux_result_src_i),
                 .y_o(write_data_o)
                );

endmodule : as_writeback
