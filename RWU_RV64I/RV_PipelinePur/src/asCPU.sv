`timescale 1ns/1ps

import as_pack::*;

module as_cpu (input  logic                       clk_i,
               input  logic                       rst_i,
               // Scan Chain
               output logic                       sc01_tdo_o,   // scan: serial out
               input  logic                       sc01_tdi_i,   // scan: serial in
               input  logic                       sc01_shift_i, // scan: shift enable
               input  logic                       sc01_clock_i, // scan: clock enabe
               // Instruction bus
               input  logic [instr_width-1:0]     wbiBusDataRd_i, // data out from imem
               output logic [instr_width-1:0]     wbiBusDataWr_o, // data in to imem            -- not connected
               output logic [iaddr_width-1:0]     wbiBusAddr_o,   // address for imem
               output logic                       wbiBusWe_o,     // we for mem                 -- not needed
               output logic [7:0]                 wbiBusSel_o,    // sel for mem                -- not needed
               output logic                       wbiBusStb_o,    // stb for mem                -- not needed
               input  logic                       wbiBusAck_i,    // ack for mem                -- not used
               output logic                       wbiBusCyc_o,    // cyc for mem                -- not needed
               // Data bus
               input  logic [reg_width-1:0]       wbdBusDataRd_i, // data out from dmem
               output logic [reg_width-1:0]       wbdBusDataWr_o, // data in to dmem
               output logic [daddr_width-1:0]     wbdBusAddr_o,   // address for dmem
               output logic                       wbdBusWe_o,     // we for mem
               output logic [7:0]                 wbdBusSel_o,    // sel for mem
               output logic                       wbdBusStb_o,    // stb for mem
               input  logic                       wbdBusAck_i,    // ack for mem
               output logic                       wbdBusCyc_o,    // cyc for mem
               output logic                       dMemRd_o,       // read enable for dmem ---replace
               output logic                       dMemWr_o,       // write enable for dmem ---replace
               // instruction delayed
               output logic [instr_width-1:0]     instr_mem_o
              );


  // Umbau
  logic aluSrcA_s,aluSrcB_s,regWr_s,jump_s,zero_s,PCsrc_s;
  logic [dmuxsel_width-1:0]  resultSrc_s;
  //logic [immsrc_width-1:0]   immSrc_s;
  logic [aluselrv_width-1:0] aluSel_s;
  // Feedback signals - pipeline
  logic pc_src_execute_s;
  logic	reg_wr_decode_s;
  logic	reg_wr_execute_s;
  logic	reg_wr_mem_s;
  logic	reg_wr_writeback_s;
  logic [dmuxsel_width-1:0]  result_mux_src_decode_s;
  logic [dmuxsel_width-1:0]  result_mux_src_execute_s;
  logic [dmuxsel_width-1:0]  result_mux_src_mem_s;
  logic [dmuxsel_width-1:0]  result_mux_src_writeback_s;
  logic	reg_a_mux_src_decode_s;
  logic	reg_b_mux_src_decode_s;
  logic	reg_a_mux_src_execute_s;
  logic	reg_b_mux_src_execute_s;
  logic	jumpx_decode_s;
  logic	jumpx_execute_s;
  logic [aluselrv_width-1:0] alusel_decode_s;
  logic [aluselrv_width-1:0] alusel_execute_s;
  logic zero_execute_s;
  //logic zero_mem_s;
  

  // instruction
  logic [instr_width-1:0]     iBusDataRd_s; // data out from imem
  logic [iaddr_width-1:0]     iBusAddr_s;   // address for imem
  // instruction - pipeline
  logic [instr_width-1:0]     instr_fetch_s;     // instruction, fetch stage
  logic [instr_width-1:0]     instr_decode_s;    // instruction, decode stage
  logic [instr_width-1:0]     instr_execute_s;   // instruction, execute stage
  logic [instr_width-1:0]     instr_mem_s;       // instruction, mem stage
  logic [instr_width-1:0]     instr_writeback_s; // instruction, write-back stage
  

  // data
  logic [reg_width-1:0]       dBusDataRd_s; // data out from dmem
  logic [reg_width-1:0]       dBusDataWr_s; // data in to dmem
  logic [daddr_width-1:0]     dBusAddr_s;   // address for dmem
  logic                       dMemRd_s;     // read enable for dmem
  logic                       dMemWr_s;     // write enable for dmem
  // Data - pipeline
  logic dmem_rd_decode_s;
  logic dmem_wr_decode_s;
  logic dmem_rd_execute_s;
  logic dmem_wr_execute_s;
  logic dmem_rd_mem_s;
  logic dmem_wr_mem_s;
  logic dmem_wr_writeback_s;
  logic [daddr_width-1:0] alu_result_execute_s;
  logic [daddr_width-1:0] alu_result_mem_s;
  logic [daddr_width-1:0] alu_result_writeback_s;
  logic [reg_width-1:0]   dmem_data_rd_mem_s;
  logic [reg_width-1:0]   dmem_data_rd_writeback_s;
  logic [reg_width-1:0]   dmem_data_rd_writeback2_s;
  logic [reg_width-1:0]   dmem_data_rd_writeback3_s;

  // PC
  logic [iaddr_width-1:0] PCnext_s; // next PC
  logic [iaddr_width-1:0] PCbr_s;   // branch target; PCTarget
  logic	[iaddr_width-1:0] PCorRS1_s;
  // PC - pipeline
  logic [iaddr_width-1:0] pc_4_fetch_s;     // pc plus 4, fetch stage
  logic [iaddr_width-1:0] pc_4_decode_s;    // pc plus 4, decode stage
  logic [iaddr_width-1:0] pc_4_execute_s;   // pc plus 4, execute stage
  logic [iaddr_width-1:0] pc_4_mem_s;       // pc plus 4, mem stage
  logic [iaddr_width-1:0] pc_4_writeback_s; // pc plus 4, write-back stage
  logic [iaddr_width-1:0] pc_fetch_s;     // pc, fetch stage
  logic [iaddr_width-1:0] pc_decode_s;    // pc, decode stage
  logic [iaddr_width-1:0] pc_execute_s;   // pc, execute stage
  logic [iaddr_width-1:0] pc_calc_execute_s;  // pc calc, execute stage

  // Immediate extention
  logic [reg_width-1:0] immExt_s;
  // Immediate extention - pipeline
  logic [reg_width-1:0] imm_decode_s;
  logic [reg_width-1:0] imm_execute_s;
  
  // Register file
  logic [reg_width-1:0] srcA_s, regA_s;
  logic [reg_width-1:0] srcB_s;
  // Register file - pipeline
  logic [reg_width-1:0]	reg_a_decode_s;
  logic [reg_width-1:0]	reg_b_decode_s;
  logic [reg_width-1:0]	reg_a_execute_s;
  logic [reg_width-1:0]	reg_b_execute_s;
  logic [reg_width-1:0]	reg_b_mem_s;

  // D-Mem
  logic [reg_width-1:0] result_writeback_s;
  logic [reg_width-1:0] result_writeback_stall_s;
  logic [reg_width-1:0] write_data_s;
  
  // ALU
  logic                 nega_s,carry_s,overflow_s;

  logic	and_in01_s;
  logic	sc01_01_s;
  logic	sc01_02_s;
  logic	sc01_03_s;
  logic	and_in02_s;
  logic	and_out_s;
  logic	to_some_pin1_s;
  logic	to_some_pin2_s;

  // pipelining
  logic branch_decode_s;
  logic	jump_decode_s;
  logic branch_execute_s;
  logic	jump_execute_s;

  //--------------------------------------------
  // Decode
  //--------------------------------------------
  logic jump_xdecode_s;
  logic	branch_xdecode_s;
  logic [4:0] alusel_xdecode_s;
  logic jumpx_xdecode_s;
  logic	reg_wr_xdecode_s;
  logic	reg_a_mux_src_xdecode_s;
  logic	reg_b_mux_src_xdecode_s;
  logic	dmem_rd_xdecode_s;
  logic	dmem_wr_xdecode_s;
  logic	[1:0] result_mux_src_xdecode_s;
  
  //--------------------------------------------
  // Master BPI Instruction Bus
  //--------------------------------------------
  as_master_bpi #(1, 64, 32) mInstrBpi(
                                   .rst_i(rst_i),
                                   .clk_i(clk_i),
                                   .addr_i(iBusAddr_s),
                                   .dat_from_core_i('b0),         // not connected
                                   .dat_to_core_o(iBusDataRd_s),
                                   .wr_i(1'b0),
                                   .wb_m_addr_o(wbiBusAddr_o),
                                   .wb_m_dat_i(wbiBusDataRd_i),
                                   .wb_m_dat_o(wbiBusDataWr_o),  // not connected
                                   .wb_m_we_o(wbiBusWe_o),       // not needed
                                   .wb_m_sel_o(wbiBusSel_o),     // not needed
                                   .wb_m_stb_o(wbiBusStb_o),     // not needed
                                   .wb_m_ack_i(wbiBusAck_i),     // not used
                                   .wb_m_cyc_o(wbiBusCyc_o)      // not needed
                                  );

  //--------------------------------------------
  // Master BPI Data Bus
  //--------------------------------------------
  as_master_bpi #(2, 64, 64) mDataBpi(
                                   .rst_i(rst_i),
                                   .clk_i(clk_i),
                                   .addr_i(dBusAddr_s),
                                   .dat_from_core_i(dBusDataWr_s),
                                   .dat_to_core_o(dBusDataRd_s),
                                   .wr_i(dmem_wr_mem_s),
                                   .wb_m_addr_o(wbdBusAddr_o),
                                   .wb_m_dat_i(wbdBusDataRd_i),
                                   .wb_m_dat_o(wbdBusDataWr_o),
                                   .wb_m_we_o(wbdBusWe_o),
                                   .wb_m_sel_o(wbdBusSel_o),
                                   .wb_m_stb_o(wbdBusStb_o),
                                   .wb_m_ack_i(wbdBusAck_i),
                                   .wb_m_cyc_o(wbdBusCyc_o)
                                  );
  // D-Mem rd/wr
  assign dMemRd_o = dmem_wr_mem_s;
  assign dMemWr_o = dmem_rd_mem_s;

  //--------------------------------------------
  // Fetch stage
  //--------------------------------------------
  as_fetch fetchStage (.clk_i(clk_i),
                       .rst_i(rst_i),
		       .stall_n_i(1'b1),
                       .pc_src_i(pc_src_execute_s),   // from memStage, PCsrc_s -> pc_src_execute_s
                       .pc_calc_i(pc_calc_execute_s), // from memStage, PCbr_s -> pc_calc_execute_s
                       .pc_o(pc_fetch_s),         // to i-mem, to pipeline
                       .pc_4_o(pc_4_fetch_s)      // to pipeline
                      );
  // Instruction bus
  assign iBusAddr_s    = pc_fetch_s;   // address of I-bus
  assign instr_fetch_s = iBusDataRd_s; // data from I-bus, instruction
  
  // IF-ID Register
  always_ff @(posedge clk_i, posedge rst_i) 
  begin
    if(rst_i == 1)
    begin
      pc_4_decode_s  <= 0;
      pc_decode_s    <= 0;
      instr_decode_s <= 0;
    end
    else
    begin
      pc_4_decode_s  <= pc_4_fetch_s;
      pc_decode_s    <= pc_fetch_s;
      instr_decode_s <= instr_fetch_s;
    end
  end

  //--------------------------------------------
  // Decode stage
  //-------------------------------------------- 
  as_decodestage decodeStage (.clk_i(clk_i),
                              .rst_i(rst_i),
                              .instruction_i(instr_decode_s),             // from pipeline
                              .write_address_i(instr_mem_s[11:7]),        // from wbStage/mem stage because of reg-file clock
                              .write_data_i(result_writeback_s),          // from wbStage, result_writeback_s
                              .write_enable_i(reg_wr_mem_s),              // from wbStage/mem stage because of reg-file clock
                              .reg_a_o(reg_a_decode_s),                   // to pipeline
                              .reg_b_o(reg_b_decode_s),                   // to pipeline
                              .immediate_o(imm_decode_s),                 // to pipeline
                              .mux_result_src_o(result_mux_src_xdecode_s), // to pipeline
                              .d_mem_wr_o(dmem_wr_xdecode_s),              // to pipeline
                              .d_mem_rd_o(dmem_rd_xdecode_s),              // to pipeline
                              .mux_alu_src_a_o(reg_a_mux_src_xdecode_s),   // to pipeline
                              .mux_alu_src_b_o(reg_b_mux_src_xdecode_s),   // to pipeline
                              .reg_file_wr_o(reg_wr_xdecode_s),            // to pipeline
                              .jump_o(jumpx_xdecode_s),                    // to pipeline
                              .alu_sel_o(alusel_xdecode_s),                // to pipeline
                              .branch_s_o(branch_xdecode_s),               // to pipeline
                              .jump_s_o(jump_xdecode_s),                   // to pipeline
                              .zero_i(1'b0),                               // constant '0', needed in non-pipelined RISC-V
                              .pc_src_o()                                  // open, needed in non-pipelined RISC-V
		             );
  
  assign jump_decode_s           = jump_xdecode_s;
  assign branch_decode_s         = branch_xdecode_s;
  assign alusel_decode_s         = alusel_xdecode_s;
  assign jumpx_decode_s          = jumpx_xdecode_s;
  assign reg_wr_decode_s         = reg_wr_xdecode_s;
  assign reg_a_mux_src_decode_s  = reg_a_mux_src_xdecode_s;
  assign reg_b_mux_src_decode_s  = reg_b_mux_src_xdecode_s;
  assign dmem_rd_decode_s        = dmem_rd_xdecode_s;
  assign dmem_wr_decode_s        = dmem_wr_xdecode_s;
  assign result_mux_src_decode_s = result_mux_src_xdecode_s;

  //--------------------------------------------
  // ID-EX Register
  //--------------------------------------------
  always_ff @(posedge clk_i, posedge rst_i) 
  begin
    if(rst_i == 1)
    begin
      pc_4_execute_s           <= 0;
      pc_execute_s             <= 0;
      instr_execute_s          <= 0;
      reg_a_execute_s          <= 0;
      reg_b_execute_s          <= 0;
      imm_execute_s            <= 0;
      reg_wr_execute_s         <= 0;
      result_mux_src_execute_s <= 0;
      dmem_rd_execute_s        <= 0;
      dmem_wr_execute_s        <= 0;
      reg_a_mux_src_execute_s  <= 0;
      reg_b_mux_src_execute_s  <= 0;
      jumpx_execute_s          <= 0;
      alusel_execute_s         <= 0;
      branch_execute_s         <= 0;
      jump_execute_s           <= 0;
    end
    else
    begin
      pc_4_execute_s           <= pc_4_decode_s;
      pc_execute_s             <= pc_decode_s;
      instr_execute_s          <= instr_decode_s;
      reg_a_execute_s          <= reg_a_decode_s;
      reg_b_execute_s          <= reg_b_decode_s;
      imm_execute_s            <= imm_decode_s;
      reg_wr_execute_s         <= reg_wr_decode_s;
      result_mux_src_execute_s <= result_mux_src_decode_s;
      dmem_rd_execute_s        <= dmem_rd_decode_s;
      dmem_wr_execute_s        <= dmem_wr_decode_s;
      reg_a_mux_src_execute_s  <= reg_a_mux_src_decode_s;
      reg_b_mux_src_execute_s  <= reg_b_mux_src_decode_s;
      jumpx_execute_s          <= jumpx_decode_s;
      alusel_execute_s         <= alusel_decode_s;
      branch_execute_s         <= branch_decode_s;
      jump_execute_s           <= jump_decode_s;
    end
  end
  
  //--------------------------------------------
  // Execute stage
  //--------------------------------------------
  as_execute executeStage (.pc_i(pc_execute_s),                       // from pipeline
                           .reg_a_i(reg_a_execute_s),                 // from pipeline
                           .reg_b_i(reg_b_execute_s),                 // from pipeline
                           .imm_i(imm_execute_s),                     // from pipeline
			   .mux_alu_src_a_i(reg_a_mux_src_execute_s), // from pipeline
			   .mux_alu_src_b_i(reg_b_mux_src_execute_s), // from pipeline
			   .jump_i(jumpx_execute_s),                  // from pipeline
			   .alu_sel_i(alusel_execute_s),              // from pipeline
			   .branch_address_o(pc_calc_execute_s),      // to pipeline
			   .alu_result_o(alu_result_execute_s),       // to pipeline
			   .branch_s_i(branch_execute_s),
                           .jump_s_i(jump_execute_s),
                           .pc_src_o(pc_src_execute_s)                // to fetchStage
                          );
 
  //--------------------------------------------
  // EX-MEM Register
  //--------------------------------------------
  always_ff @(posedge clk_i, posedge rst_i) 
  begin
    if(rst_i == 1)
    begin
      pc_4_mem_s           <= 0;
      instr_mem_s          <= 0;
      reg_wr_mem_s         <= 0;
      result_mux_src_mem_s <= 0;
      dmem_rd_mem_s        <= 0;
      alu_result_mem_s     <= 0;
    end
    else
    begin
      pc_4_mem_s           <= pc_4_execute_s;
      instr_mem_s          <= instr_execute_s;
      reg_wr_mem_s         <= reg_wr_execute_s;
      result_mux_src_mem_s <= result_mux_src_execute_s;
      dmem_rd_mem_s        <= dmem_rd_execute_s;
      alu_result_mem_s     <= alu_result_execute_s; // e.g., d-mem address
    end
  end // always_ff @ (posedge clk_i, posedge rst_i)
  // In case of a store, the clock of the d-mem-write makes the pipeline delay
  assign reg_b_mem_s    = reg_b_execute_s;
  assign dmem_wr_mem_s  = dmem_wr_execute_s;

  //--------------------------------------------
  // Mem stage (D-Mem is outside asCPU.sv)
  //--------------------------------------------
  // Data Bus
  assign dBusDataWr_s       = reg_b_mem_s;       // write data for D-mem
  assign dmem_data_rd_mem_s = dBusDataRd_s;      // read data from D-mem
  // In case of a store, the clock of the d-mem-write makes the pipeline delay
  assign dBusAddr_s         = (instr_execute_s[6:0] == 35) ? alu_result_execute_s : alu_result_mem_s; // instr_mem_s[6:0]
  assign instr_mem_o        = (instr_execute_s[6:0] == 35) ? instr_execute_s : instr_mem_s;           // instruction for D-mem

  
  //--------------------------------------------
  // MEM-WB Register
  //--------------------------------------------
  always_ff @(posedge clk_i, posedge rst_i) 
  begin
    if(rst_i == 1)
    begin
      instr_writeback_s          <= 0;
      reg_wr_writeback_s         <= 0;
      //alu_result_writeback_s     <= 0;
      dmem_wr_writeback_s        <= 0;
    end
    else
    begin
      instr_writeback_s          <= instr_mem_s;
      reg_wr_writeback_s         <= reg_wr_mem_s;
      //alu_result_writeback_s     <= alu_result_mem_s; // may be not clocked??
      dmem_wr_writeback_s        <= dmem_wr_mem_s;
    end
  end // always_ff @ (posedge clk_i, posedge rst_i)
  // no clock needed here because the registerfile-writing is clocked
  assign pc_4_writeback_s           = pc_4_mem_s;
  assign result_mux_src_writeback_s = result_mux_src_mem_s;
  assign dmem_data_rd_writeback_s   = dmem_data_rd_mem_s;
  assign alu_result_writeback_s     = alu_result_mem_s; // may be not clocked??

  //--------------------------------------------
  // Write-Back stage
  //--------------------------------------------
  // MUX3
  as_writeback writeBackStage (.return_address_i(pc_4_writeback_s),           // d2_i;  from pipeline
                               .data_mem_i(dmem_data_rd_writeback_s),         // d1_i;  from pipeline
                               .alu_result_i(alu_result_writeback_s),         // d0_i;  from pipeline; alu_result_writeback_s
                               .mux_result_src_i(result_mux_src_writeback_s), // sel_i; from pipeline
                               .write_data_o(result_writeback_s)              // y_o;   to decodeStage
                              );

  //--------------------------------------------
  // Test Scan Chain
  //--------------------------------------------
  scan_cell sc01 (clk_i, rst_i, sc01_shift_i, 1'b0, sc01_tdi_i, and_in01_s, sc01_01_s);
  scan_cell sc02 (clk_i, rst_i, sc01_shift_i, 1'b0, sc01_01_s, and_in02_s, sc01_02_s);
  assign and_out_s = and_in01_s & and_in02_s;
  scan_cell sc03 (clk_i, rst_i, sc01_shift_i, and_out_s, sc01_02_s, to_some_pin1_s, sc01_03_s);
  scan_cell sc04 (clk_i, rst_i, sc01_shift_i, 1'b0, sc01_03_s, to_some_pin2_s, sc01_tdo_o);

endmodule : as_cpu
