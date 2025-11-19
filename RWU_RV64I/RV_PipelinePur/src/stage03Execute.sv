`timescale 1ns/1ps

import as_pack::*;

module as_execute (input  logic [iaddr_width-1:0]    pc_i,
		   input  logic [reg_width-1:0]      reg_a_i,
		   input  logic [reg_width-1:0]      reg_b_i,
		   input  logic [reg_width-1:0]      imm_i,
		   input  logic mux_alu_src_a_i,
                   input  logic mux_alu_src_b_i,
		   input  logic jump_i,
                   input  logic [aluselrv_width-1:0] alu_sel_i,
                   output logic [iaddr_width-1:0]    branch_address_o,
		   output logic [reg_width-1:0]      alu_result_o,
                   input  logic branch_s_i,
                   input  logic jump_s_i,
                   output logic pc_src_o
                  );

  logic [iaddr_width-1:0] pc_branch_s;
  logic [reg_width-1:0]   alu_src_a_s;
  logic [reg_width-1:0]   alu_src_b_s;
  logic	zero_s;
  
  //--------------------------------------------
  // To branch or not to branch
  //--------------------------------------------
  assign pc_src_o = (zero_s & branch_s_i) | jump_s_i;
  
  //--------------------------------------------
  // Mux for jumps of jalr instruction or normal branches.
  //         - pc_o   : jalr
  //         - regA_s : normal branch
  //--------------------------------------------
  as_mux2 jalrmux(.d0_i(pc_i), // PC
                  .d1_i(reg_a_i),
                  .sel_i(jump_i),
                  .y_o(pc_branch_s)
                 );

  //--------------------------------------------
  // Adder for the branch targets
  //--------------------------------------------
  as_adder addbranch (.a_i(pc_branch_s),
                      .b_i(imm_i),
                      .sum_o(branch_address_o)
                     );

  //--------------------------------------------
  // ALU: input mux for regB or immediate
  //--------------------------------------------
  as_mux2 alumuxB (.d0_i(reg_b_i),
                   .d1_i(imm_i),
                   .sel_i(mux_alu_src_b_i),
                   .y_o(alu_src_b_s)
                  );

  //--------------------------------------------
  // ALU: input mux for regA or PC
  //--------------------------------------------
  as_mux2 alumuxA (.d0_i(reg_a_i),
                   .d1_i(pc_i), // PC
                   .sel_i(mux_alu_src_a_i),
                   .y_o(alu_src_a_s)
                  );

  //--------------------------------------------
  // ALU
  //--------------------------------------------
  as_alurv alu (.data01_i(alu_src_a_s),
                .data02_i(alu_src_b_s),
                .aluSel_i(alu_sel_i),
                .aluZero_o(zero_s),
                .aluNega_o(),
                .aluCarr_o(),
                .aluOver_o(),
                .aluResult_o(alu_result_o)
               );


endmodule : as_execute
