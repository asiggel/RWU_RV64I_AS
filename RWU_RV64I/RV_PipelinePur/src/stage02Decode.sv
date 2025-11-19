`timescale 1ns/1ps

import as_pack::*;

module as_decodestage (input  logic clk_i,
                  input  logic rst_i,
                  input  logic [instr_width-1:0]    instruction_i,
                  input  logic [rwaddr_width-1:0]   write_address_i,
                  input  logic [reg_width-1:0]      write_data_i,
                  input  logic write_enable_i,
                  output logic [reg_width-1:0]      reg_a_o,
                  output logic [reg_width-1:0]      reg_b_o,
                  output logic [reg_width-1:0]      immediate_o,
                  output logic [dmuxsel_width-1:0]  mux_result_src_o,
                  output logic d_mem_wr_o,
                  output logic d_mem_rd_o,
                  output logic mux_alu_src_a_o,
                  output logic mux_alu_src_b_o,
                  output logic reg_file_wr_o,
                  output logic jump_o,
                  output logic [aluselrv_width-1:0] alu_sel_o,
                  output logic branch_s_o,
                  output logic jump_s_o,
                  // needed in no-pipeline, not needed in pipeline
                  input  logic zero_i,  // pipeline: set to constant 0
                  output logic pc_src_o // pipeline: open
                 );

  logic [immsrc_width-1:0] imm_src_s;
  
  
  //--------------------------------------------
  // Register file
  //--------------------------------------------
  as_regfile regfile (.clk_i(clk_i),
                      .rst_i(rst_i),
                      .we_i(write_enable_i),
                      .raddr01_i(instruction_i[19:15]),
                      .raddr02_i(instruction_i[24:20]),
                      .waddr01_i(write_address_i),
                      .wdata01_i(write_data_i),
                      .rdata01_o(reg_a_o),
                      .rdata02_o(reg_b_o)
                     );

  //--------------------------------------------
  // Immediate generation
  //--------------------------------------------
  as_immgen extend (.instr_i(instruction_i[instr_width-1:7]),
                    .sel_i(imm_src_s),
                    .imm_o(immediate_o)
                   );

  //--------------------------------------------
  // Instruction decoder
  //--------------------------------------------
  as_controlall control (.opcode_i(instruction_i[6:0]),
                      .func3_i(instruction_i[14:12]),
                      .func7b5_i(instruction_i[30]),
                      .zero_i(zero_i),
                      .resultSrc_o(mux_result_src_o),
                      .dMemWr_o(d_mem_wr_o),
                      .dMemRd_o(d_mem_rd_o),
                      .PCSrc_o(pc_src_o),
                      .aluSrcB_o(mux_alu_src_b_o),
                      .aluSrcA_o(mux_alu_src_a_o),
                      .regWr_o(reg_file_wr_o),
                      .jump_o(jump_o),
                      .immSrc_o(imm_src_s),
                      .aluSel_o(alu_sel_o),
		      .branch_s_o(branch_s_o),
		      .jump_s_o(jump_s_o)
                      );
  
endmodule : as_decodestage
