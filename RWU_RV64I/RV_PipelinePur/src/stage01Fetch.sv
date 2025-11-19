`timescale 1ns/1ps

import as_pack::*;

module as_fetch (input  logic clk_i,
                 input  logic rst_i,
                 input  logic stall_n_i,
                 input  logic pc_src_i, // selects pc+4 or pc-branch
                 input  logic [iaddr_width-1:0] pc_calc_i, // branch, jalr
		 output logic [iaddr_width-1:0] pc_o,      // PC and I-Mem address
		 output logic [iaddr_width-1:0] pc_4_o     // for return address
                 );

  logic [iaddr_width-1:0] pc_next_s; // next PC

  //--------------------------------------------
  // PC, Program Counter
  //--------------------------------------------
  as_pc pc (.clk_i(clk_i),
            .rst_i(rst_i),
	    .stall_n_i(stall_n_i),
            .PCnext_i(pc_next_s), // next PC
            .PC_o(pc_o)           // PC
           );
  
  //--------------------------------------------
  // Adder +4 for the address of the next instruction
  //--------------------------------------------
  as_adder add4 (.a_i(pc_o),                // PC
                 .b_i(64'd4),  // plus 4
                 .sum_o(pc_4_o)             // PC plus 4
                );

  //--------------------------------------------
  // Mux for jumps of jalr instruction or normal branches.
  //         - pc_o   : jalr
  //         - regA_s : normal branch
  //--------------------------------------------
  as_mux2 jalrmux(.d0_i(pc_4_o),    // PC
                  .d1_i(pc_calc_i), // branch taken address
                  .sel_i(pc_src_i), // selects pc+4 or pc-branch
                  .y_o(pc_next_s)   // next PC
                 );
  
endmodule : as_fetch
