`timescale 1ns/1ps

import as_pack::*;

module as_data_hazard (input  logic dmem_rd_execute_i,
                       input  logic [4:0] id_ex_reg_rd_i,
                       input  logic [4:0] if_id_reg_rs1_i,
                       input  logic [4:0] if_id_reg_rs2_i,
                       output logic stall_n_o
                      );
  always_comb // load in execute stage, r-type instr. in decode stage (load-use hazard)
  begin
    if ( ( (dmem_rd_execute_i == 1) &&               // only a load reads the memory
           ( (id_ex_reg_rd_i == if_id_reg_rs1_i) ||  // one of the two source registers is
             (id_ex_reg_rd_i == if_id_reg_rs2_i) ) ) // equal to the next stages destination register
       )
      stall_n_o = 1'b0; // stall
    else
      stall_n_o = 1'b1; // no stall
  end

endmodule : as_data_hazard
